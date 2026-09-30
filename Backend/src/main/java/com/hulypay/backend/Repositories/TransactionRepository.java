package com.hulypay.backend.Repositories;

import com.hulypay.backend.Models.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, UUID> {

    List<Transaction> findByUserIdOrderByTransactionTimeDesc(UUID userId);

    List<Transaction> findByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<Transaction> findByIdAndUserId(UUID id, UUID userId);

    Optional<Transaction> findByUpiTransactionId(String upiTransactionId);

    @Query("SELECT COALESCE(SUM(t.amount), 0), COUNT(t), COALESCE(AVG(t.amount), 0) " +
           "FROM Transaction t WHERE t.user.id = :userId")
    List<Object[]> getSpendingSummary(@Param("userId") UUID userId);

    @Query("SELECT COALESCE(NULLIF(TRIM(t.category), ''), 'Others'), COALESCE(SUM(t.amount), 0), COUNT(t) " +
           "FROM Transaction t WHERE t.user.id = :userId " +
           "GROUP BY COALESCE(NULLIF(TRIM(t.category), ''), 'Others') " +
           "ORDER BY SUM(t.amount) DESC")
    List<Object[]> getCategoryBreakdown(@Param("userId") UUID userId);

    @Query(value = "SELECT CAST(t.transaction_time AS DATE) AS tx_date, SUM(t.amount) AS total_amount, COUNT(t.id) AS tx_count " +
                   "FROM transactions t WHERE t.user_id = :userId " +
                   "GROUP BY CAST(t.transaction_time AS DATE) ORDER BY tx_date ASC", nativeQuery = true)
    List<Object[]> getDailySpending(@Param("userId") UUID userId);

    @Query(value = "SELECT TO_CHAR(t.transaction_time, 'YYYY-MM') AS tx_month, SUM(t.amount) AS total_amount, COUNT(t.id) AS tx_count " +
                   "FROM transactions t WHERE t.user_id = :userId " +
                   "GROUP BY TO_CHAR(t.transaction_time, 'YYYY-MM') ORDER BY tx_month ASC", nativeQuery = true)
    List<Object[]> getMonthlySpending(@Param("userId") UUID userId);
}


