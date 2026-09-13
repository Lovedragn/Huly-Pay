import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (kDebugMode) {
      print('dotenv load warning: $e');
    }
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://aszhhxnbzstzemyhcjvi.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await AuthService.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
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
