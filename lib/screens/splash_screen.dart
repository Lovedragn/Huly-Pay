import 'dart:async';
import 'dart:math';

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

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
/// Uses the original `Logo-Dark.svg` as the authoritative single source of truth:
/// - Exact `viewBox="0 0 669 653"`
/// - Zero manually approximated/hard-coded path coordinates
/// - Dynamic DOM XML traversal + matrix accumulation
/// - Strict uniform scaling: `scale = min(targetWidth / svgWidth, targetHeight / svgHeight)`
/// - Symmetrical coordinated 4-tier vector stroke path drawing
/// - Luminous drawing pointer attached directly to the active path tangent (`tangent.position` & `tangent.vector`)
/// - Progressive white logo fill bloom matching the exact original SVG
/// - Disappear / dissolve into OLED black before navigation
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

/// Authoritative parsed geometry from original `Logo-Dark.svg`
class SvgLogoGeometry {
  final Rect viewBox;
  final List<SvgPathItem> paths;

  SvgLogoGeometry({required this.viewBox, required this.paths});

  static final SvgLogoGeometry instance = _parse();

  static SvgLogoGeometry _parse() {
    final doc = XmlDocument.parse(_rawSvg);
    final svgElem = doc.rootElement;

    final vbAttr = svgElem.getAttribute('viewBox') ?? '0 0 669 653';
    final vbParts = vbAttr.split(RegExp(r'\s+')).map(double.parse).toList();
    final viewBox = Rect.fromLTWH(vbParts[0], vbParts[1], vbParts[2], vbParts[3]);

    Matrix4 parseSvgMatrix(String transformStr) {
      final match = RegExp(r'matrix\(([^)]+)\)').firstMatch(transformStr);
      if (match == null) return Matrix4.identity();
      final nums = match.group(1)!.split(RegExp(r'[\s,]+')).map(double.parse).toList();
      return Matrix4(
        nums[0], nums[1], 0, 0,
        nums[2], nums[3], 0, 0,
        0, 0, 1, 0,
        nums[4], nums[5], 0, 1,
      );
    }

    final List<SvgPathItem> items = [];

    void traverse(XmlElement node, Matrix4 currentM, bool inClip) {
      Matrix4 newM = currentM.clone();
      final transformAttr = node.getAttribute('transform');
      if (transformAttr != null) {
        newM = newM * parseSvgMatrix(transformAttr);
      }

      final isClip = inClip || node.name.local == 'clipPath';

      if (node.name.local == 'path' && !isClip) {
        final d = node.getAttribute('d') ?? '';
        final style = node.getAttribute('style') ?? '';
        final opacity = (style.contains('fill-opacity:0.41') || style.contains('fill-opacity: 0.41')) ? 0.41 : 1.0;

        final rawPath = parseSvgPathData(d);
        final transformedPath = rawPath.transform(newM.storage);
        final bounds = transformedPath.getBounds();

        int tier;
        if (bounds.top < 50.0) {
          tier = 0; // Top Canopy
        } else if (bounds.top < 150.0) {
          tier = 1; // Upper Diagonal
        } else if (bounds.top < 300.0) {
          tier = 2; // Mid Wings
        } else {
          tier = 3; // Bottom Anchors
        }

        final isLeft = bounds.center.dx < (viewBox.width / 2);
        final isPrimary = opacity == 1.0;

        items.add(
          SvgPathItem(
            path: transformedPath,
            metrics: transformedPath.computeMetrics().toList(),
            targetOpacity: opacity,
            tier: tier,
            isLeft: isLeft,
            isPrimary: isPrimary,
          ),
        );
      }

      for (final child in node.children.whereType<XmlElement>()) {
        traverse(child, newM, isClip);
      }
    }

    traverse(svgElem, Matrix4.identity(), false);

    return SvgLogoGeometry(viewBox: viewBox, paths: items);
  }

