import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppChartColors {
  AppChartColors._();

  // ---------------------------------------------------------------------------
  // 1. Static Reference Colors (for backward compatibility & baseline definitions)
  // ---------------------------------------------------------------------------

  static const Color blue = Color(0xFF007AFF); // 0: Electric Blue (Primary)
  static const Color cyan = Color(0xFF00E5FF); // 1: Vibrant Cyan (Highlight / Active)
  static const Color green = Color(0xFF30D158); // 2: Mint / Emerald Green (Safe / Growth)
  static const Color amber = Color(0xFFFFD60A); // 3: Radiant Gold / Amber (Warning / Medium)
  static const Color rose = Color(0xFFFF375F); // 4: Crimson Rose / Coral Red (High / Peak)
  static const Color purple = Color(0xFFAF52DE); // 5: Electric Purple
  static const Color indigo = Color(0xFF5856D6); // 6: Deep Royal Indigo

  // ---------------------------------------------------------------------------
  // 2. Pre-defined Chart Color Palettes corresponding to kChartPaletteNames
  // ---------------------------------------------------------------------------

  /// Default Palette (Original Curated Scheme)
  static const List<Color> defaultPalette = [
    blue,
    cyan,
    green,
    amber,
    rose,
    purple,
    indigo,
  ];

  /// Emerald Mint Palette (Growth & Green Finance Focus)
  static const List<Color> emeraldMintPalette = [
    Color(0xFF00C076), // 0: Emerald
    Color(0xFF00E5FF), // 1: Turquoise Cyan
    Color(0xFF30D158), // 2: Mint Green
    Color(0xFFA3E635), // 3: Bright Lime
    Color(0xFF10B981), // 4: Jade
    Color(0xFF2DD4BF), // 5: Aqua
    Color(0xFF059669), // 6: Forest
  ];

  /// Cyber Purple Palette (Neon Cyberpunk & Violet)
  static const List<Color> cyberPurplePalette = [
    Color(0xFFAF52DE), // 0: Electric Purple
    Color(0xFF00E5FF), // 1: Neon Cyan
    Color(0xFF30D158), // 2: Mint
    Color(0xFFFFD60A), // 3: Amber
    Color(0xFFFF375F), // 4: Neon Pink
    Color(0xFFBF5AF2), // 5: Violet
    Color(0xFF5856D6), // 6: Royal Indigo
  ];

  /// Sunset Gold Palette (Warm Amber & Radiant Coral)
  static const List<Color> sunsetGoldPalette = [
    Color(0xFFFF9500), // 0: Sunset Orange
    Color(0xFFFFD60A), // 1: Amber Gold
    Color(0xFF30D158), // 2: Green
    Color(0xFFFB923C), // 3: Warm Peach
    Color(0xFFFF375F), // 4: Coral Red
    Color(0xFFF59E0B), // 5: Honey
    Color(0xFFEF4444), // 6: Crimson
  ];

  /// Ocean Blue Palette (Sapphire & Marine Azure)
  static const List<Color> oceanBluePalette = [
    Color(0xFF007AFF), // 0: Electric Blue
    Color(0xFF00E5FF), // 1: Sky Cyan
    Color(0xFF30D158), // 2: Mint
    Color(0xFF38BDF8), // 3: Light Sky
    Color(0xFFFF375F), // 4: Rose Accent
    Color(0xFF2563EB), // 5: Deep Blue
    Color(0xFF06B6D4), // 6: Ocean Teal
  ];

  /// Palette lookup map
  static const Map<String, List<Color>> allPalettes = {
    'Default': defaultPalette,
    'Emerald Mint': emeraldMintPalette,
    'Emerald Slate': emeraldMintPalette,
    'Cyber Purple': cyberPurplePalette,
    'Sunset Gold': sunsetGoldPalette,
    'Ocean Blue': oceanBluePalette,
  };

  /// The active global list of colors controlling all charts across the app.
  static List<Color> get globalPalette {
    final active = AppThemeManager.currentChartPalette.value;
    return allPalettes[active] ?? defaultPalette;
  }

  // ---------------------------------------------------------------------------
  // 3. Semantic Palette Aliases & Derived Sets (Dynamically driven by active palette)
  // ---------------------------------------------------------------------------

  /// Primary gradient pair for curves and flow lines
  static List<Color> get primaryGradient {
    final p = globalPalette;
    return [p[1], p[0]];
  }

  /// Dual-zone / Range threshold colors (Line chart)
  static Color get thresholdMain => globalPalette[3];
  static Color get thresholdBelow => globalPalette[2];
  static Color get thresholdAbove => globalPalette[4];

  /// Gauge threshold zone colors (Safe, Moderate, High)
  static Color get gaugeSafe => globalPalette[2];
  static Color get gaugeModerate => globalPalette[3];
  static Color get gaugeHigh => globalPalette[4];

  /// Bar chart state colors driven by active chart palette
  static Color get barTouched => globalPalette[1];
  static Color get barToday => globalPalette[0];
  static Color get barDefault => globalPalette[0].withValues(alpha: 0.45);

  static Color get barTrack => AppThemeManager.colors.isDark
      ? const Color(0xFF1C1C20)
      : const Color(0xFFE5E7EB);

   static List<Color> get heatmapPalette {
    final p = globalPalette;
    // Primary palette accent color (e.g. green in emerald, purple in cyber, amber in sunset, etc.)
    final accent = p[0];
    final highlight = p[1]; // Bright highlight tint in the palette
    final isDark = AppThemeManager.colors.isDark;

    // Background tint for empty cell (0 spend)
    final bg = isDark ? const Color(0xFF1C1C22) : const Color(0xFFE5E7EB);

    if (isDark) {
       return [
        bg,                                                        // Level 0: ₹0 (inactive)
        Color.lerp(highlight, Colors.white, 0.35)!,               // Level 1: Lowest spend (brighter & luminous)
        highlight,                                                 // Level 2: Moderate low spend
        accent,                                                    // Level 3: Higher spend
        Color.lerp(accent, const Color(0xFF000000), 0.35)!,        // Level 4: Highest spend (deepest saturated tone)
      ];
    } else {
        return [
        bg,                                                        // Level 0: ₹0 (inactive)
        Color.lerp(highlight, Colors.white, 0.65)!,               // Level 1: Lowest spend (brightest pastel)
        Color.lerp(highlight, accent, 0.4)!,                       // Level 2: Moderate low spend
        accent,                                                    // Level 3: Higher spend
        Color.lerp(accent, const Color(0xFF000000), 0.45)!,        // Level 4: Highest spend (deepest rich shade)
      ];
    }
  }

  /// Heatmap selected cell highlight color
  static Color get heatmapSelected => globalPalette[1];

  /// Heatmap active inspector chip border/accent
  static Color get heatmapChipBorder => globalPalette[0];
}
