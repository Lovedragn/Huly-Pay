import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Global list of string identifiers for App Themes and Chart Color Palettes
/// Shared across all pages of HulyPay
/// ---------------------------------------------------------------------------

const List<String> kAppThemeNames = [
  'Oled black',
  'Milk white',
  'Red velvet',
];

const List<String> kChartPaletteNames = [
  'Oled black',
  'Milk white',
  'Red velvet',
];

/// Named Cloud White tint for Clean White mode icon backgrounds and elevated surfaces
const Color kCloudWhite = Color(0xFFF4F6F9);

/// Semantic Theme Color Model for HulyPay (extends ThemeExtension for idiomatic Flutter ThemeData integration)
class AppThemeData extends ThemeExtension<AppThemeData> {
  final String name;
  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceSecondary;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color navBarBackground;
  final Color navBarActive;
  final Color navBarInactive;
  final Color iconDefault;
  final Color iconBackground;
  final Brightness brightness;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppThemeData({
    required this.name,
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceSecondary,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.navBarBackground,
    required this.navBarActive,
    required this.navBarInactive,
    required this.iconDefault,
    required this.iconBackground,
    required this.brightness,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  /// Convenience card and badge helpers
  Color get cardBackground => surface;
  Color get cardBorder => border;
  Color get badgeBackground => surfaceSecondary;

  @override
  AppThemeData copyWith({
    String? name,
    bool? isDark,
    Color? background,
    Color? surface,
    Color? surfaceSecondary,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? navBarBackground,
    Color? navBarActive,
    Color? navBarInactive,
    Color? iconDefault,
    Color? iconBackground,
    Brightness? brightness,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppThemeData(
      name: name ?? this.name,
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      navBarBackground: navBarBackground ?? this.navBarBackground,
      navBarActive: navBarActive ?? this.navBarActive,
      navBarInactive: navBarInactive ?? this.navBarInactive,
      iconDefault: iconDefault ?? this.iconDefault,
      iconBackground: iconBackground ?? this.iconBackground,
      brightness: brightness ?? this.brightness,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppThemeData lerp(ThemeExtension<AppThemeData>? other, double t) {
    if (other is! AppThemeData) return this;
    return AppThemeData(
      name: t < 0.5 ? name : other.name,
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t) ?? surfaceSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      navBarBackground: Color.lerp(navBarBackground, other.navBarBackground, t) ?? navBarBackground,
      navBarActive: Color.lerp(navBarActive, other.navBarActive, t) ?? navBarActive,
      navBarInactive: Color.lerp(navBarInactive, other.navBarInactive, t) ?? navBarInactive,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t) ?? iconDefault,
      iconBackground: Color.lerp(iconBackground, other.iconBackground, t) ?? iconBackground,
      brightness: t < 0.5 ? brightness : other.brightness,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }

  /// 1. Oled black (Default Pure Black AMOLED Scheme)
  static const AppThemeData oledBlack = AppThemeData(
    name: 'Oled black',
    isDark: true,
    background: Color(0xFF000000),
    surface: Color(0xFF141416),
    surfaceSecondary: Color(0xFF1C1C20),
    border: Color(0x33FFFFFF), // Light white border for cards
    divider: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    textMuted: Color(0xFF6B6B70),
    accent: Color(0xFF30D158), // Dominant Emerald/Mint Green
    navBarBackground: Color(0xFF000000),
    navBarActive: Color(0xFFFFFFFF), // Crisp White active bottom nav icon
    navBarInactive: Color(0xFF8E8E93),
    iconDefault: Color(0xFF8E8E93),
    iconBackground: Color(0xFF1C1C20),
    brightness: Brightness.dark,
    success: Color(0xFF30D158),
    warning: Color(0xFFFFD60A),
    error: Color(0xFFFF453A),
    info: Color(0xFF0A84FF),
  );

  /// 2. Milk white (Clean Ivory/Milk Light Mode Scheme)
  static const AppThemeData milkWhite = AppThemeData(
    name: 'Milk white',
    isDark: false,
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFEFF2F6),
    border: Color(0xFFE2E6EE),
    divider: Color(0xFFE8ECF2),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF6B7280),
    accent: Color(0xFF007AFF),
    navBarBackground: Color(0xFFFFFFFF),
    navBarActive: Color(0xFF111827), // Crisp Dark active bottom nav icon
    navBarInactive: Color(0xFF9CA3AF),
    iconDefault: Color(0xFF111827),
    iconBackground: Color(0xFFEFF2F6),
    brightness: Brightness.light,
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF0066FF),
  );

  /// 3. Red velvet (Clean White background, crisp dark typography, signature Red big amount)
  static const AppThemeData redVelvet = AppThemeData(
    name: 'Red velvet',
    isDark: false,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF7F8FA),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF111827), // Crisp readable dark text
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF9CA3AF),
    accent: Color(0xFFEB0029), // Signature Red Velvet
    navBarBackground: Color(0xFFFFFFFF),
    navBarActive: Color(0xFF111827), // Like Milk White: crisp Dark active bottom nav icon
    navBarInactive: Color(0xFF9CA3AF),
    iconDefault: Color(0xFF111827),
    iconBackground: Color(0xFFF7F8FA),
    brightness: Brightness.light,
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9800),
    error: Color(0xFFEB0029),
    info: Color(0xFF0066FF),
  );

  /// Backward compatibility aliases
  static const AppThemeData black = oledBlack;
  static const AppThemeData white = milkWhite;
  static const AppThemeData blue = oledBlack;
  static const AppThemeData oneplusRed = redVelvet;
}

