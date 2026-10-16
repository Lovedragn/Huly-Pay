package com.hulypay.backend.Models;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TransactionStatusEnum {
    CONFIRMED((short) 1, "CONFIRMED"),
    PENDING((short) 2, "PENDING");

    private final short code;
    private final String name;

    public static TransactionStatusEnum fromCode(Short code) {
        if (code == null) {
            return CONFIRMED;
        }
        for (TransactionStatusEnum status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return CONFIRMED;
    }

    public static TransactionStatusEnum fromName(String name) {
        if (name == null || name.isBlank()) {
            return CONFIRMED;
        }
        String clean = name.trim().toUpperCase();
        for (TransactionStatusEnum status : values()) {
            if (status.name.equalsIgnoreCase(clean)) {
                return status;
            }
        }
        if (clean.contains("FAIL") || clean.contains("DECLINE") || clean.contains("CANCEL") || clean.contains("PEND") || clean.contains("INIT") || clean.contains("TIME") || clean.contains("SUBMIT")) {
            return PENDING;
        }
        return CONFIRMED;
    }

    public static String toName(Short code) {
        return fromCode(code).getName();
    }

    public static short toCode(String name) {
        return fromName(name).getCode();
    }
}
