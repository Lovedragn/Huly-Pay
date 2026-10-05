package com.hulypay.backend.Services;

import org.springframework.stereotype.Service;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class VersionComparisonService {

    private static final Pattern VERSION_PATTERN = Pattern.compile("^v?(\\d+)(?:\\.(\\d+))?(?:\\.(\\d+))?.*$");

    /**
     * Compares two semantic version strings.
     * Returns:
     *   negative if v1 < v2
     *   0 if v1 == v2
     *   positive if v1 > v2
     *
     * Safely handles missing/null/invalid strings (treating invalid/empty as 0.0.0).
     */
    public int compare(String v1, String v2) {
        int[] parsed1 = parse(v1);
        int[] parsed2 = parse(v2);

        for (int i = 0; i < 3; i++) {
            if (parsed1[i] < parsed2[i]) {
                return -1;
            } else if (parsed1[i] > parsed2[i]) {
                return 1;
            }
        }
        return 0;
    }

    public boolean isOlder(String current, String target) {
        return compare(current, target) < 0;
    }

    public boolean isOlderOrEqual(String current, String target) {
        return compare(current, target) <= 0;
    }

    private int[] parse(String version) {
        if (version == null || version.trim().isEmpty()) {
            return new int[]{0, 0, 0};
        }

        String cleaned = version.trim().split("[-+]")[0]; // remove build metadata or prerelease tags like +1 or -beta
        Matcher matcher = VERSION_PATTERN.matcher(cleaned);
        if (!matcher.matches()) {
            return new int[]{0, 0, 0};
        }

        int major = parseGroup(matcher.group(1));
        int minor = parseGroup(matcher.group(2));
        int patch = parseGroup(matcher.group(3));

        return new int[]{major, minor, patch};
    }

    private int parseGroup(String group) {
        if (group == null || group.isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(group);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
