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
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class ExpenseControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void createTransactionValidatesAmountGreaterThanZero() throws Exception {
        UUID userId = UUID.randomUUID();

        // Amount zero or negative
        mockMvc.perform(post("/api/v1/transactions")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", "val-" + userId + "@hulypay.com")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 0.00,
                                  "currency": "INR",
                                  "merchantName": "Bad Store"
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.message").value("Validation failed"))
                .andExpect(jsonPath("$.errors.amount").exists());
    }

    @Test
    void transactionCrudAndUserIsolation() throws Exception {
        UUID userA = UUID.randomUUID();
        UUID userB = UUID.randomUUID();
        String emailA = "userA-" + userA + "@hulypay.com";
        String emailB = "userB-" + userB + "@hulypay.com";

        // 1. User A creates a transaction
        MvcResult postResult = mockMvc.perform(post("/api/v1/transactions")
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 250.50,
                                  "currency": "INR",
                                  "merchantName": "ABC Grocery Store",
                                  "category": "Food",
                                  "description": "Weekly grocery run",
                                  "paymentMethod": "UPI"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(250.50))
                .andExpect(jsonPath("$.merchantName").value("ABC Grocery Store"))
                .andExpect(jsonPath("$.category").value("Food"))
                .andReturn();

        String responseContent = postResult.getResponse().getContentAsString();
        String transactionAId = JsonPath.read(responseContent, "$.id");

        // 2. User A retrieves transaction by ID
        mockMvc.perform(get("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(transactionAId))
                .andExpect(jsonPath("$.amount").value(250.50));

        // 3. User B tries to view User A's transaction by ID -> 404 (isolation)
        mockMvc.perform(get("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isNotFound());

        // 4. User B lists their transactions -> User A's transaction is NOT present
        mockMvc.perform(get("/api/v1/transactions")
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.id == '" + transactionAId + "')]").doesNotExist());

        // 5. User B tries to update User A's transaction -> 404
        mockMvc.perform(put("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 999.00
                                }
                                """))
                .andExpect(status().isNotFound());

        // 6. User A updates their transaction
        mockMvc.perform(put("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 300.00,
                                  "merchantName": "Updated ABC Store"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.amount").value(300.00))
                .andExpect(jsonPath("$.merchantName").value("Updated ABC Store"));

        // 7. User A deletes their transaction
        mockMvc.perform(delete("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isNoContent());

        // 8. User A verifies transaction is deleted
        mockMvc.perform(get("/api/v1/transactions/" + transactionAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isNotFound());
    }
}


