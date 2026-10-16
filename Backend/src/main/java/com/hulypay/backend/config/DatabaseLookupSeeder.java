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
                "USD", "$"
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
                "Shopping",
                "Bills & Utilities",
                "Travel & Transport",
                "Health & Medical",
                "Investments",
                "Unwanted Expenses",
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
        List<String> statuses = List.of("CONFIRMED", "PENDING");
        for (String statusName : statuses) {
            try {
                if (!statusRepository.existsById(statusName)) {
                    statusRepository.save(TransactionStatusEntity.builder()
                            .name(statusName)
                            .build());
                }
            } catch (Exception e) {
                log.warn("Notice seeding status {}: {}", statusName, e.getMessage());
            }
        }
        try {
            statusRepository.findAll().forEach(s -> {
                if (!statuses.contains(s.getName())) {
                    try {
                        statusRepository.delete(s);
                    } catch (Exception ignored) {}
                }
            });
        } catch (Exception ignored) {}
    }

    private void seedPaymentMethods() {
        List<String> providers = List.of(
                "GOOGLE_PAY",
                "BHIM",
                "AMAZON_PAY",
                "PHONEPE",
                "PAYTM",
                "WHATSAPP_PAY",
                "UPI",
                "CASH",
                "NET_BANKING"
        );

        for (String provider : providers) {
            try {
                if (!paymentMethodRepository.existsById(provider)) {
                    paymentMethodRepository.save(PaymentMethod.builder().name(provider).build());
                }
            } catch (Exception e) {
                log.debug("Skipping payment method {}: {}", provider, e.getMessage());
            }
        }

        try {
            // Remove legacy 'GPAY' / 'GPay' from payment_methods if it exists
            paymentMethodRepository.findAll().forEach(pm -> {
                if ("GPAY".equalsIgnoreCase(pm.getName())) {
                    try {
                        paymentMethodRepository.delete(pm);
                    } catch (Exception ignored) {}
                }
            });
        } catch (Exception ignored) {}
    }
}
