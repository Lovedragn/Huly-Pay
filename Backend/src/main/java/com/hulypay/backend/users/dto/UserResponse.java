package com.hulypay.backend.users.dto;

import com.hulypay.backend.users.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

    private UUID id;
    private String email;
    private String fullName;
    private String firstName;
    private String lastName;
    private String phoneNumber;
    private Boolean active;
    private String avatarUrl;
    private String authProvider;

    public static UserResponse fromEntity(User user) {
        if (user == null) {
            return null;
        }
        return UserResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phoneNumber(user.getPhoneNumber())
                .active(user.getActive())
                .avatarUrl(user.getAvatarUrl())
                .authProvider(user.getAuthProvider())
                .build();
    }
}
