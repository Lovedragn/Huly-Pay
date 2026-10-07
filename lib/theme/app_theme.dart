import 'package:flutter/material.dart';

// Theme and chart palette names
const List<String> kAppThemeNames = ['Oled black', 'Milk white', 'Red velvet'];

const List<String> kChartPaletteNames = [
  'Oled black',
  'Milk white',
  'Red velvet',
];

const Color kCloudWhite = Color(0xFFF4F6F9);

// Semantic theme color model
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
  final Color navBarGradientFrom;
  final Color navBarGradientMiddle;
  final Color navBarGradientTo;
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
    required this.navBarGradientFrom,
    required this.navBarGradientMiddle,
    required this.navBarGradientTo,
    required this.iconDefault,
    required this.iconBackground,
    required this.brightness,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  // Convenience card and badge getters
  Color get cardBackground => surface;
  Color get cardBorder => border;
  Color get badgeBackground => surfaceSecondary;

  // Flipped top gradient (from 100% solid color at top, 60% opacity at 0.6, to 0% transparent at bottom)
  LinearGradient get topBarGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      background.withValues(alpha: 1.0),
      background.withValues(alpha: 0.6),
      background.withValues(alpha: 0.3),
    ],
    stops: const [0.3, 0.8, 1.0],
  );

  // Bottom navbar gradient
  LinearGradient get bottomBarGradient => LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [navBarGradientFrom, navBarGradientMiddle, navBarGradientTo],
    stops: const [0.0, 0, 1.0],
  );

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
    Color? navBarGradientFrom,
    Color? navBarGradientMiddle,
    Color? navBarGradientTo,
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
      navBarGradientFrom: navBarGradientFrom ?? this.navBarGradientFrom,
      navBarGradientMiddle: navBarGradientMiddle ?? this.navBarGradientMiddle,
      navBarGradientTo: navBarGradientTo ?? this.navBarGradientTo,
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
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t) ??
          surfaceSecondary,
      border: Color.lerp(border, other.border, t) ?? border,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      navBarBackground:
          Color.lerp(navBarBackground, other.navBarBackground, t) ??
          navBarBackground,
      navBarActive:
          Color.lerp(navBarActive, other.navBarActive, t) ?? navBarActive,
      navBarInactive:
          Color.lerp(navBarInactive, other.navBarInactive, t) ?? navBarInactive,
      navBarGradientFrom:
          Color.lerp(navBarGradientFrom, other.navBarGradientFrom, t) ??
          navBarGradientFrom,
      navBarGradientMiddle:
          Color.lerp(navBarGradientMiddle, other.navBarGradientMiddle, t) ??
          navBarGradientMiddle,
      navBarGradientTo:
          Color.lerp(navBarGradientTo, other.navBarGradientTo, t) ??
          navBarGradientTo,
      iconDefault: Color.lerp(iconDefault, other.iconDefault, t) ?? iconDefault,
      iconBackground:
          Color.lerp(iconBackground, other.iconBackground, t) ?? iconBackground,
      brightness: t < 0.5 ? brightness : other.brightness,
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      error: Color.lerp(error, other.error, t) ?? error,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }

  // Oled black theme preset
  static const AppThemeData oledBlack = AppThemeData(
    name: 'Oled black',
    isDark: true,
    background: Color(0xFF000000),
    surface: Color(0xFF141416),
    surfaceSecondary: Color(0xFF1C1C20),
    border: Color(0x33FFFFFF),
    divider: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    textMuted: Color(0xFF6B6B70),
    accent: Color(0xFF30D158),
    navBarBackground: Color(0xFF141416),
    navBarActive: Color(0xFFFFFFFF),
    navBarInactive: Color(0xFF8E8E93),
    navBarGradientFrom: Color.fromARGB(153, 0, 0, 0),
    navBarGradientMiddle: Color.fromARGB(153, 0, 0, 0),
    navBarGradientTo: Color.fromARGB(0, 0, 0, 0),
    iconDefault: Color(0xFF8E8E93),
    iconBackground: Color(0xFF1C1C20),
    brightness: Brightness.dark,
    success: Color(0xFF30D158),
    warning: Color(0xFFFFD60A),
    error: Color(0xFFFF453A),
    info: Color(0xFF0A84FF),
  );

  // Milk white theme preset
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
    navBarActive: Color(0xFF111827),
    navBarInactive: Color(0xFF9CA3AF),
    navBarGradientFrom: Color.fromARGB(180, 255, 255, 255),
    navBarGradientMiddle: Color.fromARGB(180, 255, 255, 255),
    navBarGradientTo: Color.fromARGB(0, 255, 255, 255),
    iconDefault: Color(0xFF111827),
    iconBackground: Color(0xFFEFF2F6),
    brightness: Brightness.light,
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF0066FF),
  );

  // Red velvet theme preset
  static const AppThemeData redVelvet = AppThemeData(
    name: 'Red velvet',
    isDark: false,
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF7F8FA),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFEEEEEE),
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textMuted: Color(0xFF9CA3AF),
    accent: Color(0xFFEB0029),
    navBarBackground: Color(0xFFFFFFFF),
    navBarActive: Color(0xFF111827),
    navBarInactive: Color(0xFF9CA3AF),
    navBarGradientFrom: Color.fromARGB(255, 255, 255, 255),
    navBarGradientMiddle: Color.fromARGB(255, 255, 255, 255),
    navBarGradientTo: Color.fromARGB(0, 255, 255, 255),
    iconDefault: Color(0xFF111827),
    iconBackground: Color(0xFFF7F8FA),
    brightness: Brightness.light,
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9800),
    error: Color(0xFFEB0029),
    info: Color(0xFF0066FF),
  );
}

