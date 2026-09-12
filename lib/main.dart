import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const HulyPayApp());
}

class HulyPayApp extends StatelessWidget {
  const HulyPayApp({super.key});

  static const String appFontFamily = 'Google Sans';
  static const List<String> appFontFallback = [
    'GoogleSans',
    'Product Sans',
    'Open Sans',
    'Roboto',
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
      home: const HomeDashboardScreen(),
    );
  }
}
