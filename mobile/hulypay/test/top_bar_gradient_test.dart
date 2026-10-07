import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Theme/app_theme.dart';

void main() {
  test('AppThemeData topBarGradient has from, middle, to with from and middle same color', () {
    for (final theme in [
      AppThemeData.oledBlack,
      AppThemeData.milkWhite,
      AppThemeData.redVelvet,
    ]) {
      final gradient = theme.topBarGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.colors.length, 3);
      expect(gradient.colors[0], theme.navBarGradientFrom);
      expect(gradient.colors[1], theme.navBarGradientMiddle);
      expect(gradient.colors[2], theme.navBarGradientTo);
      expect(theme.navBarGradientFrom, theme.navBarGradientMiddle);
      expect(gradient.stops, const [0.0, 0.5, 1.0]);
    }
  });

  test('AppThemeData bottomBarGradient has from, middle, to with from and middle same color', () {
    for (final theme in [
      AppThemeData.oledBlack,
      AppThemeData.milkWhite,
      AppThemeData.redVelvet,
    ]) {
      final gradient = theme.bottomBarGradient;
      expect(gradient.begin, Alignment.bottomCenter);
      expect(gradient.end, Alignment.topCenter);
      expect(gradient.colors.length, 3);
      expect(gradient.colors[0], theme.navBarGradientFrom);
      expect(gradient.colors[1], theme.navBarGradientMiddle);
      expect(gradient.colors[2], theme.navBarGradientTo);
      expect(theme.navBarGradientFrom, theme.navBarGradientMiddle);
      expect(gradient.stops, const [0.0, 0.5, 1.0]);
    }
  });
}
