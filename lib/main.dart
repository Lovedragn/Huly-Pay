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
  runApp(const HulyPayApp(showSplash: true));
}

class HulyPayApp extends StatelessWidget {
  final bool showSplash;
  final Widget? home;

  const HulyPayApp({super.key, this.showSplash = false, this.home});

  static const String appFontFamily = 'Google Sans';
  static const List<String> appFontFallback = [
    'GoogleSans',
    'Open Sans',
    'sans-serif',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Huly Pay',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
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
          (showSplash ? const SplashScreen() : const HomeDashboardScreen()),
    );
  }
}
