package com.hulypay.backend.Models;

import com.hulypay.backend.Security.EncryptedStringConverter;
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
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, precision = 12, scale = 2)
    private BigDecimal amount;

    @Builder.Default
    @Column(nullable = false, length = 3)
    private String currency = "INR";

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "merchant_name", columnDefinition = "TEXT")
    private String merchantName;

    @Builder.Default
    @Column(nullable = false, length = 100)
    private String category = "Others";

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @Column(name = "payment_method", length = 50)
    private String paymentMethod;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "provider", columnDefinition = "TEXT")
    private String provider;

    @Builder.Default
    @Column(nullable = false, length = 30)
    private String status = "SUCCESS";

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "upi_transaction_id", columnDefinition = "TEXT")
    private String upiTransactionId;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "transaction_reference", columnDefinition = "TEXT")
    private String transactionReference;

    @Convert(converter = EncryptedStringConverter.class)
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
}
