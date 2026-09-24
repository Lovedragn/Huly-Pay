import 'package:flutter/material.dart';

import '../models/payment_model.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';

enum HeatmapPeriod { days, weeks, month, threeMonths, sixMonths, oneYear }

class HeatmapCellData {
  final double value;
  final String xAxisLabel;
  final String yAxisLabel;
  final String tooltipText;

  const HeatmapCellData({
    required this.value,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.tooltipText,
  });
}

class _HeatmapGridModel {
  final List<String> columns;
  final List<String> rows;
  final List<HeatmapCellData> cells;

  const _HeatmapGridModel({
    required this.columns,
    required this.rows,
    required this.cells,
  });
}

/// Spending Activity Heatmap with full-width responsive cell geometry
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
  HeatmapCellData? _selectedCell;

  // Curated Dark OLED Activity Palette (Less to More) derived from global AppChartColors
  static List<Color> get _palette => AppChartColors.heatmapPalette;

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  HeatmapPeriod get _effectivePeriod {
    final clean = widget.period.toLowerCase().trim();
    if (clean.contains('day')) {
      return HeatmapPeriod.days;
    } else if (clean.contains('week')) {
      return HeatmapPeriod.weeks;
    } else if (clean.contains('quarter') || clean.contains('3') || clean.contains('three')) {
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
    final gridModel = _buildGrid(widget.payments, period);
    final periodTotal = _computePeriodTotal(widget.payments, period);
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(periodTotal),
          const SizedBox(height: 16),
          // Responsive Heatmap canvas using full width without forced squares
          _HeatmapGridWidget(
            key: ValueKey(
              '${widget.period}_${widget.payments.length}_${periodTotal.toStringAsFixed(2)}',
            ),
            columns: gridModel.columns,
            rows: gridModel.rows,
            cells: gridModel.cells,
            palette: _palette,
            selectedCell: _selectedCell,
            selectedColor: AppChartColors.heatmapSelected,
            onCellSelected: (cell) {
              setState(() {
                _selectedCell = cell;
              });
            },
          ),
          const SizedBox(height: 12),
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
            color: _selectedCell != null
                ? AppChartColors.heatmapChipBorder.withValues(alpha: 0.18)
                : const Color(0xFF1E1E24),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _selectedCell != null
                  ? AppChartColors.heatmapChipBorder
                  : const Color(0xFF2A2A30),
            ),
          ),
          child: Text(
            _selectedCell != null
                ? '${_selectedCell!.tooltipText}: ₹${_selectedCell!.value.toStringAsFixed(0)}'
                : 'Total: ₹${periodTotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: _selectedCell != null
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
        for (final color in _palette)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: const Color(0xFF2E2E36), width: 0.5),
            ),
          ),
      ],
    );
  }

  double _computePeriodTotal(
    List<PaymentModel> payments,
    HeatmapPeriod period,
  ) {
    final now = DateTime.now();
    DateTime cutoff;

    switch (period) {
      case HeatmapPeriod.days:
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
      if (!p.isSuccessful) continue;
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

  _HeatmapGridModel _buildGrid(
    List<PaymentModel> payments,
    HeatmapPeriod period,
  ) {
    final now = DateTime.now();

    List<String> rows;
    List<String> columns;
    List<List<double>> grid;
    List<List<String>> tooltips;

    switch (period) {
      case HeatmapPeriod.days:
        // Day view: Show the current week (7 days) with each column representing a day (Mon-Sun)
        rows = ['W1'];
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
              final dayIdx = (dt.weekday - 1).clamp(0, 6);
              grid[0][dayIdx] += p.amount;
            }
          } catch (_) {}
        }
        for (int c = 0; c < columns.length; c++) {
          final dayDate = weekStart.add(Duration(days: c));
          tooltips[0][c] = '${columns[c]}, ${_monthNames[dayDate.month - 1]} ${dayDate.day}';
        }
        break;

      case HeatmapPeriod.weeks:
        // Week view: Show 7 days (Monday - Sunday) for this week, each box is 1 day
        rows = ['W1'];
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        final thisWeekMonday = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.isAfter(
              thisWeekMonday.subtract(const Duration(seconds: 1)),
            )) {
              final dayIdx = (dt.weekday - 1).clamp(0, 6);
              grid[0][dayIdx] += p.amount;
            }
          } catch (_) {}
        }
        for (int c = 0; c < columns.length; c++) {
          final dayDate = thisWeekMonday.add(Duration(days: c));
          tooltips[0][c] = '${columns[c]}, ${_monthNames[dayDate.month - 1]} ${dayDate.day}';
        }
        break;

      case HeatmapPeriod.month:
        // Month view: 7 days of the week (columns Mon-Sun), rows are week numbers of the month (W1..W5)
        // Every single cell represents an individual day!
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final firstWeekday = firstDayOfMonth.weekday; // 1 = Mon, 7 = Sun
        final numWeeks = ((firstWeekday - 1 + daysInMonth + 6) ~/ 7);

        rows = List.generate(numWeeks, (i) => 'W${i + 1}');
        columns = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        // Map calendar days to grid[week][weekday]
        final Map<int, List<int>> dayToCoord = {};
        for (int d = 1; d <= daysInMonth; d++) {
          final offset = (firstWeekday - 1) + (d - 1);
          final r = offset ~/ 7;
          final c = offset % 7;
          dayToCoord[d] = [r, c];
          tooltips[r][c] = '${columns[c]}, ${_monthNames[now.month - 1]} $d';
        }

        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            if (dt.year == now.year && dt.month == now.month) {
              final coord = dayToCoord[dt.day];
              if (coord != null) {
                grid[coord[0]][coord[1]] += p.amount;
              }
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.threeMonths:
        // Quarter view: 7 rows (Mon-Sun), columns are calendar weeks (13 weeks)
        // Each box is exactly 1 day (7 rows x ~13 columns = ~91 days)
        rows = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const totalWeeks = 13;
        // Start 12 weeks prior to current week's Monday
        final currentMonday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final quarterStartMonday = currentMonday.subtract(const Duration(days: 7 * (totalWeeks - 1)));

        // Column labels: show the 3 month names distributed across the columns
        columns = List.generate(totalWeeks, (w) {
          final weekMonday = quarterStartMonday.add(Duration(days: w * 7));
          // If first week or month changed from previous week, show month name
          if (w == 0) {
            return _monthNames[weekMonday.month - 1];
          }
          final prevMonday = quarterStartMonday.add(Duration(days: (w - 1) * 7));
          if (weekMonday.month != prevMonday.month) {
            return _monthNames[weekMonday.month - 1];
          }
          return '';
        });

        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        for (int w = 0; w < totalWeeks; w++) {
          for (int d = 0; d < 7; d++) {
            final dayDate = quarterStartMonday.add(Duration(days: w * 7 + d));
            tooltips[d][w] = '${rows[d]}, ${_monthNames[dayDate.month - 1]} ${dayDate.day}';
          }
        }

        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            final paymentDay = DateTime(dt.year, dt.month, dt.day);
            final diffDays = paymentDay.difference(quarterStartMonday).inDays;
            if (diffDays >= 0 && diffDays < totalWeeks * 7) {
              final w = diffDays ~/ 7;
              final d = diffDays % 7;
              if (w >= 0 && w < totalWeeks && d >= 0 && d < 7) {
                grid[d][w] += p.amount;
              }
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.sixMonths:
        // 6 Months view: 7 rows (Mon-Sun), 26 columns (weeks)
        // Each box is exactly 1 day (7 x 26 days)
        rows = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const totalWeeks6 = 26;
        final curMonday6 = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final sixMonthStartMonday = curMonday6.subtract(const Duration(days: 7 * (totalWeeks6 - 1)));

        columns = List.generate(totalWeeks6, (w) {
          final weekMonday = sixMonthStartMonday.add(Duration(days: w * 7));
          if (w == 0) {
            return _monthNames[weekMonday.month - 1];
          }
          final prevMonday = sixMonthStartMonday.add(Duration(days: (w - 1) * 7));
          if (weekMonday.month != prevMonday.month) {
            return _monthNames[weekMonday.month - 1];
          }
          return '';
        });

        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        for (int w = 0; w < totalWeeks6; w++) {
          for (int d = 0; d < 7; d++) {
            final dayDate = sixMonthStartMonday.add(Duration(days: w * 7 + d));
            tooltips[d][w] = '${rows[d]}, ${_monthNames[dayDate.month - 1]} ${dayDate.day}';
          }
        }

        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            final paymentDay = DateTime(dt.year, dt.month, dt.day);
            final diffDays = paymentDay.difference(sixMonthStartMonday).inDays;
            if (diffDays >= 0 && diffDays < totalWeeks6 * 7) {
              final w = diffDays ~/ 7;
              final d = diffDays % 7;
              if (w >= 0 && w < totalWeeks6 && d >= 0 && d < 7) {
                grid[d][w] += p.amount;
              }
            }
          } catch (_) {}
        }
        break;

      case HeatmapPeriod.oneYear:
        // Year view: 7 rows (Mon-Sun), 52 columns (weeks)
        // Each box is strictly 1 day (standard GitHub contribution style)
        rows = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const totalWeeksYear = 52;
        final curMondayYear = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        final yearStartMonday = curMondayYear.subtract(const Duration(days: 7 * (totalWeeksYear - 1)));

        // Show quarters Q1, Q2, Q3, Q4 at appropriate column positions or month marks
        columns = List.generate(totalWeeksYear, (w) {
          final weekMonday = yearStartMonday.add(Duration(days: w * 7));
          if (w == 0) {
            return 'Q${((weekMonday.month - 1) ~/ 3) + 1}';
          }
          final prevMonday = yearStartMonday.add(Duration(days: (w - 1) * 7));
          final curQ = ((weekMonday.month - 1) ~/ 3) + 1;
          final prevQ = ((prevMonday.month - 1) ~/ 3) + 1;
          if (curQ != prevQ) {
            return 'Q$curQ';
          }
          return '';
        });

        grid = List.generate(
          rows.length,
          (_) => List<double>.filled(columns.length, 0.0),
        );
        tooltips = List.generate(
          rows.length,
          (_) => List<String>.filled(columns.length, ''),
        );

        for (int w = 0; w < totalWeeksYear; w++) {
          for (int d = 0; d < 7; d++) {
            final dayDate = yearStartMonday.add(Duration(days: w * 7 + d));
            tooltips[d][w] = '${rows[d]}, ${_monthNames[dayDate.month - 1]} ${dayDate.day}';
          }
        }

        for (final p in payments) {
          if (!p.isSuccessful) continue;
          final dateStr = p.createdAt ?? p.paymentDate;
          if (dateStr == null) continue;
          try {
            final dt = DateTime.parse(dateStr).toLocal();
            final paymentDay = DateTime(dt.year, dt.month, dt.day);
            final diffDays = paymentDay.difference(yearStartMonday).inDays;
            if (diffDays >= 0 && diffDays < totalWeeksYear * 7) {
              final w = diffDays ~/ 7;
              final d = diffDays % 7;
              if (w >= 0 && w < totalWeeksYear && d >= 0 && d < 7) {
                grid[d][w] += p.amount;
              }
            }
          } catch (_) {}
        }
        break;
    }

    final List<HeatmapCellData> cells = [];
    for (int r = 0; r < rows.length; r++) {
      for (int c = 0; c < columns.length; c++) {
        cells.add(
          HeatmapCellData(
            value: grid[r][c],
            xAxisLabel: columns[c],
            yAxisLabel: rows[r],
            tooltipText: tooltips[r][c],
          ),
        );
      }
    }

    return _HeatmapGridModel(columns: columns, rows: rows, cells: cells);
  }
}

