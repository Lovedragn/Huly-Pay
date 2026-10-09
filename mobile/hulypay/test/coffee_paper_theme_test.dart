import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Theme/app_theme.dart';
import 'package:hulypay/data/external_data.dart';

void main() {
  group('Coffee paper theme specifications', () {
    test('Coffee paper theme is included in preset lists and Milk white is removed', () {
      expect(kAppThemeNames, contains('Coffee paper'));
      expect(kAppThemeNames, isNot(contains('Milk white')));

      expect(kChartPaletteNames, contains('Coffee paper'));
      expect(kChartPaletteNames, isNot(contains('Milk white')));

      final presetIds = ExternalData.themePresets.map((p) => p['id']).toList();
      expect(presetIds, contains('Coffee paper'));
      expect(presetIds, isNot(contains('Milk white')));
    });

    test('Coffee paper theme uses light brown main background, pure white and cream white text', () {
      final theme = AppThemeData.coffeePaper;

      expect(theme.name, 'Coffee paper');
      expect(theme.isDark, isTrue);

      // Main color: light brown / coffee paper tone
      expect(theme.background, const Color(0xFF4A3427));

      // Pure white color for primary text and headings
      expect(theme.textPrimary, const Color(0xFFFFFFFF));

      // Cream white color for secondary text / components
      expect(theme.textSecondary, const Color(0xFFF5EBE0));

      // Accent is warm light brown / caramel
      expect(theme.accent, const Color(0xFFD4A373));

      // Other components use pure white and cream white
      expect(theme.iconDefault, const Color(0xFFFFFFFF));
      expect(theme.navBarActive, const Color(0xFFFFFFFF));
      expect(theme.border, const Color(0x3DF5EBE0));
      expect(theme.divider, const Color(0x24F5EBE0));
    });

    test('Heatmap palette progresses from dark brown to light brown for Coffee paper', () {
      AppThemeManager.setTheme('Coffee paper');

      final heatmap = AppChartColors.heatmapPalette;
      expect(heatmap.length, 5);

      // Dark brown (Level 0 / lowest activity)
      expect(heatmap[0], const Color(0xFF2E1C14));

      // Deep coffee brown (Level 1)
      expect(heatmap[1], const Color(0xFF543828));

      // Medium brown (Level 2)
      expect(heatmap[2], const Color(0xFF7A5239));

      // Warm brown / caramel (Level 3)
      expect(heatmap[3], const Color(0xFFA26E4B));

      // Light brown (Level 4 / highest activity)
      expect(heatmap[4], const Color(0xFFD4A373));

      // Selected cell highlight is pure white
      expect(AppChartColors.heatmapSelected, const Color(0xFFFFFFFF));

      // Chip border is light brown
      expect(AppChartColors.heatmapChipBorder, const Color(0xFFD4A373));
    });

    test('Legacy "Milk white" input automatically normalizes to Coffee paper', () {
      expect(AppThemeManager.normalizeTheme('Milk white'), 'Coffee paper');
      expect(AppThemeManager.normalizeTheme('milk'), 'Coffee paper');
      expect(AppThemeManager.normalizeTheme('white'), 'Coffee paper');
      expect(AppThemeManager.normalizeTheme('coffee paper'), 'Coffee paper');
      expect(AppThemeManager.normalizeTheme('brown'), 'Coffee paper');

      // Colors resolved correctly
      expect(AppThemeManager.getThemeColors('Milk white').name, 'Coffee paper');
      expect(AppThemeManager.getThemeColors('Coffee paper').name, 'Coffee paper');
    });
  });
}
