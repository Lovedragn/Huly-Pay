package com.hulypay.backend.expenses;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ExpenseRepository extends JpaRepository<Expense, UUID> {

    List<Expense> findByUserIdOrderByTransactionTimeDesc(UUID userId);

    Optional<Expense> findByIdAndUserId(UUID id, UUID userId);

    @Query("SELECT COALESCE(SUM(e.amount), 0), COUNT(e), COALESCE(AVG(e.amount), 0) FROM Expense e WHERE e.user.id = :userId")
    List<Object[]> getSpendingSummary(@Param("userId") UUID userId);

    @Query("SELECT COALESCE(c.name, 'Uncategorized'), COALESCE(SUM(e.amount), 0), COUNT(e) " +
           "FROM Expense e LEFT JOIN e.category c WHERE e.user.id = :userId " +
           "GROUP BY c.name ORDER BY SUM(e.amount) DESC")
    List<Object[]> getCategoryBreakdown(@Param("userId") UUID userId);

    @Query(value = "SELECT CAST(e.transaction_time AS DATE) AS tx_date, SUM(e.amount) AS total_amount, COUNT(e.id) AS tx_count " +
                   "FROM expenses e WHERE e.user_id = :userId " +
                   "GROUP BY CAST(e.transaction_time AS DATE) ORDER BY tx_date ASC", nativeQuery = true)
    List<Object[]> getDailySpending(@Param("userId") UUID userId);

    @Query(value = "SELECT TO_CHAR(e.transaction_time, 'YYYY-MM') AS tx_month, SUM(e.amount) AS total_amount, COUNT(e.id) AS tx_count " +
                   "FROM expenses e WHERE e.user_id = :userId " +
                   "GROUP BY TO_CHAR(e.transaction_time, 'YYYY-MM') ORDER BY tx_month ASC", nativeQuery = true)
    List<Object[]> getMonthlySpending(@Param("userId") UUID userId);
}
