import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';

class SpendingChart extends StatelessWidget {
  final List<SpendingBarData> data;

  const SpendingChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Spending This Month',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((bar) {
                return _buildBarItem(bar);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarItem(SpendingBarData bar) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 38,
          height: bar.height,
          decoration: BoxDecoration(
            color: bar.color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          bar.day,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
