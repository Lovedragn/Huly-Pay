package com.hulypay.backend.analytics;

import com.hulypay.backend.analytics.dto.CategoryBreakdownResponse;
import com.hulypay.backend.analytics.dto.DailySpendingResponse;
import com.hulypay.backend.analytics.dto.MonthlySpendingResponse;
import com.hulypay.backend.analytics.dto.SpendingSummaryResponse;
import com.hulypay.backend.expenses.ExpenseRepository;
import com.hulypay.backend.users.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final ExpenseRepository expenseRepository;

    @Transactional(readOnly = true)
    public SpendingSummaryResponse getSpendingSummary(User user) {
        List<Object[]> results = expenseRepository.getSpendingSummary(user.getId());
        if (results == null || results.isEmpty()) {
            return SpendingSummaryResponse.builder()
                    .totalSpent(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP))
                    .transactionCount(0)
                    .averageTransaction(BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP))
                    .build();
        }

        Object[] row = results.get(0);
        BigDecimal totalSpent = row[0] != null ? new BigDecimal(row[0].toString()).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        long count = row[1] != null ? ((Number) row[1]).longValue() : 0L;
        BigDecimal avgSpent = row[2] != null ? new BigDecimal(row[2].toString()).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);

        return SpendingSummaryResponse.builder()
                .totalSpent(totalSpent)
                .transactionCount(count)
                .averageTransaction(avgSpent)
                .build();
    }

    @Transactional(readOnly = true)
    public List<CategoryBreakdownResponse> getCategoryBreakdown(User user) {
        List<Object[]> results = expenseRepository.getCategoryBreakdown(user.getId());
        if (results == null || results.isEmpty()) {
            return List.of();
        }

        BigDecimal totalSum = BigDecimal.ZERO;
        for (Object[] row : results) {
            if (row[1] != null) {
                totalSum = totalSum.add(new BigDecimal(row[1].toString()));
            }
        }

        List<CategoryBreakdownResponse> breakdown = new ArrayList<>();
        for (Object[] row : results) {
            String category = row[0] != null ? row[0].toString() : "Uncategorized";
            BigDecimal totalAmount = row[1] != null ? new BigDecimal(row[1].toString()).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            long count = row[2] != null ? ((Number) row[2]).longValue() : 0L;
            double percentage = 0.0;
            if (totalSum.compareTo(BigDecimal.ZERO) > 0) {
                percentage = totalAmount.divide(totalSum, 4, RoundingMode.HALF_UP).doubleValue() * 100.0;
                percentage = Math.round(percentage * 100.0) / 100.0;
            }

            breakdown.add(CategoryBreakdownResponse.builder()
                    .category(category)
                    .totalAmount(totalAmount)
                    .count(count)
                    .percentage(percentage)
                    .build());
        }

        return breakdown;
    }

    @Transactional(readOnly = true)
    public List<DailySpendingResponse> getDailySpending(User user) {
        List<Object[]> results = expenseRepository.getDailySpending(user.getId());
        if (results == null || results.isEmpty()) {
            return List.of();
        }

        List<DailySpendingResponse> responses = new ArrayList<>();
        for (Object[] row : results) {
            String date = row[0] != null ? row[0].toString() : "";
            BigDecimal totalAmount = row[1] != null ? new BigDecimal(row[1].toString()).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            long count = row[2] != null ? ((Number) row[2]).longValue() : 0L;

            responses.add(DailySpendingResponse.builder()
                    .date(date)
                    .totalAmount(totalAmount)
                    .count(count)
                    .build());
        }

        return responses;
    }

    @Transactional(readOnly = true)
    public List<MonthlySpendingResponse> getMonthlySpending(User user) {
        List<Object[]> results = expenseRepository.getMonthlySpending(user.getId());
        if (results == null || results.isEmpty()) {
            return List.of();
        }

        List<MonthlySpendingResponse> responses = new ArrayList<>();
        for (Object[] row : results) {
            String month = row[0] != null ? row[0].toString() : "";
            BigDecimal totalAmount = row[1] != null ? new BigDecimal(row[1].toString()).setScale(2, RoundingMode.HALF_UP) : BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
            long count = row[2] != null ? ((Number) row[2]).longValue() : 0L;

            responses.add(MonthlySpendingResponse.builder()
                    .month(month)
                    .totalAmount(totalAmount)
                    .count(count)
                    .build());
        }

        return responses;
    }
}
