package com.hulypay.backend.payments;

public enum PaymentStatus {
    INITIATED,
    PAYMENT_INITIATED,
    PENDING,
    CONFIRMED,
    SUCCESS,
    FAILED,
    CANCELLED,
    TIMEOUT,
    VERIFYING_SMS,
    UNKNOWN
}
