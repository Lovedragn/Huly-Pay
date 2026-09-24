import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/services/local_database_service.dart';
import 'package:hulypay/services/user_preferences_service.dart';
import 'package:hulypay/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;
  late UserPreferencesService prefService;

  setUp(() async {
    dbService = LocalDatabaseService();
    await dbService.initDatabase(inMemory: true);
    prefService = UserPreferencesService();

    // Reset default theme state
    AppThemeManager.setTheme('Black');
    AppThemeManager.setChartPalette('Default');
  });

  tearDown(() async {
    await dbService.close();
    AppThemeManager.setTheme('Black');
    AppThemeManager.setChartPalette('Default');
  });

  group('UserPreferencesService Tests', () {
    test('savePreferences writes theme and chartPalette to local SQLite metadata', () async {
      await prefService.savePreferences(
        theme: 'Blue',
        chartPalette: 'Cyber Purple',
      );

      final savedTheme = await dbService.getMetadata(UserPreferencesService.keyTheme);
      final savedPalette = await dbService.getMetadata(UserPreferencesService.keyChartPalette);

      expect(savedTheme, equals('Blue'));
      expect(savedPalette, equals('Cyber Purple'));
    });

    test('loadLocalPreferences restores theme and chartPalette into AppThemeManager', () async {
      // 1. Seed SQLite metadata directly
      await dbService.setMetadata(UserPreferencesService.keyTheme, 'White');
      await dbService.setMetadata(UserPreferencesService.keyChartPalette, 'Emerald Mint');

      // Verify current theme is still default Black / Default
      expect(AppThemeManager.theme, equals('Black'));
      expect(AppThemeManager.chartPalette, equals('Default'));

      // 2. Trigger loadLocalPreferences
      await prefService.loadLocalPreferences();

      // 3. Verify AppThemeManager adopted the saved values
      expect(AppThemeManager.theme, equals('White'));
      expect(AppThemeManager.chartPalette, equals('Emerald Mint'));
      expect(AppThemeManager.colors.isDark, isFalse);
    });

    test('savePreferences gracefully completes when unauthenticated without throwing errors', () async {
      // When no user is logged in, saving should still persist locally without remote exception
      expect(
        () async => await prefService.savePreferences(
          theme: 'Blue',
          chartPalette: 'Ocean Blue',
        ),
        returnsNormally,
      );

      final savedTheme = await dbService.getMetadata(UserPreferencesService.keyTheme);
      final savedPalette = await dbService.getMetadata(UserPreferencesService.keyChartPalette);

      expect(savedTheme, equals('Blue'));
      expect(savedPalette, equals('Ocean Blue'));
    });

    test('loadRemotePreferences gracefully completes when unauthenticated without crashing', () async {
      expect(
        () async => await prefService.loadRemotePreferences(),
        returnsNormally,
      );
    });

    test('loadPreferences runs composite local and remote without issues', () async {
      await dbService.setMetadata(UserPreferencesService.keyTheme, 'Blue');
      await dbService.setMetadata(UserPreferencesService.keyChartPalette, 'Sunset Gold');

      await prefService.loadPreferences();

      expect(AppThemeManager.theme, equals('Blue'));
      expect(AppThemeManager.chartPalette, equals('Sunset Gold'));
      expect(AppThemeManager.colors.isDark, isTrue);
    });

    test('saveAnalysisPeriod and getAnalysisPeriod persist and restore period filter in local storage', () async {
      // Initially no period saved
      expect(await prefService.getAnalysisPeriod(), isNull);

      // Save '6 Months' button preference
      await prefService.saveAnalysisPeriod('6 Months');

      // Verify in SQLite metadata
      final stored = await dbService.getMetadata(UserPreferencesService.keyAnalysisPeriod);
      expect(stored, equals('6 Months'));

      // Verify via service getter
      final restored = await prefService.getAnalysisPeriod();
      expect(restored, equals('6 Months'));

      // Update to '1 Year' button preference
      await prefService.saveAnalysisPeriod('1 Year');
      expect(await prefService.getAnalysisPeriod(), equals('1 Year'));
      expect(await dbService.getMetadata(UserPreferencesService.keyAnalysisPeriod), equals('1 Year'));
    });

    test('setQuickConfirm and getQuickConfirm persist and restore Quick Confirm preference in local SQLite', () async {
      // Default is false
      expect(prefService.cachedQuickConfirm, isFalse);

      // Enable Quick Confirm
      await prefService.setQuickConfirm(true);
      expect(prefService.cachedQuickConfirm, isTrue);

      // Verify SQLite metadata
      final stored = await dbService.getMetadata(UserPreferencesService.keyQuickConfirm);
      expect(stored, equals('true'));

      // Verify via getter
      final restored = await prefService.getQuickConfirm();
      expect(restored, isTrue);

      // Disable Quick Confirm
      await prefService.setQuickConfirm(false);
      expect(prefService.cachedQuickConfirm, isFalse);
      expect(await dbService.getMetadata(UserPreferencesService.keyQuickConfirm), equals('false'));
      expect(await prefService.getQuickConfirm(), isFalse);
    });

    test('loadLocalPreferences restores Quick Confirm from SQLite metadata', () async {
      await dbService.setMetadata(UserPreferencesService.keyQuickConfirm, 'true');

      await prefService.loadLocalPreferences();

      expect(prefService.cachedQuickConfirm, isTrue);
    });

    test('setQuickScan and getQuickScan persist and restore Quick Scan preference in local SQLite', () async {
      // Default is false
      expect(prefService.cachedQuickScan, isFalse);

      // Enable Quick Scan
      await prefService.setQuickScan(true);
      expect(prefService.cachedQuickScan, isTrue);

      // Verify SQLite metadata
      final stored = await dbService.getMetadata(UserPreferencesService.keyQuickScan);
      expect(stored, equals('true'));

      // Verify via getter
      final restored = await prefService.getQuickScan();
      expect(restored, isTrue);

      // Disable Quick Scan
      await prefService.setQuickScan(false);
      expect(prefService.cachedQuickScan, isFalse);
      expect(await dbService.getMetadata(UserPreferencesService.keyQuickScan), equals('false'));
      expect(await prefService.getQuickScan(), isFalse);
    });

    test('loadLocalPreferences restores Quick Scan from SQLite metadata', () async {
      await dbService.setMetadata(UserPreferencesService.keyQuickScan, 'true');

      await prefService.loadLocalPreferences();

      expect(prefService.cachedQuickScan, isTrue);
    });
  });
}
