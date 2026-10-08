package com.hulypay.backend.Models;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
@Builder
public class PaymentMethodId implements Serializable {

    @Column(name = "method", length = 100, nullable = false)
    private String method;

    @Column(name = "provider", length = 100, nullable = false)
    private String provider;
}
