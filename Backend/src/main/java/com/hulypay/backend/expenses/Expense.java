package com.hulypay.backend.expenses;

import com.hulypay.backend.categories.Category;
import com.hulypay.backend.users.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "expenses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Expense {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Builder.Default
    @Column(nullable = false, length = 3)
    private String currency = "INR";

    @Column(name = "merchant_name")
    private String merchantName;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id")
    private Category category;

    @Column(length = 1000)
    private String description;

    @Column(name = "transaction_time", nullable = false)
    private Instant transactionTime;

    @Builder.Default
    @Column(name = "payment_method")
    private String paymentMethod = "UPI";

    @Column(name = "upi_transaction_id")
    private String upiTransactionId;

    @Builder.Default
    @Column(name = "status")
    private String status = "COMPLETED";

    private Double latitude;

    private Double longitude;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
