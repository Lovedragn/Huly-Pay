package com.hulypay.backend.Controllers;

import com.hulypay.backend.RequestDto.UpdateUserRequest;
import com.hulypay.backend.ResponseDto.UserResponse;
import com.hulypay.backend.Models.User;
import com.hulypay.backend.Services.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.syncUserFromJwt(jwt);
        return ResponseEntity.ok(UserResponse.fromEntity(user));
    }

    @PutMapping("/me")
    public ResponseEntity<UserResponse> updateCurrentUser(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody UpdateUserRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        User updated = userService.updateProfile(user, request);
        return ResponseEntity.ok(UserResponse.fromEntity(updated));
    }
}


