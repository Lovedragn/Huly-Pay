package com.hulypay.backend.categories;

import com.hulypay.backend.categories.dto.CategoryRequest;
import com.hulypay.backend.categories.dto.CategoryResponse;
import com.hulypay.backend.common.exception.BadRequestException;
import com.hulypay.backend.common.exception.ResourceNotFoundException;
import com.hulypay.backend.users.User;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    private static final List<String> DEFAULT_CATEGORIES = List.of(
            "Food",
            "Travel",
            "Shopping",
            "Bills",
            "Entertainment",
            "Health",
            "Education",
            "Fuel",
            "Rent",
            "Other"
    );

    @PostConstruct
    @Transactional
    public void seedDefaultCategories() {
        for (String categoryName : DEFAULT_CATEGORIES) {
            if (!categoryRepository.existsByNameIgnoreCaseAndIsDefaultTrue(categoryName)) {
                Category category = Category.builder()
                        .name(categoryName)
                        .isDefault(true)
                        .build();
                categoryRepository.save(category);
                log.info("Seeded default category: {}", categoryName);
            }
        }
    }

    @Transactional(readOnly = true)
    public List<CategoryResponse> getCategoriesForUser(User user) {
        return categoryRepository.findAllAvailableForUser(user.getId())
                .stream()
                .map(CategoryResponse::fromEntity)
                .toList();
    }

    @Transactional
    public CategoryResponse createCategory(User user, CategoryRequest request) {
        Category category = Category.builder()
                .name(request.getName().trim())
                .icon(request.getIcon())
                .color(request.getColor())
                .isDefault(false)
                .user(user)
                .build();

        Category saved = categoryRepository.save(category);
        return CategoryResponse.fromEntity(saved);
    }

    @Transactional
    public CategoryResponse updateCategory(User user, UUID id, CategoryRequest request) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + id));

        if (category.isDefault()) {
            throw new BadRequestException("System default categories cannot be modified");
        }

        if (category.getUser() == null || !category.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Category not found with ID: " + id);
        }

        category.setName(request.getName().trim());
        if (request.getIcon() != null) {
            category.setIcon(request.getIcon());
        }
        if (request.getColor() != null) {
            category.setColor(request.getColor());
        }

        Category updated = categoryRepository.save(category);
        return CategoryResponse.fromEntity(updated);
    }

    @Transactional
    public void deleteCategory(User user, UUID id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + id));

        if (category.isDefault()) {
            throw new BadRequestException("System default categories cannot be deleted");
        }

        if (category.getUser() == null || !category.getUser().getId().equals(user.getId())) {
            throw new ResourceNotFoundException("Category not found with ID: " + id);
        }

        categoryRepository.delete(category);
    }

    @Transactional(readOnly = true)
    public Category getValidCategory(UUID id, User user) {
        if (id == null) {
            return null;
        }
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Category not found with ID: " + id));

        if (!category.isDefault() && (category.getUser() == null || !category.getUser().getId().equals(user.getId()))) {
            throw new BadRequestException("Category does not belong to the user");
        }

        return category;
    }
}
