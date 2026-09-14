package com.hulypay.backend;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

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
    void createDirectConfirmedPaymentAutoLinksExpense() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "direct-confirmed-" + userId + "@hulypay.com";

        mockMvc.perform(post("/api/v1/payments")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 350.00,
                                  "currency": "INR",
                                  "merchantName": "Direct Merchant",
                                  "upiId": "direct@upi",
                                  "paymentMethod": "UPI",
                                  "status": "CONFIRMED",
                                  "upiTransactionId": "UPI_DIRECT_12345",
                                  "transactionReference": "REF_DIRECT_99"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.status").value("CONFIRMED"))
                .andExpect(jsonPath("$.paymentStatus").value("CONFIRMED"))
                .andExpect(jsonPath("$.expenseId").isNotEmpty())
                .andExpect(jsonPath("$.upiTransactionId").value("UPI_DIRECT_12345"));
    }
}
