package com.hulypay.backend.categories;

import com.hulypay.backend.categories.dto.CategoryRequest;
import com.hulypay.backend.categories.dto.CategoryResponse;
import com.hulypay.backend.users.User;
import com.hulypay.backend.users.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;
    private final UserService userService;

    @GetMapping
    public ResponseEntity<List<CategoryResponse>> getCategories(@AuthenticationPrincipal Jwt jwt) {
        User user = userService.getUserFromJwt(jwt);
        return ResponseEntity.ok(categoryService.getCategoriesForUser(user));
    }

    @PostMapping
    public ResponseEntity<CategoryResponse> createCategory(
            @AuthenticationPrincipal Jwt jwt,
            @Valid @RequestBody CategoryRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        CategoryResponse response = categoryService.createCategory(user, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PutMapping("/{id}")
    public ResponseEntity<CategoryResponse> updateCategory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id,
            @Valid @RequestBody CategoryRequest request
    ) {
        User user = userService.getUserFromJwt(jwt);
        CategoryResponse response = categoryService.updateCategory(user, id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteCategory(
            @AuthenticationPrincipal Jwt jwt,
            @PathVariable UUID id
    ) {
        User user = userService.getUserFromJwt(jwt);
        categoryService.deleteCategory(user, id);
        return ResponseEntity.noContent().build();
    }
}
