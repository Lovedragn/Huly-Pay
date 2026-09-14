import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_dashboard_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

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

  static const String appFontFamily = 'Google Sans';
  static const List<String> appFontFallback = [
    'GoogleSans',
    'Open Sans',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HulyPay',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: appFontFamily,
        fontFamilyFallback: appFontFallback,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        fontFamily: appFontFamily,
        fontFamilyFallback: appFontFallback,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          surface: Color(0xFF141416),
        ),
      ),
      home:
          home ??
          (showSplash
              ? SplashScreen(
                  initializeAuth: initializeAuth,
                  nextScreen: nextScreen,
                  isAuthenticated: isAuthenticated,
                )
              : const HomeDashboardScreen()),
    );
  }
}
