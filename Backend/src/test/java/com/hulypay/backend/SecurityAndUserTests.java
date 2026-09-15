package com.hulypay.backend;

import com.hulypay.backend.users.User;
import com.hulypay.backend.users.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Map;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class SecurityAndUserTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Test
    void missingJwtReturns401OnProtectedEndpoint() throws Exception {
        mockMvc.perform(get("/api/v1/users/me"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void validJwtSyncsAndReturnsUser() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "test-" + userId + "@hulypay.com";

        mockMvc.perform(get("/api/v1/users/me")
                        .with(jwt().jwt(jwt -> jwt
                                .subject(userId.toString())
                                .claim("email", email)
                                .claim("user_metadata", Map.of("first_name", "Jane", "last_name", "Doe"))
                                .claim("app_metadata", Map.of("provider", "email"))
                        )))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(userId.toString()))
                .andExpect(jsonPath("$.email").value(email))
                .andExpect(jsonPath("$.firstName").value("Jane"))
                .andExpect(jsonPath("$.lastName").value("Doe"))
                .andExpect(jsonPath("$.authProvider").value("email"));

        // Verify database persistence
        Optional<User> persisted = userRepository.findById(userId);
        assertThat(persisted).isPresent();
        assertThat(persisted.get().getEmail()).isEqualTo(email);
        assertThat(persisted.get().getFirstName()).isEqualTo("Jane");
    }

    @Test
    void updateProfileModifiesUserSuccessfully() throws Exception {
        UUID userId = UUID.randomUUID();
        String email = "update-" + userId + "@hulypay.com";

        mockMvc.perform(get("/api/v1/users/me")
                .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email))));

        mockMvc.perform(put("/api/v1/users/me")
                        .with(jwt().jwt(jwt -> jwt.subject(userId.toString()).claim("email", email)))
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {
                                  "firstName": "UpdatedFirst",
                                  "lastName": "UpdatedLast"
                                }
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.firstName").value("UpdatedFirst"))
                .andExpect(jsonPath("$.lastName").value("UpdatedLast"));

        User user = userRepository.findById(userId).orElseThrow();
        assertThat(user.getFirstName()).isEqualTo("UpdatedFirst");
        assertThat(user.getLastName()).isEqualTo("UpdatedLast");
    }
}
