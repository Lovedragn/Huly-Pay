package com.hulypay.backend.expenses.dto;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
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
public class UpdateExpenseRequest {

    @Positive(message = "Amount must be greater than zero")
    private BigDecimal amount;

    @Size(min = 3, max = 3, message = "Currency must be a 3-letter ISO code")
    private String currency;

    @Size(max = 255, message = "Merchant name must not exceed 255 characters")
    private String merchantName;

    private UUID categoryId;

    @Size(max = 1000, message = "Description must not exceed 1000 characters")
    private String description;

    private Instant transactionTime;

    @Size(max = 50, message = "Payment method must not exceed 50 characters")
    private String paymentMethod;

    @Size(max = 100, message = "UPI transaction ID must not exceed 100 characters")
    private String upiTransactionId;

    private String status;

    private Double latitude;

    private Double longitude;
}
