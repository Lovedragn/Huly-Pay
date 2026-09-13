import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'home_dashboard_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final Widget? nextScreen;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
    this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  bool _navigated = false;
  bool _hasLocalUser = false;

  @override
  void initState() {
    super.initState();
    _checkLocalStorage();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    _navigationTimer = Timer(widget.duration, _navigateToNext);
  }

  Future<void> _checkLocalStorage() async {
    try {
      final cachedProfile = await UserRepository().getCachedUserProfile();
      if (cachedProfile != null) {
        _hasLocalUser = true;
      }
    } catch (_) {}

    // Auto-fetch fresh data every time user opens application
    if (AuthService().isAuthenticated || _hasLocalUser) {
      try {
        UserRepository().getUserProfile(forceRefresh: true);
        PaymentRepository().getPayments(forceRefresh: true);
      } catch (_) {}
    }
  }

  void _navigateToNext() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _navigationTimer?.cancel();

    // Check local storage first, then go to application: Authenticated / Cached -> HomeDashboardScreen; Unauthenticated -> SignInScreen
    final bool hasValidSessionOrCache = AuthService().isAuthenticated || _hasLocalUser;
    final Widget targetScreen = widget.nextScreen ??
        (hasValidSessionOrCache
            ? const HomeDashboardScreen()
            : const SignInScreen());

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
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
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        key: const Key('splash_gesture_detector'),
        onTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Dark luxury silk wave background from design
            Image.asset(
              'asserts/pictures/splash_silk_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) {
                return Image.asset(
                  'asserts/pictures/hylpay_splash.png',
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const ColoredBox(color: Colors.black),
                );
              },
            ),

            // Subtle dark overlay to ensure pure black aesthetic
            Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),

            // Center: Logo, "Hulypay", and "Track. Pay. Grow." matching hylpay-splash.png
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Emblem logo mark matching hypay-splash.png
                    SvgPicture.asset(
                      'asserts/logo/logo.svg',
                      width: 130,
                      height: 78,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // "Hulypay" text in bold matching hypay-splash.png
                    const Text(
                      'Hulypay',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Tagline: "Track. Pay. Grow."
                    const Text(
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
            ),
          ],
        ),
      ),
    );
  }
}
