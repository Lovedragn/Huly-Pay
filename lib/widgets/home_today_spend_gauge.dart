import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/payment_model.dart';

/// Speedometer-style gauge chart inspired by gauge_chart_sample3.dart
/// Combines two rings:
/// - Inner progress ring showing current measurement filled up to today's spend
/// - Outer zones ring painting fixed threshold bands (Green, Amber, Red)
class HomeTodaySpendGaugeChart extends StatelessWidget {
  final List<PaymentModel> payments;
  final double dailyBudget;

  const HomeTodaySpendGaugeChart({
    super.key,
    required this.payments,
    this.dailyBudget = 5000.0,
  });

  @override
  Widget build(BuildContext context) {
    final todaySpend = _computeTodaySpend(payments);
    final clampedSpend = math.min(todaySpend, dailyBudget * 1.2);
    final ratio = dailyBudget > 0 ? (todaySpend / dailyBudget) : 0.0;

    Color activeColor;
    String statusText;
    if (ratio < 0.50) {
      activeColor = const Color(0xFF30D158); // Green
      statusText = 'Within Budget';
    } else if (ratio < 0.80) {
      activeColor = const Color(0xFFFFD60A); // Amber
      statusText = 'Moderate Spend';
    } else {
      activeColor = const Color(0xFFFF453A); // Red
      statusText = 'Near Limit';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S TOTAL SPEND",
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Color(0xFF8E8E93),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Daily Limit Gauge',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: activeColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: activeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 240,
              height: 140,
              child: CustomPaint(
                painter: _SpeedometerGaugePainter(
                  value: clampedSpend,
                  maxValue: dailyBudget,
                  activeColor: activeColor,
                ),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          todaySpend == 0
                              ? '₹0.00'
                              : '₹${todaySpend.toStringAsFixed(todaySpend.truncateToDouble() == todaySpend ? 0 : 2)}',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Budget: ₹${dailyBudget.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            color: Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildZoneIndicator('Safe (<50%)', const Color(0xFF30D158)),
              _buildZoneIndicator('Medium (50-80%)', const Color(0xFFFFD60A)),
              _buildZoneIndicator('High (>80%)', const Color(0xFFFF453A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _computeTodaySpend(List<PaymentModel> payments) {
    final now = DateTime.now();
    final todayPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    double total = 0.0;
    for (final p in payments) {
      if (p.status.toUpperCase() == 'FAILED') continue;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr != null && dateStr.startsWith(todayPrefix)) {
        total += p.amount;
      }
    }
    return total;
  }
}

/// Precise CustomPainter implementing gauge_chart_sample3.dart rings:
/// 1. Outer GaugeZonesRing with 3 threshold arcs separated by gaps & rounded caps
/// 2. Inner GaugeProgressRing with measurement fill & background arc
class _SpeedometerGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;
  final Color activeColor;

  _SpeedometerGaugePainter({
    required this.value,
    required this.maxValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final outerRadius = (size.width / 2) - 8;
    const outerStrokeWidth = 7.0;
    const innerStrokeWidth = 18.0;
    const ringSpacing = 8.0;
    final innerRadius = outerRadius - (outerStrokeWidth / 2) - ringSpacing - (innerStrokeWidth / 2);

    // 1. Draw Outer Zones Ring (gauge_chart_sample3 zones)
    // Sweep is 180 degrees from math.pi to 2 * math.pi
    final zones = [
      (from: 0.0, to: 0.50, color: const Color(0xFF30D158)),
      (from: 0.50, to: 0.80, color: const Color(0xFFFFD60A)),
      (from: 0.80, to: 1.0, color: const Color(0xFFFF453A)),
    ];

    const totalAngle = math.pi;
    const gapAngle = 0.07; // Gap between zones

    for (int i = 0; i < zones.length; i++) {
      final z = zones[i];
      final start = math.pi + (z.from * totalAngle) + (i == 0 ? 0 : gapAngle / 2);
      final end = math.pi + (z.to * totalAngle) - (i == zones.length - 1 ? 0 : gapAngle / 2);
      final sweep = math.max(0.01, end - start);

      final paint = Paint()
        ..color = z.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        start,
        sweep,
        false,
        paint,
      );
    }

    // 2. Draw Inner Progress Ring Background
    final bgPaint = Paint()
      ..color = const Color(0xFF222228)
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerStrokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      math.pi,
      totalAngle,
      false,
      bgPaint,
    );

    // 3. Draw Inner Progress Ring Measurement Fill
    final progressFraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    if (progressFraction > 0.001) {
      final progressPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        math.pi,
        totalAngle * progressFraction,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedometerGaugePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.activeColor != activeColor;
  }
}
