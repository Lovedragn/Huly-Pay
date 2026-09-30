package com.hulypay.backend.RequestDto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TransactionSmsVerificationRequest {

    @NotBlank(message = "SMS body is required")
    private String smsBody;

    private String sender;

    @JsonProperty("receivedAt")
    private String receivedAt;
}




