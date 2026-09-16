import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../theme/app_theme.dart';
import 'auth_service.dart';
import 'local_database_service.dart';

/// Service to persist and synchronize user theme and color palette presets
/// both locally (SQLite cache_metadata) and remotely in Supabase (users_preference table).
class UserPreferencesService {
  static final UserPreferencesService _instance = UserPreferencesService._internal();
  factory UserPreferencesService() => _instance;
  UserPreferencesService._internal();

  /// Target Supabase table name
  static const String tableUsersPreference = 'users_preference';

  /// Local SQLite metadata cache keys
  static const String keyTheme = 'user_pref_theme';
  static const String keyChartPalette = 'user_pref_chart_palette';
  static const String keyAnalysisPeriod = 'user_pref_analysis_period';
  static const String keyDailyLimit = 'user_pref_daily_limit';
  static const String keyDefaultPaymentApp = 'user_pref_default_payment_app';

  String? _cachedAnalysisPeriod;
  double? _cachedDailyLimit;
  String _cachedDefaultPaymentApp = 'google_pay'; // 'google_pay' or 'amazon_pay'

  /// Synchronously returns preferred default payment app identifier
  String get cachedDefaultPaymentApp => _cachedDefaultPaymentApp;

  /// Synchronously returns any cached period in memory (e.g. from loadLocalPreferences)
  String? get cachedAnalysisPeriod => _cachedAnalysisPeriod;

  /// Synchronously returns any cached daily limit in memory
  double? get cachedDailyLimit => _cachedDailyLimit;

  SupabaseClient? _customClient;

  /// Allow injecting a SupabaseClient for testing purposes
  @visibleForTesting
  void setCustomClient(SupabaseClient? client) {
    _customClient = client;
  }

  SupabaseClient? get _client => _customClient ?? AuthService().client;

