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

  const AnalysisCategoryPieChart({
    super.key,
    required this.items,
    required this.totalAmount,
    this.centerLabel = 'Spent this month',
    this.showLegend = false,
  });

  @override
  State<AnalysisCategoryPieChart> createState() => _AnalysisCategoryPieChartState();
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Donut Chart with Center Total
              SizedBox(
                height: 220,
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
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: widget.items.isEmpty ? 0 : 3,
                        centerSpaceRadius: 52,
                        sections: widget.items.isEmpty
                            ? [
                                PieChartSectionData(
                                  color: const Color(0xFF222226),
                                  value: 100,
                                  radius: 48,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF22222A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: item.color.withValues(alpha: 0.6))
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
                                color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      final fontSize = isTouched ? 18.0 : 12.0;
      final radius = isTouched ? 58.0 : 48.0;
      const shadows = [
        Shadow(color: Colors.black87, blurRadius: 4),
      ];

      return PieChartSectionData(
        color: item.color,
        value: item.percentage.toDouble().clamp(1.0, 100.0),
        title: '${item.percentage}%',
        radius: radius,
        titleStyle: TextStyle(
          fontFamily: 'Google Sans',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    });
  }
}
