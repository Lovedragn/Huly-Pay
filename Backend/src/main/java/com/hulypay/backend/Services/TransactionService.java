package com.hulypay.backend.Services;

import com.hulypay.backend.Exceptions.BadRequestException;
import com.hulypay.backend.Exceptions.ResourceNotFoundException;
import com.hulypay.backend.Models.*;
import com.hulypay.backend.Repositories.*;
import com.hulypay.backend.RequestDto.*;
import com.hulypay.backend.ResponseDto.*;
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
    private final MerchantRepository merchantRepository;
    private final CategoryRepository categoryRepository;
    private final CurrencyRepository currencyRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final TransactionSmsParserService smsParserService;

    @Transactional
    public TransactionResponse createTransaction(User user, CreateTransactionRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Amount must be greater than zero");
        }

        String currency = (request.getCurrency() != null && !request.getCurrency().isBlank())
                ? request.getCurrency().trim().toUpperCase()
                : "INR";
        ensureCurrencyExists(currency);

        String category = (request.getCategory() != null && !request.getCategory().isBlank())
                ? request.getCategory().trim()
                : "Others";
        ensureCategoryExists(category);

        String statusStr = (request.getStatus() != null && !request.getStatus().isBlank())
                ? request.getStatus().trim().toUpperCase()
                : "SUCCESS";
        short statusCode = TransactionStatusEnum.toCode(statusStr);

        String rawMerchant = request.getMerchantName();
        String derivedMerchant = (rawMerchant != null && !rawMerchant.isBlank())
                ? rawMerchant.trim()
                : (request.getUpiId() != null && !request.getUpiId().isBlank() ? formatMerchantFromUpi(request.getUpiId().trim()) : null);

        Merchant merchant = resolveMerchant(derivedMerchant);

        String txnRef = request.getTransactionReference();
        if (txnRef == null || txnRef.isBlank()) {
            txnRef = "REF_" + System.currentTimeMillis();
        }

        ensurePaymentMethodExists(request.getPaymentMethod(), request.getProvider());

        Instant txTime = request.getTransactionTime() != null ? request.getTransactionTime() : Instant.now();

        Transaction transaction = Transaction.builder()
                .user(user)
                .amount(request.getAmount())
                .currencyCode(currency)
                .merchant(merchant)
                .merchantName(derivedMerchant != null ? derivedMerchant : (merchant != null ? merchant.getName() : null))
                .categoryName(category)
                .description(request.getDescription())
                .paymentMethod(request.getPaymentMethod())
                .provider(request.getProvider())
                .status(statusStr)
                .statusCode(statusCode)
                .upiTransactionId(request.getUpiTransactionId())
                .transactionReference(txnRef)
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
            String curr = request.getCurrency().trim().toUpperCase();
            ensureCurrencyExists(curr);
            transaction.setCurrencyCode(curr);
        }

        if (request.getMerchantName() != null) {
            if (request.getMerchantName().isBlank()) {
                transaction.setMerchant(null);
                transaction.setMerchantName(null);
            } else {
                String clean = request.getMerchantName().trim();
                transaction.setMerchant(resolveMerchant(clean));
                transaction.setMerchantName(clean);
            }
        }

        if (request.getCategory() != null) {
            String cat = request.getCategory().isBlank() ? "Others" : request.getCategory().trim();
            ensureCategoryExists(cat);
            transaction.setCategoryName(cat);
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

        if (transaction.getPaymentMethod() != null && transaction.getProvider() != null) {
            ensurePaymentMethodExists(transaction.getPaymentMethod(), transaction.getProvider());
        }

        if (request.getStatus() != null && !request.getStatus().isBlank()) {
            transaction.setStatus(request.getStatus());
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
            transaction.setStatus(request.getStatus());
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

    public static String formatMerchantFromUpi(String upiId) {
        if (upiId == null || upiId.isBlank()) return "UPI Merchant";
        String trimmed = upiId.trim();
        if (trimmed.contains("@")) {
            String handle = trimmed.split("@")[0].trim();
            if (handle.isBlank()) return "UPI Merchant";
            if (handle.matches("\\d+")) {
                return "Merchant (" + handle + ")";
            }
            String cleaned = handle.replaceAll("[._\\-+]", " ").trim();
            if (cleaned.isBlank()) return "UPI Merchant";
            StringBuilder sb = new StringBuilder();
            for (String word : cleaned.split("\\s+")) {
                if (!word.isBlank()) {
                    if (sb.length() > 0) sb.append(" ");
                    sb.append(Character.toUpperCase(word.charAt(0)))
                      .append(word.substring(1).toLowerCase());
                }
            }
            return sb.toString();
        }
        return trimmed;
    }

    private Merchant resolveMerchant(String merchantName) {
        if (merchantName == null || merchantName.isBlank()) {
            return null;
        }
        String clean = merchantName.trim();
        return merchantRepository.findByNameIgnoreCase(clean)
                .orElseGet(() -> merchantRepository.save(Merchant.builder().name(clean).build()));
    }

    private void ensureCurrencyExists(String currencyCode) {
        if (currencyCode != null && !currencyCode.isBlank()) {
            String code = currencyCode.trim().toUpperCase();
            if (!currencyRepository.existsById(code)) {
                currencyRepository.save(Currency.builder().code(code).symbol(code).build());
            }
        }
    }

    private void ensureCategoryExists(String categoryName) {
        if (categoryName != null && !categoryName.isBlank()) {
            String name = categoryName.trim();
            if (!categoryRepository.existsById(name)) {
                categoryRepository.save(Category.builder().name(name).build());
            }
        }
    }

    private void ensurePaymentMethodExists(String method, String provider) {
        if (method != null && !method.isBlank() && provider != null && !provider.isBlank()) {
            PaymentMethodId id = PaymentMethodId.builder()
                    .method(method.trim())
                    .provider(provider.trim())
                    .build();
            if (!paymentMethodRepository.existsById(id)) {
                paymentMethodRepository.save(PaymentMethod.builder().id(id).build());
            }
        }
    }
}
