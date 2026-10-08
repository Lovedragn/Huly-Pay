package com.hulypay.backend.Models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "transaction_status")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TransactionStatusEntity {

    @Id
    @Column(name = "code", nullable = false)
    private Short code;

    @Column(name = "name", length = 30, nullable = false, unique = true)
    private String name;
}
