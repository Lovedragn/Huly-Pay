package com.hulypay.backend.analytics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SpendingSummaryResponse {

    private BigDecimal totalSpent;
    private long transactionCount;
    private BigDecimal averageTransaction;
}
