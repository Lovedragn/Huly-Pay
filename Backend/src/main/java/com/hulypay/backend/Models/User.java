package com.hulypay.backend.Models;

import com.hulypay.backend.Security.EncryptedStringConverter;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {

    @Id
    @Column(name = "id", nullable = false, updatable = false)
    private UUID id;

    @Column(nullable = false, unique = true)
    private String email;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "full_name", nullable = false, columnDefinition = "TEXT")
    private String fullName;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "phone_number", columnDefinition = "TEXT")
    private String phoneNumber;

    @Builder.Default
    @Column(name = "active", nullable = false)
    private Boolean active = true;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "first_name", columnDefinition = "TEXT")
    private String firstName;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "last_name", columnDefinition = "TEXT")
    private String lastName;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "avatar_url", columnDefinition = "TEXT")
    private String avatarUrl;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "auth_provider", columnDefinition = "TEXT")
    private String authProvider;

    @Convert(converter = EncryptedStringConverter.class)
    @Column(name = "provider_subject", columnDefinition = "TEXT")
    private String providerSubject;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private Instant updatedAt;
}
