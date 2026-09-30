package com.hulypay.backend.Security;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Cipher;
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
 * Server-side Encryption Service using AES-256-GCM.
 *
 * Architecture:
 * - Master Key: Provided securely via environment variable HULYPAY_MASTER_KEY (or app.security.master-key property).
 *   Derives a 256-bit AES key deterministically using SHA-256.
 * - Nonce / IV: A new random 12-byte initialization vector generated for every encryption.
 * - Ciphertext format: Base64-encoded [12-byte IV] + [AES-256-GCM ciphertext + 128-bit auth tag].
 * - The master key is strictly kept server-side and never exposed to Flutter, database, or API responses.
 */
@Slf4j
@Service
public class EncryptionService {

    private static final String AES_ALGO = "AES";
    private static final String AES_GCM_NO_PADDING = "AES/GCM/NoPadding";
    private static final int GCM_IV_LENGTH = 12; // 96-bit nonce recommended for GCM
    private static final int GCM_TAG_LENGTH = 128; // in bits

    private final SecretKey masterKey;
    private final SecureRandom secureRandom = new SecureRandom();

    public EncryptionService(
            @Value("${app.security.master-key:${HULYPAY_MASTER_KEY:12345678790sujith}}") String masterKeyProperty
    ) {
        this.masterKey = deriveMasterKey(masterKeyProperty);
    }

    /**
     * Derives a deterministic 256-bit AES Key from the master key string using SHA-256.
     */
    private SecretKey deriveMasterKey(String masterKeyString) {
        if (masterKeyString == null || masterKeyString.trim().isEmpty()) {
            log.warn("No master key provided in environment (HULYPAY_MASTER_KEY). Using fallback dummy key.");
            masterKeyString = "12345678790sujith";
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
     * Encrypts plaintext using AES-256-GCM with a new random nonce/IV for each operation.
     * The 12-byte nonce is prepended to the ciphertext before Base64 encoding.
     *
     * @param value the raw string to encrypt
     * @return Base64-encoded [IV + ciphertext + GCM auth tag]
     */
    public String encrypt(String value) {
        if (value == null) {
            return null;
        }
        if (value.isEmpty()) {
            return "";
        }

        try {
            byte[] iv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(iv);

            Cipher cipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            cipher.init(Cipher.ENCRYPT_MODE, masterKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] ciphertext = cipher.doFinal(value.getBytes(StandardCharsets.UTF_8));

            ByteBuffer buffer = ByteBuffer.allocate(iv.length + ciphertext.length);
            buffer.put(iv);
            buffer.put(ciphertext);

            return Base64.getEncoder().encodeToString(buffer.array());
        } catch (Exception e) {
            log.error("AES-256-GCM encryption failed: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to encrypt data", e);
        }
    }

    /**
     * Decrypts AES-256-GCM encrypted string with prepended 12-byte nonce/IV.
     * If the payload is null, empty, or unencrypted legacy plaintext, it returns the input safely.
     *
     * @param encryptedValue Base64-encoded [IV + ciphertext + GCM auth tag]
     * @return decrypted plaintext string
     */
    public String decrypt(String encryptedValue) {
        if (encryptedValue == null || encryptedValue.isBlank()) {
            return encryptedValue;
        }

        try {
            byte[] decoded = Base64.getDecoder().decode(encryptedValue.trim());
            // Must contain at least 12-byte IV + 16-byte GCM authentication tag
            if (decoded.length < GCM_IV_LENGTH + (GCM_TAG_LENGTH / 8)) {
                return encryptedValue;
            }

            ByteBuffer buffer = ByteBuffer.wrap(decoded);
            byte[] iv = new byte[GCM_IV_LENGTH];
            buffer.get(iv);

            byte[] ciphertext = new byte[buffer.remaining()];
            buffer.get(ciphertext);

            Cipher cipher = Cipher.getInstance(AES_GCM_NO_PADDING);
            cipher.init(Cipher.DECRYPT_MODE, masterKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] decrypted = cipher.doFinal(ciphertext);

            return new String(decrypted, StandardCharsets.UTF_8);
        } catch (Exception e) {
            // If decryption fails (e.g. legacy unencrypted row in database), return original raw text gracefully
            log.debug("Could not decrypt payload as AES-256-GCM; treating as raw plaintext: {}", e.getMessage());
            return encryptedValue;
        }
    }
}
