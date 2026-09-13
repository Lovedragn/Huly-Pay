package com.hulypay.backend.payments.dto;

import com.hulypay.backend.payments.PaymentStatus;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ReconcilePaymentRequest {

    @NotNull(message = "Payment status is required")
    private PaymentStatus status;

    private String upiTransactionId;

    private String transactionReference;
}
