// Centralized website user preferences manager using a single JSON object under "user_preference_website"
export const USER_PREFERENCE_WEBSITE_KEY = "user_preference_website";

export const DEFAULT_USER_PREFERENCES = {
  theme: "light",
  currency: "INR",
  theaterMode: false,
  chartMetric: "amount",       // "amount" | "average"
  timeRange: "7d",             // "7d" | "1m" | "4m" | "6m" | "1y" | "all"
  benchmark: false,            // boolean
  viewMode: "category",        // "category" | "merchant"
  tableVisibleRecords: 5,      // count of visible transaction rows
};

/**
 * Safely read user preferences from localStorage
 */
export function getUserPreferences() {
  if (typeof window === "undefined") {
    return { ...DEFAULT_USER_PREFERENCES };
  }

  try {
    const raw = localStorage.getItem(USER_PREFERENCE_WEBSITE_KEY);
    if (raw) {
      const parsed = JSON.parse(raw);
      return { ...DEFAULT_USER_PREFERENCES, ...parsed };
    }

    // Backward-compatibility: migrate legacy individual keys if present
    const legacyTheme = localStorage.getItem("hulypay_theme_preference");
    const legacyCurrency = localStorage.getItem("hulypay_pref_currency");
    const legacyTheater = localStorage.getItem("hulypay_pref_theater_mode");
    const legacyMetric = localStorage.getItem("hulypay_pref_chart_metric");
    const legacyRange = localStorage.getItem("hulypay_pref_time_range");
    const legacyBenchmark = localStorage.getItem("hulypay_pref_benchmark");
    const legacyViewMode = localStorage.getItem("hulypay_pref_view_mode");
    const legacyTxCount = sessionStorage.getItem("hulypay_pref_tx_visible_count");

    if (
      legacyTheme ||
      legacyCurrency ||
      legacyTheater ||
      legacyMetric ||
      legacyRange ||
      legacyBenchmark ||
      legacyViewMode
    ) {
      const migrated = {
        ...DEFAULT_USER_PREFERENCES,
        ...(legacyTheme && { theme: legacyTheme }),
        ...(legacyCurrency && { currency: legacyCurrency }),
        ...(legacyTheater !== null && { theaterMode: legacyTheater === "true" }),
        ...(legacyMetric && { chartMetric: legacyMetric }),
        ...(legacyRange && { timeRange: legacyRange }),
        ...(legacyBenchmark !== null && { benchmark: legacyBenchmark === "true" }),
        ...(legacyViewMode && { viewMode: legacyViewMode }),
        ...(legacyTxCount && { tableVisibleRecords: parseInt(legacyTxCount, 10) || 5 }),
      };
      saveUserPreferences(migrated);
      return migrated;
    }
  } catch (err) {
    console.warn("Could not parse user_preference_website from storage:", err);
  }

  return { ...DEFAULT_USER_PREFERENCES };
}

/**
 * Save user preferences as JSON under "user_preference_website"
 */
export function saveUserPreferences(prefs) {
  if (typeof window === "undefined") return;
  try {
    const current = getUserPreferences();
    const updated = { ...current, ...prefs };
    localStorage.setItem(USER_PREFERENCE_WEBSITE_KEY, JSON.stringify(updated));
    window.dispatchEvent(
      new CustomEvent("user_preference_website_updated", { detail: updated })
    );
  } catch (err) {
    console.warn("Could not save to user_preference_website:", err);
  }
}

/**
 * Update partial user preference keys
 */
export function updateUserPreference(key, value) {
  saveUserPreferences({ [key]: value });
}
