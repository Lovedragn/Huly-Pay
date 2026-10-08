package com.hulypay.backend.config;

import com.hulypay.backend.Models.*;
import com.hulypay.backend.Repositories.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Slf4j
@Component
@Order(1)
@RequiredArgsConstructor
public class DatabaseLookupSeeder implements CommandLineRunner {

    private final CurrencyRepository currencyRepository;
    private final CategoryRepository categoryRepository;
    private final TransactionStatusRepository statusRepository;
    private final PaymentMethodRepository paymentMethodRepository;

    @Override
    public void run(String... args) {
        try {
            seedCurrencies();
        } catch (Exception e) {
            log.warn("Could not seed currencies: {}", e.getMessage());
        }

        try {
            seedCategories();
        } catch (Exception e) {
            log.warn("Could not seed categories: {}", e.getMessage());
        }

        try {
            seedTransactionStatuses();
        } catch (Exception e) {
            log.warn("Could not seed transaction statuses: {}", e.getMessage());
        }

        try {
            seedPaymentMethods();
        } catch (Exception e) {
            log.warn("Could not seed payment methods: {}", e.getMessage());
        }
    }

    private void seedCurrencies() {
        Map<String, String> currencies = Map.of(
                "INR", "₹",
                "USD", "$",
                "EUR", "€",
                "GBP", "£",
                "JPY", "¥",
                "CAD", "CA$",
                "AUD", "AU$",
                "AED", "د.إ",
                "SGD", "S$"
        );

        currencies.forEach((code, symbol) -> {
            try {
                if (!currencyRepository.existsById(code)) {
                    currencyRepository.save(Currency.builder().code(code).symbol(symbol).build());
                }
            } catch (Exception e) {
                log.debug("Skipping currency {}: {}", code, e.getMessage());
            }
        });
    }

    private void seedCategories() {
        List<String> categories = List.of(
                "Food & Dining",
                "Groceries",
                "Shopping",
                "Bills & Utilities",
                "Entertainment",
                "Travel & Transport",
                "Health & Medical",
                "Education",
                "Investments",
                "Personal Care",
                "Others"
        );

        categories.forEach(name -> {
            try {
                if (!categoryRepository.existsById(name)) {
                    categoryRepository.save(Category.builder().name(name).build());
                }
            } catch (Exception e) {
                log.debug("Skipping category {}: {}", name, e.getMessage());
            }
        });
    }

    private void seedTransactionStatuses() {
        for (TransactionStatusEnum status : TransactionStatusEnum.values()) {
            try {
                if (!statusRepository.existsById(status.getCode())) {
                    statusRepository.save(TransactionStatusEntity.builder()
                            .code(status.getCode())
                            .name(status.getName())
                            .build());
                }
            } catch (Exception e) {
                log.debug("Skipping status {}: {}", status.getName(), e.getMessage());
            }
        }
    }

    private void seedPaymentMethods() {
        List<String[]> methods = List.of(
                new String[]{"UPI", "GOOGLE_PAY"},
                new String[]{"UPI", "PHONEPE"},
                new String[]{"UPI", "PAYTM"},
                new String[]{"UPI", "BHIM"},
                new String[]{"UPI", "AMAZON_PAY"},
                new String[]{"UPI", "CRED"},
                new String[]{"UPI", "UPI"},
                new String[]{"GPAY", "GOOGLE_PAY"},
                new String[]{"DEBIT_CARD", "BANK"},
                new String[]{"CREDIT_CARD", "BANK"},
                new String[]{"NET_BANKING", "BANK"},
                new String[]{"CASH", "MANUAL"},
                new String[]{"OTHER", "OTHER"}
        );

        for (String[] pair : methods) {
            try {
                PaymentMethodId id = PaymentMethodId.builder().method(pair[0]).provider(pair[1]).build();
                if (!paymentMethodRepository.existsById(id)) {
                    paymentMethodRepository.save(PaymentMethod.builder().id(id).build());
                }
            } catch (Exception e) {
                log.debug("Skipping payment method {}: {}", pair[0], e.getMessage());
            }
        }
    }
}