/// Global Theme State Manager
class AppThemeManager {
  AppThemeManager._();

  /// Global reactive theme notifier
  static final ValueNotifier<String> currentTheme = ValueNotifier<String>('Oled black');

  /// Global reactive chart palette notifier (auto-synced to currentTheme)
  static final ValueNotifier<String> currentChartPalette = ValueNotifier<String>('Oled black');

  /// Active theme data
  static AppThemeData get colors => getThemeColors(currentTheme.value);

  /// Active theme name
  static String get theme => currentTheme.value;

  /// Active chart palette name
  static String get chartPalette => currentChartPalette.value;

  /// Normalize theme names to handle aliases like 'Black', 'White', 'Blue', etc.
  static String normalizeTheme(String themeName) {
    final lower = themeName.toLowerCase().trim();
    if (lower.contains('red') || lower.contains('velvet') || lower.contains('oneplus')) {
      return 'Red velvet';
    } else if (lower.contains('milk') || lower.contains('white') || lower.contains('light')) {
      return 'Milk white';
    }
    return 'Oled black';
  }

  /// Change active app theme globally (automatically synchronizes chart palette)
  static void setTheme(String themeName) {
    final resolved = normalizeTheme(themeName);
    if (currentTheme.value != resolved) {
      currentTheme.value = resolved;
    }
    // Keep chart palette directly unified with app theme
    if (currentChartPalette.value != resolved) {
      currentChartPalette.value = resolved;
    }
  }

  /// Change active chart color palette globally (unified to theme)
  static void setChartPalette(String paletteName) {
    final resolved = normalizeTheme(paletteName);
    if (currentChartPalette.value != resolved) {
      currentChartPalette.value = resolved;
    }
    if (currentTheme.value != resolved) {
      currentTheme.value = resolved;
    }
  }

  /// Get AppThemeData by theme name
  static AppThemeData getThemeColors(String themeName) {
    final resolved = normalizeTheme(themeName);
    switch (resolved) {
      case 'Milk white':
        return AppThemeData.milkWhite;
      case 'Red velvet':
        return AppThemeData.redVelvet;
      case 'Oled black':
      default:
        return AppThemeData.oledBlack;
    }
  }

