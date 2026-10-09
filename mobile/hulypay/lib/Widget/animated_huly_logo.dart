import 'package:flutter/material.dart';

Path _parseSvgPath(String d) {
  final path = Path();
  final regExp = RegExp(r'([A-Za-z])|(-?[0-9]+(?:\.[0-9]+)?(?:[eE]-?[0-9]+)?)');
  final matches = regExp.allMatches(d).map((m) => m.group(0)!).toList();
  int i = 0;
  String currentCommand = '';
  while (i < matches.length) {
    final token = matches[i];
    if (RegExp(r'^[A-Za-z]$').hasMatch(token)) {
      currentCommand = token;
      i++;
      if (currentCommand == 'Z' || currentCommand == 'z') {
        path.close();
        continue;
      }
    }
    switch (currentCommand) {
      case 'M':
        final x = double.parse(matches[i++]);
        final y = double.parse(matches[i++]);
        path.moveTo(x, y);
        break;
      case 'C':
        final x1 = double.parse(matches[i++]);
        final y1 = double.parse(matches[i++]);
        final x2 = double.parse(matches[i++]);
        final y2 = double.parse(matches[i++]);
        final x = double.parse(matches[i++]);
        final y = double.parse(matches[i++]);
        path.cubicTo(x1, y1, x2, y2, x, y);
        break;
      case 'L':
        final x = double.parse(matches[i++]);
        final y = double.parse(matches[i++]);
        path.lineTo(x, y);
        break;
      case 'Z':
      case 'z':
        path.close();
        break;
      default:
        i++;
    }
  }
  return path;
}

