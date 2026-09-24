import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/screens/settings_screen.dart';
import 'package:hulypay/theme/app_theme.dart';
import 'package:hulypay/theme/chart_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppThemeManager.setTheme('Black');
    AppThemeManager.setChartPalette('Default');
  });

  tearDown(() {
    AppThemeManager.setTheme('Black');
    AppThemeManager.setChartPalette('Default');
  });

  group('AppTheme & Chart Colors Customization Unit Tests', () {
    test('Global list of string tokens are defined and shared', () {
      expect(kAppThemeNames, containsAll(['Black', 'White', 'Blue']));
      expect(
        kChartPaletteNames,
        containsAll([
          'Default',
          'Emerald Mint',
          'Cyber Purple',
          'Sunset Gold',
          'Ocean Blue',
        ]),
      );
    });

    test('Default values are Black theme and Default chart palette', () {
      expect(AppThemeManager.theme, equals('Black'));
      expect(AppThemeManager.chartPalette, equals('Default'));
      expect(AppThemeManager.colors.isDark, isTrue);
      expect(AppThemeManager.colors.background, equals(const Color(0xFF000000)));
      expect(AppThemeManager.colors.surface, equals(const Color(0xFF141416)));
      expect(AppChartColors.globalPalette, equals(AppChartColors.defaultPalette));
    });

    test('White theme updates color tokens to clean light mode', () {
      AppThemeManager.setTheme('White');
      expect(AppThemeManager.theme, equals('White'));
      expect(AppThemeManager.colors.isDark, isFalse);
      expect(AppThemeManager.colors.background, equals(const Color(0xFFF6F8FA)));
      expect(AppThemeManager.colors.surface, equals(const Color(0xFFFFFFFF)));
      expect(AppThemeManager.colors.surfaceSecondary, equals(kCloudWhite));
      expect(AppThemeManager.colors.iconBackground, equals(kCloudWhite));
      expect(AppThemeManager.colors.textPrimary, equals(const Color(0xFF000000)));
    });

    test('Blue theme updates color tokens to deep oceanic midnight mode', () {
      AppThemeManager.setTheme('Blue');
      expect(AppThemeManager.theme, equals('Blue'));
      expect(AppThemeManager.colors.isDark, isTrue);
      expect(AppThemeManager.colors.background, equals(const Color(0xFF060B18)));
      expect(AppThemeManager.colors.surface, equals(const Color(0xFF0C1630)));
      expect(AppThemeManager.colors.accent, equals(const Color(0xFF388BFD)));
    });

    test('Theme normalizer handles aliases correctly', () {
      expect(AppThemeManager.normalizeTheme('OLED Black'), equals('Black'));
      expect(AppThemeManager.normalizeTheme('Clean White'), equals('White'));
      expect(AppThemeManager.normalizeTheme('Midnight Dark'), equals('Blue'));
      expect(AppThemeManager.normalizeTheme('Oceanic Blue'), equals('Blue'));
    });

    test('Chart palette customization updates chart colors dynamically', () {
      // 1. Switch to Emerald Mint
      AppThemeManager.setChartPalette('Emerald Mint');
      expect(AppThemeManager.chartPalette, equals('Emerald Mint'));
      expect(AppChartColors.globalPalette[0], equals(const Color(0xFF00C076)));

      // 2. Switch to Cyber Purple
      AppThemeManager.setChartPalette('Cyber Purple');
      expect(AppThemeManager.chartPalette, equals('Cyber Purple'));
      expect(AppChartColors.globalPalette[0], equals(const Color(0xFFAF52DE)));

      // 3. Switch to Sunset Gold
      AppThemeManager.setChartPalette('Sunset Gold');
      expect(AppThemeManager.chartPalette, equals('Sunset Gold'));
      expect(AppChartColors.globalPalette[0], equals(const Color(0xFFFF9500)));

      // 4. Switch to Ocean Blue
      AppThemeManager.setChartPalette('Ocean Blue');
      expect(AppThemeManager.chartPalette, equals('Ocean Blue'));
      expect(AppChartColors.globalPalette[0], equals(const Color(0xFF007AFF)));

      // 5. Reset to Default
      AppThemeManager.setChartPalette('Default');
      expect(AppThemeManager.chartPalette, equals('Default'));
      expect(AppChartColors.globalPalette, equals(AppChartColors.defaultPalette));
    });
  });

  group('SettingsScreen Customization Option Widget Tests', () {
    testWidgets('Customization button option opens dual-section modal sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Customization option exists
      final customizationFinder = find.text('Customization');
      expect(customizationFinder, findsOneWidget);

      // 2. Tap Customization option
      await tester.tap(customizationFinder);
      await tester.pumpAndSettle();

      // 3. Verify Modal Sheet renders both sections
      expect(find.text('APP THEME'), findsOneWidget);
      expect(find.text('CHART COLORS'), findsOneWidget);

      // 4. Verify Themes are listed
      expect(find.text('Black'), findsWidgets);
      expect(find.text('White'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);

      // 5. Verify Chart palettes are listed
      expect(find.text('Emerald Mint'), findsOneWidget);
      expect(find.text('Cyber Purple'), findsOneWidget);
      expect(find.text('Sunset Gold'), findsOneWidget);
      expect(find.text('Ocean Blue'), findsOneWidget);

      // 6. Tap White theme
      await tester.tap(find.text('White'));
      await tester.pumpAndSettle();
      expect(AppThemeManager.theme, equals('White'));

      // 7. Tap Emerald Mint chart palette
      await tester.ensureVisible(find.text('Emerald Mint'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Emerald Mint'));
      await tester.pumpAndSettle();
      expect(AppThemeManager.chartPalette, equals('Emerald Mint'));
    });

    testWidgets('SettingsScreen displays and toggles Quick Confirm switch', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final quickConfirmFinder = find.text('Quick Confirm');
      await tester.ensureVisible(quickConfirmFinder);
      await tester.pumpAndSettle();

      expect(quickConfirmFinder, findsOneWidget);
      expect(find.text('Bypass SMS check & auto-confirm QR payments'), findsOneWidget);

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      final initialVal = tester.widget<Switch>(switchFinder).value;

      // Tap the row to toggle
      await tester.tap(quickConfirmFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(switchFinder).value, equals(!initialVal));
    });
  });
}
