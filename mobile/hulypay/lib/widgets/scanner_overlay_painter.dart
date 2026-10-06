import 'package:flutter/material.dart';

/// Paints a translucent overlay over the camera with a rounded-rect cutout.
class ScannerOverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  final double cornerRadius;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.cutoutRect,
    this.cornerRadius = 20.0,
    this.overlayColor = const Color(0xC7000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerRadius)),
        ),
    );

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = overlayColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.cutoutRect != cutoutRect ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.overlayColor != overlayColor;
}
