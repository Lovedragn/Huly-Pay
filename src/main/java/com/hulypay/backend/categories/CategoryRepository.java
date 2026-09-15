package com.hulypay.backend.categories;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface CategoryRepository extends JpaRepository<Category, UUID> {

    @Query("SELECT c FROM Category c WHERE c.isDefault = true OR (c.user IS NOT NULL AND c.user.id = :userId) ORDER BY c.isDefault DESC, c.name ASC")
    List<Category> findAllAvailableForUser(@Param("userId") UUID userId);

    List<Category> findByIsDefaultTrue();

    boolean existsByNameIgnoreCaseAndIsDefaultTrue(String name);

    Optional<Category> findByIdAndUserId(UUID id, UUID userId);
}
