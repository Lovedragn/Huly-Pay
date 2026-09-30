package com.hulypay.backend.Security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Envelope Encryption Service using AES-256-GCM.
 *
 * Architecture:
 * - KEK (Key Encryption Key / Master Key): Provided securely via environment variable / .env (HULYPAY_MASTER_KEY or app.security.master-key).
 * - DEK (Data Encryption Key): A random 256-bit AES key generated per encryption operation.
 * - Envelope Output: Base64-encoded binary payload containing:
 *     [1-byte version: 0x01]
 *     [12-byte KEK IV]
 *     [2-byte encrypted DEK length]
 *     [encrypted DEK (wrapped with KEK)]
 *     [12-byte DEK IV]
 *     [ciphertext (data encrypted with DEK)]
 */
@Slf4j
@Service
public class EnvelopeEncryptionService {

    private static final byte ENVELOPE_VERSION = 0x01;
    private static final String AES_ALGO = "AES";
    private static final String AES_GCM_NO_PADDING = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12;
    private static final int GCM_TAG_LENGTH = 128; // in bits

    private final SecretKey masterKey;
    private final SecureRandom secureRandom = new SecureRandom();

    public EnvelopeEncryptionService(
            @Value("${app.security.master-key:${HULYPAY_MASTER_KEY:}}") String masterKeyProperty
    ) {
        this.masterKey = deriveMasterKey(masterKeyProperty);
    }

    /**
     * Derives a deterministic 256-bit AES Key from the master key string using SHA-256.
     */
    private SecretKey deriveMasterKey(String masterKeyString) {
        if (masterKeyString == null || masterKeyString.trim().isEmpty()) {
            log.warn("No master key provided in environment (HULYPAY_MASTER_KEY). Using secure embedded fallback for local development.");
            masterKeyString = "HulyPay-Default-Dev-MasterKey-2026-Secure-Salt";
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] keyBytes = digest.digest(masterKeyString.trim().getBytes(StandardCharsets.UTF_8));
            return new SecretKeySpec(keyBytes, AES_ALGO);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 algorithm missing from JVM", e);
        }
    }

    /**
     * Generates a new 256-bit Data Encryption Key (DEK).
     */
    public SecretKey generateDek() {
        try {
            KeyGenerator keyGen = KeyGenerator.getInstance(AES_ALGO);
            keyGen.init(256, secureRandom);
            return keyGen.generateKey();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("AES key generator unavailable", e);
        }
    }

    /**
     * Encrypts plaintext using Envelope Encryption.
     * Returns null if plaintext is null.
     */
    public String encrypt(String plaintext) {
        if (plaintext == null) {
            return null;
        }
        if (plaintext.isEmpty()) {
            return "";
        }

        try {
            // 1. Generate a unique DEK for this data
            SecretKey dek = generateDek();

            // 2. Encrypt DEK using KEK (Master Key)
            byte[] kekIv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(kekIv);
            Cipher kekCipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            kekCipher.init(Cipher.ENCRYPT_MODE, masterKey, new GCMParameterSpec(GCM_TAG_LENGTH, kekIv));
            byte[] encryptedDek = kekCipher.doFinal(dek.getEncoded());

            // 3. Encrypt data using DEK
            byte[] dekIv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(dekIv);
            Cipher dataCipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            dataCipher.init(Cipher.ENCRYPT_MODE, dek, new GCMParameterSpec(GCM_TAG_LENGTH, dekIv));
            byte[] ciphertext = dataCipher.doFinal(plaintext.getBytes(StandardCharsets.UTF_8));

            // 4. Pack into compact envelope byte array:
            // [1 byte version] + [12 bytes kekIv] + [2 bytes dekLength] + [encryptedDek] + [12 bytes dekIv] + [ciphertext]
            ByteBuffer buffer = ByteBuffer.allocate(1 + GCM_IV_LENGTH + 2 + encryptedDek.length + GCM_IV_LENGTH + ciphertext.length);
            buffer.put(ENVELOPE_VERSION);
            buffer.put(kekIv);
            buffer.putShort((short) encryptedDek.length);
            buffer.put(encryptedDek);
            buffer.put(dekIv);
            buffer.put(ciphertext);

            return Base64.getEncoder().encodeToString(buffer.array());
        } catch (Exception e) {
            log.error("Envelope encryption failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to encrypt data with envelope encryption", e);
        }
    }

    /**
     * Decrypts an envelope-encrypted ciphertext.
     * If the input is not in envelope format (or already plaintext), it returns the input safely.
     */
    public String decrypt(String envelopeBase64) {
        if (envelopeBase64 == null || envelopeBase64.isBlank()) {
            return envelopeBase64;
        }

        try {
            byte[] envelopeBytes = Base64.getDecoder().decode(envelopeBase64.trim());
            if (envelopeBytes.length < 1 + GCM_IV_LENGTH + 2 + GCM_IV_LENGTH) {
                // Not envelope encrypted (e.g. legacy plain text)
                return envelopeBase64;
            }

            ByteBuffer buffer = ByteBuffer.wrap(envelopeBytes);
            byte version = buffer.get();
            if (version != ENVELOPE_VERSION) {
                // Not our envelope version, return as plaintext fallback
                return envelopeBase64;
            }

            byte[] kekIv = new byte[GCM_IV_LENGTH];
            buffer.get(kekIv);

            short dekLength = buffer.getShort();
            if (dekLength <= 0 || dekLength > buffer.remaining()) {
                return envelopeBase64;
            }

            byte[] encryptedDek = new byte[dekLength];
            buffer.get(encryptedDek);

            byte[] dekIv = new byte[GCM_IV_LENGTH];
            buffer.get(dekIv);

            byte[] ciphertext = new byte[buffer.remaining()];
            buffer.get(ciphertext);

            // 1. Decrypt DEK with KEK
            Cipher kekCipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            kekCipher.init(Cipher.DECRYPT_MODE, masterKey, new GCMParameterSpec(GCM_TAG_LENGTH, kekIv));
            byte[] rawDek = kekCipher.doFinal(encryptedDek);
            SecretKeySpec dek = new SecretKeySpec(rawDek, AES_ALGO);

            // 2. Decrypt data with DEK
            Cipher dataCipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            dataCipher.init(Cipher.DECRYPT_MODE, dek, new GCMParameterSpec(GCM_TAG_LENGTH, dekIv));
            byte[] plaintextBytes = dataCipher.doFinal(ciphertext);

            return new String(plaintextBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            // If decryption fails (e.g. legacy unencrypted row in database), log debug and return raw text
            log.debug("Could not decrypt payload as envelope; treating as raw plaintext: {}", e.getMessage());
            return envelopeBase64;
        }
    }
}