  /// Loads locally cached preferences from SQLite (0ms latency, works offline)
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
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: loadLocalPreferences error: $e');
      }
    }
  }

  /// Loads remote preferences from Supabase `users_preference` table
  /// and updates both AppThemeManager and local SQLite cache only if remote is newer or local unset.
  Future<void> loadRemotePreferences() async {
    final client = _client;
    final user = AuthService().currentUser;

    if (client == null || user == null) {
      return;
    }

    try {
      final response = await client
          .from(tableUsersPreference)
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null) {
        final remoteTheme = response['theme'] as String?;
        final remotePalette = (response['chart_palette'] ?? response['color_palette']) as String?;
        final remoteUpdatedAtStr = response['updated_at'] as String?;
        final remoteUpdatedAt = remoteUpdatedAtStr != null ? DateTime.tryParse(remoteUpdatedAtStr) : null;

        // Check local timestamps to avoid clobbering recent offline local edits
        final localThemeEntry = await LocalDatabaseService().getMetadataEntry(keyTheme);
        final localThemeUpdated = localThemeEntry != null && localThemeEntry['updated_at'] != null
            ? DateTime.tryParse(localThemeEntry['updated_at'] as String)
            : null;

        final shouldApplyTheme = localThemeEntry == null ||
            (remoteUpdatedAt != null && localThemeUpdated != null && remoteUpdatedAt.isAfter(localThemeUpdated));

        if (remoteTheme != null && remoteTheme.isNotEmpty && shouldApplyTheme) {
          AppThemeManager.setTheme(remoteTheme);
          await LocalDatabaseService().setMetadata(keyTheme, remoteTheme);
        }

        final localPaletteEntry = await LocalDatabaseService().getMetadataEntry(keyChartPalette);
        final localPaletteUpdated = localPaletteEntry != null && localPaletteEntry['updated_at'] != null
            ? DateTime.tryParse(localPaletteEntry['updated_at'] as String)
            : null;

        final shouldApplyPalette = localPaletteEntry == null ||
            (remoteUpdatedAt != null && localPaletteUpdated != null && remoteUpdatedAt.isAfter(localPaletteUpdated));

        if (remotePalette != null && remotePalette.isNotEmpty && shouldApplyPalette) {
          AppThemeManager.setChartPalette(remotePalette);
          await LocalDatabaseService().setMetadata(keyChartPalette, remotePalette);
        }

        final remoteDaily = (response['daily_limit'] ??
                response['spending_limit'] ??
                response['daily_budget']) as num?;
        final remoteMonthly = (response['monthly_limit'] ??
                response['monthly_target']) as num?;
        final remoteLimit = remoteDaily != null
            ? remoteDaily.toDouble()
            : (remoteMonthly != null ? (remoteMonthly.toDouble() / 30.0).roundToDouble() : null);

        if (remoteLimit != null && remoteLimit > 0) {
          final localLimitEntry = await LocalDatabaseService().getMetadataEntry(keyDailyLimit);
          final localLimitUpdated = localLimitEntry != null && localLimitEntry['updated_at'] != null
              ? DateTime.tryParse(localLimitEntry['updated_at'] as String)
              : null;
          final shouldApplyLimit = localLimitEntry == null ||
              (remoteUpdatedAt != null && localLimitUpdated != null && remoteUpdatedAt.isAfter(localLimitUpdated));

          if (shouldApplyLimit) {
            _cachedDailyLimit = remoteLimit;
            await LocalDatabaseService().setMetadata(keyDailyLimit, remoteLimit.toString());
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: loadRemotePreferences error: $e');
      }
    }
  }

  /// Combined loader: Reads fast local cache first, then syncs with Supabase in background
  Future<void> loadPreferences() async {
    await loadLocalPreferences();
    await loadRemotePreferences();
  }

  /// Saves the user's selected theme and chart color palette presets.
  /// 1. Persists to local SQLite metadata for instant offline availability.
  /// 2. Upserts into Supabase `users_preference` table if user is authenticated.
  Future<void> savePreferences({
    required String theme,
    required String chartPalette,
  }) async {
    // 1. Immediately cache in SQLite
    try {
      await LocalDatabaseService().setMetadata(keyTheme, theme);
      await LocalDatabaseService().setMetadata(keyChartPalette, chartPalette);
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: local save error: $e');
      }
    }

    // 2. Sync to Supabase `users_preference` table if authenticated
    final client = _client;
    final user = AuthService().currentUser;

    if (client == null || user == null) {
      return;
    }

    final timestamp = DateTime.now().toUtc().toIso8601String();

    try {
      // Primary upsert using standard schema (chart_palette)
      await client.from(tableUsersPreference).upsert({
        'user_id': user.id,
        'theme': theme,
        'chart_palette': chartPalette,
        'updated_at': timestamp,
      }, onConflict: 'user_id');
    } on PostgrestException catch (pe) {
      final msg = pe.message.toLowerCase();
      // Graceful fallback if schema column is named 'color_palette'
      if (msg.contains('chart_palette') || pe.code == '42703' || pe.code == 'PGRST204') {
        try {
          await client.from(tableUsersPreference).upsert({
            'user_id': user.id,
            'theme': theme,
            'color_palette': chartPalette,
            'updated_at': timestamp,
          }, onConflict: 'user_id');
          return;
        } catch (fallbackError) {
          if (kDebugMode) {
            print('UserPreferencesService: fallback upsert error: $fallbackError');
          }
        }
      }
      if (kDebugMode) {
        print('UserPreferencesService: Supabase upsert PostgrestException: $pe');
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: Supabase save error: $e');
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
  /// and syncs to Supabase users_preference table if authenticated.
  Future<void> saveDailyLimit(double limit) async {
    _cachedDailyLimit = limit;
    try {
      await LocalDatabaseService().setMetadata(keyDailyLimit, limit.toString());
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: saveDailyLimit error: $e');
      }
    }

    final client = _client;
    final userId = AuthService().currentUser?.id ?? AuthService().currentUserProfile?.id;
    if (client != null && userId != null) {
      try {
        await client.from(tableUsersPreference).upsert({
          'user_id': userId,
          'daily_limit': limit,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id');
      } catch (e) {
        if (kDebugMode) {
          print('UserPreferencesService: saveDailyLimit remote error: $e');
        }
      }
    }
  }

  /// Retrieves the saved daily spending limit from local storage or remote Supabase, defaulting to 5000.0
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
          if (!forceRefresh) return parsed;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('UserPreferencesService: getDailyLimit local error: $e');
      }
    }

    final client = _client;
    final userId = AuthService().currentUser?.id ?? AuthService().currentUserProfile?.id;
    if (client != null && userId != null) {
      try {
        final response = await client
            .from(tableUsersPreference)
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        if (response != null) {
          final remoteDaily = (response['daily_limit'] ??
                  response['spending_limit'] ??
                  response['daily_budget']) as num?;
          if (remoteDaily != null && remoteDaily > 0) {
            final val = remoteDaily.toDouble();
            _cachedDailyLimit = val;
            await LocalDatabaseService().setMetadata(keyDailyLimit, val.toString());
            return val;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('UserPreferencesService: getDailyLimit remote error: $e');
        }
      }
    }

    return _cachedDailyLimit ?? 5000.0;
  }

  /// Sets the preferred default payment application ('google_pay' or 'amazon_pay')
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

  /// Gets the preferred default payment application ('google_pay' or 'amazon_pay')
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
}
