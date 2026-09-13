import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ScanAndPayScreen extends StatefulWidget {
  const ScanAndPayScreen({super.key});

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  void _handleBack([int? targetIndex]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, targetIndex);
    }
  }

  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFrontCamera ? 'Switched to Front Camera' : 'Switched to Rear Camera',
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Top Controls & Main Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 110, // padding for bottom nav
                ),
                child: Column(
                  children: [
                    // Top Bar (Back Button)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: _handleBack,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161619),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF24242A),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 44),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // Scanner Viewfinder Box with 4 corner brackets
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141416),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomPaint(
                          size: const Size(250, 250),
                          painter: ScannerFramePainter(
                            cornerColor: Colors.white,
                            cornerLength: 36.0,
                            strokeWidth: 4.0,
                            cornerRadius: 8.0,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Instructions
                    const Text(
                      'Scan any UPI QR code',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Align the QR code within the frame',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // Back to Home Button
                    GestureDetector(
                      onTap: () => _handleBack(0),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFF2A2A30),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Back to Home',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),
                  ],
                ),
              ),
            ),

            // Vertical Flash & Switch buttons on right side bottom near blue QR icon
            Positioned(
              right: 34,
              bottom: 118,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flash Toggle Button
                  GestureDetector(
                    key: const Key('flash_button'),
                    onTap: () {
                      setState(() {
                        _isFlashOn = !_isFlashOn;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isFlashOn
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF161619),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFlashOn
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF24242A),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Switch Camera Button (using switch.svg)
                  GestureDetector(
                    key: const Key('switch_camera_button'),
                    onTap: _toggleCamera,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isFrontCamera
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF161619),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFrontCamera
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF24242A),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'asserts/icon/switch.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar (with QR active in blue)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: -1, // No tab active
                isQrActive: true, // QR button active in bright blue
                onItemSelected: (index) {
                  _handleBack(index);
                },
                onQrScanTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter to draw the 4 white corner brackets of the viewfinder reticle
class ScannerFramePainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;

  ScannerFramePainter({
    this.cornerColor = Colors.white,
    this.cornerLength = 36.0,
    this.strokeWidth = 4.0,
    this.cornerRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final l = cornerLength;

    // Top-Left Corner
    final tl = Path();
    tl.moveTo(0, l);
    tl.lineTo(0, r);
    tl.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    tl.lineTo(l, 0);
    canvas.drawPath(tl, paint);

    // Top-Right Corner
    final tr = Path();
    tr.moveTo(w - l, 0);
    tr.lineTo(w - r, 0);
    tr.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    tr.lineTo(w, l);
    canvas.drawPath(tr, paint);

    // Bottom-Left Corner
    final bl = Path();
    bl.moveTo(0, h - l);
    bl.lineTo(0, h - r);
    bl.arcToPoint(Offset(r, h), radius: Radius.circular(r));
    bl.lineTo(l, h);
    canvas.drawPath(bl, paint);

    // Bottom-Right Corner
    final br = Path();
    br.moveTo(w - l, h);
    br.lineTo(w - r, h);
    br.arcToPoint(Offset(w, h - r), radius: Radius.circular(r));
    br.lineTo(w, h - l);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerFramePainter oldDelegate) =>
      oldDelegate.cornerColor != cornerColor ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerRadius != cornerRadius;
}