  /// Produce Material ThemeData for MaterialApp
  static ThemeData getMaterialTheme(String themeName) {
    final themeColors = getThemeColors(themeName);
    final isDark = themeColors.isDark;

    return ThemeData(
      useMaterial3: true,
      brightness: themeColors.brightness,
      scaffoldBackgroundColor: themeColors.background,
      fontFamily: 'Google Sans',
      fontFamilyFallback: const ['GoogleSans', 'Open Sans', 'sans-serif'],
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: themeColors.accent,
              surface: themeColors.surface,
            )
          : ColorScheme.light(
              primary: themeColors.accent,
              surface: themeColors.surface,
            ),
      extensions: <ThemeExtension<dynamic>>[
        themeColors,
      ],
      dividerColor: themeColors.divider,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Design Tokens: Spacing & Radii (Centralized Single Source of Truth)
/// ---------------------------------------------------------------------------

class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class AppRadii {
  AppRadii._();

  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double card = 24.0;
  static const double sheet = 32.0;
  static const double pill = 100.0;
}

/// ---------------------------------------------------------------------------
/// Idiomatic Flutter BuildContext Extension for Clean Theming
/// Allows writing `context.appTheme.surface` or `context.colors.textPrimary`
/// ---------------------------------------------------------------------------

extension AppThemeContextExtension on BuildContext {
  /// Access active AppThemeData via ThemeData extension or fallback to AppThemeManager
  AppThemeData get appTheme {
    final ext = Theme.of(this).extension<AppThemeData>();
    return ext ?? AppThemeManager.colors;
  }

  /// Shorthand alias for `context.appTheme`
  AppThemeData get colors => appTheme;

  /// Quick brightness check
  bool get isDarkMode => appTheme.isDark;

  /// Core Theme.of(context) shortcuts
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

/// ---------------------------------------------------------------------------
/// Unified App Chart Colors (Merged from chart_colors.dart)
/// Automatically tied to active theme: Oled black, Milk white, Red velvet
/// ---------------------------------------------------------------------------

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
  // 2. Pre-defined Chart Color Palettes corresponding to kAppThemeNames
  // ---------------------------------------------------------------------------

  /// 1. Oled Black Palette (Luminous OLED Accents with dominant Emerald/Mint Green)
  static const List<Color> oledBlackPalette = [
    Color(0xFF30D158), // 0: Mint / Emerald Green (Dominant Primary)
    Color(0xFF00E5FF), // 1: Vibrant Cyan (Highlight)
    Color(0xFF007AFF), // 2: Electric Blue
    Color(0xFFFFD60A), // 3: Radiant Amber Gold
    Color(0xFFFF375F), // 4: Crimson Rose
    Color(0xFFAF52DE), // 5: Electric Purple
    Color(0xFF5856D6), // 6: Deep Royal Indigo
  ];

  /// 2. Milk White Palette (Fresh, clean, high-clarity professional accents)
  static const List<Color> milkWhitePalette = [
    Color(0xFF0066FF), // 0: Pure Royal Blue
    Color(0xFF00B4D8), // 1: Clean Ocean Cyan
    Color(0xFF10B981), // 2: Fresh Mint Green
    Color(0xFFF59E0B), // 3: Warm Amber Gold
    Color(0xFFEF4444), // 4: Soft Rose Red
    Color(0xFF8B5CF6), // 5: Soft Lavender Purple
    Color(0xFF3B82F6), // 6: Sky Blue
  ];

  /// 3. Red Velvet Palette (Bright Yellow to Radiant Red Gradient Palette)
  static const List<Color> redVelvetPalette = [
    Color(0xFFFFD600), // 0: Bright Neon Yellow
    Color(0xFFFFAB00), // 1: Warm Golden Amber
    Color(0xFFFF6D00), // 2: Radiant Orange
    Color(0xFFFF3D00), // 3: Bright Coral Scarlet
    Color(0xFFEB0029), // 4: Signature OnePlus / Velvet Red
    Color(0xFFFF1744), // 5: Electric Crimson Red
    Color(0xFFC00021), // 6: Deep Ruby Red
  ];

  /// Backward compatibility aliases
  static const List<Color> defaultPalette = oledBlackPalette;
  static const List<Color> oneplusRedPalette = redVelvetPalette;

  /// Palette lookup map
  static const Map<String, List<Color>> allPalettes = {
    'Oled black': oledBlackPalette,
    'Milk white': milkWhitePalette,
    'Red velvet': redVelvetPalette,
    // Aliases
    'OnePlus red': redVelvetPalette,
    'Black': oledBlackPalette,
    'White': milkWhitePalette,
    'Red': redVelvetPalette,
    'Default': oledBlackPalette,
  };

  /// The active global list of colors controlling all charts across the app.
  static List<Color> get globalPalette {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);
    switch (activeTheme) {
      case 'Milk white':
        return milkWhitePalette;
      case 'Red velvet':
        return redVelvetPalette;
      case 'Oled black':
      default:
        return oledBlackPalette;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Semantic Palette Aliases & Derived Sets (Dynamically driven by active palette)
  // ---------------------------------------------------------------------------

  /// Primary gradient pair for curves and flow lines
  static List<Color> get primaryGradient {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);
    if (activeTheme == 'Red velvet') {
      // Red velvet style: bright red trend line
      return const [Color(0xFFEB0029), Color(0xFFEB0029)];
    }
    final p = globalPalette;
    return [p[1], p[0]];
  }

  /// Dot color for Spend Trend chart points
  static Color get trendDotColor {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);
    if (activeTheme == 'Red velvet') {
      // Red velvet style: signature red dots
      return const Color(0xFFEB0029);
    }
    return globalPalette[1]; // Vibrant Cyan or highlight
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

  // ---------------------------------------------------------------------------
  // Heatmap Palettes (Specific monochromatic gradient ramps per theme)
  // ---------------------------------------------------------------------------

  /// Dedicated 5-level Heatmap Palette per theme:
  /// - Oled black: Black bg -> Light mint/green -> Medium bright green -> Bright neon green -> Deep vibrant emerald
  /// - Red velvet: Light gray bg -> Soft light coral/red -> Warm bright red -> Vivid red -> Signature deep velvet red
  /// - Milk white: Soft gray bg -> Pale sky blue -> Vibrant royal blue -> Deep cobalt -> Midnight navy blue
  static List<Color> get heatmapPalette {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);

    if (activeTheme == 'Oled black') {
      // Oled black: Pure green gradation (Level 0: dark cell -> Level 1: soft mint green -> Level 4: luminous bright green)
      return const [
        Color(0xFF141715), // Level 0: Inactive cell
        Color(0xFF1E3A27), // Level 1: Low spend (deep subtle green)
        Color(0xFF236838), // Level 2: Moderate low (medium forest green)
        Color(0xFF2BB653), // Level 3: High spend (bright emerald green)
        Color(0xFF34E869), // Level 4: Highest spend (electric bright neon green)
      ];
    } else if (activeTheme == 'Red velvet') {
      // Red velvet: Clean monochromatic red gradation (Level 0: clean surface -> Level 4: signature red velvet)
      return const [
        Color.fromARGB(255, 255, 255, 255), // Level 0: Inactive cell
        Color.fromARGB(255, 255, 150, 150), // Level 1: Low spend (light rose / soft blush)
        Color.fromARGB(255, 255, 100, 100), // Level 2: Moderate low (medium coral red)
        Color.fromARGB(255, 255, 30, 30), // Level 3: High spend (vibrant crimson red)
        Color.fromARGB(255, 255, 0, 0), // Level 4: Highest spend (signature red font color)
      ];
    } else {
      // Milk white: Clean monochromatic blue gradation (Level 0: clean surface -> Level 4: deep royal blue)
      return const [
        Color(0xFFEFF2F6), // Level 0: Inactive cell
        Color(0xFFBAE6FD), // Level 1: Low spend (light sky blue)
        Color(0xFF60A5FA), // Level 2: Moderate low (clear azure blue)
        Color(0xFF2563EB), // Level 3: High spend (vibrant royal blue)
        Color(0xFF1E40AF), // Level 4: Highest spend (deep cobalt navy)
      ];
    }
  }

  /// Heatmap selected cell highlight color
  static Color get heatmapSelected {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);
    if (activeTheme == 'Oled black') {
      return const Color(0xFF34E869);
    } else if (activeTheme == 'Red velvet') {
      return const Color(0xFFEB0029);
    } else {
      return const Color(0xFF007AFF);
    }
  }

  /// Heatmap active inspector chip border/accent
  static Color get heatmapChipBorder {
    final activeTheme = AppThemeManager.normalizeTheme(AppThemeManager.currentTheme.value);
    if (activeTheme == 'Oled black') {
      return const Color(0xFF30D158);
    } else if (activeTheme == 'Red velvet') {
      return const Color(0xFFEB0029);
    } else {
      return const Color(0xFF007AFF);
    }
  }
}

