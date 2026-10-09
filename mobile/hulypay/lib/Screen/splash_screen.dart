import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../Repository/transaction_repository.dart';
import '../Repository/user_repository.dart';
import '../Widget/animated_huly_logo.dart';
import '../Service/api_client.dart';
import '../Service/app_update_service.dart';
import '../Service/auth_service.dart';
import '../Service/token_validator.dart';
import '../Service/user_preferences_service.dart';
import '../Theme/app_theme.dart';
import 'Home/home_dashboard_screen.dart';
import 'Security/sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget? nextScreen;
  final bool initializeAuth;
  final bool? isAuthenticated;

  const SplashScreen({
    super.key,
    this.duration = const Duration(seconds: 1),
    this.nextScreen,
    this.initializeAuth = true,
    this.isAuthenticated,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _navigationTimer;
  bool _navigated = false;
  bool _hasLocalUser = false;

  @override
  void initState() {
    super.initState();
    _initializeAppAndAuth();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNext();
      }
    });

    _controller.forward();

    // Seamless handoff: Remove native splash screen after Flutter renders Frame 1
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });

    _navigationTimer = Timer(widget.duration + const Duration(milliseconds: 300), _navigateToNext);
  }

  Future<void> _initializeAppAndAuth() async {
    // 1. Always check local storage cache first
    try {
      final cachedProfile = await UserRepository().getCachedUserProfile();
      if (cachedProfile != null) {
        _hasLocalUser = true;
      }
    } catch (_) {}

    if (!widget.initializeAuth) return;

    // 2. Initialize dotenv in background if not yet loaded
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
        final envApiBase = dotenv.env['API_BASE_URL'];
        if (envApiBase != null && envApiBase.isNotEmpty) {
          ApiClient().updateBaseUrl(envApiBase);
        }
      } catch (e) {
        if (kDebugMode) {
          print('dotenv load warning: $e');
        }
      }
    }

    // 3. Initialize Supabase / AuthService in background if not yet initialized
    if (!AuthService.isInitialized) {
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabasePublishableKey =
          dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '';
      await AuthService.initialize(
        url: supabaseUrl,
        publishableKey: supabasePublishableKey,
      );
    }

    // --- STEP 1: Fast Client-Side Check (Zero-Network) ---
    // If a token exists but has expired locally, wipe it immediately without making any remote calls!
    final token = AuthService().currentAccessToken;
    if (token != null && TokenValidator.isExpired(token)) {
      if (kDebugMode) {
        print(
          'SplashScreen [Step 1]: Token expired locally. Wiping stale session (0 KB network overhead).',
        );
      }
      try {
        await AuthService().signOut();
      } catch (_) {}
      _hasLocalUser = false;
      return; // Do NOT proceed to Step 2 remote calls
    }

    // --- STEP 2: Server-Side Validation (Secure & Authoritative) ---
    // Only if the token passed Step 1 and is active, fetch fresh data
    if (AuthService().hasValidActiveToken) {
      try {
        UserRepository().getUserProfile(forceRefresh: true);
        TransactionRepository().getTransactions(forceRefresh: true);
      } catch (_) {}
    }

    // --- STEP 3: Load Presets from Local SQLite Storage ---
    try {
      await UserPreferencesService().loadPreferences();
    } catch (_) {}

    // --- STEP 4: Trigger backend health check and version check in background ---
    AppUpdateService().checkAppVersion();
  }

  void _navigateToNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _navigationTimer?.cancel();
    AppUpdateService().markAppReady();

    // Two-step validation result: Time-valid session or cached profile -> HomeDashboardScreen; else -> SignInScreen
    final bool hasValidActiveToken = AuthService().hasValidActiveToken;
    final bool hasValidSessionOrCache =
        widget.isAuthenticated ?? (hasValidActiveToken || _hasLocalUser);
    final bool isQuickScan = UserPreferencesService().cachedQuickScan;
    final Widget targetScreen =
        widget.nextScreen ??
        (hasValidSessionOrCache
            ? HomeDashboardScreen(quickScan: isQuickScan)
            : const SignInScreen());

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 240),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double logoSize = 102.0;
    final colors = AppThemeManager.colors;
    final isDark = colors.isDark;
    final backgroundColor = isDark ? const Color(0xFF000000) : colors.background;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        key: const Key('splash_gesture_detector'),
        onTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // Slower first, then accelerating faster
              final double curvedProgress = Curves.easeIn.transform(_controller.value);
              return Hero(
                tag: 'huly_pay_brand_logo',
                child: AnimatedHulyLogo(
                  progress: curvedProgress,
                  reverse: true,
                  color: isDark ? Colors.white : Colors.black,
                  size: logoSize,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
