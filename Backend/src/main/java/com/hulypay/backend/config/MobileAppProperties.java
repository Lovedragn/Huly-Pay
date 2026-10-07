package com.hulypay.backend.config;

import java.util.ArrayList;
import java.util.List;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "app.mobile")
public class MobileAppProperties {

    private PlatformConfig android = new PlatformConfig();
    private PlatformConfig ios = new PlatformConfig();
    private String minimumAndroidVersion = "1.0.0";
    private String minimumIosVersion = "1.0.0";
    private List<String> releaseNotes = new ArrayList<>();

    @Data
    public static class PlatformConfig {
        private String version = "1.0.0";
        private String downloadUrl = "";
        private List<String> releaseNotes = new ArrayList<>();
    }
}