// Global theme state manager
class AppThemeManager {
  AppThemeManager._();

  // Active theme and palette notifiers
  static final ValueNotifier<String> currentTheme = ValueNotifier<String>(
    'Oled black',
  );
  static final ValueNotifier<String> currentChartPalette =
      ValueNotifier<String>('Oled black');

  // Active theme properties
  static AppThemeData get colors => getThemeColors(currentTheme.value);
  static String get theme => currentTheme.value;
  static String get chartPalette => currentChartPalette.value;

  // Normalize theme names
  static String normalizeTheme(String themeName) {
    final lower = themeName.toLowerCase().trim();
    if (lower.contains('red') ||
        lower.contains('velvet') ||
        lower.contains('oneplus')) {
      return 'Red velvet';
    } else if (lower.contains('milk') ||
        lower.contains('white') ||
        lower.contains('light')) {
      return 'Milk white';
    }
    return 'Oled black';
  }

  // Update theme globally
  static void setTheme(String themeName) {
    final resolved = normalizeTheme(themeName);
    if (currentTheme.value != resolved) {
      currentTheme.value = resolved;
    }
    if (currentChartPalette.value != resolved) {
      currentChartPalette.value = resolved;
    }
  }

  // Update chart palette globally
  static void setChartPalette(String paletteName) {
    final resolved = normalizeTheme(paletteName);
    if (currentChartPalette.value != resolved) {
      currentChartPalette.value = resolved;
    }
    if (currentTheme.value != resolved) {
      currentTheme.value = resolved;
    }
  }

  // Resolve AppThemeData by name
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

  // Produce Material ThemeData
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
      extensions: <ThemeExtension<dynamic>>[themeColors],
      dividerColor: themeColors.divider,
    );
  }
}

// Spacing tokens
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

// Radii tokens
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

// BuildContext extension for theme access
extension AppThemeContextExtension on BuildContext {
  AppThemeData get appTheme {
    final ext = Theme.of(this).extension<AppThemeData>();
    return ext ?? AppThemeManager.colors;
  }

  AppThemeData get colors => appTheme;
  bool get isDarkMode => appTheme.isDark;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// Chart color definitions and palettes
class AppChartColors {
  AppChartColors._();

  // Static reference colors
  static const Color blue = Color(0xFF007AFF);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color green = Color(0xFF30D158);
  static const Color amber = Color(0xFFFFD60A);
  static const Color rose = Color(0xFFFF375F);
  static const Color purple = Color(0xFFAF52DE);
  static const Color indigo = Color(0xFF5856D6);

