package com.hulypay.backend.payments;

import com.hulypay.backend.common.exception.BadRequestException;
import com.hulypay.backend.common.exception.ResourceNotFoundException;
import com.hulypay.backend.expenses.Expense;
import com.hulypay.backend.expenses.ExpenseRepository;
import com.hulypay.backend.payments.dto.CreatePaymentRequest;
import com.hulypay.backend.payments.dto.PaymentResponse;
import com.hulypay.backend.users.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.hulypay.backend.payments.dto.ReconcilePaymentRequest;
import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalTime;
import com.hulypay.backend.payments.dto.SmsVerificationRequest;
import com.hulypay.backend.payments.dto.SmsVerificationResponse;
import com.hulypay.backend.payments.sms.ParsedSmsResult;
import com.hulypay.backend.payments.sms.SmsParserService;
import jakarta.annotation.PostConstruct;
import org.springframework.jdbc.core.JdbcTemplate;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final ExpenseRepository expenseRepository;
    private final JdbcTemplate jdbcTemplate;
    private final SmsParserService smsParserService;

    @PostConstruct
    public void ensurePaymentStatusConstraint() {
        try {
            jdbcTemplate.execute("ALTER TABLE payments DROP CONSTRAINT IF EXISTS payments_status_check");
            jdbcTemplate.execute("ALTER TABLE payments ADD CONSTRAINT payments_status_check CHECK (status IN ('INITIATED', 'PAYMENT_INITIATED', 'PENDING', 'CONFIRMED', 'SUCCESS', 'FAILED', 'CANCELLED', 'TIMEOUT', 'VERIFYING_SMS', 'UNKNOWN'))");
            log.info("Ensured payments_status_check constraint permits Phase 3 and SMS verification statuses");
        } catch (Exception e) {
            log.warn("Payment status constraint notice: {}", e.getMessage());
        }
    }

    @Transactional
    public PaymentResponse createPayment(User user, CreatePaymentRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Amount must be greater than zero");
        }

        Expense expense = null;
        if (request.getExpenseId() != null) {
            expense = expenseRepository.findByIdAndUserId(request.getExpenseId(), user.getId())
                    .orElseThrow(() -> new ResourceNotFoundException("Expense not found with ID: " + request.getExpenseId()));
        }

        PaymentStatus initialStatus = request.getStatus() != null
                ? request.getStatus()
                : ((request.getUpiTransactionId() != null && !request.getUpiTransactionId().isBlank())
                        ? PaymentStatus.PENDING
                        : PaymentStatus.INITIATED);

        String currency = (request.getCurrency() != null && !request.getCurrency().isBlank())
                ? request.getCurrency().toUpperCase()
                : "INR";

        LocalDate paymentDate = request.getPaymentDate() != null ? request.getPaymentDate() : LocalDate.now();
        LocalTime paymentTime = request.getPaymentTime() != null ? request.getPaymentTime() : LocalTime.now();
        String paymentMethod = (request.getPaymentMethod() != null && !request.getPaymentMethod().isBlank())
                ? request.getPaymentMethod()
                : "UPI";

        // Auto-create and link expense if payment is already confirmed/successful from client
        if ((initialStatus == PaymentStatus.CONFIRMED || initialStatus == PaymentStatus.SUCCESS) && expense == null) {
            String payeeDesc = request.getMerchantName() != null ? request.getMerchantName()
                    : (request.getUpiId() != null ? request.getUpiId() : "Merchant");

            expense = Expense.builder()
                    .user(user)
                    .amount(request.getAmount())
                    .currency(currency)
                    .merchantName(request.getMerchantName())
                    .paymentMethod(paymentMethod)
                    .upiTransactionId(request.getUpiTransactionId())
                    .status("COMPLETED")
                    .latitude(request.getLatitude())
                    .longitude(request.getLongitude())
                    .transactionTime(Instant.now())
                    .description("Payment to " + payeeDesc)
                    .build();

            expense = expenseRepository.save(expense);
        }

        Payment payment = Payment.builder()
                .user(user)
                .expense(expense)
                .amount(request.getAmount())
                .currency(currency)
                .upiTransactionId(request.getUpiTransactionId())
                .upiId(request.getUpiId())
                .merchantName(request.getMerchantName())
                .paymentMethod(paymentMethod)
                .transactionReference(request.getTransactionReference())
                .status(initialStatus)
                .provider(request.getProvider())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .locationAccuracyMeters(request.getLocationAccuracyMeters())
                .paymentDate(paymentDate)
                .paymentTime(paymentTime)
                .build();

        Payment saved = paymentRepository.save(payment);
        log.info("Recorded payment {} with status {} for user {}", saved.getId(), saved.getStatus(), user.getId());
        return PaymentResponse.fromEntity(saved);
    }

    @Transactional
    public PaymentResponse reconcilePayment(User user, UUID id, ReconcilePaymentRequest request) {
        Payment payment = paymentRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found with ID: " + id));

        payment.setStatus(request.getStatus());
        if (request.getUpiTransactionId() != null && !request.getUpiTransactionId().isBlank()) {
            payment.setUpiTransactionId(request.getUpiTransactionId());
        }
        if (request.getTransactionReference() != null && !request.getTransactionReference().isBlank()) {
            payment.setTransactionReference(request.getTransactionReference());
        }

        // Link/create expense if confirmed or success
        if ((request.getStatus() == PaymentStatus.CONFIRMED || request.getStatus() == PaymentStatus.SUCCESS)
                && payment.getExpense() == null) {
            String payeeDesc = payment.getMerchantName() != null ? payment.getMerchantName()
                    : (payment.getUpiId() != null ? payment.getUpiId() : "Merchant");

            Expense expense = Expense.builder()
                    .user(user)
                    .amount(payment.getAmount())
                    .currency(payment.getCurrency())
                    .merchantName(payment.getMerchantName())
                    .paymentMethod(payment.getPaymentMethod())
                    .upiTransactionId(payment.getUpiTransactionId())
                    .status("COMPLETED")
                    .latitude(payment.getLatitude())
                    .longitude(payment.getLongitude())
                    .transactionTime(payment.getCreatedAt() != null ? payment.getCreatedAt() : Instant.now())
                    .description("Payment to " + payeeDesc)
                    .build();

            Expense savedExpense = expenseRepository.save(expense);
            payment.setExpense(savedExpense);
        }

        Payment saved = paymentRepository.save(payment);
        log.info("Reconciled payment {} to status {} for user {}", saved.getId(), saved.getStatus(), user.getId());
        return PaymentResponse.fromEntity(saved);
    }

    @Transactional
    public List<PaymentResponse> getPaymentsForUser(User user) {
        return paymentRepository.findByUserIdOrderByCreatedAtDesc(user.getId())
                .stream()
                .map(PaymentResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public PaymentResponse getPaymentById(User user, UUID id) {
        Payment payment = paymentRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found with ID: " + id));
        return PaymentResponse.fromEntity(payment);
    }

    @Transactional
    public SmsVerificationResponse verifyPaymentSms(User user, UUID id, SmsVerificationRequest request) {
        Payment payment = paymentRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Payment not found with ID: " + id));

        // 1. Idempotency guard: If payment is already finalized, return current status without re-processing
        if (payment.getStatus() == PaymentStatus.SUCCESS || payment.getStatus() == PaymentStatus.CONFIRMED) {
            return SmsVerificationResponse.builder()
                    .verified(true)
                    .status(payment.getStatus())
                    .message("Payment is already confirmed")
                    .extractedAmount(payment.getAmount())
                    .extractedUpiReference(payment.getUpiTransactionId())
                    .payment(PaymentResponse.fromEntity(payment))
                    .build();
        }
        if (payment.getStatus() == PaymentStatus.FAILED || payment.getStatus() == PaymentStatus.TIMEOUT) {
            return SmsVerificationResponse.builder()
                    .verified(true)
                    .status(payment.getStatus())
                    .message("Payment was previously marked as " + payment.getStatus())
                    .payment(PaymentResponse.fromEntity(payment))
                    .build();
        }

        // 2. Parse the incoming SMS content
        ParsedSmsResult parsed = smsParserService.parse(request.getSmsBody());
        SmsParserService.VerificationMatchResult matchResult = smsParserService.matchPaymentWithSms(payment, parsed);

        if (!matchResult.matched()) {
            log.info("SMS verification non-match for payment {}: {}", id, matchResult.details());
            return SmsVerificationResponse.builder()
                    .verified(false)
                    .status(payment.getStatus())
                    .message(matchResult.details())
                    .extractedAmount(parsed.getAmount())
                    .extractedUpiReference(parsed.getUpiReference())
                    .payment(PaymentResponse.fromEntity(payment))
                    .build();
        }

        // 3. Matched: Handle success vs failure
        if (matchResult.isFailure()) {
            payment.setStatus(PaymentStatus.FAILED);
            Payment saved = paymentRepository.save(payment);
            log.info("SMS verification marked payment {} as FAILED", id);
            return SmsVerificationResponse.builder()
                    .verified(true)
                    .status(PaymentStatus.FAILED)
                    .message(matchResult.details())
                    .extractedAmount(parsed.getAmount())
                    .extractedUpiReference(parsed.getUpiReference())
                    .payment(PaymentResponse.fromEntity(saved))
                    .build();
        }

        // 4. Successful match
        payment.setStatus(PaymentStatus.SUCCESS);
        if (parsed.getUpiReference() != null && !parsed.getUpiReference().isBlank()) {
            payment.setUpiTransactionId(parsed.getUpiReference());
        }

        // Auto-create / link expense if not already present
        if (payment.getExpense() == null) {
            String payeeDesc = payment.getMerchantName() != null ? payment.getMerchantName()
                    : (payment.getUpiId() != null ? payment.getUpiId() : "Merchant");

            Expense expense = Expense.builder()
                    .user(user)
                    .amount(payment.getAmount())
                    .currency(payment.getCurrency())
                    .merchantName(payment.getMerchantName())
                    .paymentMethod(payment.getPaymentMethod())
                    .upiTransactionId(payment.getUpiTransactionId())
                    .status("COMPLETED")
                    .latitude(payment.getLatitude())
                    .longitude(payment.getLongitude())
                    .transactionTime(payment.getCreatedAt() != null ? payment.getCreatedAt() : Instant.now())
                    .description("Payment to " + payeeDesc)
                    .build();

            Expense savedExpense = expenseRepository.save(expense);
            payment.setExpense(savedExpense);
        }

        Payment saved = paymentRepository.save(payment);
        log.info("SMS verified payment {} as SUCCESS for user {}", saved.getId(), user.getId());
        return SmsVerificationResponse.builder()
                .verified(true)
                .status(PaymentStatus.SUCCESS)
                .message("Payment verified successfully via SMS")
                .extractedAmount(parsed.getAmount())
                .extractedUpiReference(parsed.getUpiReference())
                .payment(PaymentResponse.fromEntity(saved))
                .build();
    }
}