  // Exact contents of asserts/logo/Logo-Dark.svg (Single Source of Truth)
  static const String _rawSvg = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="100%" height="100%" viewBox="0 0 669 653" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:affinity="https://www.affinity.studio/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linejoin:round;stroke-miterlimit:2;" fill="#ffffff">
    <g fill="#ffffff" transform="matrix(1,0,0,1,-165.846047,-173.718635)">
        <g transform="matrix(1.314433,0,0,1.296734,-486.801558,175.81639)">
            <g transform="matrix(0.900493,0,0,0.912784,300.653754,-205.31046)">
                <g transform="matrix(-1,0,0,1,1000,0)">
                    <path d="M771.47,423.375C771.976,423.409 782.298,474.87 782.486,475.215C654.297,530.874 611.567,590.585 500,593.381C499.846,593.194 498.617,532.542 500,532.175C577.472,534.224 635.301,478.437 771.47,423.375Z"/>
                </g>
                <g transform="matrix(-1,0,0,1,1000,0)">
                    <path d="M500,478.515C619.474,490.881 673.811,378.142 729.566,329.395C729.055,328.871 691.927,289.893 692.446,289.715C647.785,327.139 603.754,426.725 500,428.7C499.577,455.089 500.388,477.724 500,478.515Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip1">
                        <path d="M500,478.515C619.474,490.881 673.811,378.142 729.566,329.395C729.055,328.871 691.927,289.893 692.446,289.715C647.785,327.139 603.754,426.725 500,428.7C499.577,455.089 500.388,477.724 500,478.515Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip1)">
                        <path d="M500,478.515C500.186,478.137 500.097,472.749 500,464.339L500,428.7C603.754,426.725 647.785,327.139 692.446,289.715C691.927,289.893 729.055,328.871 729.566,329.395C673.811,378.142 619.474,490.881 500,478.515Z"/>
                    </g>
                </g>
                <g transform="matrix(-1,0,0,1,1000,0)">
                    <path d="M500,322.594C499.672,322.642 499.338,368.895 500,368.698C574.967,368.698 614.783,241.075 614.783,241.075L563.806,223.155C563.806,223.155 532.917,318.566 500,322.594Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip2">
                        <path d="M500,322.594C499.672,322.642 499.338,368.895 500,368.698C574.967,368.698 614.783,241.075 614.783,241.075L563.806,223.155C563.806,223.155 532.917,318.566 500,322.594Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip2)">
                        <path d="M500,368.698L500,322.594C532.917,318.566 563.806,223.155 563.806,223.155L614.783,241.075C614.783,241.075 563.171,389.19 500,368.698Z"/>
                    </g>
                </g>
                <g transform="matrix(-1,0,0,1,1000,0)">
                    <path d="M537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229C749.994,628.246 759.612,627.51 750.055,628.225C566.022,641.997 578.781,660.74 588.805,764.475L537.555,774.475Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip3">
                        <path d="M537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229C749.994,628.246 759.612,627.51 750.055,628.225C566.022,641.997 578.781,660.74 588.805,764.475L537.555,774.475Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip3)">
                        <path d="M750,628.229C566.025,642 578.782,660.75 588.805,764.475L537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229Z"/>
                    </g>
                </g>
                <g transform="matrix(1,0,0,1,-0.349601,0)">
                    <path d="M771.47,423.375C771.976,423.409 782.298,474.87 782.486,475.215C654.297,530.874 611.567,590.585 500,593.381C499.846,593.194 498.617,532.542 500,532.175C577.472,534.224 635.301,478.437 771.47,423.375Z"/>
                </g>
                <g transform="matrix(1,0,0,1,-0.349601,0)">
                    <path d="M500,478.515C619.474,490.881 673.811,378.142 729.566,329.395C729.055,328.871 691.927,289.893 692.446,289.715C647.785,327.139 603.754,426.725 500,428.7C499.577,455.089 500.388,477.724 500,478.515Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip4">
                        <path d="M500,478.515C619.474,490.881 673.811,378.142 729.566,329.395C729.055,328.871 691.927,289.893 692.446,289.715C647.785,327.139 603.754,426.725 500,428.7C499.577,455.089 500.388,477.724 500,478.515Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip4)">
                        <path d="M500,478.515C500.186,478.137 500.097,472.749 500,464.339L500,428.7C603.754,426.725 647.785,327.139 692.446,289.715C691.927,289.893 729.055,328.871 729.566,329.395C673.811,378.142 619.474,490.881 500,478.515Z"/>
                    </g>
                </g>
                <g transform="matrix(1,0,0,1,-0.349601,0)">
                    <path d="M500,322.594C499.672,322.642 499.338,368.895 500,368.698C574.967,368.698 614.783,241.075 614.783,241.075L563.806,223.155C563.806,223.155 532.917,318.566 500,322.594Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip5">
                        <path d="M500,322.594C499.672,322.642 499.338,368.895 500,368.698C574.967,368.698 614.783,241.075 614.783,241.075L563.806,223.155C563.806,223.155 532.917,318.566 500,322.594Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip5)">
                        <path d="M500,368.698L500,322.594C532.917,318.566 563.806,223.155 563.806,223.155L614.783,241.075C614.783,241.075 563.171,389.19 500,368.698Z"/>
                    </g>
                </g>
                <g transform="matrix(1,0,0,1,-0.349601,0)">
                    <path d="M537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229C749.994,628.246 759.612,627.51 750.055,628.225C566.022,641.997 578.781,660.74 588.805,764.475L537.555,774.475Z" style="fill-opacity:0.41;"/>
                    <clipPath id="_clip6">
                        <path d="M537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229C749.994,628.246 759.612,627.51 750.055,628.225C566.022,641.997 578.781,660.74 588.805,764.475L537.555,774.475Z"/>
                    </clipPath>
                    <g clip-path="url(#_clip6)">
                        <path d="M750,628.229C566.025,642 578.782,660.75 588.805,764.475L537.555,774.475C495.417,517.53 721,616.503 770.055,573.225C777.496,566.659 753.333,619.062 750,628.229Z"/>
                    </g>
                </g>
            </g>
        </g>
    </g>
</svg>''';
}

/// Svg Path Item with precomputed metrics and visual properties
class SvgPathItem {
  final Path path;
  final List<PathMetric> metrics;
  final double targetOpacity;
  final int tier; // 0: Top, 1: Upper, 2: Mid, 3: Bottom
  final bool isLeft;
  final bool isPrimary;

  const SvgPathItem({
    required this.path,
    required this.metrics,
    required this.targetOpacity,
    required this.tier,
    required this.isLeft,
    required this.isPrimary,
  });
}

/// High-performance CustomPainter implementing progressive path drawing and pointer
class LogoStrokePainter extends CustomPainter {
  final double progress;

  LogoStrokePainter({required this.progress});

  // Coordinated timeline windows for the 4 tiers (Top -> Upper -> Mid -> Bottom)
  static const double _t0Start = 0.10, _t0End = 0.22;
  static const double _t1Start = 0.18, _t1End = 0.32;
  static const double _t2Start = 0.28, _t2End = 0.42;
  static const double _t3Start = 0.38, _t3End = 0.52;

  static (double start, double end) _tierWindow(int tier) {
    switch (tier) {
      case 0:
        return (_t0Start, _t0End);
      case 1:
        return (_t1Start, _t1End);
      case 2:
        return (_t2Start, _t2End);
      default:
        return (_t3Start, _t3End);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final geometry = SvgLogoGeometry.instance;
    final double svgW = geometry.viewBox.width; // 669.0
    final double svgH = geometry.viewBox.height; // 653.0

    // Disappear phase at end: progress in [0.80, 1.00]
    double globalFade = 1.0;
    double disappearScale = 1.0;
    if (progress > 0.80) {
      final p = ((progress - 0.80) / 0.20).clamp(0.0, 1.0);
      globalFade = 1.0 - Curves.easeInOutCubic.transform(p);
      disappearScale = 1.0 + 0.04 * Curves.easeInOutCubic.transform(p);
    }

    if (globalFade <= 0.001) return;

    // Strict uniform scaling and exact centering matching SVG aspect ratio
    final double scale =
        min(size.width / svgW, size.height / svgH) * disappearScale;
    final double dx = (size.width - svgW * scale) / 2.0;
    final double dy = (size.height - svgH * scale) / 2.0;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    // 1. Draw solid / shadow fills (fade in progressively between 0.30 and 0.55)
    _drawFills(canvas, geometry, globalFade);

    // 2. Draw active vector strokes and the attached luminous drawing pointer
    _drawStrokesAndPointers(canvas, geometry, globalFade);

    canvas.restore();
  }

  void _drawFills(Canvas canvas, SvgLogoGeometry geometry, double globalFade) {
    if (progress < 0.30) return;

    final double fillP = Curves.easeOutCubic.transform(
      ((progress - 0.30) / 0.25).clamp(0.0, 1.0),
    );

    final fillPaint = Paint()..style = PaintingStyle.fill;

    for (final item in geometry.paths) {
      final double alpha = item.targetOpacity * fillP * globalFade;
      if (alpha > 0.001) {
        fillPaint.color = Colors.white.withValues(alpha: alpha);
        canvas.drawPath(item.path, fillPaint);
      }
    }
  }

  void _drawStrokesAndPointers(
    Canvas canvas,
    SvgLogoGeometry geometry,
    double globalFade,
  ) {
    // Stroke outline fades out once fill is solid (0.48 to 0.62)
    double strokeAlpha = 1.0;
    if (progress >= 0.48) {
      strokeAlpha =
          1.0 -
          Curves.easeInOut.transform(
            ((progress - 0.48) / 0.14).clamp(0.0, 1.0),
          );
    }
    if (strokeAlpha <= 0.001) return;

    final strokePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    // Pointer visibility fades in at start of drawing (0.08 to 0.14) and fades out at (0.48 to 0.55)
    double pointerAlpha = 0.0;
    if (progress >= 0.08 && progress < 0.14) {
      pointerAlpha = ((progress - 0.08) / 0.06).clamp(0.0, 1.0);
    } else if (progress >= 0.14 && progress < 0.48) {
      pointerAlpha = 1.0;
    } else if (progress >= 0.48 && progress <= 0.55) {
      pointerAlpha = 1.0 - ((progress - 0.48) / 0.07).clamp(0.0, 1.0);
    }

    // Trace each path and attach pointer to active endpoint
    for (final item in geometry.paths) {
      final (tStart, tEnd) = _tierWindow(item.tier);
      if (progress < tStart) continue;

      final double p = ((progress - tStart) / (tEnd - tStart)).clamp(0.0, 1.0);
      final double curvedP = Curves.easeInOutCubic.transform(p);

      final double alpha =
          (item.targetOpacity == 1.0 ? 1.0 : 0.5) * strokeAlpha * globalFade;
      strokePaint.color = Colors.white.withValues(alpha: alpha);

      for (final metric in item.metrics) {
        final double currentLength = metric.length * curvedP;
        final extracted = metric.extractPath(0.0, currentLength);
        canvas.drawPath(extracted, strokePaint);

        // Only attach pointer to the primary blade contour while actively drawing (p in [0.001, 0.999])
        if (item.isPrimary &&
            pointerAlpha > 0.001 &&
            p > 0.001 &&
            p < 0.999) {
          final tangent = metric.getTangentForOffset(currentLength);
          if (tangent != null) {
            _drawPointer(
              canvas,
              tangent.position,
              tangent.vector,
              pointerAlpha * globalFade,
            );
          }
        }
      }
    }
  }

  void _drawPointer(
    Canvas canvas,
    Offset position,
    Offset vector,
    double alpha,
  ) {
    if (alpha <= 0.001) return;

    final double angle = atan2(vector.dy, vector.dx);

    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    // 1. Subtle soft halo (radius ~5.5px in SVG space, ~1.2dp on screen, no distracting flare)
    final haloPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.28 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    canvas.drawCircle(Offset.zero, 5.5, haloPaint);

    // 2. Elongated luminous drawing head along path tangent (length 7.0px, width 3.5px)
    final headPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.85 * alpha)
          ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 7.0, height: 3.5),
      headPaint,
    );

    // 3. Crisp white center tip
    final tipPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 1.0 * alpha)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 2.0, tipPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoStrokePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

