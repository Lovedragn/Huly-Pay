import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    this.duration = const Duration(milliseconds: 2200),
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
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;
  bool _navigated = false;
  bool _hasLocalUser = false;

  @override
  void initState() {
    super.initState();
    _initializeAppAndAuth();

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
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://aszhhxnbzstzemyhcjvi.supabase.co';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      await AuthService.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    }

    // --- STEP 1: Fast Client-Side Check (Zero-Network) ---
    // If a token exists but has expired locally, wipe it immediately without making any remote calls!
    // This saves 100% of network round-trips and avoids hitting backend endpoints with dead credentials.
    final token = AuthService().currentAccessToken;
    if (token != null && TokenValidator.isExpired(token)) {
      if (kDebugMode) {
        print('SplashScreen [Step 1]: Token expired locally. Wiping stale session (0 KB network overhead).');
      }
      try {
        await AuthService().signOut();
      } catch (_) {}
      _hasLocalUser = false;
      return; // Do NOT proceed to Step 2 remote calls
    }

    // --- STEP 2: Server-Side Validation (Secure & Authoritative) ---
    // Only if the token passed Step 1 and is active, fetch fresh data to avoid 401 error in network tab
    if (AuthService().hasValidActiveToken) {
      try {
        UserRepository().getUserProfile(forceRefresh: true);
        PaymentRepository().getPayments(forceRefresh: true);
      } catch (_) {}
    }

    // --- STEP 3: Load Presets from Local Cache & Supabase users_preference ---
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
    final bool hasValidSessionOrCache = widget.isAuthenticated ?? (hasValidActiveToken || _hasLocalUser);
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
            // 1. Dynamic SVG Vector Animated White Wave Lines Background (Replaces static PNG)
            Positioned.fill(
              child: AnimatedWaveBackground(
                animation: _controller,
              ),
            ),

            // 2. Center: Animated Logo from svg-animation.md, "Hulypay", and "Track. Pay. Grow."
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
                    // Staggered animated SVG paths matching svg-animation.md
                    AnimatedHulyLogo(
                      controller: _controller,
                      width: 155,
                      height: 98,
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

/// Dynamic SVG Vector Wave Lines Background
///
/// Draws sweeping, undulating silk wave curves using mathematical cubic beziers and
/// linear opacity gradients, eliminating the need for heavy static background images.
class AnimatedWaveBackground extends StatelessWidget {
  final Animation<double> animation;

  const AnimatedWaveBackground({
    super.key,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WaveSilkPainter(progress: animation.value),
        );
      },
    );
  }
}

class WaveSilkPainter extends CustomPainter {
  final double progress;

  WaveSilkPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Solid OLED dark background
    final bgPaint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double phase = progress * 2.6 * pi;

    // 6 Layered silk wave curves flowing across the screen with gentle harmonics
    final List<Map<String, dynamic>> waveConfigs = [
      {'yFactor': 0.30, 'amp': 36.0, 'freq': 1.1, 'opacity': 0.08, 'stroke': 1.6, 'shift': 0.0},
      {'yFactor': 0.38, 'amp': 52.0, 'freq': 1.3, 'opacity': 0.16, 'stroke': 2.0, 'shift': 0.8},
      {'yFactor': 0.46, 'amp': 64.0, 'freq': 1.0, 'opacity': 0.22, 'stroke': 2.4, 'shift': 1.5},
      {'yFactor': 0.54, 'amp': 48.0, 'freq': 1.4, 'opacity': 0.16, 'stroke': 1.9, 'shift': 2.2},
      {'yFactor': 0.62, 'amp': 40.0, 'freq': 1.2, 'opacity': 0.11, 'stroke': 1.5, 'shift': 2.9},
      {'yFactor': 0.70, 'amp': 32.0, 'freq': 1.5, 'opacity': 0.06, 'stroke': 1.2, 'shift': 3.6},
    ];

    for (final cfg in waveConfigs) {
      final double yBase = h * (cfg['yFactor'] as double);
      final double amp = cfg['amp'] as double;
      final double freq = cfg['freq'] as double;
      final double opacity = cfg['opacity'] as double;
      final double stroke = cfg['stroke'] as double;
      final double shift = cfg['shift'] as double;

      final path = Path();
      path.moveTo(0, yBase + sin(phase + shift) * amp * 0.4);

      for (double x = 0; x <= w; x += 6) {
        final double normX = x / w;
        final double y = yBase +
            sin(normX * freq * 2 * pi + phase + shift) * amp +
            cos(normX * 1.5 * pi + phase * 0.5) * (amp * 0.35);
        path.lineTo(x, y);
      }

      wavePaint
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: opacity * 0.6),
            Colors.white.withValues(alpha: opacity),
            Colors.white.withValues(alpha: opacity * 0.7),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
        ).createShader(Rect.fromLTWH(0, yBase - amp, w, amp * 2))
        ..strokeWidth = stroke;

      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveSilkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Staggered SVG Path Animator based on svg-animation.md
