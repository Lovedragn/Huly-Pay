package com.hulypay.backend.RequestDto;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateTransactionRequest {

    @Positive(message = "Amount must be greater than zero")
    private BigDecimal amount;

    @Size(min = 1, max = 10, message = "Currency must be a valid code or symbol")
    private String currency;

    @Size(max = 255, message = "Merchant name must not exceed 255 characters")
    private String merchantName;

    @Size(max = 100, message = "Category must not exceed 100 characters")
    private String category;

    @Size(max = 500, message = "Description must not exceed 500 characters")
    private String description;

    @Size(max = 100, message = "Payment method must not exceed 100 characters")
    private String paymentMethod;

    @Size(max = 100, message = "Provider must not exceed 100 characters")
    private String provider;

    @Size(max = 30, message = "Status must not exceed 30 characters")
    private String status;

    @Size(max = 255, message = "UPI transaction ID must not exceed 255 characters")
    private String upiTransactionId;

    @Size(max = 255, message = "Transaction reference must not exceed 255 characters")
    private String transactionReference;

    @Size(max = 255, message = "UPI ID must not exceed 255 characters")
    private String upiId;

    private Double latitude;

    private Double longitude;

    private Double locationAccuracyMeters;

    private Instant transactionTime;
}




