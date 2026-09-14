import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';

/// Weekly Spending Bar Chart inspired by bar_chart_sample1.dart
/// Features interactive touch tooltips, touched rod highlights,
/// rounded rods, background track rods, and real weekly payment data.
class HomeWeeklyBarChart extends StatefulWidget {
  final List<PaymentModel> payments;
  final VoidCallback? onTap;

  const HomeWeeklyBarChart({super.key, required this.payments, this.onTap});

  @override
  State<HomeWeeklyBarChart> createState() => _HomeWeeklyBarChartState();
}

class _HomeWeeklyBarChartState extends State<HomeWeeklyBarChart> {
  int _touchedIndex = -1;

  static Color get _defaultBarColor => AppChartColors.barDefault;
  static Color get _todayBarColor => AppChartColors.barToday;
  static Color get _touchedBarColor => AppChartColors.barTouched;
  static Color get _trackColor => AppChartColors.barTrack;

  @override
  Widget build(BuildContext context) {
    final weeklyAmounts = _computeWeeklyData(widget.payments);
    final totalWeekSpend = weeklyAmounts.fold<double>(0, (sum, v) => sum + v);
    final maxSpend = _calculateMax(weeklyAmounts);
    final colors = AppThemeManager.colors;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY SPENDING',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _todayBarColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _todayBarColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    totalWeekSpend == 0
                        ? '₹0.00'
                        : '₹${totalWeekSpend.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: _todayBarColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                _buildBarChartData(weeklyAmounts, maxSpend),
                duration: const Duration(milliseconds: 250),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Today', _todayBarColor),
                _buildLegendItem('Past Days', _defaultBarColor),
                _buildLegendItem('Budget Limit', _trackColor, isBordered: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color, {
    bool isBordered = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: isBordered
                ? Border.all(color: const Color(0xFF3A3A42))
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  BarChartData _buildBarChartData(List<double> weeklyAmounts, double maxSpend) {
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0 = Mon ... 6 = Sun

    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => const Color(0xFF1E1E24),
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipMargin: 8,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final dayNames = [
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
            ];
            final dayName = (group.x >= 0 && group.x < 7)
                ? dayNames[group.x]
                : '';
            final amount = weeklyAmounts[group.x];
            return BarTooltipItem(
              '$dayName\n',
              const TextStyle(
                fontFamily: 'Google Sans',
                color: Color(0xFF8E8E93),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              children: [
                TextSpan(
                  text:
                      '₹${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: _touchedBarColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (event, response) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                response == null ||
                response.spot == null) {
              _touchedIndex = -1;
              return;
            }
            _touchedIndex = response.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 28,
            getTitlesWidget: (value, meta) =>
                _getBottomTitles(value, meta, todayIndex),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      alignment: BarChartAlignment.spaceAround,
      maxY: maxSpend,
      barGroups: List.generate(7, (i) {
        final isTouched = (i == _touchedIndex);
        final isToday = (i == todayIndex);
        final amount = weeklyAmounts[i];

        Color barColor;
        Gradient? barGradient;
        if (isTouched) {
          barColor = _touchedBarColor;
          barGradient = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [_touchedBarColor.withValues(alpha: 0.7), _touchedBarColor],
          );
        } else if (isToday) {
          barColor = _todayBarColor;
          barGradient = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [_todayBarColor.withValues(alpha: 0.7), _todayBarColor],
          );
        } else if (amount > 0) {
          barColor = _defaultBarColor;
          barGradient = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [_defaultBarColor.withValues(alpha: 0.5), _defaultBarColor],
          );
        } else {
          barColor = AppThemeManager.colors.isDark
              ? const Color(0xFF26262B)
              : const Color(0xFFE5E7EB);
          barGradient = null;
        }

        // Keep a minimum height so zero amounts show a small subtle indicator
        final double barY = amount > 0 ? amount : (maxSpend * 0.04);

        return BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: isTouched ? (barY * 1.05) : barY,
              color: barColor,
              gradient: barGradient,
              width: 36,
              borderRadius: BorderRadius.circular(12),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxSpend,
                color: _trackColor,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta, int todayIndex) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final idx = value.toInt();
    if (idx < 0 || idx >= 7) return const SizedBox.shrink();

    final isToday = (idx == todayIndex);

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Text(
        dayLabels[idx],
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: isToday
              ? _todayBarColor
              : (AppThemeManager.colors.isDark
                  ? const Color(0xFF6B6B70)
                  : const Color(0xFF9CA3AF)),
          fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  double _calculateMax(List<double> amounts) {
    double max = 0;
    for (final a in amounts) {
      if (a > max) max = a;
    }
    if (max == 0) return 500;
    return (max * 1.25).ceilToDouble();
  }

  List<double> _computeWeeklyData(List<PaymentModel> payments) {
    final amounts = List<double>.filled(7, 0.0);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    for (final p in payments) {
      final s = p.status.toUpperCase();
      if (s != 'CONFIRMED' && s != 'SUCCESS') continue;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr == null) continue;

      try {
        final dt = DateTime.parse(dateStr);
        if (dt.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
          final dayIdx = dt.weekday - 1;
          if (dayIdx >= 0 && dayIdx < 7) {
            amounts[dayIdx] += p.amount;
          }
        }
      } catch (_) {}
    }

    return amounts;
  }
}
