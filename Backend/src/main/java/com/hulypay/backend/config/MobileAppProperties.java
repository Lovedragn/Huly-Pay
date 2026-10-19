package com.hulypay.backend.config;

import java.util.ArrayList;
import java.util.List;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "app.mobile")
public class MobileAppProperties {

    private PlatformConfig android = new PlatformConfig();
    private PlatformConfig ios = new PlatformConfig();
    private String minimumAndroidVersion = "3.9.6";
    private String minimumIosVersion = "3.9.6";
    private List<String> releaseNotes = new ArrayList<>();

    public MobileAppProperties() {
    }

    public PlatformConfig getAndroid() {
        return android;
    }

    public void setAndroid(PlatformConfig android) {
        this.android = android;
    }

    public PlatformConfig getIos() {
        return ios;
    }

    public void setIos(PlatformConfig ios) {
        this.ios = ios;
    }

    public String getMinimumAndroidVersion() {
        return minimumAndroidVersion;
    }

    public void setMinimumAndroidVersion(String minimumAndroidVersion) {
        this.minimumAndroidVersion = minimumAndroidVersion;
    }

    public String getMinimumIosVersion() {
        return minimumIosVersion;
    }

    public void setMinimumIosVersion(String minimumIosVersion) {
        this.minimumIosVersion = minimumIosVersion;
    }

    public List<String> getReleaseNotes() {
        return releaseNotes;
    }

    public void setReleaseNotes(List<String> releaseNotes) {
        this.releaseNotes = releaseNotes;
    }

    public static class PlatformConfig {
        private String version = "4.2.0";
        private String downloadUrl = "https://github.com/Lovedragn/Huly-Pay/releases/download/v4.2.0/hulypay_v4.2.0.apk";
        private List<String> releaseNotes = new ArrayList<>();

        public PlatformConfig() {
        }

        public String getVersion() {
            return version;
        }

        public void setVersion(String version) {
            this.version = version;
        }

        public String getDownloadUrl() {
            return downloadUrl;
        }

        public void setDownloadUrl(String downloadUrl) {
            this.downloadUrl = downloadUrl;
        }

        public List<String> getReleaseNotes() {
            return releaseNotes;
        }

        public void setReleaseNotes(List<String> releaseNotes) {
            this.releaseNotes = releaseNotes;
        }
    }
}
