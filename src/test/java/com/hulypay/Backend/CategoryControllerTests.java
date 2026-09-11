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
class CategoryControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private CategoryRepository categoryRepository;

    @Test
    void defaultCategoriesAreReturned() throws Exception {
        UUID userId = UUID.randomUUID();

        mockMvc.perform(get("/api/v1/categories")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", "cat-" + userId + "@hulypay.com"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[?(@.name == 'Food')].default").value(true));
    }

    @Test
    void userCanCreateCustomCategoryAndItIsIsolated() throws Exception {
        UUID userA = UUID.randomUUID();
        UUID userB = UUID.randomUUID();
        String emailA = "userA-" + userA + "@hulypay.com";
        String emailB = "userB-" + userB + "@hulypay.com";

        MvcResult result = mockMvc.perform(post("/api/v1/categories")
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "UserA Custom Hobby",
                                  "icon": "palette",
                                  "color": "#FF5733"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.name").value("UserA Custom Hobby"))
                .andExpect(jsonPath("$.default").value(false))
                .andReturn();

        String responseContent = result.getResponse().getContentAsString();
        String customCatId = JsonPath.read(responseContent, "$.id");

        // User B cannot see User A's custom category
        mockMvc.perform(get("/api/v1/categories")
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[?(@.name == 'UserA Custom Hobby')]").doesNotExist());

        // User B cannot delete User A's category
        mockMvc.perform(delete("/api/v1/categories/" + customCatId)
                        .with(jwt().jwt(jwt -> jwt.subject(userB.toString()).claim("email", emailB))))
                .andExpect(status().isNotFound());

        // User A can delete their category
        mockMvc.perform(delete("/api/v1/categories/" + customCatId)
                        .with(jwt().jwt(jwt -> jwt.subject(userA.toString()).claim("email", emailA))))
                .andExpect(status().isNoContent());
    }

    @Test
    void cannotModifyDefaultCategory() throws Exception {
        UUID userId = UUID.randomUUID();
        Category defaultCat = categoryRepository.findByIsDefaultTrue().get(0);

        mockMvc.perform(put("/api/v1/categories/" + defaultCat.getId())
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", "mod-" + userId + "@hulypay.com")))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "name": "Modified Default Name"
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("System default categories cannot be modified"));
    }
}
