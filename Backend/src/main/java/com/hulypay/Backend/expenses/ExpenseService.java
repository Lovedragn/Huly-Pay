package com.hulypay.backend.expenses;

import com.hulypay.backend.categories.Category;
import com.hulypay.backend.categories.CategoryService;
import com.hulypay.backend.common.exception.BadRequestException;
import com.hulypay.backend.common.exception.ResourceNotFoundException;
import com.hulypay.backend.expenses.dto.CreateExpenseRequest;
import com.hulypay.backend.expenses.dto.ExpenseResponse;
import com.hulypay.backend.expenses.dto.UpdateExpenseRequest;
import com.hulypay.backend.users.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final CategoryService categoryService;

    @Transactional
    public ExpenseResponse createExpense(User user, CreateExpenseRequest request) {
        if (request.getAmount() == null || request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new BadRequestException("Amount must be greater than zero");
        }

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryService.getValidCategory(request.getCategoryId(), user);
        }

        Instant txTime = request.getTransactionTime() != null ? request.getTransactionTime() : Instant.now();
        String currency = (request.getCurrency() != null && !request.getCurrency().isBlank()) ? request.getCurrency().toUpperCase() : "INR";
        String paymentMethod = (request.getPaymentMethod() != null && !request.getPaymentMethod().isBlank()) ? request.getPaymentMethod() : "UPI";

        Expense expense = Expense.builder()
                .user(user)
                .amount(request.getAmount())
                .currency(currency)
                .merchantName(request.getMerchantName())
                .category(category)
                .description(request.getDescription())
                .transactionTime(txTime)
                .paymentMethod(paymentMethod)
                .upiTransactionId(request.getUpiTransactionId())
                .status("COMPLETED")
                .latitude(request.getLatitude())
                .longitude(request.getLongitude())
                .build();

        Expense saved = expenseRepository.save(expense);
        return ExpenseResponse.fromEntity(saved);
    }

    @Transactional(readOnly = true)
    public List<ExpenseResponse> getExpensesForUser(User user) {
        return expenseRepository.findByUserIdOrderByTransactionTimeDesc(user.getId())
                .stream()
                .map(ExpenseResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public ExpenseResponse getExpenseById(User user, UUID id) {
        Expense expense = expenseRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with ID: " + id));
        return ExpenseResponse.fromEntity(expense);
    }

    @Transactional
    public ExpenseResponse updateExpense(User user, UUID id, UpdateExpenseRequest request) {
        Expense expense = expenseRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with ID: " + id));

        if (request.getAmount() != null) {
            if (request.getAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new BadRequestException("Amount must be greater than zero");
            }
            expense.setAmount(request.getAmount());
        }

        if (request.getCurrency() != null && !request.getCurrency().isBlank()) {
            expense.setCurrency(request.getCurrency().toUpperCase());
        }

        if (request.getMerchantName() != null) {
            expense.setMerchantName(request.getMerchantName());
        }

        if (request.getCategoryId() != null) {
            Category category = categoryService.getValidCategory(request.getCategoryId(), user);
            expense.setCategory(category);
        }

        if (request.getDescription() != null) {
            expense.setDescription(request.getDescription());
        }

        if (request.getTransactionTime() != null) {
            expense.setTransactionTime(request.getTransactionTime());
        }

        if (request.getPaymentMethod() != null) {
            expense.setPaymentMethod(request.getPaymentMethod());
        }

        if (request.getUpiTransactionId() != null) {
            expense.setUpiTransactionId(request.getUpiTransactionId());
        }

        if (request.getStatus() != null) {
            expense.setStatus(request.getStatus());
        }

        if (request.getLatitude() != null) {
            expense.setLatitude(request.getLatitude());
        }

        if (request.getLongitude() != null) {
            expense.setLongitude(request.getLongitude());
        }

        Expense updated = expenseRepository.save(expense);
        return ExpenseResponse.fromEntity(updated);
    }

    @Transactional
    public void deleteExpense(User user, UUID id) {
        Expense expense = expenseRepository.findByIdAndUserId(id, user.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Expense not found with ID: " + id));
        expenseRepository.delete(expense);
    }
}
