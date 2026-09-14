import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';

/// Speedometer-style gauge chart inspired by gauge_chart_sample3.dart
/// Combines two rings:
/// - Inner progress ring showing current measurement filled up to today's spend
/// - Outer zones ring painting fixed threshold bands (Green, Amber, Red)
///
/// Features:
/// - Timezone-aware local date matching against UTC server timestamps
/// - Live aggregation of real payments with offline fallback to SQLite cache
/// - Dynamic user-configurable daily max limit with persistent storage
/// - Clean status transition (<50% Within Budget, 50-80% Moderate Spend, 80-100% Near Limit, >=100% Limit Exceeded)
class HomeTodaySpendGaugeChart extends StatefulWidget {
  final List<PaymentModel> payments;
  final double dailyBudget;
  final VoidCallback? onLimitChanged;

  const HomeTodaySpendGaugeChart({
    super.key,
    required this.payments,
    this.dailyBudget = 5000.0,
    this.onLimitChanged,
  });

  @override
  State<HomeTodaySpendGaugeChart> createState() =>
      _HomeTodaySpendGaugeChartState();
}

class _HomeTodaySpendGaugeChartState extends State<HomeTodaySpendGaugeChart> {
  double? _customLimit;

  @override
  void didUpdateWidget(covariant HomeTodaySpendGaugeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dailyBudget != oldWidget.dailyBudget) {
      _customLimit = null;
    }
  }

  double get _effectiveLimit {
    return _customLimit ?? widget.dailyBudget;
  }

  @override
  Widget build(BuildContext context) {
    final todaySpend = _computeTodaySpend(widget.payments);
    final limit = _effectiveLimit > 0 ? _effectiveLimit : 5000.0;
    final ratio = limit > 0 ? (todaySpend / limit) : 0.0;
    final clampedSpend = math.min(todaySpend, limit * 1.5);

    final Color activeColor;
    final String statusText;
    if (ratio >= 1.0) {
      activeColor = AppChartColors.gaugeHigh;
      statusText = 'Limit Exceeded';
    } else if (ratio >= 0.80) {
      activeColor = AppChartColors.gaugeHigh;
      statusText = 'Near Limit';
    } else if (ratio >= 0.50) {
      activeColor = AppChartColors.gaugeModerate;
      statusText = 'Moderate Spend';
    } else {
      activeColor = AppChartColors.gaugeSafe;
      statusText = 'Within Budget';
    }

    final colors = AppThemeManager.colors;
    final trackColor =
        colors.isDark ? const Color(0xFF222228) : const Color(0xFFE5E7EB);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _showSetLimitModal,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Text(
                      "Daily Limit",
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.border, width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "₹${limit.toInt()}",
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: colors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons.edit_outlined,
                            size: 10,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: activeColor.withValues(alpha: 0.35),
                  ),
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
                  maxValue: limit,
                  activeColor: activeColor,
                  trackColor: trackColor,
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
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          todaySpend > limit
                              ? '₹${(todaySpend - limit).toStringAsFixed(0)} over limit'
                              : '₹${(limit - todaySpend).clamp(0.0, limit).toStringAsFixed(0)} left of ₹${limit.toInt()}',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: todaySpend > limit
                                ? activeColor
                                : const Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
              _buildZoneIndicator('Safe (<50%)', AppChartColors.gaugeSafe),
              _buildZoneIndicator(
                'Medium (50-80%)',
                AppChartColors.gaugeModerate,
              ),
              _buildZoneIndicator('High (>80%)', AppChartColors.gaugeHigh),
            ],
          ),
        ],
      ),
    );
  }

  void _showSetLimitModal() {
    final colors = AppThemeManager.colors;
    final presets = [2000.0, 5000.0, 10000.0, 25000.0, 50000.0];
    final currentLimit = _effectiveLimit;
    final controller = TextEditingController(
      text: currentLimit.toInt().toString(),
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Set Daily Spending Limit',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a preset or enter your custom daily budget',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((val) {
                      final isSelected =
                          double.tryParse(controller.text) == val;
                      return ChoiceChip(
                        label: Text('₹${val.toInt()}'),
                        selected: isSelected,
                        selectedColor: colors.accent,
                        backgroundColor: colors.surfaceSecondary,
                        labelStyle: TextStyle(
                          fontFamily: 'Google Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: isSelected ? Colors.white : colors.textPrimary,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setSheetState(() {
                              controller.text = val.toInt().toString();
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      labelText: 'Custom Limit Amount',
                      labelStyle: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                      filled: true,
                      fillColor: colors.surfaceSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.accent, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () async {
                        final parsed = double.tryParse(controller.text);
                        if (parsed != null && parsed > 0) {
                          await UserPreferencesService().saveDailyLimit(parsed);
                          if (mounted) {
                            setState(() {
                              _customLimit = parsed;
                            });
                          }
                          widget.onLimitChanged?.call();
                        }
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: const Text(
                        'Save Limit',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildZoneIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

  static bool _isToday(String? dateStr, DateTime now) {
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    final trimmed = dateStr.trim();

    // 1. Try ISO8601 parsing with local conversion (reconciles UTC server timestamps)
    try {
      final dt = DateTime.parse(trimmed).toLocal();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return true;
      }
    } catch (_) {}

    // 2. Millisecond epoch parsing
    final ms = int.tryParse(trimmed);
    if (ms != null && ms > 1000000000) {
      try {
        final dt = DateTime.fromMillisecondsSinceEpoch(
          trimmed.length == 10 ? ms * 1000 : ms,
        ).toLocal();
        if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
          return true;
        }
      } catch (_) {}
    }

    // 3. Fallback: custom split (e.g. YYYY-MM-DD or DD-MM-YYYY)
    final parts = trimmed.split(RegExp(r'[-/T ]'));
    if (parts.length >= 3) {
      if (parts[0].length == 4) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y == now.year && m == now.month && d == now.day) return true;
      } else if (parts[2].length == 4) {
        final p1 = int.tryParse(parts[0]);
        final p2 = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (y == now.year &&
            ((p1 == now.day && p2 == now.month) ||
                (p1 == now.month && p2 == now.day))) {
          return true;
        }
      }
    }

    // 4. Prefix match fallback
    final todayPrefix =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return trimmed.startsWith(todayPrefix);
  }

  double _computeTodaySpend(List<PaymentModel> payments) {
    final now = DateTime.now();
    double total = 0.0;
    for (final p in payments) {
      final s = p.status.toUpperCase();
      if (s == 'FAILED' || s == 'CANCELLED') continue;

      if (_isToday(p.createdAt, now) || _isToday(p.paymentDate, now)) {
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
  final Color trackColor;

  _SpeedometerGaugePainter({
    required this.value,
    required this.maxValue,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 10);
    final outerRadius = (size.width / 2) - 8;
    const outerStrokeWidth = 7.0;
    const innerStrokeWidth = 18.0;
    const ringSpacing = 8.0;
    final innerRadius =
        outerRadius -
        (outerStrokeWidth / 2) -
        ringSpacing -
        (innerStrokeWidth / 2);

    // 1. Draw Outer Zones Ring (gauge_chart_sample3 zones)
    // Sweep is 180 degrees from math.pi to 2 * math.pi
    final zones = [
      (from: 0.0, to: 0.50, color: AppChartColors.gaugeSafe),
      (from: 0.50, to: 0.80, color: AppChartColors.gaugeModerate),
      (from: 0.80, to: 1.0, color: AppChartColors.gaugeHigh),
    ];

    const totalAngle = math.pi;
    const gapAngle = 0.07; // Gap between zones

    for (int i = 0; i < zones.length; i++) {
      final z = zones[i];
      final start =
          math.pi + (z.from * totalAngle) + (i == 0 ? 0 : gapAngle / 2);
      final end =
          math.pi +
          (z.to * totalAngle) -
          (i == zones.length - 1 ? 0 : gapAngle / 2);
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
      ..color = trackColor
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
    final progressFraction = maxValue > 0
        ? (value / maxValue).clamp(0.0, 1.0)
        : 0.0;
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
        oldDelegate.activeColor != activeColor ||
        oldDelegate.trackColor != trackColor;
  }
}
