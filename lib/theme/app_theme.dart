import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Global list of string identifiers for App Themes and Chart Color Palettes
/// Shared across all pages of HulyPay
/// ---------------------------------------------------------------------------

const List<String> kAppThemeNames = [
  'Black', // Default (OLED Dark)
  'White', // Clean White (Light Mode)
  'Blue',  // Deep Blue (Oceanic Midnight)
];

const List<String> kChartPaletteNames = [
  'Default',       // Current chart colors (Electric Blue, Cyan, Mint, Amber, Rose)
  'Emerald Mint',  // Mint, Emerald, Lime, Teal, Jade
  'Cyber Purple',  // Electric Purple, Violet, Neon Pink, Indigo, Cyan
  'Sunset Gold',   // Sunset Orange, Amber Gold, Coral, Peach, Crimson
  'Ocean Blue',    // Electric Blue, Sky Cyan, Marine Azure, Deep Sapphire
];

/// Named Cloud White tint for Clean White mode icon backgrounds and elevated surfaces
const Color kCloudWhite = Color(0xFFF4F6F9);

/// Semantic Theme Color Model for HulyPay
class AppThemeData {
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
  });

  /// 1. Black (Default OLED Scheme)
  static const AppThemeData black = AppThemeData(
    name: 'Black',
    isDark: true,
    background: Color(0xFF000000),
    surface: Color(0xFF141416),
    surfaceSecondary: Color(0xFF1C1C20),
    border: Color(0x33FFFFFF), // Light white border for cards
    divider: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8E8E93),
    textMuted: Color(0xFF6B6B70),
    accent: Color(0xFF007AFF),
    navBarBackground: Color(0xFF000000),
    navBarActive: Color(0xFFFFFFFF),
    navBarInactive: Color(0xFF8E8E93),
    iconDefault: Color(0xFF8E8E93),
    iconBackground: Color(0xFF1C1C20),
    brightness: Brightness.dark,
  );

  /// 2. White (Clean Light Mode Scheme)
  static const AppThemeData white = AppThemeData(
    name: 'White',
    isDark: false,
    background: Color(0xFFF6F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceSecondary: kCloudWhite,
    border: Color(0xFFE2E6EE),
    divider: Color(0xFFE8ECF2),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF222226),
    textMuted: Color(0xFF4B5563),
    accent: Color(0xFF007AFF),
    navBarBackground: Color(0xFFFFFFFF),
    navBarActive: Color(0xFF000000),
    navBarInactive: Color(0xFF6B7280),
    iconDefault: Color(0xFF000000),
    iconBackground: kCloudWhite,
    brightness: Brightness.light,
  );

  /// 3. Blue (Deep Oceanic Midnight Scheme)
  static const AppThemeData blue = AppThemeData(
    name: 'Blue',
    isDark: true,
    background: Color(0xFF060B18),
    surface: Color(0xFF0C1630),
    surfaceSecondary: Color(0xFF132042),
    border: Color(0x33FFFFFF), // Light white border for cards
    divider: Color(0x24FFFFFF),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF8CA5C8),
    textMuted: Color(0xFF5B759C),
    accent: Color(0xFF388BFD),
    navBarBackground: Color(0xFF060B18),
    navBarActive: Color(0xFF58A6FF),
    navBarInactive: Color(0xFF6A85AC),
    iconDefault: Color(0xFF8CA5C8),
    iconBackground: Color(0xFF132042),
    brightness: Brightness.dark,
  );
}

/// Global Theme State Manager
class AppThemeManager {
  AppThemeManager._();

  /// Global reactive theme notifier
  static final ValueNotifier<String> currentTheme = ValueNotifier<String>('Black');

  /// Global reactive chart palette notifier
  static final ValueNotifier<String> currentChartPalette = ValueNotifier<String>('Default');

  /// Active theme data
  static AppThemeData get colors => getThemeColors(currentTheme.value);

  /// Active theme name
  static String get theme => currentTheme.value;

  /// Active chart palette name
  static String get chartPalette => currentChartPalette.value;

  /// Normalize theme names to handle aliases like 'OLED Black' or 'Midnight Dark'
  static String normalizeTheme(String themeName) {
    final lower = themeName.toLowerCase().trim();
    if (lower.contains('white') || lower.contains('light')) {
      return 'White';
    } else if (lower.contains('blue') || lower.contains('midnight')) {
      return 'Blue';
    }
    return 'Black';
  }

  /// Change active app theme globally
  static void setTheme(String themeName) {
    final resolved = normalizeTheme(themeName);
    if (currentTheme.value != resolved) {
      currentTheme.value = resolved;
    }
  }

  /// Change active chart color palette globally
  static void setChartPalette(String paletteName) {
    if (kChartPaletteNames.contains(paletteName) && currentChartPalette.value != paletteName) {
      currentChartPalette.value = paletteName;
    }
  }

  /// Get AppThemeData by theme name
  static AppThemeData getThemeColors(String themeName) {
    final resolved = normalizeTheme(themeName);
    switch (resolved) {
      case 'White':
        return AppThemeData.white;
      case 'Blue':
        return AppThemeData.blue;
      case 'Black':
      default:
        return AppThemeData.black;
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
      dividerColor: themeColors.divider,
    );
  }
}
