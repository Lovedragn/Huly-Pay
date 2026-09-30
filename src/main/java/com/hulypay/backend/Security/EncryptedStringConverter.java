package com.hulypay.backend.Security;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * JPA AttributeConverter that automatically encrypts entity fields with
 * Envelope Encryption on database INSERT/UPDATE and decrypts on SELECT.
 */
@Component
@Converter
public class EncryptedStringConverter implements AttributeConverter<String, String> {

    private static EncryptionService encryptionService;

    @Autowired
    public void setEncryptionService(EncryptionService service) {
        EncryptedStringConverter.encryptionService = service;
    }

    @Override
    public String convertToDatabaseColumn(String attribute) {
        if (attribute == null) {
            return null;
        }
        if (encryptionService == null) {
            return attribute;
        }
        return encryptionService.encrypt(attribute);
    }

    @Override
    public String convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        if (encryptionService == null) {
            return dbData;
        }
        return encryptionService.decrypt(dbData);
    }
}
