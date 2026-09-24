import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../theme/app_theme.dart';

/// Interactive Donut / Pie Chart inspired by pie_chart_sample2.dart
/// Features touch selection expanding active section radius, dynamic font sizes,
/// drop shadows, and indicator legends for spending categories.
class AnalysisCategoryPieChart extends StatefulWidget {
  final List<CategorySpendingItem> items;
  final String totalAmount;
  final String centerLabel;
  final bool showLegend;
  final bool showCardBackground;
  final Widget? bottomRightAction;

  const AnalysisCategoryPieChart({
    super.key,
    required this.items,
    required this.totalAmount,
    this.centerLabel = 'Spent this month',
    this.showLegend = false,
    this.showCardBackground = false,
    this.bottomRightAction,
  });

  @override
  State<AnalysisCategoryPieChart> createState() =>
      _AnalysisCategoryPieChartState();
}

class _AnalysisCategoryPieChartState extends State<AnalysisCategoryPieChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: widget.showCardBackground ? 20 : 0,
            vertical: widget.showCardBackground ? 24 : 12,
          ),
          decoration: widget.showCardBackground
              ? BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.border, width: 1),
                )
              : null,
          child: Column(
            children: [
              // Donut Chart with Center Total
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!
                                  .touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: widget.items.isEmpty ? 0 : 3,
                        centerSpaceRadius: 48,
                        sections: widget.items.isEmpty
                            ? [
                                PieChartSectionData(
                                  color: const Color(0xFF222226),
                                  value: 100,
                                  radius: 46,
                                  showTitle: false,
                                ),
                              ]
                            : _showingSections(),
                      ),
                      duration: const Duration(milliseconds: 250),
                    ),
                    // Centered total spending amount
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.centerLabel,
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            color: Color(0xFF8E8E93),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.totalAmount,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: AppThemeManager.colors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    if (widget.bottomRightAction != null)
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: widget.bottomRightAction!,
                      ),
                  ],
                ),
              ),
              if (widget.showLegend && widget.items.isNotEmpty) ...[
                const SizedBox(height: 20),
                // Category Indicator Legends (pie_chart_sample2 style)
                Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: List.generate(widget.items.length, (i) {
                    final item = widget.items[i];
                    final isSelected = (i == _touchedIndex);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _touchedIndex = (_touchedIndex == i) ? -1 : i;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF22222A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(
                                  color: item.color.withValues(alpha: 0.6),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF8E8E93),
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${item.percentage}%',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: item.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(widget.items.length, (i) {
      final isTouched = (i == _touchedIndex);
      final item = widget.items[i];
      final fontSize = isTouched ? 16.0 : 13.0;
      final radius = isTouched ? 54.0 : 46.0;
      // Show label if section is touched or large enough (> 4%), otherwise keep it clean
      final showTitle = isTouched || item.percentage >= 4;

      return PieChartSectionData(
        color: item.color,
        value: item.percentage.toDouble().clamp(1.0, 100.0),
        title: showTitle ? '${item.percentage}%' : '',
        radius: radius,
        cornerRadius: 8,
        titlePositionPercentageOffset: 0.55,
        titleStyle: TextStyle(
          fontFamily: 'Google Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          shadows: const [
            Shadow(
              color: Color(0xCC000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
      );
    });
  }
}
