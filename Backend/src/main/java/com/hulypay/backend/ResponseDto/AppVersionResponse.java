package com.hulypay.backend.ResponseDto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AppVersionResponse {

    private String currentVersion;
    private String latestVersion;
    private String minimumVersion;
    private boolean updateAvailable;
    private boolean forceUpdate;
    private String downloadUrl;
    private String message;
}
