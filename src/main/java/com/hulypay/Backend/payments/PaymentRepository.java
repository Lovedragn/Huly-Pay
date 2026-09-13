package com.hulypay.backend.payments;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    List<Payment> findByUserIdOrderByCreatedAtDesc(UUID userId);

    Optional<Payment> findByIdAndUserId(UUID id, UUID userId);

    Optional<Payment> findByUpiTransactionId(String upiTransactionId);

    @Modifying
    @Query("DELETE FROM Payment p WHERE p.status IN (com.hulypay.backend.payments.PaymentStatus.INITIATED, com.hulypay.backend.payments.PaymentStatus.PAYMENT_INITIATED) AND p.createdAt < :cutoff")
    int deleteStaleInitiatedPayments(@Param("cutoff") Instant cutoff);

    @Modifying
    @Query("DELETE FROM Payment p WHERE p.status = com.hulypay.backend.payments.PaymentStatus.PENDING AND p.createdAt < :cutoff")
    int deleteStalePendingPayments(@Param("cutoff") Instant cutoff);
}
