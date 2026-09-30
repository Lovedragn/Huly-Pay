import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_validator.dart';
import '../services/user_preferences_service.dart';
import 'home_dashboard_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget? nextScreen;
  final bool initializeAuth;
  final bool? isAuthenticated;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 300),
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
      duration: const Duration(milliseconds: 280),
    );

    _controller.forward();

    // Smoothly hand off from the native splash screen to the Flutter animated splash screen
    FlutterNativeSplash.remove();

    _navigationTimer = Timer(widget.duration, _navigateToNext);
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
        PaymentRepository().getPayments(forceRefresh: true);
      } catch (_) {}
    }

    // --- STEP 3: Load Presets from Local SQLite Storage ---
    try {
      await UserPreferencesService().loadPreferences();
    } catch (_) {}
  }

  void _navigateToNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _navigationTimer?.cancel();

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
    const double logoSize = 120.0;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        key: const Key('splash_gesture_detector'),
        onTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double t = _controller.value;
                  final double opacity = Curves.easeOut.transform(
                    (t / 0.4).clamp(0.0, 1.0),
                  );
                  final double scale =
                      0.88 +
                      0.12 *
                          Curves.easeOutCubic.transform(
                            (t / 0.5).clamp(0.0, 1.0),
                          );
                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  );
                },
                child: Hero(
                  tag: 'huly_pay_brand_logo',
                  child: SvgPicture.asset(
                    'assets/logo/Logo-Dark.svg',
                    width: logoSize,
                    height: logoSize,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double t = _controller.value;
                  double textOpacity = 0.0;
                  if (t >= 0.25 && t < 0.60) {
                    textOpacity = Curves.easeOutCubic.transform(
                      (t - 0.25) / 0.35,
                    );
                  } else if (t >= 0.60) {
                    textOpacity = 1.0;
                  }
                  return Opacity(
                    opacity: textOpacity.clamp(0.0, 1.0),
                    child: child,
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hulypay',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Track. Pay. Grow.',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