/// CustomPainter that natively renders the Huly emblem stroke-by-stroke reveal animation.
class AnimatedHulyLogoPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;

  static final List<Path> _logoPaths = [
    _parseSvgPath('M16.9687 28.9806C14.7321 15.4741 26.7056 20.6767 29.3093 18.4017C29.7043 18.0566 28.4218 20.8112 28.2449 21.293C28.2445 21.2939 28.755 21.2552 28.2478 21.2928C18.4797 22.0168 19.1569 23.002 19.689 28.4549L16.9687 28.9806Z'),
    _parseSvgPath('M14.9939 5.22707C15.0113 5.22959 15.0291 7.66092 14.9939 7.65056C11.0148 7.65056 8.90148 0.94195 8.90148 0.94195L11.6072 -3.05176e-05C11.6072 -3.05176e-05 13.2468 5.01533 14.9939 5.22707Z'),
    _parseSvgPath('M29.3845 10.5247C29.4114 10.5265 29.9592 13.2316 29.9692 13.2497C23.1652 16.1755 20.8972 19.3143 14.9754 19.4612C14.9673 19.4514 14.902 16.2632 14.9754 16.2439C19.0875 16.3516 22.1569 13.4191 29.3845 10.5247Z'),
    _parseSvgPath('M0.584738 10.5247C0.55788 10.5265 0.0100069 13.2316 2.76566e-05 13.2497C6.80404 16.1755 9.07206 19.3143 14.9938 19.4612C15.002 19.4514 15.0672 16.2632 14.9938 16.2439C10.8817 16.3516 7.81231 13.4191 0.584738 10.5247Z'),
    _parseSvgPath('M14.9938 13.4232C8.65237 14.0732 5.76828 8.14699 2.80892 5.58456C2.83604 5.55702 4.80672 3.50811 4.77917 3.49875C7.14969 5.46597 9.48676 10.7008 14.9938 10.8046C15.0163 12.1918 14.9732 13.3816 14.9938 13.4232Z'),
    _parseSvgPath('M14.9754 13.4232C21.3169 14.0732 24.201 8.14699 27.1603 5.58456C27.1332 5.55702 25.1625 3.50811 25.1901 3.49875C22.8196 5.46597 20.4825 10.7008 14.9754 10.8046C14.953 12.1918 14.996 13.3816 14.9754 13.4232Z'),
    _parseSvgPath('M13.0005 28.9806C15.2371 15.4741 3.26365 20.6767 0.65991 18.4017C0.264957 18.0566 1.54748 20.8112 1.72439 21.293C1.72471 21.2939 1.2142 21.2552 1.72147 21.2928C11.4896 22.0168 10.8123 23.002 10.2803 28.4549L13.0005 28.9806Z'),
    _parseSvgPath('M14.9753 5.22707C14.9579 5.22959 14.9402 7.66092 14.9753 7.65056C18.9544 7.65056 21.0678 0.94195 21.0678 0.94195L18.362 -3.05176e-05C18.362 -3.05176e-05 16.7225 5.01533 14.9753 5.22707Z'),
  ];

  static final List<Path> _guidePaths = [
    _parseSvgPath('M29.3 18.4 C27 19.6 23.2 19.4 20 20 C17.1 20.7 15.9 23 16.97 28.98'),
    _parseSvgPath('M14.994 5.227 C13.4 5.02 12 3.2 10.9 1.2'),
    _parseSvgPath('M29.4 11.9 C23.3 14.3 20.1 17.5 14.98 17.85'),
    _parseSvgPath('M0.6 11.9 C6.7 14.3 9.9 17.5 15 17.85'),
    _parseSvgPath('M4.8 3.5 C8 8.3 10.8 11.9 14.994 12.1'),
    _parseSvgPath('M14.975 12.1 C19.2 11.9 22 8.3 25.19 3.5'),
    _parseSvgPath('M13 28.98 C14.1 23 12.9 20.7 10 20 C6.8 19.4 3 19.6 0.66 18.4'),
    _parseSvgPath('M14.975 5.227 C16.6 5.02 18 3.2 19.1 1.2'),
  ];

  static const List<double> _strokeWidths = [13.0, 9.5, 10.5, 10.5, 9.5, 9.5, 13.0, 9.5];
  static const List<double> _delays = [0.07, 0.04, 0.03, 0.06, 0.08, 0.10, 0.00, 0.04];

  AnimatedHulyLogoPainter({
    required this.progress,
    required this.color,
    this.reverse = false,
  });

  final bool reverse;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 30.0, size.height / 29.0);

    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 8; i++) {
      final double delayNormalized = _delays[i] / 0.5; // Staggered delays
      final double durationNormalized = 0.4 / 0.5; // Stroke duration
      final double p = ((progress - delayNormalized) / durationNormalized).clamp(0.0, 1.0);

      if (reverse) {
        // Reverse mode: Start fully visible, un-draw/erase along each petal curve
        if (p <= 0.0) {
          fillPaint.blendMode = BlendMode.srcOver;
          canvas.drawPath(_logoPaths[i], fillPaint);
        } else if (p >= 1.0) {
          continue; // Petal is fully erased
        } else {
          canvas.saveLayer(const Rect.fromLTWH(-10, -10, 50, 49), Paint());

          // 1. Draw full, crisp logo petal (preserves original vector geometry)
          fillPaint.blendMode = BlendMode.srcOver;
          canvas.drawPath(_logoPaths[i], fillPaint);

          // 2. Subtract eraser stroke along guide curve (exact parity with SVG black eraser on white mask)
          final eraserPaint = Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = _strokeWidths[i]
            ..blendMode = BlendMode.dstOut;

          final metric = _guidePaths[i].computeMetrics().first;
          final eraserStroke = metric.extractPath(0.0, metric.length * p);
          canvas.drawPath(eraserStroke, eraserPaint);

          canvas.restore();
        }
      } else {
        // Forward mode: Reveal from empty to fully drawn
        if (p <= 0.0) continue;

        if (p >= 1.0) {
          fillPaint.blendMode = BlendMode.srcOver;
          canvas.drawPath(_logoPaths[i], fillPaint);
        } else {
          canvas.saveLayer(const Rect.fromLTWH(-10, -10, 50, 49), Paint());
          final metric = _guidePaths[i].computeMetrics().first;
          final extracted = metric.extractPath(0.0, metric.length * p);
          strokePaint.strokeWidth = _strokeWidths[i];
          canvas.drawPath(extracted, strokePaint);

          fillPaint.blendMode = BlendMode.srcIn;
          canvas.drawPath(_logoPaths[i], fillPaint);
          canvas.restore();
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AnimatedHulyLogoPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.reverse != reverse;
}

class AnimatedHulyLogo extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final bool reverse;

  const AnimatedHulyLogo({
    super.key,
    required this.progress,
    required this.color,
    this.size = 120.0,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * (29.0 / 30.0),
      child: CustomPaint(
        size: Size(size, size * (29.0 / 30.0)),
        painter: AnimatedHulyLogoPainter(
          progress: progress,
          color: color,
          reverse: reverse,
        ),
      ),
    );
  }
}