///
/// Animates each of the 9 vector paths of the HulyPay logo mark sequentially
/// using keyframe timings (0.1s to 0.9s delays with 0.5s ease-in transitions).
class AnimatedHulyLogo extends StatelessWidget {
  final AnimationController controller;
  final double width;
  final double height;

  const AnimatedHulyLogo({
    super.key,
    required this.controller,
    this.width = 155,
    this.height = 98,
  });

  static const List<String> _paths = [
    "M29.3284 0.164185V2.15333C33.1522 2.93787 36.1638 5.95872 36.9348 9.7875H38.9227C38.1088 4.86707 34.2439 0.992464 29.3284 0.164185Z",
    "M11.7242 1.95404H25.4426V0H11.7242C5.89641 0 1.07779 4.22609 0.158203 9.78846H2.14605C3.04503 5.32152 6.99376 1.95404 11.7242 1.95404Z",
    "M2.14605 13.66L0.158203 13.66C1.07779 19.2224 5.89641 23.4485 11.7242 23.4485C11.7242 23.4485 13.7382 23.5204 14.636 23.4485C15.6361 23.3684 16.7791 21.6327 16.8637 21.5022C16.8659 21.4978 16.8687 21.4945 16.8687 21.4945H14.3822H11.7242C6.99376 21.4945 3.04503 18.127 2.14605 13.66Z",
    "M16.8687 21.4945C16.8687 21.4945 16.8659 21.4978 16.8637 21.5022C16.867 21.4971 16.8687 21.4945 16.8687 21.4945Z",
    "M27.4345 3.90808H19.3401V5.86212H27.3566C30.5612 5.86212 33.2187 8.51962 33.2187 11.7242C33.2187 13.9274 31.9996 15.835 30.2218 16.8375V19.0378C33.1466 17.9065 35.2506 15.0408 35.2506 11.7242C35.2506 7.42538 31.7333 3.90812 27.4345 3.90808Z",
    "M13.9705 17.5864V19.5404H16.4917C17.2732 19.5404 17.9771 19.8528 18.6023 20.3998L20.2443 22.0418C21.1821 22.9795 22.4326 23.4484 23.683 23.4485H27.3565C33.1799 23.4485 37.9956 19.2288 38.9204 13.6727H36.9321C36.0283 18.1333 32.0825 21.4944 27.3565 21.4944H23.605C22.8235 21.4944 22.1196 21.1821 21.4944 20.6351L19.8532 18.9931C18.9152 18.0552 17.6643 17.5864 16.4137 17.5864H13.9705Z",
    "M10.092 19.3678V17.3501C7.66532 16.6323 5.86224 14.3639 5.86224 11.7242C5.86224 8.51962 8.51974 5.86212 11.7244 5.86212H15.4092V3.90808H11.7244C7.42548 3.90808 3.9082 7.42535 3.9082 11.7242C3.9082 15.4638 6.56972 18.6119 10.092 19.3678Z",
    "M26.1066 19.5404H26.3745V17.5864H26.1066C25.3251 17.5864 24.6212 17.2739 23.9959 16.727L22.354 15.085C21.5724 14.3036 20.6344 13.8346 19.6185 13.6783H18.9153V15.6323C19.6968 15.6324 20.4007 15.9446 21.0259 16.4917L22.6671 18.1337C23.6051 19.0715 24.8561 19.5404 26.1066 19.5404Z",
    "M15.092 15.6323V13.6783H11.7242C10.63 13.6783 9.7702 12.8185 9.7702 11.7242C9.7702 10.63 10.63 9.7702 11.7242 9.7702H27.3566C28.4508 9.7702 29.3106 10.63 29.3106 11.7242C29.3106 12.8185 28.4508 13.6783 27.3566 13.6783H23.4485L24.8552 15.085C25.2459 15.4757 25.7149 15.6323 26.2619 15.6323H27.3566C29.5451 15.6323 31.2646 13.9128 31.2646 11.7242C31.2646 9.53572 29.5451 7.81616 27.3566 7.81616H11.7242C9.53572 7.81616 7.81616 9.53572 7.81616 11.7242C7.81616 13.9128 9.53572 15.6323 11.7242 15.6323H15.092Z",
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: List.generate(_paths.length, (index) {
          // Keyframe staggered timing from svg-animation.md (0.1s to 0.9s delay with 0.5s duration)
          // Over 1.4s controller duration:
          final double startNorm = ((index + 1) * 0.1 / 1.4).clamp(0.0, 1.0);
          final double endNorm = (((index + 1) * 0.1 + 0.5) / 1.4).clamp(0.0, 1.0);

          final Animation<double> pathAnimation = CurvedAnimation(
            parent: controller,
            curve: Interval(startNorm, endNorm, curve: Curves.easeIn),
          );

          return FadeTransition(
            opacity: pathAnimation,
            child: SvgPicture.string(
              '<svg width="40" height="24" viewBox="0 0 40 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="${_paths[index]}" fill="white"/></svg>',
              width: width,
              height: height,
              fit: BoxFit.contain,
            ),
          );
        }),
      ),
    );
  }
}
