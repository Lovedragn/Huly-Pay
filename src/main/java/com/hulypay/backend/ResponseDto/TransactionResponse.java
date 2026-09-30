package com.hulypay.backend.ResponseDto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.hulypay.backend.Models.Transaction;
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
public class TransactionResponse {

    private UUID id;
    private UUID userId;
    private BigDecimal amount;
    private String currency;
    private String merchantName;
    private String category;
    private String description;
    private String paymentMethod;
    private String provider;
    private String status;
    private String upiTransactionId;
    private String transactionReference;
    private String upiId;
    private Double latitude;
    private Double longitude;
    private Double locationAccuracyMeters;
    private Instant transactionTime;
    private Instant createdAt;
    private Instant updatedAt;

    // Backward compatibility property for clients expecting paymentStatus
    @JsonProperty("paymentStatus")
    public String getPaymentStatus() {
        return status;
    }

    public static TransactionResponse fromEntity(Transaction transaction) {
        if (transaction == null) {
            return null;
        }
        return TransactionResponse.builder()
                .id(transaction.getId())
                .userId(transaction.getUser() != null ? transaction.getUser().getId() : null)
                .amount(transaction.getAmount())
                .currency(transaction.getCurrency())
                .merchantName(transaction.getMerchantName())
                .category(transaction.getCategory())
                .description(transaction.getDescription())
                .paymentMethod(transaction.getPaymentMethod())
                .provider(transaction.getProvider())
                .status(transaction.getStatus())
                .upiTransactionId(transaction.getUpiTransactionId())
                .transactionReference(transaction.getTransactionReference())
                .upiId(transaction.getUpiId())
                .latitude(transaction.getLatitude())
                .longitude(transaction.getLongitude())
                .locationAccuracyMeters(transaction.getLocationAccuracyMeters())
                .transactionTime(transaction.getTransactionTime())
                .createdAt(transaction.getCreatedAt())
                .updatedAt(transaction.getUpdatedAt())
                .build();
    }
}





