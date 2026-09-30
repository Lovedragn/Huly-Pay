package com.hulypay.backend;

import com.hulypay.backend.Security.EnvelopeEncryptionService;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class EnvelopeEncryptionServiceTests {

    private final EnvelopeEncryptionService encryptionService =
            new EnvelopeEncryptionService("test-secret-master-key-32-chars-long!");

    @Test
    void testEnvelopeEncryptionAndDecryptionRoundtrip() {
        String original = "upi_user@okaxis_9876543210";
        String encrypted = encryptionService.encrypt(original);

        assertNotNull(encrypted);
        assertNotEquals(original, encrypted);

        String decrypted = encryptionService.decrypt(encrypted);
        assertEquals(original, decrypted);
    }

    @Test
    void testFrequentChangingDekPerEncryption() {
        String original = "Same Merchant Name";
        String encrypted1 = encryptionService.encrypt(original);
        String encrypted2 = encryptionService.encrypt(original);

        // Even with the identical plaintext and same master key,
        // each encryption generates a fresh, unique random DEK + IV
        assertNotEquals(encrypted1, encrypted2);

        // Both decrypt back to the identical plaintext
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
