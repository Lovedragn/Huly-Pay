import 'package:fl_heatmap/fl_heatmap.dart';
import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';

enum HeatmapPeriod {
  days,
  weeks,
  month,
  threeMonths,
  sixMonths,
  oneYear,
}

/// Spending Activity Heatmap powered by fl_heatmap: ^0.4.6
/// Controlled by the global period selector on the Analysis page:
/// Days, Weeks, This Month, 3 Months, 6 Months, 1 Year.
class SpendingHeatmap extends StatefulWidget {
  final List<PaymentModel> payments;
  final String period;

  const SpendingHeatmap({
    super.key,
    required this.payments,
    this.period = 'This Month',
  });

  @override
  State<SpendingHeatmap> createState() => _SpendingHeatmapState();
}

class _SpendingHeatmapState extends State<SpendingHeatmap> {
  HeatmapItem? _selectedItem;

  // Curated Dark OLED Activity Palette (Less to More) derived from global AppChartColors
  static List<Color> get _palette => AppChartColors.heatmapPalette;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  HeatmapPeriod get _effectivePeriod {
    final clean = widget.period.toLowerCase().trim();
    if (clean.contains('day')) {
      return HeatmapPeriod.days;
    } else if (clean.contains('week')) {
      return HeatmapPeriod.weeks;
    } else if (clean.contains('3') || clean.contains('three')) {
      return HeatmapPeriod.threeMonths;
    } else if (clean.contains('6') || clean.contains('six')) {
      return HeatmapPeriod.sixMonths;
    } else if (clean.contains('year')) {
      return HeatmapPeriod.oneYear;
    } else {
      return HeatmapPeriod.month;
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = _effectivePeriod;
    final heatmapData = _buildHeatmapData(widget.payments, period);
    final periodTotal = _computePeriodTotal(widget.payments, period);
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(periodTotal),
          const SizedBox(height: 16),
          // Heatmap grid with key to trigger fresh state on period change
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Theme(
              data: Theme.of(context).copyWith(
                textTheme: Theme.of(context).textTheme.copyWith(
                      bodyMedium: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Color(0xFF8E8E93),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
              child: Heatmap(
                key: ValueKey(widget.period),
                heatmapData: heatmapData,
                showXAxisLabels: true,
                showYAxisLabels: false,
                onItemSelectedListener: (item) {
                  setState(() {
                    _selectedItem = item;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(double periodTotal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Heatmap',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: AppThemeManager.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _selectedItem != null
                ? AppChartColors.heatmapChipBorder.withValues(alpha: 0.18)
                : const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedItem != null
                  ? AppChartColors.heatmapChipBorder
                  : const Color(0xFF2A2A30),
            ),
          ),
          child: Text(
            _selectedItem != null
                ? '${_selectedItem!.xAxisLabel}: ₹${_selectedItem!.value.toStringAsFixed(0)}'
                : 'Total: ₹${periodTotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: _selectedItem != null
                  ? AppChartColors.heatmapSelected
                  : const Color(0xFF8E8E93),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Less',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 10,
          ),
        ),
        const SizedBox(width: 5),
        for (final color in _palette)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: const Color(0xFF2E2E36),
                width: 0.5,
              ),
            ),
          ),
        const SizedBox(width: 5),
        const Text(
          'More',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  double _computePeriodTotal(List<PaymentModel> payments, HeatmapPeriod period) {
    final now = DateTime.now();
    DateTime cutoff;

    switch (period) {
      case HeatmapPeriod.days:
        cutoff = DateTime(now.year, now.month, now.day);
        break;
      case HeatmapPeriod.weeks:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        cutoff = DateTime(monday.year, monday.month, monday.day);
        break;
      case HeatmapPeriod.month:
        cutoff = DateTime(now.year, now.month, 1);
        break;
      case HeatmapPeriod.threeMonths:
        cutoff = DateTime(now.year, now.month - 2, 1);
        break;
      case HeatmapPeriod.sixMonths:
        cutoff = DateTime(now.year, now.month - 5, 1);
        break;
      case HeatmapPeriod.oneYear:
        cutoff = DateTime(now.year - 1, now.month, 1);
        break;
    }

    double total = 0;
    for (final p in payments) {
      final s = p.status.toUpperCase();
      if (s == 'FAILED' || s == 'CANCELLED') continue;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr == null) continue;
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        if (dt.isAfter(cutoff.subtract(const Duration(seconds: 1)))) {
          total += p.amount;
        }
      } catch (_) {}
    }
    return total;
  }

  HeatmapData _buildHeatmapData(List<PaymentModel> payments, HeatmapPeriod period) {
    final now = DateTime.now();

    List<String> rows;
    List<String> columns;
    List<List<double>> grid;

    switch (period) {
      case HeatmapPeriod.days:
        rows = ['r0'];
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
              final dayIdx = (now.weekday - 1).clamp(0, 6);
              grid[0][dayIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.weeks:
        rows = ['r0'];
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        final thisWeekMonday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.isAfter(thisWeekMonday.subtract(const Duration(seconds: 1)))) {
              final dayIdx = (dt.weekday - 1).clamp(0, 6);
              grid[0][dayIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.month:
        rows = ['r0', 'r1', 'r2', 'r3'];
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.year == now.year && dt.month == now.month) {
              final weekIdx = ((dt.day - 1) ~/ 7).clamp(0, 3);
              final dayIdx = (dt.weekday - 1).clamp(0, 6);
              grid[weekIdx][dayIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.threeMonths:
        final monthOffsets = [2, 1, 0];
        columns = monthOffsets.map((offset) {
          final m = ((now.month - 1 - offset) % 12 + 12) % 12;
          return _monthNames[m];
        }).toList();
        rows = ['r0', 'r1', 'r2', 'r3'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            final diffMonths = (now.year - dt.year) * 12 + (now.month - dt.month);
            if (diffMonths >= 0 && diffMonths <= 2) {
              final colIdx = 2 - diffMonths;
              final weekIdx = ((dt.day - 1) ~/ 7).clamp(0, 3);
              grid[weekIdx][colIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.sixMonths:
        final monthOffsets = [5, 4, 3, 2, 1, 0];
        columns = monthOffsets.map((offset) {
          final m = ((now.month - 1 - offset) % 12 + 12) % 12;
          return _monthNames[m];
        }).toList();
        rows = ['r0', 'r1', 'r2', 'r3'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            final diffMonths = (now.year - dt.year) * 12 + (now.month - dt.month);
            if (diffMonths >= 0 && diffMonths <= 5) {
              final colIdx = 5 - diffMonths;
              final weekIdx = ((dt.day - 1) ~/ 7).clamp(0, 3);
              grid[weekIdx][colIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.oneYear:
        columns = _monthNames;
        rows = ['r0', 'r1', 'r2', 'r3'];
        grid = List.generate(rows.length, (_) => List<double>.filled(columns.length, 0.0));

        for (final p in payments) {
          final s = p.status.toUpperCase();
          if (s == 'FAILED' || s == 'CANCELLED') continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.year == now.year) {
              final colIdx = (dt.month - 1).clamp(0, 11);
              final weekIdx = ((dt.day - 1) ~/ 7).clamp(0, 3);
              grid[weekIdx][colIdx] += p.amount;
            }
          } catch (_) {}
        }
        break;
    }

    final List<HeatmapItem> items = [];

    // Row-major order matching fl_heatmap expectation:
    // for (row in rows) for (col in columns)
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < columns.length; c++) {
        final value = grid[r][c];
        items.add(
          HeatmapItem(
            value: value,
            xAxisLabel: columns[c],
            yAxisLabel: rows[r],
            unit: '₹',
          ),
        );
      }
    }

    return HeatmapData(
      rows: rows,
      columns: columns,
      items: items,
      colorPalette: _palette,
      selectedColor: AppChartColors.heatmapSelected,
      radius: 6.0,
    );
  }
}
