package com.hulypay.backend.Models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "payment_methods")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentMethod {

    @Id
    @Column(name = "name", length = 100, nullable = false)
    private String name;

    public String getMethod() {
        return "UPI";
    }

    public String getProvider() {
        return name;
    }
}
