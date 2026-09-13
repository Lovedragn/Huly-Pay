package com.hulypay.backend.payments;

import com.hulypay.backend.payments.dto.CreatePaymentRequest;
import com.hulypay.backend.payments.dto.PaymentResponse;
import com.hulypay.backend.payments.dto.ReconcilePaymentRequest;
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
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final UserService userService;

    @PostMapping
    public ResponseEntity<PaymentResponse> createPayment(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CreatePaymentRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        PaymentResponse response = paymentService.createPayment(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping
    public ResponseEntity<List<PaymentResponse>> getPayments(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(paymentService.getPaymentsForUser(user));
    }

    @GetMapping("/{id}")
    public ResponseEntity<PaymentResponse> getPaymentById(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(paymentService.getPaymentById(user, id));
    }

    @PutMapping("/{id}/reconcile")
    public ResponseEntity<PaymentResponse> reconcilePayment(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody ReconcilePaymentRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        PaymentResponse response = paymentService.reconcilePayment(user, id, request);
        return ResponseEntity.ok(response);
    }
}
