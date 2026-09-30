package com.hulypay.backend.RequestDto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionReconcileRequest {

    @NotBlank(message = "Status is required")
    private String status;

    private String upiTransactionId;

    private String transactionReference;
}




