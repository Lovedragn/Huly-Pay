package com.hulypay.backend.Repositories;

import com.hulypay.backend.Models.TransactionStatusEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface TransactionStatusRepository extends JpaRepository<TransactionStatusEntity, Short> {
    Optional<TransactionStatusEntity> findByNameIgnoreCase(String name);
}
