package com.hulypay.backend.payments.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreatePaymentRequest {

    private UUID expenseId;

    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be greater than zero")
    private BigDecimal amount;

    @Builder.Default
    @Size(min = 3, max = 3, message = "Currency must be a 3-letter ISO code")
    private String currency = "INR";

    @Size(max = 100, message = "UPI transaction ID must not exceed 100 characters")
    private String upiTransactionId;

    @Size(max = 100, message = "UPI ID must not exceed 100 characters")
    private String upiId;

    @Size(max = 255, message = "Merchant name must not exceed 255 characters")
    private String merchantName;

    @Size(max = 50, message = "Payment method must not exceed 50 characters")
    private String paymentMethod;

    @Size(max = 100, message = "Transaction reference must not exceed 100 characters")
    private String transactionReference;

    @Size(max = 50, message = "Provider must not exceed 50 characters")
    private String provider;

    private Double latitude;

    private Double longitude;

    private Double locationAccuracyMeters;

    private LocalDate paymentDate;

    private LocalTime paymentTime;
}
