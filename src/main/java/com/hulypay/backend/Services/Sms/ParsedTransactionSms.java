package com.hulypay.backend.Services.Sms;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ParsedTransactionSms {

    private boolean isDebit;

    private boolean isCredit;

    private boolean isFailed;

    private BigDecimal amount;

    private String currency;

    private String payeeOrVpa;

    private String upiReference;

    private String rawSms;
}



