package com.hulypay.backend.ResponseDto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionSmsVerificationResponse {

    private boolean verified;

    private String status;

    private String message;

    private BigDecimal extractedAmount;

    private String extractedUpiReference;

    private TransactionResponse transaction;
}




