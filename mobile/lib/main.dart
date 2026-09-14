import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'services/user_preferences_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Load previously cached theme & color presets before the first frame to eliminate theme flicker
  try {
    await UserPreferencesService().loadLocalPreferences();
  } catch (_) {}

  // Instantly render SplashScreen on the very first frame without blocking on auth or dotenv
  runApp(const HulyPayApp(showSplash: true));
}

class HulyPayApp extends StatelessWidget {
  final bool showSplash;
  final Widget? home;
  final bool initializeAuth;
  final Widget? nextScreen;
  final bool? isAuthenticated;

  const HulyPayApp({
    super.key,
    this.showSplash = false,
    this.home,
    this.initializeAuth = true,
    this.nextScreen,
    this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppThemeManager.currentTheme,
      builder: (context, currentThemeName, _) {
        return ValueListenableBuilder<String>(
          valueListenable: AppThemeManager.currentChartPalette,
          builder: (context, currentChartPaletteName, _) {
            final activeThemeColors = AppThemeManager.colors;
            final materialTheme = AppThemeManager.getMaterialTheme(currentThemeName);

            // Update system status bar icons based on theme brightness
            SystemChrome.setSystemUIOverlayStyle(
              SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: activeThemeColors.isDark
                    ? Brightness.light
                    : Brightness.dark,
                statusBarBrightness: activeThemeColors.isDark
                    ? Brightness.dark
                    : Brightness.light,
              ),
            );

            return MaterialApp(
              title: 'HulyPay',
              debugShowCheckedModeBanner: false,
              theme: materialTheme,
              darkTheme: materialTheme,
              themeMode: activeThemeColors.isDark ? ThemeMode.dark : ThemeMode.light,
              home: home ??
                  (showSplash
                      ? SplashScreen(
                          initializeAuth: initializeAuth,
                          nextScreen: nextScreen,
                          isAuthenticated: isAuthenticated,
                        )
                      : const HomeDashboardScreen()),
            );
          },
        );
      },
    );
  }
}
