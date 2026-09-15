package com.hulypay.backend.payments.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SmsVerificationRequest {

    @NotBlank(message = "smsBody is required")
    private String smsBody;

    private String receivedAt;

    private String sender;

    private String packageName;
}
