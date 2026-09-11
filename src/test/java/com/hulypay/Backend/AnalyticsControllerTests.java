package com.hulypay.backend;

import com.hulypay.backend.categories.Category;
import com.hulypay.backend.categories.CategoryRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class AnalyticsControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private CategoryRepository categoryRepository;

    @Test
    void analyticsCalculatesDatabaseAggregationsAccurately() throws Exception {
        UUID user = UUID.randomUUID();
        String userEmail = "analytics-" + user + "@hulypay.com";
        Category food = categoryRepository.findByIsDefaultTrue().stream()
                .filter(c -> "Food".equalsIgnoreCase(c.getName()))
                .findFirst()
                .orElseThrow();
        Category travel = categoryRepository.findByIsDefaultTrue().stream()
                .filter(c -> "Travel".equalsIgnoreCase(c.getName()))
                .findFirst()
                .orElseThrow();

        // 1. User records Expense 1: 100.00 (Food)
        mockMvc.perform(post("/api/v1/expenses")
                .with(jwt().jwt(jwt -> jwt.subject(user.toString()).claim("email", userEmail)))
                .contentType(MediaType.APPLICATION_JSON)
                .content(String.format("""
                        {
                          "amount": 100.00,
                          "currency": "INR",
                          "merchantName": "Cafe",
                          "categoryId": "%s"
                        }
                        """, food.getId())));

        // 2. User records Expense 2: 200.00 (Travel)
        mockMvc.perform(post("/api/v1/expenses")
                .with(jwt().jwt(jwt -> jwt.subject(user.toString()).claim("email", userEmail)))
                .contentType(MediaType.APPLICATION_JSON)
                .content(String.format("""
                        {
                          "amount": 200.00,
                          "currency": "INR",
                          "merchantName": "Metro",
                          "categoryId": "%s"
                        }
                        """, travel.getId())));

        // Verify summary: totalSpent = 300.00, count = 2, avg = 150.00
        mockMvc.perform(get("/api/v1/analytics/summary")
                        .with(jwt().jwt(jwt -> jwt.subject(user.toString()).claim("email", userEmail))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalSpent").value(300.00))
                .andExpect(jsonPath("$.transactionCount").value(2))
                .andExpect(jsonPath("$.averageTransaction").value(150.00));

        // Verify category breakdown
        mockMvc.perform(get("/api/v1/analytics/category-breakdown")
                        .with(jwt().jwt(jwt -> jwt.subject(user.toString()).claim("email", userEmail))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[?(@.category == 'Travel')].totalAmount").value(200.00))
                .andExpect(jsonPath("$[?(@.category == 'Food')].totalAmount").value(100.00));

        // Verify another user has 0 analytics
        UUID otherUser = UUID.randomUUID();
        String otherEmail = "empty-" + otherUser + "@hulypay.com";
        mockMvc.perform(get("/api/v1/analytics/summary")
                        .with(jwt().jwt(jwt -> jwt.subject(otherUser.toString()).claim("email", otherEmail))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalSpent").value(0.00))
                .andExpect(jsonPath("$.transactionCount").value(0));
    }
}
