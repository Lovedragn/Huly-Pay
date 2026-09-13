import 'package:flutter/material.dart';

/// Centralized Global Chart Color Schema for Huly.Pay
///
/// All charts across the application (Line Chart, Gauge Chart, Weekly Bar Chart,
/// Analysis Donut / Pie Chart, and Spending Heatmap) are controlled by this
/// single, unified list of colors.
class AppChartColors {
  AppChartColors._();

  // ---------------------------------------------------------------------------
  // 1. Unified Global List of Colors (Single Source of Truth)
  // ---------------------------------------------------------------------------

  static const Color blue = Color(0xFF007AFF); // 0: Electric Blue (Primary)
  static const Color cyan = Color(0xFF00E5FF); // 1: Vibrant Cyan (Highlight / Active)
  static const Color green = Color(0xFF30D158); // 2: Mint / Emerald Green (Safe / Growth)
  static const Color amber = Color(0xFFFFD60A); // 3: Radiant Gold / Amber (Warning / Medium)
  static const Color rose = Color(0xFFFF375F); // 4: Crimson Rose / Coral Red (High / Peak)
  static const Color purple = Color(0xFFAF52DE); // 5: Electric Purple
  static const Color indigo = Color(0xFF5856D6); // 6: Deep Royal Indigo

  /// The global list of colors controlling all charts across the app.
  static const List<Color> globalPalette = [
    blue,
    cyan,
    green,
    amber,
    rose,
    purple,
    indigo,
  ];

  // ---------------------------------------------------------------------------
  // 2. Semantic Palette Aliases & Derived Sets (Driven by globalPalette)
  // ---------------------------------------------------------------------------

  /// Primary gradient pair (Cyan -> Electric Blue) for curves and flow lines
  static List<Color> get primaryGradient => [cyan, blue];

  /// Dual-zone / Range threshold colors (Line chart)
  static Color get thresholdMain => amber;
  static Color get thresholdBelow => green;
  static Color get thresholdAbove => rose;

  /// Gauge threshold zone colors (Safe, Moderate, High)
  static Color get gaugeSafe => green;
  static Color get gaugeModerate => amber;
  static Color get gaugeHigh => rose;

  /// Bar chart state colors
  static Color get barTouched => cyan;
  static Color get barToday => blue;
  static Color get barDefault => const Color(0xFF6B6B70);
  static Color get barTrack => const Color(0xFF1C1C20);

  /// Heatmap activity intensity palette (from dark surface up to peak green)
  static List<Color> get heatmapPalette => const [
        Color(0xFF1C1C22), // Level 0: Inactive
        Color(0xFF0B3820), // Level 1: Subtle
        Color(0xFF136E38), // Level 2: Moderate
        Color(0xFF1FA352), // Level 3: High
        green, // Level 4: Peak Activity (matches global green)
      ];

  /// Heatmap selected cell highlight color
  static Color get heatmapSelected => cyan;

  /// Heatmap active inspector chip border/accent
  static Color get heatmapChipBorder => blue;
}
