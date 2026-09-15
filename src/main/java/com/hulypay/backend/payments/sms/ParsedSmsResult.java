package com.hulypay.backend.payments.sms;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ParsedSmsResult {

    private boolean isDebit;

    private boolean isCredit;

    private boolean isFailed;

    private BigDecimal amount;

    private String currency;

    private String payeeOrVpa;

    private String upiReference;

    private String rawSms;
}
