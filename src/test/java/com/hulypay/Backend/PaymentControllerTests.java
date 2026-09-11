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
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class PaymentControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void createPaymentAndVerifyScoping() throws Exception {
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
                                  "provider": "PHONEPE",
                                  "upiTransactionId": "UPI1234567890"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(500.00))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.upiTransactionId").value("UPI1234567890"))
                .andReturn();

        String paymentId = JsonPath.read(result.getResponse().getContentAsString(), "$.id");

        // User A retrieves it
        mockMvc.perform(get("/api/v1/payments/" + paymentId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(paymentId));

        // User B cannot access User A's payment
        mockMvc.perform(get("/api/v1/payments/" + paymentId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isNotFound());
    }
}
