package com.hulypay.backend.expenses;

import com.hulypay.backend.expenses.dto.CreateExpenseRequest;
import com.hulypay.backend.expenses.dto.ExpenseResponse;
import com.hulypay.backend.expenses.dto.UpdateExpenseRequest;
import com.hulypay.backend.users.User;
import com.hulypay.backend.users.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/expenses")
@RequiredArgsConstructor
public class ExpenseController {

    private final ExpenseService expenseService;
    private final UserService userService;

    @PostMapping
    public ResponseEntity<ExpenseResponse> createExpense(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreateExpenseRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        ExpenseResponse response = expenseService.createExpense(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<ExpenseResponse>> getExpenses(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(expenseService.getExpensesForUser(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ExpenseResponse> getExpenseById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(expenseService.getExpenseById(user, id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ExpenseResponse> updateExpense(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateExpenseRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(expenseService.updateExpense(user, id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteExpense(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        expenseService.deleteExpense(user, id);
        return ResponseEntity.noContent().build();
    }
}
