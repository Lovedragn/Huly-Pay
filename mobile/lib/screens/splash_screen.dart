import 'dart:async';
import 'dart:math';

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
    this.duration = const Duration(milliseconds: 1320),
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
  Timer? _navigationTimer;
  bool _navigated = false;
  bool _hasLocalUser = false;

  @override
  void initState() {
    super.initState();
    _initializeAppAndAuth();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
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
    const double logoSize = 120.0;

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
              child: FadeTransition(
                opacity: _fadeAnimation,
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

/// Staggered SVG Vector Animator based on animation.md
///
/// Combines the start and end animation states of the new circular HulyPay emblem:
/// - Fades and expands the outer circular guide ring
/// - Sequentially blossoms each symmetrical pair of vector blades (Top, Upper-Diagonal,
///   Mid-Wings, Bottom-Anchor) with their 0.41 opacity depth shadow layers
/// - Eases into the crisp, complete final logo mark matching animation.md
/// Animated Huly Logo for Splash Screen
///
/// Implements a stationary circular loading animation without any rotational spin.
/// The 8 radial vector blades fade in sequentially in a clockwise circle (1 cycle),
/// followed by a brief full presentation, then fade out sequentially in the same
/// clockwise circle (1 cycle).
class AnimatedHulyLogo extends StatelessWidget {
  final AnimationController controller;
  final double width;
  final double height;

  const AnimatedHulyLogo({
    super.key,
    required this.controller,
    this.width = 120,
    this.height = 120,
  });

  static const String _vb = 'viewBox="0 0 658 649"';

  // Outer circular ring
  static const String _ring =
      '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
      '<ellipse cx="328.608" cy="324.184" rx="324" ry="324" fill="none" stroke="white" stroke-width="2.5" stroke-opacity="0.22" stroke-dasharray="10 8"/>'
      '</svg>';

  // 8 Symmetrical vector blades arranged in precise clockwise order
  static const List<_BladeDefinition> _blades = [
    // 0. Top-Right blade (~12:30)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M329.378,115.601c-0.389,0.057 -0.783,54.803 0,54.57c88.734,0 135.861,-151.058 135.861,-151.058l-60.338,-21.211c0,0 -36.562,112.931 -75.523,117.699Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M329.378,170.171l0,-54.57c38.961,-4.768 75.523,-117.699 75.523,-117.699l60.338,21.211c0,0 -61.09,175.314 -135.861,151.058Z" fill="white"/>'
          '</svg>',
      inStart: 0.000,
      inEnd: 0.140,
      outStart: 0.540,
      outEnd: 0.680,
    ),
    // 1. Upper-Right blade (~2:00)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M329.378,300.156c141.414,14.637 205.73,-118.806 271.723,-176.504c-0.605,-0.62 -44.55,-46.756 -43.937,-46.967c-52.862,44.296 -104.979,162.169 -227.786,164.508c-0.5,31.234 0.46,58.027 0,58.963Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M329.378,300.156c0.22,-0.448 0.115,-6.825 0,-16.779l-0,-42.184c122.807,-2.338 174.924,-120.212 227.786,-164.508c-0.613,0.211 43.332,46.346 43.937,46.967c-65.993,57.698 -130.309,191.141 -271.723,176.504Z" fill="white"/>'
          '</svg>',
      inStart: 0.045,
      inEnd: 0.185,
      outStart: 0.585,
      outEnd: 0.725,
    ),
    // 2. Mid-Right wing blade (~3:30)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M650.701,234.89c0.598,0.04 12.816,60.951 13.038,61.36c-151.729,65.88 -202.305,136.556 -334.361,139.865c-0.182,-0.221 -1.637,-72.012 0,-72.445c91.699,2.425 160.148,-63.607 321.323,-128.78Z" fill="white"/>'
          '</svg>',
      inStart: 0.090,
      inEnd: 0.230,
      outStart: 0.630,
      outEnd: 0.770,
    ),
    // 3. Bottom-Right anchor blade (~5:00)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M373.829,650.465c-49.876,-304.129 217.133,-186.981 275.196,-238.207c8.808,-7.771 -19.792,54.255 -23.738,65.105c-0.007,0.02 11.377,-0.851 0.065,-0.005c-217.828,16.301 -202.726,38.486 -190.862,161.271l-60.661,11.836Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M625.288,477.363c-217.76,16.301 -202.66,38.493 -190.797,161.266l-60.661,11.836c-49.876,-304.129 217.133,-186.981 275.196,-238.207c8.808,-7.771 -19.792,54.255 -23.738,65.105Z" fill="white"/>'
          '</svg>',
      inStart: 0.135,
      inEnd: 0.275,
      outStart: 0.675,
      outEnd: 0.815,
    ),
    // 4. Bottom-Left anchor blade (~7:00)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M285.341,650.465c49.876,-304.129 -217.133,-186.981 -275.196,-238.207c-8.808,-7.771 19.792,54.255 23.738,65.105c0.007,0.02 -11.377,-0.851 -0.065,-0.005c217.828,16.301 202.726,38.486 190.862,161.271l60.661,11.836Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M33.882,477.363c217.76,16.301 202.66,38.493 190.797,161.266l60.661,11.836c49.876,-304.129 -217.133,-186.981 -275.196,-238.207c-8.808,-7.771 19.792,54.255 23.738,65.105Z" fill="white"/>'
          '</svg>',
      inStart: 0.180,
      inEnd: 0.320,
      outStart: 0.720,
      outEnd: 0.860,
    ),
    // 5. Mid-Left wing blade (~8:30)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M8.469,234.89c-0.598,0.04 -12.816,60.951 -13.038,61.36c151.729,65.88 202.305,136.556 334.361,139.865c0.182,-0.221 1.637,-72.012 0,-72.445c-91.699,2.425 -160.148,-63.607 -321.323,-128.78Z" fill="white"/>'
          '</svg>',
      inStart: 0.225,
      inEnd: 0.365,
      outStart: 0.765,
      outEnd: 0.905,
    ),
    // 6. Upper-Left blade (~10:00)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M329.792,300.156c-141.414,14.637 -205.73,-118.806 -271.723,-176.504c0.605,-0.62 44.55,-46.756 43.937,-46.967c52.862,44.296 104.979,162.169 227.786,164.508c0.5,31.234 -0.46,58.027 0,58.963Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M329.792,300.156c-0.22,-0.448 -0.115,-6.825 -0,-16.779l0,-42.184c-122.807,-2.338 -174.924,-120.212 -227.786,-164.508c0.613,0.211 -43.332,46.346 -43.937,46.967c65.993,57.698 130.309,191.141 271.723,176.504Z" fill="white"/>'
          '</svg>',
      inStart: 0.270,
      inEnd: 0.410,
      outStart: 0.810,
      outEnd: 0.950,
    ),
    // 7. Top-Left blade (~11:30)
    _BladeDefinition(
      svg:
          '<svg $_vb xmlns="http://www.w3.org/2000/svg">'
          '<path d="M329.792,115.601c0.389,0.057 0.783,54.803 0,54.57c-88.734,0 -135.861,-151.058 -135.861,-151.058l60.338,-21.211c0,0 36.562,112.931 75.523,117.699Z" style="fill-opacity: 0.41;" fill="white"/>'
          '<path d="M329.792,170.171l0,-54.57c-38.961,-4.768 -75.523,-117.699 -75.523,-117.699l-60.338,21.211c0,0 61.09,175.314 135.861,151.058Z" fill="white"/>'
          '</svg>',
      inStart: 0.315,
      inEnd: 0.455,
      outStart: 0.855,
      outEnd: 0.995,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;

        // Outer halo ring opacity: rises gently in the beginning and fades at the end
        double ringOpacity = 0.0;
        if (t < 0.25) {
          ringOpacity = Curves.easeOut.transform((t / 0.25).clamp(0.0, 1.0));
        } else if (t <= 0.75) {
          ringOpacity = 1.0;
        } else if (t < 1.0) {
          ringOpacity =
              1.0 - Curves.easeIn.transform(((t - 0.75) / 0.25).clamp(0.0, 1.0));
        }

        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Outer subtle halo ring (stationary, no spin)
              if (ringOpacity > 0.001)
                Opacity(
                  opacity: ringOpacity,
                  child: SvgPicture.string(
                    _ring,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                  ),
                ),

              // 2. The 8 stationary vector blades with circular loading fade in and fade out
              ..._blades.map((blade) {
                final double opacity = blade.calculateOpacity(t);
                if (opacity <= 0.001) return const SizedBox.shrink();

                return Opacity(
                  opacity: opacity,
                  child: SvgPicture.string(
                    blade.svg,
                    width: width,
                    height: height,
                    fit: BoxFit.contain,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _BladeDefinition {
  final String svg;
  final double inStart;
  final double inEnd;
  final double outStart;
  final double outEnd;

  const _BladeDefinition({
    required this.svg,
    required this.inStart,
    required this.inEnd,
    required this.outStart,
    required this.outEnd,
  });

  double calculateOpacity(double t) {
    if (t < inStart) return 0.0;
    if (t < inEnd) {
      final p = (t - inStart) / (inEnd - inStart);
      return Curves.easeOutCubic.transform(p.clamp(0.0, 1.0));
    }
    if (t <= outStart) return 1.0;
    if (t < outEnd) {
      final p = (t - outStart) / (outEnd - outStart);
      return 1.0 - Curves.easeInCubic.transform(p.clamp(0.0, 1.0));
    }
    return 0.0;
  }
}
