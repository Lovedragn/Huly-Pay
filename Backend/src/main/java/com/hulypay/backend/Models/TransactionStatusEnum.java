package com.hulypay.backend.Models;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum TransactionStatusEnum {
    SUCCESS((short) 1, "SUCCESS"),
    PENDING((short) 2, "PENDING"),
    FAILED((short) 3, "FAILED"),
    CANCELLED((short) 4, "CANCELLED"),
    TIMEOUT((short) 5, "TIMEOUT"),
    CONFIRMED((short) 6, "CONFIRMED"),
    SUBMITTED((short) 7, "SUBMITTED"),
    INITIATED((short) 8, "INITIATED");

    private final short code;
    private final String name;

    public static TransactionStatusEnum fromCode(Short code) {
        if (code == null) {
            return SUCCESS;
        }
        for (TransactionStatusEnum status : values()) {
            if (status.code == code) {
                return status;
            }
        }
        return SUCCESS;
    }

    public static TransactionStatusEnum fromName(String name) {
        if (name == null || name.isBlank()) {
            return SUCCESS;
        }
        String clean = name.trim().toUpperCase();
        for (TransactionStatusEnum status : values()) {
            if (status.name.equalsIgnoreCase(clean)) {
                return status;
            }
        }
        if (clean.contains("FAIL") || clean.contains("DECLINE")) return FAILED;
        if (clean.contains("PEND")) return PENDING;
        if (clean.contains("CONFIRM")) return CONFIRMED;
        if (clean.contains("SUBMIT")) return SUBMITTED;
        if (clean.contains("INIT")) return INITIATED;
        if (clean.contains("CANCEL")) return CANCELLED;
        if (clean.contains("TIME")) return TIMEOUT;
        return SUCCESS;
    }

    public static String toName(Short code) {
        return fromCode(code).getName();
    }

    public static short toCode(String name) {
        return fromName(name).getCode();
    }
}
