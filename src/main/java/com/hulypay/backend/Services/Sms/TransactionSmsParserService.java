package com.hulypay.backend.Services.Sms;

import com.hulypay.backend.Models.Transaction;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
public class TransactionSmsParserService {

    // Patterns for amount extraction
    private static final Pattern[] AMOUNT_PATTERNS = new Pattern[]{
            Pattern.compile("(?i)(?:rs\\.?|inr|₹)\\s*([0-9,]+(?:\\.[0-9]{1,2})?)"),
            Pattern.compile("(?i)(?:debited\\s+(?:by|for|with)?|paid|sent|spent|transferred)\\s+(?:rs\\.?|inr|₹)?\\s*([0-9,]+(?:\\.[0-9]{1,2})?)"),
            Pattern.compile("(?i)(?:amount\\s*(?:of)?|txn\\s*(?:of)?)\\s*(?:rs\\.?|inr|₹)?\\s*([0-9,]+(?:\\.[0-9]{1,2})?)")
    };

    // Patterns for UPI reference / UTR
    private static final Pattern[] UPI_REF_PATTERNS = new Pattern[]{
            Pattern.compile("(?i)(?:upi\\s*(?:ref|reference)?(?:\\s*no\\.?)?|utr(?:\\s*no\\.?)?|rrn|txn\\s*(?:id|ref)?)\\s*[:=\\-\\s]+([0-9A-Za-z]{6,25})"),
            Pattern.compile("(?i)UPI/([0-9A-Za-z]{6,25})"),
            Pattern.compile("(?i)(?:ref\\s*(?:no\\.?)?)\\s*[:=\\-\\s]+([0-9A-Za-z]{6,25})")
    };

    // Patterns for payee or VPA
    private static final Pattern[] VPA_PATTERNS = new Pattern[]{
            Pattern.compile("(?i)(?:to|vpa)\\s+([a-zA-Z0-9.\\-_]+@[a-zA-Z0-9]+)"),
            Pattern.compile("(?i)to\\s+([A-Za-z0-9\\s]{3,30}?)(?:\\s+on|\\s+via|\\.|\\s+ref|$)")
    };

    // Keywords for debit vs credit vs failure
    private static final String[] DEBIT_KEYWORDS = new String[]{"debited", "debit", "paid", "sent", "transferred", "spent", "withdrawn"};
    private static final String[] FAILED_KEYWORDS = new String[]{"failed", "failure", "declined", "unsuccessful", "rejected", "cancelled", "canceled"};
    private static final String[] CREDIT_KEYWORDS = new String[]{"credited", "credit", "received", "refunded"};

    public ParsedTransactionSms parse(String smsBody) {
        if (smsBody == null || smsBody.isBlank()) {
            return ParsedTransactionSms.builder().rawSms(smsBody).build();
        }

        String lower = smsBody.toLowerCase();

        boolean isFailed = false;
        for (String kw : FAILED_KEYWORDS) {
            if (lower.contains(kw)) {
                isFailed = true;
                break;
            }
        }

        boolean isDebit = false;
        for (String kw : DEBIT_KEYWORDS) {
            if (lower.contains(kw)) {
                isDebit = true;
                break;
            }
        }

        boolean isCredit = false;
        for (String kw : CREDIT_KEYWORDS) {
            if (lower.contains(kw)) {
                isCredit = true;
                break;
            }
        }

        // Amount extraction
        BigDecimal amount = null;
        for (Pattern p : AMOUNT_PATTERNS) {
            Matcher m = p.matcher(smsBody);
            if (m.find()) {
                String raw = m.group(1).replace(",", "").trim();
                try {
                    amount = new BigDecimal(raw).setScale(2, RoundingMode.HALF_UP);
                    break;
                } catch (Exception ignored) {
                }
            }
        }

        // UPI reference / UTR extraction
        String upiRef = null;
        for (Pattern p : UPI_REF_PATTERNS) {
            Matcher m = p.matcher(smsBody);
            if (m.find()) {
                upiRef = m.group(1).trim();
                break;
            }
        }

        // VPA / Payee extraction
        String payee = null;
        for (Pattern p : VPA_PATTERNS) {
            Matcher m = p.matcher(smsBody);
            if (m.find()) {
                String candidate = m.group(1).trim();
                if (!candidate.equalsIgnoreCase("VPA") && !candidate.equalsIgnoreCase("UPI")) {
                    payee = candidate;
                    break;
                }
            }
        }

        return ParsedTransactionSms.builder()
                .rawSms(smsBody)
                .amount(amount)
                .currency("INR")
                .isDebit(isDebit)
                .isCredit(isCredit)
                .isFailed(isFailed)
                .upiReference(upiRef)
                .payeeOrVpa(payee)
                .build();
    }

    public VerificationMatchResult matchTransactionWithSms(Transaction transaction, ParsedTransactionSms parsed) {
        if (parsed == null) {
            return new VerificationMatchResult(false, false, "Could not parse SMS content");
        }

        // Check if SMS indicates a failure
        if (parsed.isFailed()) {
            if (parsed.getAmount() != null && transaction.getAmount() != null) {
                if (parsed.getAmount().compareTo(transaction.getAmount().setScale(2, RoundingMode.HALF_UP)) != 0) {
                    return new VerificationMatchResult(false, false, "SMS indicates failure but amount does not match expected transaction");
                }
            }
            return new VerificationMatchResult(true, true, "SMS indicates transaction failed or was declined");
        }

        // If it's a pure credit SMS without debit, it's not our outgoing transaction
        if (parsed.isCredit() && !parsed.isDebit()) {
            return new VerificationMatchResult(false, false, "SMS indicates incoming credit, not an outgoing transaction");
        }

        // Amount verification
        if (parsed.getAmount() == null) {
            return new VerificationMatchResult(false, false, "Could not extract amount from transaction SMS");
        }

        BigDecimal expectedAmount = transaction.getAmount().setScale(2, RoundingMode.HALF_UP);
        if (parsed.getAmount().compareTo(expectedAmount) != 0) {
            return new VerificationMatchResult(false, false, String.format(
                    "Amount mismatch: SMS amount %s does not match expected transaction amount %s",
                    parsed.getAmount(), expectedAmount
            ));
        }

        // Payee / UPI ID verification (if present in both)
        if (parsed.getPayeeOrVpa() != null && transaction.getUpiId() != null) {
            String cleanParsedPayee = parsed.getPayeeOrVpa().toLowerCase();
            String cleanExpectedUpi = transaction.getUpiId().toLowerCase();
            if (cleanParsedPayee.contains("@") && cleanExpectedUpi.contains("@")) {
                if (!cleanParsedPayee.equals(cleanExpectedUpi) && !cleanExpectedUpi.contains(cleanParsedPayee)) {
                    log.warn("VPA check notice: parsed {} vs expected {}", cleanParsedPayee, cleanExpectedUpi);
                }
            }
        }

        return new VerificationMatchResult(true, false, "Transaction successfully matched with bank SMS");
    }

    public record VerificationMatchResult(boolean matched, boolean isFailure, String details) {
    }
}



