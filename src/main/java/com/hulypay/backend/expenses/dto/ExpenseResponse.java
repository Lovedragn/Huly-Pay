package com.hulypay.backend.expenses.dto;

import com.hulypay.backend.categories.dto.CategoryResponse;
import com.hulypay.backend.expenses.Expense;
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
public class ExpenseResponse {

    private UUID id;
    private UUID userId;
    private BigDecimal amount;
    private String currency;
    private String merchantName;
    private CategoryResponse category;
    private String description;
    private Instant transactionTime;
    private String paymentMethod;
    private String upiTransactionId;
    private String status;
    private Double latitude;
    private Double longitude;
    private Instant createdAt;
    private Instant updatedAt;

    public static ExpenseResponse fromEntity(Expense expense) {
        if (expense == null) {
            return null;
        }
        return ExpenseResponse.builder()
                .id(expense.getId())
                .userId(expense.getUser() != null ? expense.getUser().getId() : null)
                .amount(expense.getAmount())
                .currency(expense.getCurrency())
                .merchantName(expense.getMerchantName())
                .category(CategoryResponse.fromEntity(expense.getCategory()))
                .description(expense.getDescription())
                .transactionTime(expense.getTransactionTime())
                .paymentMethod(expense.getPaymentMethod())
                .upiTransactionId(expense.getUpiTransactionId())
                .status(expense.getStatus())
                .latitude(expense.getLatitude())
                .longitude(expense.getLongitude())
                .createdAt(expense.getCreatedAt())
                .updatedAt(expense.getUpdatedAt())
                .build();
    }
}
