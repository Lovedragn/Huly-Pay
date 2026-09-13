import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class DonutChart extends StatelessWidget {
  final List<CategorySpendingItem> items;
  final String totalAmount;
  final String centerLabel;
  final double size;
  final double strokeWidth;

  const DonutChart({
    super.key,
    required this.items,
    required this.totalAmount,
    this.centerLabel = 'Spent this month',
    this.size = 210,
    this.strokeWidth = 26,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              centerSpaceRadius: (size - strokeWidth * 2) / 2,
              sectionsSpace: 4,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                enabled: true,
              ),
              sections: items.map((cat) {
                return PieChartSectionData(
                  color: cat.color,
                  value: cat.percentage.toDouble(),
                  radius: strokeWidth,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerLabel,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                totalAmount,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
