package com.hulypay.backend.Models;

import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
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

    @EmbeddedId
    private PaymentMethodId id;

    public String getMethod() {
        return id != null ? id.getMethod() : null;
    }

    public String getProvider() {
        return id != null ? id.getProvider() : null;
    }
}
