package com.hulypay.backend.Controllers;

import com.hulypay.backend.RequestDto.*;
import com.hulypay.backend.ResponseDto.*;
import com.hulypay.backend.Models.User;
import com.hulypay.backend.Services.TransactionService;
import com.hulypay.backend.Services.UserService;
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
@RequestMapping("/api/v1/transactions")
@RequiredArgsConstructor
public class TransactionController {

    private final TransactionService transactionService;
    private final UserService userService;

    @PostMapping
    public ResponseEntity<TransactionResponse> createTransaction(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreateTransactionRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        TransactionResponse response = transactionService.createTransaction(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<TransactionResponse>> getTransactions(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(transactionService.getTransactionsForUser(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<TransactionResponse> getTransactionById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(transactionService.getTransactionById(user, id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TransactionResponse> updateTransaction(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody UpdateTransactionRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(transactionService.updateTransaction(user, id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTransaction(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        transactionService.deleteTransaction(user, id);
        return ResponseEntity.noContent().build();
    }

    @PutMapping("/{id}/reconcile")
    public ResponseEntity<TransactionResponse> reconcileTransaction(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody TransactionReconcileRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        TransactionResponse response = transactionService.reconcileTransaction(user, id, request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/{id}/sms-verification")
    public ResponseEntity<TransactionSmsVerificationResponse> verifyTransactionSms(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody TransactionSmsVerificationRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        TransactionSmsVerificationResponse response = transactionService.verifyTransactionSms(user, id, request);
        return ResponseEntity.ok(response);
    }
}


