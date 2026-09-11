package com.hulypay.backend;

import com.hulypay.backend.categories.Category;
import com.hulypay.backend.categories.CategoryRepository;
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

    @Autowired
    private CategoryRepository categoryRepository;

    @Test
    void createExpenseValidatesAmountGreaterThanZero() throws Exception {
        UUID userId = UUID.randomUUID();

        // Amount zero or negative
        mockMvc.perform(post("/api/v1/expenses")
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
    void expenseCrudAndUserIsolation() throws Exception {
        UUID userA = UUID.randomUUID();
        UUID userB = UUID.randomUUID();
        String emailA = "userA-" + userA + "@hulypay.com";
        String emailB = "userB-" + userB + "@hulypay.com";
        Category foodCategory = categoryRepository.findByIsDefaultTrue().stream()
                .filter(c -> "Food".equalsIgnoreCase(c.getName()))
                .findFirst()
                .orElseThrow();

        // 1. User A creates an expense
        MvcResult postResult = mockMvc.perform(post("/api/v1/expenses")
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(String.format("""
                                {
                                  "amount": 250.50,
                                  "currency": "INR",
                                  "merchantName": "ABC Grocery Store",
                                  "categoryId": "%s",
                                  "description": "Weekly grocery run",
                                  "paymentMethod": "UPI"
                                }
                                """, foodCategory.getId())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.amount").value(250.50))
                .andExpect(jsonPath("$.merchantName").value("ABC Grocery Store"))
                .andExpect(jsonPath("$.category.name").value("Food"))
                .andReturn();

        String responseContent = postResult.getResponse().getContentAsString();
        String expenseAId = JsonPath.read(responseContent, "$.id");

        // 2. User A retrieves expense by ID
        mockMvc.perform(get("/api/v1/expenses/" + expenseAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(expenseAId))
                .andExpect(jsonPath("$.amount").value(250.50));

        // 3. User B tries to view User A's expense by ID -> 404 (isolation)
        mockMvc.perform(get("/api/v1/expenses/" + expenseAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isNotFound());

        // 4. User B lists their expenses -> User A's expense is NOT present
        mockMvc.perform(get("/api/v1/expenses")
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.id == '" + expenseAId + "')]").doesNotExist());

        // 5. User B tries to update User A's expense -> 404
        mockMvc.perform(put("/api/v1/expenses/" + expenseAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 999.00
                                }
                                """))
                .andExpect(status().isNotFound());

        // 6. User A updates their expense
        mockMvc.perform(put("/api/v1/expenses/" + expenseAId)
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

        // 7. User A deletes their expense
        mockMvc.perform(delete("/api/v1/expenses/" + expenseAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isNoContent());

        // 8. User A verifies expense is deleted
        mockMvc.perform(get("/api/v1/expenses/" + expenseAId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isNotFound());
    }
}
