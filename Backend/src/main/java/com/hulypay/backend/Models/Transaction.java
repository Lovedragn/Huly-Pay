package com.hulypay.backend.Models;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "transactions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Builder.Default
    @Column(name = "currency_code", length = 3)
    private String currencyCode = "INR";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchant_id")
    private Merchant merchant;

    @Column(name = "merchant_name")
    private String merchantName;

    @Builder.Default
    @Column(name = "category_name")
    private String categoryName = "Others";

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "payment_method")
    private String paymentMethod;

    @Column(name = "provider")
    private String provider;

    @Builder.Default
    @Column(name = "status")
    private String status = "SUCCESS";

    @Builder.Default
    @Column(name = "status_code")
    private Short statusCode = 1;

    @Column(name = "upi_transaction_id", columnDefinition = "TEXT")
    private String upiTransactionId;

    @Column(name = "transaction_reference", columnDefinition = "TEXT")
    private String transactionReference;

    @Column(name = "upi_id", columnDefinition = "TEXT")
    private String upiId;

    private Double latitude;

    private Double longitude;

    @Column(name = "location_accuracy_meters")
    private Double locationAccuracyMeters;

    @Builder.Default
    @Column(name = "transaction_time", nullable = false)
    private Instant transactionTime = Instant.now();

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;

    // Convenience accessors
    public String getMerchantName() {
        if (merchant != null && merchant.getName() != null && !merchant.getName().isBlank()) {
            return merchant.getName();
        }
        return merchantName;
    }

    public String getCurrency() {
        return currencyCode != null ? currencyCode : "INR";
    }

    public void setCurrency(String currency) {
        this.currencyCode = (currency != null && !currency.isBlank()) ? currency.trim().toUpperCase() : "INR";
    }

    public String getCategory() {
        return categoryName != null ? categoryName : "Others";
    }

    public void setCategory(String category) {
        this.categoryName = (category != null && !category.isBlank()) ? category.trim() : "Others";
    }

    public String getStatus() {
        if (status != null && !status.isBlank()) {
            return status;
        }
        return TransactionStatusEnum.toName(statusCode);
    }

    public void setStatus(String status) {
        this.status = (status != null && !status.isBlank()) ? status.trim().toUpperCase() : "SUCCESS";
        this.statusCode = TransactionStatusEnum.toCode(this.status);
    }

    public void setStatusCode(Short code) {
        this.statusCode = code != null ? code : 1;
        this.status = TransactionStatusEnum.toName(this.statusCode);
    }
}
