package com.hulypay.backend.payments.dto;

import com.hulypay.backend.payments.Payment;
import com.hulypay.backend.payments.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentResponse {

    private UUID id;
    private UUID userId;
    private UUID expenseId;
    private BigDecimal amount;
    private String currency;
    private String upiTransactionId;
    private String merchantName;
    private PaymentStatus status;
    private String provider;
    private Instant createdAt;
    private Instant updatedAt;

    public static PaymentResponse fromEntity(Payment payment) {
        if (payment == null) {
            return null;
        }
        return PaymentResponse.builder()
                .id(payment.getId())
                .userId(payment.getUser() != null ? payment.getUser().getId() : null)
                .expenseId(payment.getExpense() != null ? payment.getExpense().getId() : null)
                .amount(payment.getAmount())
                .currency(payment.getCurrency())
                .upiTransactionId(payment.getUpiTransactionId())
                .merchantName(payment.getMerchantName())
                .status(payment.getStatus())
                .provider(payment.getProvider())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }
}
