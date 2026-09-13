package com.hulypay.backend.payments.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.hulypay.backend.payments.Payment;
import com.hulypay.backend.payments.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
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
    private String upiId;
    private String merchantName;
    private String paymentMethod;
    private String transactionReference;
    private PaymentStatus status;
    private String provider;
    private Double latitude;
    private Double longitude;
    private Double locationAccuracyMeters;
    private LocalDate paymentDate;
    private LocalTime paymentTime;
    private Instant createdAt;
    private Instant updatedAt;

    @JsonProperty("paymentStatus")
    public PaymentStatus getPaymentStatus() {
        return status;
    }

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
                .upiId(payment.getUpiId())
                .merchantName(payment.getMerchantName())
                .paymentMethod(payment.getPaymentMethod())
                .transactionReference(payment.getTransactionReference())
                .status(payment.getStatus())
                .provider(payment.getProvider())
                .latitude(payment.getLatitude())
                .longitude(payment.getLongitude())
                .locationAccuracyMeters(payment.getLocationAccuracyMeters())
                .paymentDate(payment.getPaymentDate())
                .paymentTime(payment.getPaymentTime())
                .createdAt(payment.getCreatedAt())
                .updatedAt(payment.getUpdatedAt())
                .build();
    }
}
