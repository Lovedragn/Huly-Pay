import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/screens/scan_and_pay_screen.dart';
import 'package:hulypay/theme/app_theme.dart';

void main() {
  group('ScannerPalette', () {
    test('Red velvet theme has white background, red scanner SVG, and back button style controls', () {
      final palette = ScannerPalette.from(AppThemeData.redVelvet);

      // Background inverted to white
      expect(palette.scaffold, const Color(0xFFFFFFFF));
      expect(palette.overlay, const Color(0xE6FFFFFF));

      // Scan SVG should be red
      expect(palette.scannerSvg, AppThemeData.redVelvet.accent);
      expect(palette.scannerSvg, const Color(0xFFEB0029));

      // Buttons styled like standard back button
      expect(palette.buttonBorder, AppThemeData.redVelvet.border);
      expect(palette.buttonIcon, AppThemeData.redVelvet.textPrimary);
      expect(palette.buttonBg, Colors.white.withValues(alpha: 0.92));
    });

    test('Oled black theme retains dark palette', () {
      final palette = ScannerPalette.from(AppThemeData.oledBlack);

      expect(palette.isDark, isTrue);
      expect(palette.scaffold, const Color(0xFF000000));
      expect(palette.overlay, const Color(0xC7000000));
      expect(palette.scannerSvg, Colors.white);
      expect(palette.buttonIcon, Colors.white);
    });

    test('Milk white theme uses blue scanner SVG and milk white theme borders', () {
      final palette = ScannerPalette.from(AppThemeData.milkWhite);

      expect(palette.isDark, isFalse);
      expect(palette.scaffold, AppThemeData.milkWhite.background);
      expect(palette.overlay, const Color(0xE6FFFFFF));
      expect(palette.scannerSvg, const Color(0xFF007AFF));
      expect(palette.buttonBorder, AppThemeData.milkWhite.border);
      expect(palette.buttonIcon, AppThemeData.milkWhite.textPrimary);
    });
  });
}
