import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Screen/Home/Payment/scan_and_pay_screen.dart';
import 'package:hulypay/Theme/app_theme.dart';

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

    test('Coffee paper theme uses pure white scanner SVG and coffee paper palette', () {
      final palette = ScannerPalette.from(AppThemeData.coffeePaper);

      expect(palette.isDark, isTrue);
      expect(palette.scaffold, AppThemeData.coffeePaper.background);
      expect(palette.scannerSvg, const Color(0xFFFFFFFF));
      expect(palette.buttonIcon, const Color(0xFFFFFFFF));
    });

    test('Funky theme uses cyan scanner SVG and blue button icon on light sky blue background', () {
      final palette = ScannerPalette.from(AppThemeData.funky);

      expect(palette.isDark, isFalse);
      expect(palette.scaffold, AppThemeData.funky.background);
      expect(palette.scannerSvg, const Color(0xFF00FFFF));
      expect(palette.buttonIcon, const Color(0xFF0284C7));
    });
  });
}
