import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Theme/app_theme.dart';

void main() {
  test('AppThemeData topBarGradient has background opacity gradient', () {
    for (final theme in [
      AppThemeData.oledBlack,
      AppThemeData.coffeePaper,
      AppThemeData.redVelvet,
      AppThemeData.funky,
    ]) {
      final gradient = theme.topBarGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors.length, 3);
      expect(gradient.colors[0], theme.background.withValues(alpha: 1.0));
      expect(gradient.colors[1], theme.background.withValues(alpha: 0.6));
      expect(gradient.colors[2], theme.background.withValues(alpha: 0.3));
      expect(gradient.stops, const [0.3, 0.8, 1.0]);
    }
  });

  test('AppThemeData bottomBarGradient has from, middle, to with from and middle same color', () {
    for (final theme in [
      AppThemeData.oledBlack,
      AppThemeData.coffeePaper,
      AppThemeData.redVelvet,
      AppThemeData.funky,
    ]) {
      final gradient = theme.bottomBarGradient;
      expect(gradient.begin, Alignment.bottomCenter);
      expect(gradient.end, Alignment.topCenter);
      expect(gradient.colors.length, 3);
      expect(gradient.colors[0], theme.navBarGradientFrom);
      expect(gradient.colors[1], theme.navBarGradientMiddle);
      expect(gradient.colors[2], theme.navBarGradientTo);
      expect(theme.navBarGradientFrom, theme.navBarGradientMiddle);
      expect(gradient.stops, const [0.0, 0, 1.0]);
    }
  });
}
