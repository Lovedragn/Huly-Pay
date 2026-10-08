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
class NewSchemaDesignEndpointTests {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void testAllHealthAndInfoEndpoints() throws Exception {
        mockMvc.perform(get("/"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));

        mockMvc.perform(get("/api/health"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));

        mockMvc.perform(get("/api/health/database"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("UP"));
    }

    @Test
    void testSchemaCurrenciesInrAndUsdWorkflow() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "schema-curr-" + userId + "@hulypay.com";

        // 1. Create INR transaction with code
        MvcResult inrResult = mockMvc.perform(post("/api/v1/transactions")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 750.00,
                                  "currency": "INR",
                                  "merchantName": "Reliance Retail",
                                  "category": "Groceries",
                                  "paymentMethod": "UPI",
                                  "provider": "GOOGLE_PAY",
                                  "status": "SUCCESS"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.currency").value("INR"))
                .andExpect(jsonPath("$.currencySymbol").value("₹"))
                .andExpect(jsonPath("$.merchantName").value("Reliance Retail"))
                .andExpect(jsonPath("$.category").value("Groceries"))
                .andExpect(jsonPath("$.paymentMethod").value("UPI"))
                .andExpect(jsonPath("$.provider").value("GOOGLE_PAY"))
                .andExpect(jsonPath("$.status").value("SUCCESS"))
                .andReturn();

        String inrTxId = JsonPath.read(inrResult.getResponse().getContentAsString(), "$.id");

        // 2. Create USD transaction with symbol "$"
        MvcResult usdResult = mockMvc.perform(post("/api/v1/transactions")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 49.99,
                                  "currency": "$",
                                  "merchantName": "Steam Games",
                                  "category": "Entertainment",
                                  "paymentMethod": "CREDIT_CARD",
                                  "provider": "BANK",
                                  "status": "CONFIRMED"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.currency").value("USD"))
                .andExpect(jsonPath("$.currencySymbol").value("$"))
                .andExpect(jsonPath("$.merchantName").value("Steam Games"))
                .andExpect(jsonPath("$.category").value("Entertainment"))
                .andExpect(jsonPath("$.status").value("CONFIRMED"))
                .andReturn();

        String usdTxId = JsonPath.read(usdResult.getResponse().getContentAsString(), "$.id");

        // 3. Retrieve transactions by ID
        mockMvc.perform(get("/api/v1/transactions/" + inrTxId)
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("INR"))
                .andExpect(jsonPath("$.currencySymbol").value("₹"));

        mockMvc.perform(get("/api/v1/transactions/" + usdTxId)
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("USD"))
                .andExpect(jsonPath("$.currencySymbol").value("$"));

        // 4. Update USD transaction currency to ₹
        mockMvc.perform(put("/api/v1/transactions/" + usdTxId)
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "amount": 55.00,
                                  "currency": "₹"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currency").value("INR"))
                .andExpect(jsonPath("$.currencySymbol").value("₹"));

        // 5. Test analytics endpoints
        mockMvc.perform(get("/api/v1/analytics/summary")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.transactionCount").value(2));

        mockMvc.perform(get("/api/v1/analytics/category-breakdown")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());

        mockMvc.perform(get("/api/v1/analytics/daily-spending")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());

        mockMvc.perform(get("/api/v1/analytics/monthly-spending")
                        .with(jwt().jwt(j -> j.subject(userId.toString()).claim("email", email))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray());
    }
}
