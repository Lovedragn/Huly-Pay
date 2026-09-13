package com.hulypay.backend;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import com.hulypay.backend.payments.PaymentService;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class PaymentControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private PaymentService paymentService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    void createPaymentWithLocationAndVerifyScoping() throws Exception {
        UUID userA = UUID.randomUUID();
        UUID userB = UUID.randomUUID();
        String emailA = "payA-" + userA + "@hulypay.com";
        String emailB = "payB-" + userB + "@hulypay.com";

        MvcResult result = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 500.00,
                                  "currency": "INR",
                                  "merchantName": "Cafe Coffee",
                                  "upiId": "cafecoffee@okaxis",
                                  "paymentMethod": "GPAY",
                                  "transactionReference": "TXN_REF_9988",
                                  "provider": "GOOGLE_PAY",
                                  "upiTransactionId": "UPI1234567890",
                                  "latitude": 12.9716,
                                  "longitude": 77.5946,
                                  "locationAccuracyMeters": 4.5
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(500.00))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.upiId").value("cafecoffee@okaxis"))
                .andExpect(jsonPath("$.paymentMethod").value("GPAY"))
                .andExpect(jsonPath("$.transactionReference").value("TXN_REF_9988"))
                .andExpect(jsonPath("$.latitude").value(12.9716))
                .andExpect(jsonPath("$.longitude").value(77.5946))
                .andExpect(jsonPath("$.locationAccuracyMeters").value(4.5))
                .andReturn();

        String paymentId = JsonPath.read(result.getResponse().getContentAsString(), "$.id");

        // User A retrieves it
        mockMvc.perform(get("/api/v1/payments/" + paymentId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(paymentId))
                .andExpect(jsonPath("$.latitude").value(12.9716))
                .andExpect(jsonPath("$.longitude").value(77.5946));

        // User B cannot access User A's payment
        mockMvc.perform(get("/api/v1/payments/" + paymentId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isNotFound());
    }

    @Test
    void createPaymentValidatesAmount() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "val-" + userId + "@hulypay.com";

        mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": -50.00,
                                  "currency": "INR",
                                  "merchantName": "Bad Payment"
                                }
                                """))
                .andExpect(status().isBadRequest());
    }

    @Test
    void reconcilePaymentLifecycleAndVerifyExpenseLinking() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "reconcile-" + userId + "@hulypay.com";

        MvcResult createResult = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 250.00,
                                  "currency": "INR",
                                  "merchantName": "ABC Store",
                                  "upiId": "abcstore@upi",
                                  "paymentMethod": "GOOGLE_PAY",
                                  "latitude": 13.082680,
                                  "longitude": 80.270718,
                                  "locationAccuracyMeters": 8.5
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("INITIATED"))
                .andReturn();

        String paymentId = JsonPath.read(createResult.getResponse().getContentAsString(), "$.id");

        // Reconcile to CONFIRMED
        mockMvc.perform(put("/api/v1/payments/" + paymentId + "/reconcile")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "CONFIRMED",
                                  "upiTransactionId": "UPI_CONFIRMED_9988",
                                  "transactionReference": "REF_CONFIRMED_77"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(paymentId))
                .andExpect(jsonPath("$.status").value("CONFIRMED"))
                .andExpect(jsonPath("$.paymentStatus").value("CONFIRMED"))
                .andExpect(jsonPath("$.expenseId").isNotEmpty())
                .andExpect(jsonPath("$.upiTransactionId").value("UPI_CONFIRMED_9988"))
                .andExpect(jsonPath("$.latitude").value(13.082680))
                .andExpect(jsonPath("$.longitude").value(80.270718));

        // Verify GET /api/v1/payments/{id} returns matching details
        mockMvc.perform(get("/api/v1/payments/" + paymentId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.paymentStatus").value("CONFIRMED"))
                .andExpect(jsonPath("$.merchantName").value("ABC Store"));
    }

    @Test
    void stalePaymentsCleanupDeletesOldInitiatedAndPending() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "stale-clean-" + userId + "@hulypay.com";

        // 1. Create INITIATED payment (will be aged to 35 min ago)
        MvcResult resStaleInit = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 110.00,
                                  "currency": "INR",
                                  "merchantName": "Stale Initiated Store"
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn();
        String staleInitId = JsonPath.read(resStaleInit.getResponse().getContentAsString(), "$.id");

        // 2. Create FRESH INITIATED payment (will be aged to 5 min ago)
        MvcResult resFreshInit = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 120.00,
                                  "currency": "INR",
                                  "merchantName": "Fresh Initiated Store"
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn();
        String freshInitId = JsonPath.read(resFreshInit.getResponse().getContentAsString(), "$.id");

        // 3. Create PENDING payment (will be aged to 26 hours ago)
        MvcResult resStalePending = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 210.00,
                                  "currency": "INR",
                                  "merchantName": "Stale Pending Store",
                                  "upiTransactionId": "UPI_STALE_PENDING"
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn();
        String stalePendingId = JsonPath.read(resStalePending.getResponse().getContentAsString(), "$.id");

        // 4. Create FRESH PENDING payment (will be aged to 2 hours ago)
        MvcResult resFreshPending = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 220.00,
                                  "currency": "INR",
                                  "merchantName": "Fresh Pending Store",
                                  "upiTransactionId": "UPI_FRESH_PENDING"
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn();
        String freshPendingId = JsonPath.read(resFreshPending.getResponse().getContentAsString(), "$.id");

        // 5. Create and reconcile CONFIRMED payment (will be aged to 3 days ago, should NEVER be deleted)
        MvcResult resConfirmed = mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 350.00,
                                  "currency": "INR",
                                  "merchantName": "Confirmed Store"
                                }
                                """))
                .andExpect(status().isCreated())
                .andReturn();
        String confirmedId = JsonPath.read(resConfirmed.getResponse().getContentAsString(), "$.id");

        mockMvc.perform(put("/api/v1/payments/" + confirmedId + "/reconcile")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "status": "CONFIRMED",
                                  "upiTransactionId": "UPI_CONF_1"
                                }
                                """))
                .andExpect(status().isOk());

        // Set created_at timestamps
        Instant time35mAgo = Instant.now().minus(35, ChronoUnit.MINUTES);
        jdbcTemplate.update("UPDATE payments SET created_at = ? WHERE id = ?", java.sql.Timestamp.from(time35mAgo), UUID.fromString(staleInitId));

        Instant time5mAgo = Instant.now().minus(5, ChronoUnit.MINUTES);
        jdbcTemplate.update("UPDATE payments SET created_at = ? WHERE id = ?", java.sql.Timestamp.from(time5mAgo), UUID.fromString(freshInitId));

        Instant time26hAgo = Instant.now().minus(26, ChronoUnit.HOURS);
        jdbcTemplate.update("UPDATE payments SET created_at = ? WHERE id = ?", java.sql.Timestamp.from(time26hAgo), UUID.fromString(stalePendingId));

        Instant time2hAgo = Instant.now().minus(2, ChronoUnit.HOURS);
        jdbcTemplate.update("UPDATE payments SET created_at = ? WHERE id = ?", java.sql.Timestamp.from(time2hAgo), UUID.fromString(freshPendingId));

        Instant time3dAgo = Instant.now().minus(3, ChronoUnit.DAYS);
        jdbcTemplate.update("UPDATE payments SET created_at = ? WHERE id = ?", java.sql.Timestamp.from(time3dAgo), UUID.fromString(confirmedId));

        // Trigger cleanup
        paymentService.cleanupStalePayments();

        // Stale initiated (>30m) must be deleted
        mockMvc.perform(get("/api/v1/payments/" + staleInitId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isNotFound());

        // Stale pending (>1d) must be deleted
        mockMvc.perform(get("/api/v1/payments/" + stalePendingId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isNotFound());

        // Fresh initiated (<30m) must be preserved
        mockMvc.perform(get("/api/v1/payments/" + freshInitId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk());

        // Fresh pending (<1d) must be preserved
        mockMvc.perform(get("/api/v1/payments/" + freshPendingId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk());

        // Confirmed must be preserved regardless of age
        mockMvc.perform(get("/api/v1/payments/" + confirmedId)
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CONFIRMED"));
    }
}