  // Oled black palette
  static const List<Color> oledBlackPalette = [
    Color(0xFF30D158),
    Color(0xFF00E5FF),
    Color(0xFF007AFF),
    Color(0xFFFFD60A),
    Color(0xFFFF375F),
    Color(0xFFAF52DE),
    Color(0xFF5856D6),
  ];

  // Milk white palette
  static const List<Color> milkWhitePalette = [
    Color(0xFF0066FF),
    Color(0xFF00B4D8),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF3B82F6),
  ];

  // Red velvet palette
  static const List<Color> redVelvetPalette = [
    Color(0xFFFFD600),
    Color(0xFFFFAB00),
    Color(0xFFFF6D00),
    Color(0xFFFF3D00),
    Color(0xFFEB0029),
    Color(0xFFFF1744),
    Color(0xFFC00021),
  ];

  // Default fallback palette
  static const List<Color> defaultPalette = oledBlackPalette;

  // Palette lookup map
  static const Map<String, List<Color>> allPalettes = {
    'Oled black': oledBlackPalette,
    'Milk white': milkWhitePalette,
    'Red velvet': redVelvetPalette,
  };

  // Active theme chart palette
  static List<Color> get globalPalette {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );
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

  // Trend line gradient
  static List<Color> get primaryGradient {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );
    if (activeTheme == 'Red velvet') {
      return const [Color(0xFFEB0029), Color(0xFFEB0029)];
    }
    final p = globalPalette;
    return [p[1], p[0]];
  }

  // Spend trend dot color
  static Color get trendDotColor {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );
    if (activeTheme == 'Red velvet') {
      return const Color(0xFFEB0029);
    }
    return globalPalette[1];
  }

  // Threshold colors
  static Color get thresholdMain => globalPalette[3];
  static Color get thresholdBelow => globalPalette[2];
  static Color get thresholdAbove => globalPalette[4];

  // Gauge colors
  static Color get gaugeSafe => globalPalette[2];
  static Color get gaugeModerate => globalPalette[3];
  static Color get gaugeHigh => globalPalette[4];

  // Bar chart colors
  static Color get barTouched => globalPalette[1];
  static Color get barToday => globalPalette[0];
  static Color get barDefault => globalPalette[0].withValues(alpha: 0.45);

  static Color get barTrack => AppThemeManager.colors.isDark
      ? const Color(0xFF1C1C20)
      : const Color(0xFFE5E7EB);

  // 5-level heatmap palette per theme
  static List<Color> get heatmapPalette {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );

    if (activeTheme == 'Oled black') {
      return const [
        Color(0xFF141715),
        Color(0xFF1E3A27),
        Color(0xFF236838),
        Color(0xFF2BB653),
        Color(0xFF34E869),
      ];
    } else if (activeTheme == 'Red velvet') {
      return const [
        Color.fromARGB(255, 255, 255, 255),
        Color.fromARGB(255, 255, 150, 150),
        Color.fromARGB(255, 255, 100, 100),
        Color.fromARGB(255, 255, 30, 30),
        Color.fromARGB(255, 255, 0, 0),
      ];
    } else {
      return const [
        Color(0xFFEFF2F6),
        Color(0xFFBAE6FD),
        Color(0xFF60A5FA),
        Color(0xFF2563EB),
        Color(0xFF1E40AF),
      ];
    }
  }

  // Heatmap selected cell highlight
  static Color get heatmapSelected {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );
    if (activeTheme == 'Oled black') {
      return const Color(0xFF34E869);
    } else if (activeTheme == 'Red velvet') {
      return const Color(0xFFEB0029);
    } else {
      return const Color(0xFF007AFF);
    }
  }

  // Heatmap chip border color
  static Color get heatmapChipBorder {
    final activeTheme = AppThemeManager.normalizeTheme(
      AppThemeManager.currentTheme.value,
    );
    if (activeTheme == 'Oled black') {
      return const Color(0xFF30D158);
    } else if (activeTheme == 'Red velvet') {
      return const Color(0xFFEB0029);
    } else {
      return const Color(0xFF007AFF);
    }
  }
}
