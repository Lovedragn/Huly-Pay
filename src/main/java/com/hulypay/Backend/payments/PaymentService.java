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

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final ExpenseRepository expenseRepository;

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

        PaymentStatus initialStatus = (request.getUpiTransactionId() != null && !request.getUpiTransactionId().isBlank())
                ? PaymentStatus.PENDING
                : PaymentStatus.INITIATED;

        String currency = (request.getCurrency() != null && !request.getCurrency().isBlank())
                ? request.getCurrency().toUpperCase()
                : "INR";

        Payment payment = Payment.builder()
                .user(user)
                .expense(expense)
                .amount(request.getAmount())
                .currency(currency)
                .upiTransactionId(request.getUpiTransactionId())
                .merchantName(request.getMerchantName())
                .status(initialStatus)
                .provider(request.getProvider())
                .build();

        Payment saved = paymentRepository.save(payment);
        log.info("Recorded payment {} with status {} for user {}", saved.getId(), saved.getStatus(), user.getId());
        return PaymentResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
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
}
