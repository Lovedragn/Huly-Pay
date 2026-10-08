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

    @Column(name = "amount", nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Builder.Default
    @Column(name = "currency", length = 10, nullable = false)
    private String currency = "₹";

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "merchant_name", referencedColumnName = "name")
    private Merchant merchant;

    @Builder.Default
    @Column(name = "category", length = 100, nullable = false)
    private String category = "Others";

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "payment_method", length = 100)
    private String paymentMethod;

    @Column(name = "provider", length = 100)
    private String provider;

    @Builder.Default
    @Column(name = "status", length = 30, nullable = false)
    private String status = "SUCCESS";

    @Column(name = "upi_transaction_id", columnDefinition = "TEXT")
    private String upiTransactionId;

    @Column(name = "transaction_reference", columnDefinition = "TEXT")
    private String transactionReference;

    @Column(name = "upi_id", columnDefinition = "TEXT")
    private String upiId;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
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
        return null;
    }

    public void setMerchantName(String merchantName) {
        if (merchantName != null && !merchantName.isBlank()) {
            this.merchant = Merchant.builder().name(merchantName.trim()).build();
        } else {
            this.merchant = null;
        }
    }

    public String getCurrency() {
        return currency != null && !currency.isBlank() ? currency : "₹";
    }

    public void setCurrency(String currency) {
        if (currency == null || currency.isBlank()) {
            this.currency = "₹";
            return;
        }
        String clean = currency.trim();
        if (clean.equalsIgnoreCase("USD") || clean.equals("$")) {
            this.currency = "$";
        } else if (clean.equalsIgnoreCase("INR") || clean.equals("₹") || clean.equalsIgnoreCase("RS")) {
            this.currency = "₹";
        } else {
            this.currency = clean;
        }
    }

    public String getCurrencyCode() {
        return ("$".equals(currency) || "USD".equalsIgnoreCase(currency)) ? "USD" : "INR";
    }

    public String getCurrencySymbol() {
        return ("$".equals(currency) || "USD".equalsIgnoreCase(currency)) ? "$" : "₹";
    }

    public String getCategory() {
        return category != null && !category.isBlank() ? category : "Others";
    }

    public void setCategory(String category) {
        this.category = (category != null && !category.isBlank()) ? category.trim() : "Others";
    }

    public String getCategoryName() {
        return getCategory();
    }

    public void setCategoryName(String categoryName) {
        setCategory(categoryName);
    }

    public Short getStatusCode() {
        return TransactionStatusEnum.toCode(status);
    }

    public void setStatusCode(Short code) {
        this.status = TransactionStatusEnum.toName(code);
    }
}
