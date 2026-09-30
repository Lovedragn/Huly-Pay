import 'dart:async';
import 'package:flutter/foundation.dart';

import '../theme/app_theme.dart';
import 'local_database_service.dart';

/// Service to persist and manage user theme, color palette, limits, and settings
/// locally in SQLite (cache_metadata). No remote Supabase persistence is used.
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  /// Local SQLite metadata cache keys
  static const String keyTheme = 'user_pref_theme';
  static const String keyChartPalette = 'user_pref_chart_palette';
  static const String keyAnalysisPeriod = 'user_pref_analysis_period';
  static const String keyDailyLimit = 'user_pref_daily_limit';
  static const String keyDefaultPaymentApp = 'user_pref_default_payment_app';
  static const String keyQuickConfirm = 'user_pref_quick_confirm';
  static const String keyQuickScan = 'user_pref_quick_scan';

  String? _cachedAnalysisPeriod;
  double? _cachedDailyLimit;
  String _cachedDefaultPaymentApp = 'ask_every_time';
  bool _cachedQuickConfirm = false;
  bool _cachedQuickScan = false;

  /// Synchronously returns preferred default payment app identifier
  String get cachedDefaultPaymentApp => _cachedDefaultPaymentApp;

  /// Synchronously returns whether Quick Confirm is enabled
  bool get cachedQuickConfirm => _cachedQuickConfirm;

  /// Synchronously returns whether Quick Scan on app launch is enabled
  bool get cachedQuickScan => _cachedQuickScan;

  /// Synchronously returns any cached period in memory
  String? get cachedAnalysisPeriod => _cachedAnalysisPeriod;

  /// Synchronously returns any cached daily limit in memory
  double? get cachedDailyLimit => _cachedDailyLimit;

  /// Loads preferences from SQLite (0ms latency, works offline)
  Future<void> loadLocalPreferences() async {
    try {
      final savedTheme = await LocalDatabaseService().getMetadata(keyTheme);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        AppThemeManager.setTheme(savedTheme);
      }

      final savedPalette = await LocalDatabaseService().getMetadata(keyChartPalette);
      if (savedPalette != null && savedPalette.isNotEmpty) {
        AppThemeManager.setChartPalette(savedPalette);
      }

      final savedPeriod = await LocalDatabaseService().getMetadata(keyAnalysisPeriod);
      if (savedPeriod != null && savedPeriod.isNotEmpty) {
        _cachedAnalysisPeriod = savedPeriod;
      }

      final savedLimit = await LocalDatabaseService().getMetadata(keyDailyLimit);
      if (savedLimit != null && savedLimit.isNotEmpty) {
        final parsed = double.tryParse(savedLimit);
        if (parsed != null && parsed > 0) {
          _cachedDailyLimit = parsed;
        }
      }

      final savedApp = await LocalDatabaseService().getMetadata(keyDefaultPaymentApp);
      if (savedApp != null && savedApp.isNotEmpty) {
        _cachedDefaultPaymentApp = savedApp;
      }

      final savedQuickConfirm = await LocalDatabaseService().getMetadata(keyQuickConfirm);
      if (savedQuickConfirm != null) {
        _cachedQuickConfirm = savedQuickConfirm.toLowerCase() == 'true';
      }

      final savedQuickScan = await LocalDatabaseService().getMetadata(keyQuickScan);
      if (savedQuickScan != null) {
        _cachedQuickScan = savedQuickScan.toLowerCase() == 'true';
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: loadLocalPreferences error: $e');
      }
    }
  }

  /// Kept for backward compatibility: delegates directly to local preferences loader
  Future<void> loadRemotePreferences() async {
    await loadLocalPreferences();
  }

  /// Loads preferences from local SQLite storage
  Future<void> loadPreferences() async {
    await loadLocalPreferences();
  }

  /// Saves the user's selected theme and chart color palette presets locally in SQLite.
  Future<void> savePreferences({
    required String theme,
    required String chartPalette,
  }) async {
    try {
      await LocalDatabaseService().setMetadata(keyTheme, theme);
      await LocalDatabaseService().setMetadata(keyChartPalette, chartPalette);
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: local save error: $e');
      }
    }
  }

  /// Saves the user's selected period filter (e.g. 'Days', 'Weeks', 'This Month', '3 Months', '6 Months', '1 Year')
  /// in local storage (SQLite cache_metadata)
  Future<void> saveAnalysisPeriod(String period) async {
    _cachedAnalysisPeriod = period;
    try {
      await LocalDatabaseService().setMetadata(keyAnalysisPeriod, period);
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: saveAnalysisPeriod error: $e');
      }
    }
  }

  /// Retrieves the saved analysis period filter from local storage
  Future<String?> getAnalysisPeriod() async {
    if (_cachedAnalysisPeriod != null) {
      return _cachedAnalysisPeriod;
    }
    try {
      final saved = await LocalDatabaseService().getMetadata(keyAnalysisPeriod);
      if (saved != null && saved.isNotEmpty) {
        _cachedAnalysisPeriod = saved;
        return saved;
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: getAnalysisPeriod error: $e');
      }
    }
    return null;
  }

  /// Saves the user's customized daily spending limit in local storage (SQLite cache_metadata)
  Future<void> saveDailyLimit(double limit) async {
    _cachedDailyLimit = limit;
    try {
      await LocalDatabaseService().setMetadata(keyDailyLimit, limit.toString());
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: saveDailyLimit error: $e');
      }
    }
  }

  /// Retrieves the saved daily spending limit from local SQLite storage, defaulting to 5000.0
  Future<double> getDailyLimit({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedDailyLimit != null) {
      return _cachedDailyLimit!;
    }
    try {
      final saved = await LocalDatabaseService().getMetadata(keyDailyLimit);
      if (saved != null && saved.isNotEmpty) {
        final parsed = double.tryParse(saved);
        if (parsed != null && parsed > 0) {
          _cachedDailyLimit = parsed;
          return parsed;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: getDailyLimit local error: $e');
      }
    }

    return _cachedDailyLimit ?? 5000.0;
  }

  /// Sets the preferred default payment application ('google_pay' or 'amazon_pay') in SQLite
  Future<void> setDefaultPaymentApp(String appId) async {
    _cachedDefaultPaymentApp = appId;
    try {
      await LocalDatabaseService().setMetadata(keyDefaultPaymentApp, appId);
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: setDefaultPaymentApp error: $e');
      }
    }
  }

  /// Gets the preferred default payment application ('google_pay' or 'amazon_pay') from SQLite
  Future<String> getDefaultPaymentApp() async {
    try {
      final saved = await LocalDatabaseService().getMetadata(keyDefaultPaymentApp);
      if (saved != null && saved.isNotEmpty) {
        _cachedDefaultPaymentApp = saved;
        return saved;
      }
    } catch (_) {}
    return _cachedDefaultPaymentApp;
  }

  /// Sets whether Quick Confirm is enabled in SQLite
  Future<void> setQuickConfirm(bool enabled) async {
    _cachedQuickConfirm = enabled;
    try {
      await LocalDatabaseService().setMetadata(keyQuickConfirm, enabled.toString());
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: setQuickConfirm error: $e');
      }
    }
  }

  /// Gets whether Quick Confirm is enabled from local SQLite storage or cached state
  Future<bool> getQuickConfirm() async {
    try {
      final saved = await LocalDatabaseService().getMetadata(keyQuickConfirm);
      if (saved != null && saved.isNotEmpty) {
        _cachedQuickConfirm = saved.toLowerCase() == 'true';
        return _cachedQuickConfirm;
      }
    } catch (_) {}
    return _cachedQuickConfirm;
  }

  /// Sets whether Quick Scan is enabled in SQLite
  Future<void> setQuickScan(bool enabled) async {
    _cachedQuickScan = enabled;
    try {
      await LocalDatabaseService().setMetadata(keyQuickScan, enabled.toString());
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: setQuickScan error: $e');
      }
    }
  }

  /// Gets whether Quick Scan is enabled from local SQLite storage or cached state
  Future<bool> getQuickScan() async {
    try {
      final saved = await LocalDatabaseService().getMetadata(keyQuickScan);
      if (saved != null && saved.isNotEmpty) {
        _cachedQuickScan = saved.toLowerCase() == 'true';
        return _cachedQuickScan;
      }
    } catch (_) {}
    return _cachedQuickScan;
  }
}
