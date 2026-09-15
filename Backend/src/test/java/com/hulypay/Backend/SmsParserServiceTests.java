package com.hulypay.backend;

import com.hulypay.backend.payments.Payment;
import com.hulypay.backend.payments.sms.ParsedSmsResult;
import com.hulypay.backend.payments.sms.SmsParserService;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.*;

class SmsParserServiceTests {

    private final SmsParserService smsParser = new SmsParserService();

    @Test
    void testHdfcDebitSmsParsing() {
        String sms = "Dear Customer, Rs.500.00 has been debited from account **1234 to VPA merchant@okaxis on 15-09-26. UPI Ref: 425612345678. Not you? Call bank.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        assertTrue(parsed.isDebit());
        assertFalse(parsed.isFailed());
        assertEquals(new BigDecimal("500.00"), parsed.getAmount());
        assertEquals("425612345678", parsed.getUpiReference());
        assertEquals("merchant@okaxis", parsed.getPayeeOrVpa());
    }

    @Test
    void testSbiDebitSmsParsing() {
        String sms = "Your A/C ending 5678 is debited for Rs 250.50 on 15-Sep-26 by UPI ref no 425687654321 - SBI";
        ParsedSmsResult parsed = smsParser.parse(sms);

        assertTrue(parsed.isDebit());
        assertFalse(parsed.isFailed());
        assertEquals(new BigDecimal("250.50"), parsed.getAmount());
        assertEquals("425687654321", parsed.getUpiReference());
    }

    @Test
    void testIciciBankSentSms() {
        String sms = "Sent Rs.1,200.00 from ICICI Bank A/c ... to cafestore@icici on 15-Sep-26. UPI Ref no 425699887766.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        assertTrue(parsed.isDebit());
        assertFalse(parsed.isFailed());
        assertEquals(new BigDecimal("1200.00"), parsed.getAmount());
        assertEquals("425699887766", parsed.getUpiReference());
        assertEquals("cafestore@icici", parsed.getPayeeOrVpa());
    }

    @Test
    void testAxisBankDebitSms() {
        String sms = "INR 350.00 debited from Axis Bank A/C ... on 15-09-2026. Info: UPI/425698765432/merchant.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        assertTrue(parsed.isDebit());
        assertFalse(parsed.isFailed());
        assertEquals(new BigDecimal("350.00"), parsed.getAmount());
        assertEquals("425698765432", parsed.getUpiReference());
    }

    @Test
    void testFailedTransactionSms() {
        String sms = "UPI transaction of Rs.500.00 to merchant@upi failed due to incorrect UPI PIN or bank server issue.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        assertTrue(parsed.isFailed());
        assertEquals(new BigDecimal("500.00"), parsed.getAmount());

        Payment payment = Payment.builder()
                .amount(new BigDecimal("500.00"))
                .upiId("merchant@upi")
                .build();

        SmsParserService.VerificationMatchResult result = smsParser.matchPaymentWithSms(payment, parsed);
        assertTrue(result.matched());
        assertTrue(result.isFailure());
    }

    @Test
    void testMatchingSuccessPaymentWithSms() {
        String sms = "Rs 750.00 debited via UPI from Bank A/C. UPI Ref 998877665544.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        Payment payment = Payment.builder()
                .amount(new BigDecimal("750.00"))
                .build();

        SmsParserService.VerificationMatchResult result = smsParser.matchPaymentWithSms(payment, parsed);
        assertTrue(result.matched());
        assertFalse(result.isFailure());
    }

    @Test
    void testAmountMismatchDetection() {
        String sms = "Rs 100.00 debited via UPI from Bank A/C. UPI Ref 998877665544.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        Payment payment = Payment.builder()
                .amount(new BigDecimal("200.00"))
                .build();

        SmsParserService.VerificationMatchResult result = smsParser.matchPaymentWithSms(payment, parsed);
        assertFalse(result.matched());
        assertTrue(result.details().contains("Amount mismatch"));
    }

    @Test
    void testCreditSmsRejectedForOutgoingPayment() {
        String sms = "A/C 1234 is credited with INR 500.00 on 15-Sep-26 by UPI/998877.";
        ParsedSmsResult parsed = smsParser.parse(sms);

        Payment payment = Payment.builder()
                .amount(new BigDecimal("500.00"))
                .build();

        SmsParserService.VerificationMatchResult result = smsParser.matchPaymentWithSms(payment, parsed);
        assertFalse(result.matched());
        assertTrue(result.details().contains("incoming credit"));
    }
}
