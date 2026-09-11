package com.hulypay.backend.users;

import com.hulypay.backend.users.dto.UpdateUserRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public User syncUserFromJwt(Jwt jwt) {
        String sub = jwt.getSubject();
        if (sub == null || sub.isBlank()) {
            throw new IllegalArgumentException("JWT subject claim (sub) is missing");
        }

        UUID userId = UUID.fromString(sub);
        String email = jwt.getClaimAsString("email");
        if (email == null || email.isBlank()) {
            email = "user-" + userId + "@hulypay.local";
        }

        String authProvider = "email";
        Object appMetadataObj = jwt.getClaim("app_metadata");
        if (appMetadataObj instanceof Map<?, ?> appMetadata) {
            Object provider = appMetadata.get("provider");
            if (provider != null) {
                authProvider = provider.toString();
            }
        }

        String firstName = null;
        String lastName = null;
        String avatarUrl = null;

        Object userMetadataObj = jwt.getClaim("user_metadata");
        if (userMetadataObj instanceof Map<?, ?> userMetadata) {
            if (userMetadata.get("first_name") != null) {
                firstName = userMetadata.get("first_name").toString();
            }
            if (userMetadata.get("last_name") != null) {
                lastName = userMetadata.get("last_name").toString();
            }
            if (firstName == null && userMetadata.get("full_name") != null) {
                String fullName = userMetadata.get("full_name").toString();
                String[] parts = fullName.trim().split("\\s+", 2);
                firstName = parts[0];
                if (parts.length > 1) {
                    lastName = parts[1];
                }
            }
            if (userMetadata.get("avatar_url") != null) {
                avatarUrl = userMetadata.get("avatar_url").toString();
            } else if (userMetadata.get("picture") != null) {
                avatarUrl = userMetadata.get("picture").toString();
            }
        }

        final String finalEmail = email;
        final String finalAuthProvider = authProvider;
        final String finalFirstName = firstName;
        final String finalLastName = lastName;
        final String finalAvatarUrl = avatarUrl;

        return userRepository.findById(userId)
                .map(existingUser -> {
                    boolean modified = false;
                    if (existingUser.getEmail() == null || !existingUser.getEmail().equals(finalEmail)) {
                        existingUser.setEmail(finalEmail);
                        modified = true;
                    }
                    if (existingUser.getFirstName() == null && finalFirstName != null) {
                        existingUser.setFirstName(finalFirstName);
                        modified = true;
                    }
                    if (existingUser.getLastName() == null && finalLastName != null) {
                        existingUser.setLastName(finalLastName);
                        modified = true;
                    }
                    if (existingUser.getAvatarUrl() == null && finalAvatarUrl != null) {
                        existingUser.setAvatarUrl(finalAvatarUrl);
                        modified = true;
                    }
                    if (existingUser.getAuthProvider() == null && finalAuthProvider != null) {
                        existingUser.setAuthProvider(finalAuthProvider);
                        modified = true;
                    }
                    return modified ? userRepository.save(existingUser) : existingUser;
                })
                .orElseGet(() -> {
                    log.info("Provisioning new user with ID: {} and email: {}", userId, finalEmail);
                    User newUser = User.builder()
                            .id(userId)
                            .email(finalEmail)
                            .firstName(finalFirstName)
                            .lastName(finalLastName)
                            .avatarUrl(finalAvatarUrl)
                            .authProvider(finalAuthProvider)
                            .providerSubject(sub)
                            .build();
                    return userRepository.saveAndFlush(newUser);
                });
    }

    @Transactional
    public User getUserFromJwt(Jwt jwt) {
        return syncUserFromJwt(jwt);
    }

    @Transactional
    public User updateProfile(User user, UpdateUserRequest request) {
        if (request.getFirstName() != null) {
            user.setFirstName(request.getFirstName());
        }
        if (request.getLastName() != null) {
            user.setLastName(request.getLastName());
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        return userRepository.save(user);
    }
}
