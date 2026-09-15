package com.hulypay.backend.payments.dto;

import com.hulypay.backend.payments.PaymentStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SmsVerificationResponse {

    private boolean verified;

    private PaymentStatus status;

    private String message;

    private BigDecimal extractedAmount;

    private String extractedUpiReference;

    private String extractedSender;

    private PaymentResponse payment;
}
