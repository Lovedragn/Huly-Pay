import 'dart:async';
import 'dart:math';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_drawing/path_drawing.dart';

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
    this.duration = const Duration(milliseconds: 1750),
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
      duration: const Duration(milliseconds: 1700),
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
      final supabaseUrl =
          dotenv.env['SUPABASE_URL'] ??
          'https://aszhhxnbzstzemyhcjvi.supabase.co';
      final supabaseAnonKey =
          dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
          dotenv.env['SUPABASE_ANON_KEY'] ??
          '';
      await AuthService.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    }

    // --- STEP 1: Fast Client-Side Check (Zero-Network) ---
    // If a token exists but has expired locally, wipe it immediately without making any remote calls!
    // This saves 100% of network round-trips and avoids hitting backend endpoints with dead credentials.
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
    final bool hasValidSessionOrCache =
        widget.isAuthenticated ?? (hasValidActiveToken || _hasLocalUser);
    final Widget targetScreen =
        widget.nextScreen ??
        (hasValidSessionOrCache
            ? const HomeDashboardScreen()
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
    final size = MediaQuery.of(context).size;
    const double logoSize = 140.0;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: GestureDetector(
        key: const Key('splash_gesture_detector'),
        onTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Dynamic SVG Vector Animated White Wave Lines Background
            Positioned.fill(
              child: AnimatedWaveBackground(animation: _controller),
            ),

            // 2. Center: Animated Logo placed at exact screen center matching the native splash position & size
            Center(
              child: Hero(
                tag: 'huly_pay_brand_logo',
                child: AnimatedHulyLogo(
                  controller: _controller,
                  width: logoSize,
                  height: logoSize,
                ),
              ),
            ),

            // 3. Branding Text: Positioned below the center logo without shifting the logo
            Positioned(
              left: 0,
              right: 0,
              top: (size.height / 2) + (logoSize / 2) + 24,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final double t = _controller.value;
                  double textOpacity = 0.0;
                  if (t >= 0.30 && t < 0.60) {
                    textOpacity = Curves.easeOutCubic.transform(
                      (t - 0.30) / 0.30,
                    );
                  } else if (t >= 0.60 && t <= 0.80) {
                    textOpacity = 1.0;
                  } else if (t > 0.80 && t <= 1.0) {
                    textOpacity =
                        1.0 -
                        Curves.easeInOutCubic.transform(
                          ((t - 0.80) / 0.20).clamp(0.0, 1.0),
                        );
                  }
                  return Opacity(
                    opacity: textOpacity.clamp(0.0, 1.0),
                    child: child,
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "Hulypay" text in bold matching hypay-splash.png
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
                    // Tagline: "Track. Pay. Grow."
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

  const AnimatedWaveBackground({super.key, required this.animation});

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
      {
        'yFactor': 0.30,
        'amp': 36.0,
        'freq': 1.1,
        'opacity': 0.08,
        'stroke': 1.6,
        'shift': 0.0,
      },
      {
        'yFactor': 0.38,
        'amp': 52.0,
        'freq': 1.3,
        'opacity': 0.16,
        'stroke': 2.0,
        'shift': 0.8,
      },
      {
        'yFactor': 0.46,
        'amp': 64.0,
        'freq': 1.0,
        'opacity': 0.22,
        'stroke': 2.4,
        'shift': 1.5,
      },
      {
        'yFactor': 0.54,
        'amp': 48.0,
        'freq': 1.4,
        'opacity': 0.16,
        'stroke': 1.9,
        'shift': 2.2,
      },
      {
        'yFactor': 0.62,
        'amp': 40.0,
        'freq': 1.2,
        'opacity': 0.11,
        'stroke': 1.5,
        'shift': 2.9,
      },
      {
        'yFactor': 0.70,
        'amp': 32.0,
        'freq': 1.5,
        'opacity': 0.06,
        'stroke': 1.2,
        'shift': 3.6,
      },
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
        final double y =
            yBase +
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

/// Animated Huly Logo for Splash Screen
///
/// Implements a luminous SVG stroke path drawing animation:
/// - Phase 1 (0.00 - 0.58): The vector contours trace and draw themselves onto the screen
/// - Phase 2 (0.38 - 0.68): Solid white fills & 0.41 depth shadows bloom in, merging with the strokes
/// - Phase 3 (0.68 - 0.80): Full crisp emblem hold in pristine clarity
/// - Phase 4 (0.80 - 1.00): Disappear / dissolve into OLED black before transitioning
class AnimatedHulyLogo extends StatelessWidget {
  final AnimationController controller;
  final double width;
  final double height;

  const AnimatedHulyLogo({
    super.key,
    required this.controller,
    this.width = 140,
    this.height = 140,
  });

  // Precomputed parsed SVG paths and metrics from Logo-Dark.svg
  static final List<_LogoPathData> _paths = _initPaths();

  // Outer circular guide ring
  static final _LogoPathData _ringPath = () {
    final p = Path()
      ..addOval(
        Rect.fromCircle(
          center: const Offset(328.608, 324.184),
          radius: 324.0,
        ),
      );
    return _LogoPathData(
      path: p,
      metrics: p.computeMetrics().toList(),
      targetOpacity: 0.22,
      drawStart: 0.00,
      drawEnd: 0.48,
    );
  }();

  static List<_LogoPathData> _initPaths() {
    final List<({String d, double opacity, double start, double end})> raw = [
      // --- Top blades (Canopy / Crown) ---
      (
        d:
            'M329.792,115.601c0.389,0.057 0.783,54.803 0,54.57c-88.734,0 -135.861,-151.058 -135.861,-151.058l60.338,-21.211c0,0 36.562,112.931 75.523,117.699Z',
        opacity: 0.41,
        start: 0.00,
        end: 0.44,
      ),
      (
        d:
            'M329.792,170.171l0,-54.57c-38.961,-4.768 -75.523,-117.699 -75.523,-117.699l-60.338,21.211c0,0 61.09,175.314 135.861,151.058Z',
        opacity: 1.0,
        start: 0.00,
        end: 0.44,
      ),
      (
        d:
            'M329.378,115.601c-0.389,0.057 -0.783,54.803 0,54.57c88.734,0 135.861,-151.058 135.861,-151.058l-60.338,-21.211c0,0 -36.562,112.931 -75.523,117.699Z',
        opacity: 0.41,
        start: 0.00,
        end: 0.44,
      ),
      (
        d:
            'M329.378,170.171l0,-54.57c38.961,-4.768 75.523,-117.699 75.523,-117.699l60.338,21.211c0,0 -61.09,175.314 -135.861,151.058Z',
        opacity: 1.0,
        start: 0.00,
        end: 0.44,
      ),

      // --- Upper diagonal blades ---
      (
        d:
            'M329.792,300.156c-141.414,14.637 -205.73,-118.806 -271.723,-176.504c0.605,-0.62 44.55,-46.756 43.937,-46.967c52.862,44.296 104.979,162.169 227.786,164.508c0.5,31.234 -0.46,58.027 0,58.963Z',
        opacity: 0.41,
        start: 0.06,
        end: 0.50,
      ),
      (
        d:
            'M329.792,300.156c-0.22,-0.448 -0.115,-6.825 -0,-16.779l0,-42.184c-122.807,-2.338 -174.924,-120.212 -227.786,-164.508c0.613,0.211 -43.332,46.346 -43.937,46.967c65.993,57.698 130.309,191.141 271.723,176.504Z',
        opacity: 1.0,
        start: 0.06,
        end: 0.50,
      ),
      (
        d:
            'M329.378,300.156c141.414,14.637 205.73,-118.806 271.723,-176.504c-0.605,-0.62 -44.55,-46.756 -43.937,-46.967c-52.862,44.296 -104.979,162.169 -227.786,164.508c-0.5,31.234 0.46,58.027 0,58.963Z',
        opacity: 0.41,
        start: 0.06,
        end: 0.50,
      ),
      (
        d:
            'M329.378,300.156c0.22,-0.448 0.115,-6.825 0,-16.779l-0,-42.184c122.807,-2.338 174.924,-120.212 227.786,-164.508c-0.613,0.211 43.332,46.346 43.937,46.967c-65.993,57.698 -130.309,191.141 271.723,176.504Z',
        opacity: 1.0,
        start: 0.06,
        end: 0.50,
      ),

      // --- Mid-Wings ---
      (
        d:
            'M8.469,234.89c-0.598,0.04 -12.816,60.951 -13.038,61.36c151.729,65.88 202.305,136.556 334.361,139.865c0.182,-0.221 1.637,-72.012 0,-72.445c-91.699,2.425 -160.148,-63.607 -321.323,-128.78Z',
        opacity: 1.0,
        start: 0.12,
        end: 0.54,
      ),
      (
        d:
            'M650.701,234.89c0.598,0.04 12.816,60.951 13.038,61.36c-151.729,65.88 -202.305,136.556 -334.361,139.865c-0.182,-0.221 -1.637,-72.012 0,-72.445c91.699,2.425 160.148,-63.607 321.323,-128.78Z',
        opacity: 1.0,
        start: 0.12,
        end: 0.54,
      ),

      // --- Bottom anchor blades ---
      (
        d:
            'M285.341,650.465c49.876,-304.129 -217.133,-186.981 -275.196,-238.207c-8.808,-7.771 19.792,54.255 23.738,65.105c0.007,0.02 -11.377,-0.851 -0.065,-0.005c217.828,16.301 202.726,38.486 190.862,161.271l60.661,11.836Z',
        opacity: 0.41,
        start: 0.16,
        end: 0.58,
      ),
      (
        d:
            'M33.882,477.363c217.76,16.301 202.66,38.493 190.797,161.266l60.661,11.836c49.876,-304.129 -217.133,-186.981 -275.196,-238.207c-8.808,-7.771 19.792,54.255 23.738,65.105Z',
        opacity: 1.0,
        start: 0.16,
        end: 0.58,
      ),
      (
        d:
            'M373.829,650.465c-49.876,-304.129 217.133,-186.981 275.196,-238.207c8.808,-7.771 -19.792,54.255 -23.738,65.105c-0.007,0.02 11.377,-0.851 0.065,-0.005c-217.828,16.301 -202.726,38.486 -190.862,161.271l-60.661,11.836Z',
        opacity: 0.41,
        start: 0.16,
        end: 0.58,
      ),
      (
        d:
            'M625.288,477.363c-217.76,16.301 -202.66,38.493 -190.797,161.266l-60.661,11.836c-49.876,-304.129 217.133,-186.981 275.196,-238.207c8.808,-7.771 -19.792,54.255 -23.738,65.105Z',
        opacity: 1.0,
        start: 0.16,
        end: 0.58,
      ),
    ];

    return raw.map((item) {
      final p = parseSvgPathData(item.d);
      return _LogoPathData(
        path: p,
        metrics: p.computeMetrics().toList(),
        targetOpacity: item.opacity,
        drawStart: item.start,
        drawEnd: item.end,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(width, height),
          painter: LogoStrokePainter(progress: controller.value),
        );
      },
    );
  }
}

class _LogoPathData {
  final Path path;
  final List<PathMetric> metrics;
  final double targetOpacity;
  final double drawStart;
  final double drawEnd;

  _LogoPathData({
    required this.path,
    required this.metrics,
    required this.targetOpacity,
    required this.drawStart,
    required this.drawEnd,
  });
}

class LogoStrokePainter extends CustomPainter {
  final double progress;

  LogoStrokePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    // ViewBox dimensions from original SVG: 658 x 649
    const double vbWidth = 658.0;
    const double vbHeight = 649.0;

    // Disappear phase at the end: progress in [0.80, 1.0]
    double globalFade = 1.0;
    double scale = 1.0;
    if (progress > 0.80) {
      final p = ((progress - 0.80) / 0.20).clamp(0.0, 1.0);
      globalFade = 1.0 - Curves.easeInOutCubic.transform(p);
      scale = 1.0 + 0.04 * Curves.easeInOutCubic.transform(p);
    }

    if (globalFade <= 0.001) return;

    canvas.save();

    // Scale and center from viewBox to target widget size
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(scale);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.scale(size.width / vbWidth, size.height / vbHeight);

    // 1. Draw outer guide ring stroke
    _drawRing(canvas, globalFade);

    // 2. Draw stroke outlines and solid fills for blades
    _drawBlades(canvas, globalFade);

    canvas.restore();
  }

  void _drawRing(Canvas canvas, double globalFade) {
    final ring = AnimatedHulyLogo._ringPath;
    if (progress < ring.drawStart) return;

    final double p =
        ((progress - ring.drawStart) / (ring.drawEnd - ring.drawStart)).clamp(
          0.0,
          1.0,
        );
    final double curvedP = Curves.easeOutCubic.transform(p);

    final strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withValues(
            alpha: ring.targetOpacity * globalFade,
          );

    for (final metric in ring.metrics) {
      final extracted = metric.extractPath(0.0, metric.length * curvedP);
      canvas.drawPath(extracted, strokePaint);
    }
  }

  void _drawBlades(Canvas canvas, double globalFade) {
    // Fill blossom begins at t = 0.38 and completes by t = 0.68
    double fillT = 0.0;
    if (progress >= 0.38) {
      fillT = Curves.easeOutCubic.transform(
        ((progress - 0.38) / 0.30).clamp(0.0, 1.0),
      );
    }

    // Stroke outline gracefully merges into fill once solid
    double strokeAlpha = 1.0;
    if (progress >= 0.56) {
      strokeAlpha =
          1.0 -
          Curves.easeInOut.transform(
            ((progress - 0.56) / 0.12).clamp(0.0, 1.0),
          );
    }

    final strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // A. Draw solid fills and depth shadows
    if (fillT > 0.001) {
      for (final item in AnimatedHulyLogo._paths) {
        final double alpha = item.targetOpacity * fillT * globalFade;
        if (alpha > 0.001) {
          fillPaint.color = Colors.white.withValues(alpha: alpha);
          canvas.drawPath(item.path, fillPaint);
        }
      }
    }

    // B. Draw stroke path drawing animation
    if (strokeAlpha > 0.001) {
      for (final item in AnimatedHulyLogo._paths) {
        if (progress < item.drawStart) continue;

        final double p =
            ((progress - item.drawStart) / (item.drawEnd - item.drawStart))
                .clamp(0.0, 1.0);
        final double curvedP = Curves.easeInOutCubic.transform(p);

        final double alpha =
            (item.targetOpacity == 1.0 ? 1.0 : 0.6) *
            strokeAlpha *
            globalFade;
        strokePaint.color = Colors.white.withValues(alpha: alpha);

        for (final metric in item.metrics) {
          final extracted = metric.extractPath(0.0, metric.length * curvedP);
          canvas.drawPath(extracted, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LogoStrokePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
