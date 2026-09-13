import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/dashboard_data.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/donut_chart.dart';
import 'home_dashboard_screen.dart';
import 'scan_and_pay_screen.dart';
import 'transactions_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final List<CategorySpendingItem>? initialCategories;
  final String? totalSpent;
  final bool isEmbedded;

  const AnalysisScreen({
    super.key,
    this.initialCategories,
    this.totalSpent,
    this.isEmbedded = false,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late List<CategorySpendingItem> _categories;
  late String _totalSpent;
  String _selectedPeriod = 'This Month';
  final List<String> _periodOptions = const [
    'This Month',
    'Last Month',
    'Last 3 Months',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _categories = widget.initialCategories ?? MockData.analysisCategoryItems;
    _totalSpent = widget.totalSpent ?? '₹12,480';
  }

  void _openScanAndPay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScanAndPayScreen(),
      ),
    );
  }

  void _openTransactions() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const TransactionsScreen(),
      ),
    );
  }

  void _openHome() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeDashboardScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: 110, // padding for bottom nav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          Center(
            child: DonutChart(
              items: _categories,
              totalAmount: _totalSpent,
              size: 210,
              strokeWidth: 26,
            ),
          ),
          const SizedBox(height: 32),
          _buildCategoryList(),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: content),

            // Bottom Navigation Bar (Analyze active)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: 1, // Analyze tab active
                isQrActive: false,
                onItemSelected: (index) {
                  if (index == 0) {
                    _openHome();
                  } else if (index == 2) {
                    _openTransactions();
                  }
                },
                onQrScanTap: _openScanAndPay,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Spending Insights',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (val) {
            setState(() {
              _selectedPeriod = val;
            });
          },
          color: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (context) {
            return _periodOptions.map((period) {
              return PopupMenuItem<String>(
                value: period,
                child: Text(
                  period,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: period == _selectedPeriod
                        ? Colors.white
                        : const Color(0xFF8E8E93),
                    fontSize: 14,
                    fontWeight: period == _selectedPeriod
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141416),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF222226),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPeriod,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: _categories.map((cat) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF202024),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cat.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                cat.title,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${cat.percentage}%',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                cat.amount,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
