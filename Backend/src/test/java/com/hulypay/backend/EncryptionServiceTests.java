package com.hulypay.backend;

import com.hulypay.backend.Security.EncryptionService;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EncryptionServiceTests {

    private final EncryptionService encryptionService =
            new EncryptionService("12345678790sujith");

    @Test
    void testEncryptionAndDecryptionRoundtrip() {
        String original = "9876543210";
        String encrypted = encryptionService.encrypt(original);

        assertNotNull(encrypted);
        assertNotEquals(original, encrypted);

        String decrypted = encryptionService.decrypt(encrypted);
        assertEquals(original, decrypted);
    }

    @Test
    void testSensitiveFieldsRoundtrip() {
        String phone = "+919876543210";
        String upiId = "john.doe@okaxis";
        String txnRef = "TXN_REF_2026_987654321";

        assertEquals(phone, encryptionService.decrypt(encryptionService.encrypt(phone)));
        assertEquals(upiId, encryptionService.decrypt(encryptionService.encrypt(upiId)));
        assertEquals(txnRef, encryptionService.decrypt(encryptionService.encrypt(txnRef)));
    }

    @Test
    void testRandomNonceProducesDifferentCiphertextForSamePlaintext() {
        String original = "user@upi";
        String encrypted1 = encryptionService.encrypt(original);
        String encrypted2 = encryptionService.encrypt(original);

        // A new random nonce/IV is generated for each encryption operation
        assertNotEquals(encrypted1, encrypted2);

        // Both decrypt back to identical plaintext
        assertEquals(original, encryptionService.decrypt(encrypted1));
        assertEquals(original, encryptionService.decrypt(encrypted2));
    }

    @Test
    void testNullAndEmptyHandling() {
        assertNull(encryptionService.encrypt(null));
        assertNull(encryptionService.decrypt(null));
        assertEquals("", encryptionService.encrypt(""));
        assertEquals("", encryptionService.decrypt(""));
    }

    @Test
    void testLegacyPlaintextGracefulFallback() {
        String legacyPlaintext = "Legacy Raw Plaintext Value";
        String result = encryptionService.decrypt(legacyPlaintext);
        assertEquals(legacyPlaintext, result);
    }
}
