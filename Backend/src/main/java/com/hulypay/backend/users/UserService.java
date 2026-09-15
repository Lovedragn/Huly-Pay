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

        String phoneNumber = jwt.getClaimAsString("phone");
        if (phoneNumber != null && phoneNumber.isBlank()) {
            phoneNumber = null;
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
        String fullName = null;

        Object userMetadataObj = jwt.getClaim("user_metadata");
        if (userMetadataObj instanceof Map<?, ?> userMetadata) {
            if (userMetadata.get("first_name") != null) {
                firstName = userMetadata.get("first_name").toString();
            }
            if (userMetadata.get("last_name") != null) {
                lastName = userMetadata.get("last_name").toString();
            }
            if (userMetadata.get("full_name") != null) {
                fullName = userMetadata.get("full_name").toString();
            } else if (userMetadata.get("name") != null) {
                fullName = userMetadata.get("name").toString();
            }
            if (userMetadata.get("avatar_url") != null) {
                avatarUrl = userMetadata.get("avatar_url").toString();
            } else if (userMetadata.get("picture") != null) {
                avatarUrl = userMetadata.get("picture").toString();
            }
            if (phoneNumber == null && userMetadata.get("phone") != null) {
                phoneNumber = userMetadata.get("phone").toString();
            }
        }

        // Derive fullName if not explicitly provided
        if (fullName == null || fullName.isBlank()) {
            if (firstName != null && !firstName.isBlank() && lastName != null && !lastName.isBlank()) {
                fullName = firstName + " " + lastName;
            } else if (firstName != null && !firstName.isBlank()) {
                fullName = firstName;
            } else if (lastName != null && !lastName.isBlank()) {
                fullName = lastName;
            } else {
                int atIndex = email.indexOf('@');
                fullName = atIndex > 0 ? email.substring(0, atIndex) : "User";
            }
        }

        // Derive firstName / lastName from fullName if missing
        if (firstName == null && fullName != null && !fullName.isBlank()) {
            String[] parts = fullName.trim().split("\\s+", 2);
            firstName = parts[0];
            if (parts.length > 1 && lastName == null) {
                lastName = parts[1];
            }
        }

        final String finalEmail = email;
        final String finalAuthProvider = authProvider;
        final String finalFirstName = firstName;
        final String finalLastName = lastName;
        final String finalFullName = fullName;
        final String finalPhoneNumber = phoneNumber;
        final String finalAvatarUrl = avatarUrl;

        return userRepository.findById(userId)
                .map(existingUser -> {
                    boolean modified = false;
                    if (existingUser.getEmail() == null || !existingUser.getEmail().equals(finalEmail)) {
                        existingUser.setEmail(finalEmail);
                        modified = true;
                    }
                    if (existingUser.getFullName() == null || existingUser.getFullName().isBlank()) {
                        existingUser.setFullName(finalFullName);
                        modified = true;
                    }
                    if (existingUser.getActive() == null) {
                        existingUser.setActive(true);
                        modified = true;
                    }
                    if (existingUser.getPhoneNumber() == null && finalPhoneNumber != null) {
                        existingUser.setPhoneNumber(finalPhoneNumber);
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
                            .fullName(finalFullName)
                            .firstName(finalFirstName)
                            .lastName(finalLastName)
                            .phoneNumber(finalPhoneNumber)
                            .active(true)
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
        if (request.getFirstName() != null || request.getLastName() != null) {
            String fn = user.getFirstName() != null ? user.getFirstName() : "";
            String ln = user.getLastName() != null ? user.getLastName() : "";
            String combined = (fn + " " + ln).trim();
            if (!combined.isEmpty()) {
                user.setFullName(combined);
            }
        }
        if (request.getAvatarUrl() != null) {
            user.setAvatarUrl(request.getAvatarUrl());
        }
        return userRepository.save(user);
    }
}
