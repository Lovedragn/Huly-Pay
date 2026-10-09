import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Theme/app_theme.dart';
import 'package:hulypay/data/external_data.dart';

void main() {
  group('Funky theme specifications', () {
    test('Funky theme is registered in themes and palettes lists', () {
      expect(kAppThemeNames, contains('Funky'));
      expect(kChartPaletteNames, contains('Funky'));

      final presetIds = ExternalData.themePresets.map((p) => p['id']).toList();
      expect(presetIds, contains('Funky'));
    });

    test('Funky theme has light sky blue background, pure white cards, electric blue accents, and integrates all four bright colors', () {
      final theme = AppThemeData.funky;

      expect(theme.name, 'Funky');
      expect(theme.isDark, isFalse);
      expect(theme.brightness, Brightness.light);

      // Light sky blue background & pure white card surfaces
      expect(theme.background, const Color(0xFF38BDF8));
      expect(theme.surface, const Color(0xFFFFFFFF));
      expect(theme.surfaceSecondary, const Color(0xFFE0F2FE));

      // Typography inside white cards
      expect(theme.textPrimary, const Color(0xFF0F172A));
      expect(theme.accent, const Color(0xFF0284C7));
      expect(theme.navBarActive, const Color(0xFF0284C7));
      expect(theme.iconDefault, const Color(0xFF0284C7));

      // Pure Red (#ff0000)
      expect(theme.error, const Color(0xFFFF0000));

      // Neon Green (#2bff00)
      expect(theme.success, const Color(0xFF2BFF00));

      // Bright Yellow (#ffc800)
      expect(theme.warning, const Color(0xFFFFC800));

      // Electric Cyan (#00ffff)
      expect(theme.info, const Color(0xFF00FFFF));
    });

    test('Funky chart palette leads with all main four colors in order', () {
      AppThemeManager.setTheme('Funky');

      final palette = AppChartColors.globalPalette;
      expect(palette.length, greaterThanOrEqualTo(4));

      // Red (#ff0000)
      expect(palette[0], const Color(0xFFFF0000));
      // Green (#2bff00)
      expect(palette[1], const Color(0xFF2BFF00));
      // Yellow (#ffc800)
      expect(palette[2], const Color(0xFFFFC800));
      // Cyan (#00ffff)
      expect(palette[3], const Color(0xFF00FFFF));
    });

    test('Funky heatmap uses all four colors: White base -> Cyan -> Green -> Yellow -> Red', () {
      AppThemeManager.setTheme('Funky');

      final heatmap = AppChartColors.heatmapPalette;
      expect(heatmap.length, 5);

      // Pure white card base
      expect(heatmap[0], const Color(0xFFFFFFFF));
      // Level 1: Cyan (#00ffff)
      expect(heatmap[1], const Color(0xFF00FFFF));
      // Level 2: Green (#2bff00)
      expect(heatmap[2], const Color(0xFF2BFF00));
      // Level 3: Yellow (#ffc800)
      expect(heatmap[3], const Color(0xFFFFC800));
      // Level 4: Red (#ff0000, peak)
      expect(heatmap[4], const Color(0xFFFF0000));

      // Selected highlight: Cyan (#00ffff)
      expect(AppChartColors.heatmapSelected, const Color(0xFF00FFFF));
      // Chip border: Red (#ff0000)
      expect(AppChartColors.heatmapChipBorder, const Color(0xFFFF0000));
    });

    test('Funky theme name normalizes properly', () {
      expect(AppThemeManager.normalizeTheme('Funky'), 'Funky');
      expect(AppThemeManager.normalizeTheme('funky'), 'Funky');
      expect(AppThemeManager.normalizeTheme('super funky'), 'Funky');

      expect(AppThemeManager.getThemeColors('Funky').name, 'Funky');
    });
  });
}
