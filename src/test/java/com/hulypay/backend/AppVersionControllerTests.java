package com.hulypay.backend;

import com.hulypay.backend.Services.VersionComparisonService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "app.mobile.android.version=1.2.0",
        "app.mobile.android.download-url=https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk",
        "app.mobile.ios.version=1.2.0",
        "app.mobile.ios.download-url=https://huly-pay.vercel.app/downloads/hulypay-1.2.0.ipa",
        "app.mobile.minimum-android-version=1.1.0",
        "app.mobile.minimum-ios-version=1.1.0"
})
class AppVersionControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private VersionComparisonService versionService;

    @Test
    @DisplayName("Unit tests: Semantic version comparison rules")
    void testVersionComparisonRules() {
        // 1.1.0 < 1.2.0
        assertTrue(versionService.compare("1.1.0", "1.2.0") < 0);
        assertTrue(versionService.isOlder("1.1.0", "1.2.0"));

        // 1.2.0 == 1.2.0
        assertEquals(0, versionService.compare("1.2.0", "1.2.0"));
        assertFalse(versionService.isOlder("1.2.0", "1.2.0"));

        // 1.3.0 > 1.2.0
        assertTrue(versionService.compare("1.3.0", "1.2.0") > 0);
        assertFalse(versionService.isOlder("1.3.0", "1.2.0"));

        // 1.9.0 < 2.0.0
        assertTrue(versionService.compare("1.9.0", "2.0.0") < 0);

        // 2.0.0 > 1.99.0
        assertTrue(versionService.compare("2.0.0", "1.99.0") > 0);

        // 2.0.0 vs 1.9.0 = no update
        assertFalse(versionService.isOlder("2.0.0", "1.9.0"));

        // Build metadata/postfix support e.g. 1.0.0+1
        assertEquals(0, versionService.compare("1.0.0+1", "1.0.0"));
    }

    @Test
    @DisplayName("GET /api/app/version without token - 1.1.0 -> 1.2.0 optional update available")
    void testOptionalUpdateAvailableAndroid() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "android")
                        .header("X-App-Version", "1.1.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentVersion").value("1.1.0"))
                .andExpect(jsonPath("$.latestVersion").value("1.2.0"))
                .andExpect(jsonPath("$.minimumVersion").value("1.1.0"))
                .andExpect(jsonPath("$.updateAvailable").value(true))
                .andExpect(jsonPath("$.forceUpdate").value(false))
                .andExpect(jsonPath("$.downloadUrl").value("https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk"))
                .andExpect(jsonPath("$.message").value("A new version of HulyPay is available."));
    }

    @Test
    @DisplayName("GET /api/app/version - iOS platform check")
    void testIosPlatformCheck() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "ios")
                        .header("X-App-Version", "1.1.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentVersion").value("1.1.0"))
                .andExpect(jsonPath("$.latestVersion").value("1.2.0"))
                .andExpect(jsonPath("$.minimumVersion").value("1.1.0"))
                .andExpect(jsonPath("$.updateAvailable").value(true))
                .andExpect(jsonPath("$.forceUpdate").value(false))
                .andExpect(jsonPath("$.downloadUrl").value("https://huly-pay.vercel.app/downloads/hulypay-1.2.0.ipa"));
    }

    @Test
    @DisplayName("GET /api/app/version - Current version is latest 1.2.0 -> no update")
    void testCurrentIsLatest() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "android")
                        .header("X-App-Version", "1.2.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.updateAvailable").value(false))
                .andExpect(jsonPath("$.forceUpdate").value(false));
    }

    @Test
    @DisplayName("GET /api/app/version - Current version 1.3.0 > latest 1.2.0 -> no update")
    void testCurrentIsNewer() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "android")
                        .header("X-App-Version", "1.3.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.updateAvailable").value(false))
                .andExpect(jsonPath("$.forceUpdate").value(false));
    }

    @Test
    @DisplayName("GET /api/app/version - Current version 1.0.0 < minimum 1.1.0 -> force update")
    void testForceUpdateWhenOlderThanMinimum() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "android")
                        .header("X-App-Version", "1.0.0"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.updateAvailable").value(true))
                .andExpect(jsonPath("$.forceUpdate").value(true))
                .andExpect(jsonPath("$.message").value("Your version of HulyPay is no longer supported. Please update to continue."));
    }

    @Test
    @DisplayName("GET /api/app/version - Missing header or invalid platform defaults safely")
    void testMissingHeaderAndInvalidPlatform() throws Exception {
        mockMvc.perform(get("/api/app/version")
                        .param("platform", "windows_phone"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.currentVersion").value("1.0.0"))
                .andExpect(jsonPath("$.latestVersion").value("1.2.0"))
                .andExpect(jsonPath("$.downloadUrl").value("https://huly-pay.vercel.app/downloads/hulypay-1.2.0.apk"));
    }
}