class _HeatmapGridWidget extends StatelessWidget {
  final List<String> columns;
  final List<String> rows;
  final List<HeatmapCellData> cells;
  final List<Color> palette;
  final HeatmapCellData? selectedCell;
  final Color selectedColor;
  final ValueChanged<HeatmapCellData?> onCellSelected;

  const _HeatmapGridWidget({
    super.key,
    required this.columns,
    required this.rows,
    required this.cells,
    required this.palette,
    required this.selectedCell,
    required this.selectedColor,
    required this.onCellSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double cellHeight = rows.length == 1
        ? 38.0
        : rows.length <= 5
            ? 22.0
            : 16.0;
    const double spacing = 4.0;
    final double gridHeight =
        (cellHeight * rows.length) + (spacing * (rows.length - 1));

    double maxValue = 0;
    for (final cell in cells) {
      if (cell.value > maxValue) {
        maxValue = cell.value;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: gridHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              final colCount = columns.length;
              final cellWidth =
                  (totalWidth - (spacing * (colCount - 1))) / colCount;

              final List<Widget> rowWidgets = [];
              for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
                final List<Widget> colWidgets = [];
                for (int colIndex = 0; colIndex < colCount; colIndex++) {
                  final cellIndex = rowIndex * colCount + colIndex;
                  final cell = cellIndex < cells.length
                      ? cells[cellIndex]
                      : null;
                  final isSelected = cell != null && selectedCell == cell;
                  final cellColor = _getColorForValue(
                    cell?.value ?? 0,
                    maxValue,
                  );

                  colWidgets.add(
                    GestureDetector(
                      onTap: () {
                        if (cell != null) {
                          onCellSelected(isSelected ? null : cell);
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: cellWidth,
                        height: cellHeight,
                        margin: EdgeInsets.only(
                          right: colIndex < colCount - 1 ? spacing : 0,
                        ),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(rows.length > 5 ? 3.0 : 5.0),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : const Color(0xFF26262E),
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                rowWidgets.add(
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: rowIndex < rows.length - 1 ? spacing : 0,
                    ),
                    child: Row(children: colWidgets),
                  ),
                );
              }

              return Column(children: rowWidgets);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: columns.map((label) {
            return Expanded(
              child: label.isEmpty
                  ? const SizedBox.shrink()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFF8E8E93),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForValue(double value, double max) {
    if (palette.isEmpty) return const Color(0xFF1C1C22);
    if (value <= 0 || max <= 0) return palette.first;

    final ratio = (value / max).clamp(0.0, 1.0);
    final numTiers = palette.length - 1;
    final index = (ratio * numTiers).ceil().clamp(1, numTiers);
    return palette[index];
  }
}
