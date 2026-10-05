package com.hulypay.backend.Controllers;

import com.hulypay.backend.Config.MobileAppProperties;
import com.hulypay.backend.ResponseDto.AppVersionResponse;
import com.hulypay.backend.Services.VersionComparisonService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@Tag(name = "App Version", description = "Endpoints for mobile app update checking")
public class AppVersionController {

    private final MobileAppProperties mobileAppProperties;
    private final VersionComparisonService versionComparisonService;

    @Operation(summary = "Check mobile application version and available updates")
    @GetMapping("/api/app/version")
    public ResponseEntity<AppVersionResponse> checkVersion(
            @Parameter(description = "Operating system platform: 'android' or 'ios'")
            @RequestParam(name = "platform", defaultValue = "android") String platform,
            @Parameter(description = "Installed mobile app version")
            @RequestHeader(name = "X-App-Version", required = false) String appVersionHeader
    ) {
        String cleanPlatform = platform != null ? platform.trim().toLowerCase() : "android";
        boolean isIos = "ios".equalsIgnoreCase(cleanPlatform);

        String latestVersion;
        String downloadUrl;
        String minimumVersion;

        if (isIos) {
            latestVersion = mobileAppProperties.getIos().getVersion();
            downloadUrl = mobileAppProperties.getIos().getDownloadUrl();
            minimumVersion = mobileAppProperties.getMinimumIosVersion();
        } else {
            // Default to Android for android and any other input
            latestVersion = mobileAppProperties.getAndroid().getVersion();
            downloadUrl = mobileAppProperties.getAndroid().getDownloadUrl();
            minimumVersion = mobileAppProperties.getMinimumAndroidVersion();
        }

        String currentVersion = (appVersionHeader != null && !appVersionHeader.trim().isEmpty())
                ? appVersionHeader.trim()
                : "1.0.0";

        boolean updateAvailable = versionComparisonService.isOlder(currentVersion, latestVersion);
        boolean forceUpdate = versionComparisonService.isOlder(currentVersion, minimumVersion);

        String message;
        if (forceUpdate) {
            message = "Your version of HulyPay is no longer supported. Please update to continue.";
        } else if (updateAvailable) {
            message = "A new version of HulyPay is available.";
        } else {
            message = "You are using the latest version of HulyPay.";
        }

        AppVersionResponse response = AppVersionResponse.builder()
                .currentVersion(currentVersion)
                .latestVersion(latestVersion)
                .minimumVersion(minimumVersion)
                .updateAvailable(updateAvailable)
                .forceUpdate(forceUpdate)
                .downloadUrl(downloadUrl)
                .message(message)
                .build();

        return ResponseEntity.ok(response);
    }
}
