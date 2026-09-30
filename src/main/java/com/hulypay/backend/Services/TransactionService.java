package com.hulypay.backend.Services;

import com.hulypay.backend.RequestDto.*;
import com.hulypay.backend.ResponseDto.*;
import com.hulypay.backend.Exceptions.BadRequestException;
import com.hulypay.backend.Exceptions.ResourceNotFoundException;
import com.hulypay.backend.Models.Transaction;
import com.hulypay.backend.Models.User;
import com.hulypay.backend.Repositories.TransactionRepository;
import com.hulypay.backend.Services.Sms.ParsedTransactionSms;
import com.hulypay.backend.Services.Sms.TransactionSmsParserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class TransactionService {

    private final TransactionRepository transactionRepository;
    private final TransactionSmsParserService smsParserService;

    @Transactional
    public TransactionResponse createTransaction(User user, CreateTransactionRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Amount must be greater than zero");
        }

        String currency = (request.getCurrency() != null && !request.getCurrency().isBlank())
                ? request.getCurrency().toUpperCase()
                : "INR";

        String category = (request.getCategory() != null && !request.getCategory().isBlank())
                ? request.getCategory().trim()
                : "Others";

        String status = (request.getStatus() != null && !request.getStatus().isBlank())
                ? request.getStatus().trim().toUpperCase()
                : "SUCCESS";

        Instant txTime = request.getTransactionTime() != null ? request.getTransactionTime() : Instant.now();

        Transaction transaction = Transaction.builder()
                .user(user)
                .amount(request.getAmount())
                .currency(currency)
                .merchantName(request.getMerchantName())
                .category(category)
                .description(request.getDescription())
                .paymentMethod(request.getPaymentMethod())
                .provider(request.getProvider())
                .status(status)
                .upiTransactionId(request.getUpiTransactionId())
                .transactionReference(request.getTransactionReference())
                .upiId(request.getUpiId())
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .locationAccuracyMeters(request.getLocationAccuracyMeters())
                .transactionTime(txTime)
                .build();

        Transaction saved = transactionRepository.save(transaction);
        log.info("Created transaction {} for user {}", saved.getId(), user.getId());
        return TransactionResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<TransactionResponse> getTransactionsForUser(User user) {
        return transactionRepository.findByUserIdOrderByTransactionTimeDesc(user.getId())
                .stream()
                .map(TransactionResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public TransactionResponse getTransactionById(User user, UUID id) {
        Transaction transaction = transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID: " + id));
        return TransactionResponse.fromEntity(transaction);
    }

    @Transactional
    public TransactionResponse updateTransaction(User user, UUID id, UpdateTransactionRequest request) {
        Transaction transaction = transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID: " + id));

        if (request.getAmount() != null) {
            if (request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BadRequestException("Amount must be greater than zero");
            }
            transaction.setAmount(request.getAmount());
        }

        if (request.getCurrency() != null && !request.getCurrency().isBlank()) {
            transaction.setCurrency(request.getCurrency().toUpperCase());
        }

        if (request.getMerchantName() != null) {
            transaction.setMerchantName(request.getMerchantName());
        }

        if (request.getCategory() != null) {
            transaction.setCategory(request.getCategory().isBlank() ? "Others" : request.getCategory().trim());
        }

        if (request.getDescription() != null) {
            transaction.setDescription(request.getDescription());
        }

        if (request.getPaymentMethod() != null) {
            transaction.setPaymentMethod(request.getPaymentMethod());
        }

        if (request.getProvider() != null) {
            transaction.setProvider(request.getProvider());
        }

        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            transaction.setStatus(request.getStatus().trim().toUpperCase());
        }

        if (request.getUpiTransactionId() != null) {
            transaction.setUpiTransactionId(request.getUpiTransactionId());
        }

        if (request.getTransactionReference() != null) {
            transaction.setTransactionReference(request.getTransactionReference());
        }

        if (request.getUpiId() != null) {
            transaction.setUpiId(request.getUpiId());
        }

        if (request.getLatitude() != null) {
            transaction.setLatitude(request.getLatitude());
        }

        if (request.getLongitude() != null) {
            transaction.setLongitude(request.getLongitude());
        }

        if (request.getLocationAccuracyMeters() != null) {
            transaction.setLocationAccuracyMeters(request.getLocationAccuracyMeters());
        }

        if (request.getTransactionTime() != null) {
            transaction.setTransactionTime(request.getTransactionTime());
        }

        Transaction updated = transactionRepository.save(transaction);
        return TransactionResponse.fromEntity(updated);
    }

    @Transactional
    public void deleteTransaction(User user, UUID id) {
        Transaction transaction = transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID: " + id));
        transactionRepository.delete(transaction);
    }

    @Transactional
    public TransactionResponse reconcileTransaction(User user, UUID id, TransactionReconcileRequest request) {
        Transaction transaction = transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID: " + id));

        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            transaction.setStatus(request.getStatus().trim().toUpperCase());
        }
        if (request.getUpiTransactionId() != null && !request.getUpiTransactionId().isBlank()) {
            transaction.setUpiTransactionId(request.getUpiTransactionId());
        }
        if (request.getTransactionReference() != null && !request.getTransactionReference().isBlank()) {
            transaction.setTransactionReference(request.getTransactionReference());
        }

        Transaction saved = transactionRepository.save(transaction);
        log.info("Reconciled transaction {} to status {} for user {}", saved.getId(), saved.getStatus(), user.getId());
        return TransactionResponse.fromEntity(saved);
    }

    @Transactional
    public TransactionSmsVerificationResponse verifyTransactionSms(User user, UUID id, TransactionSmsVerificationRequest request) {
        Transaction transaction = transactionRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Transaction not found with ID: " + id));

        String curStatus = transaction.getStatus() != null ? transaction.getStatus().toUpperCase() : "";
        if ("SUCCESS".equals(curStatus) || "CONFIRMED".equals(curStatus) || "COMPLETED".equals(curStatus)) {
            return TransactionSmsVerificationResponse.builder()
                    .verified(true)
                    .status(transaction.getStatus())
                    .message("Payment is already confirmed")
                    .extractedAmount(transaction.getAmount())
                    .extractedUpiReference(transaction.getUpiTransactionId())
                    .transaction(TransactionResponse.fromEntity(transaction))
                    .build();
        }

        if ("FAILED".equals(curStatus) || "TIMEOUT".equals(curStatus) || "CANCELLED".equals(curStatus)) {
            return TransactionSmsVerificationResponse.builder()
                    .verified(true)
                    .status(transaction.getStatus())
                    .message("Payment was previously marked as " + transaction.getStatus())
                    .transaction(TransactionResponse.fromEntity(transaction))
                    .build();
        }

        ParsedTransactionSms parsed = smsParserService.parse(request.getSmsBody());
        TransactionSmsParserService.VerificationMatchResult matchResult = smsParserService.matchTransactionWithSms(transaction, parsed);

        if (!matchResult.matched()) {
            log.info("SMS verification non-match for transaction {}: {}", id, matchResult.details());
            return TransactionSmsVerificationResponse.builder()
                    .verified(false)
                    .status(transaction.getStatus())
                    .message(matchResult.details())
                    .extractedAmount(parsed.getAmount())
                    .extractedUpiReference(parsed.getUpiReference())
                    .transaction(TransactionResponse.fromEntity(transaction))
                    .build();
        }

        if (matchResult.isFailure()) {
            transaction.setStatus("FAILED");
            Transaction saved = transactionRepository.save(transaction);
            return TransactionSmsVerificationResponse.builder()
                    .verified(true)
                    .status("FAILED")
                    .message(matchResult.details())
                    .extractedAmount(parsed.getAmount())
                    .extractedUpiReference(parsed.getUpiReference())
                    .transaction(TransactionResponse.fromEntity(saved))
                    .build();
        }

        transaction.setStatus("SUCCESS");
        if (parsed.getUpiReference() != null && !parsed.getUpiReference().isBlank()) {
            transaction.setUpiTransactionId(parsed.getUpiReference());
        }

        Transaction saved = transactionRepository.save(transaction);
        log.info("SMS verified transaction {} as SUCCESS for user {}", saved.getId(), user.getId());
        return TransactionSmsVerificationResponse.builder()
                .verified(true)
                .status("SUCCESS")
                .message("Payment verified successfully via SMS")
                .extractedAmount(parsed.getAmount())
                .extractedUpiReference(parsed.getUpiReference())
                .transaction(TransactionResponse.fromEntity(saved))
                .build();
    }
}


