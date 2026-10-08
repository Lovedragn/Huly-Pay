package com.hulypay.backend.Repositories;

import com.hulypay.backend.Models.PaymentMethod;
import com.hulypay.backend.Models.PaymentMethodId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PaymentMethodRepository extends JpaRepository<PaymentMethod, PaymentMethodId> {
}
