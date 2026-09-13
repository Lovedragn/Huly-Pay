import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../theme/chart_colors.dart';
import '../widgets/analysis_category_pie_chart.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/spending_heatmap.dart';
import 'home_dashboard_screen.dart';
import 'scan_and_pay_screen.dart';
import 'transactions_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final List<CategorySpendingItem>? initialCategories;
  final String? totalSpent;
  final List<PaymentModel>? initialPayments;
  final bool isEmbedded;

  const AnalysisScreen({
    super.key,
    this.initialCategories,
    this.totalSpent,
    this.initialPayments,
    this.isEmbedded = false,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  late List<CategorySpendingItem> _categories;
  late String _totalSpent;
  List<PaymentModel> _allPayments = [];
  String _selectedPeriod = 'This Month';
  final List<String> _periodOptions = const [
    'Days',
    'Weeks',
    'This Month',
    '3 Months',
    '6 Months',
    '1 Year',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPayments != null) {
      _allPayments = List.from(widget.initialPayments!);
      _filterAndRecalculate();
    } else if (widget.initialCategories != null) {
      _categories = widget.initialCategories!;
      _totalSpent = widget.totalSpent ?? '₹0';
    } else {
      _categories = [];
      _totalSpent = widget.totalSpent ?? '₹0';
      _loadData();
    }
  }

  Future<void> _loadData() async {
    // 1. Read SQLite cached payments first
    try {
      final cached = await PaymentRepository().getCachedPayments();
      if (mounted && cached.isNotEmpty) {
        _setAllPayments(cached);
      }
    } catch (_) {}

    // 2. Fetch fresh payments from backend and update SQLite
    try {
      final payments = await PaymentRepository().getPayments(forceRefresh: true);
      if (mounted && payments.isNotEmpty) {
        _setAllPayments(payments);
      }
    } catch (_) {}
  }

  void _setAllPayments(List<PaymentModel> payments) {
    _allPayments = payments.where((p) {
      final s = p.status.toUpperCase();
      return s == 'CONFIRMED' || s == 'SUCCESS';
    }).toList();
    _filterAndRecalculate();
  }

  DateTime _getCutoffForPeriod(String period) {
    final now = DateTime.now();
    final clean = period.toLowerCase().trim();
    if (clean.contains('day')) {
      return now.subtract(const Duration(days: 7));
    } else if (clean.contains('week')) {
      return now.subtract(const Duration(days: 14));
    } else if (clean.contains('3') || clean.contains('three')) {
      return DateTime(now.year, now.month - 2, 1);
    } else if (clean.contains('6') || clean.contains('six')) {
      return DateTime(now.year, now.month - 5, 1);
    } else if (clean.contains('year')) {
      return DateTime(now.year - 1, now.month, 1);
    } else {
      // Month / This Month
      return DateTime(now.year, now.month, 1);
    }
  }

  String _getCenterLabel(String period) {
    final clean = period.toLowerCase().trim();
    if (clean.contains('day')) {
      return 'Spent last 7 days';
    } else if (clean.contains('week')) {
      return 'Spent last 2 weeks';
    } else if (clean.contains('3') || clean.contains('three')) {
      return 'Spent last 3 months';
    } else if (clean.contains('6') || clean.contains('six')) {
      return 'Spent last 6 months';
    } else if (clean.contains('year')) {
      return 'Spent this year';
    } else {
      return 'Spent this month';
    }
  }

  void _filterAndRecalculate() {
    if (!mounted) return;
    if (_allPayments.isEmpty) {
      if (widget.initialCategories != null) {
        setState(() {
          _categories = widget.initialCategories!;
          _totalSpent = widget.totalSpent ?? (_categories.isEmpty ? '₹0' : '₹12,480');
        });
      }
      return;
    }

    final cutoff = _getCutoffForPeriod(_selectedPeriod);
    final filtered = _allPayments.where((p) {
      if (p.status.toUpperCase() == 'FAILED') return false;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr == null) return false;
      try {
        final dt = DateTime.parse(dateStr);
        return dt.isAfter(cutoff.subtract(const Duration(seconds: 1)));
      } catch (_) {
        return false;
      }
    }).toList();

    if (filtered.isEmpty) {
      setState(() {
        _totalSpent = '₹0';
        _categories = [];
      });
      return;
    }

    double total = 0;
    final Map<String, double> categorySums = {};

    for (final p in filtered) {
      total += p.amount;
      String cat = p.merchantName?.trim() ?? 'Other';
      if (cat.isEmpty) cat = 'Other';
      categorySums[cat] = (categorySums[cat] ?? 0) + p.amount;
    }

    final colors = AppChartColors.globalPalette;

    int colorIdx = 0;
    final List<CategorySpendingItem> computed = [];

    final sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final pct = total > 0 ? ((entry.value / total) * 100).round() : 0;
      final amt = '₹${entry.value.toStringAsFixed(entry.value.truncateToDouble() == entry.value ? 0 : 2)}';
      computed.add(
        CategorySpendingItem(
          title: entry.key,
          percentage: pct,
          amount: amt,
          color: colors[colorIdx % colors.length],
        ),
      );
      colorIdx++;
    }

    setState(() {
      _totalSpent = '₹${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)}';
      _categories = computed;
    });
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
          const SizedBox(height: 24),
          AnalysisCategoryPieChart(
            items: _categories,
            totalAmount: _totalSpent,
            centerLabel: _getCenterLabel(_selectedPeriod),
          ),
          const SizedBox(height: 24),
          SpendingHeatmap(
            payments: _allPayments,
            period: _selectedPeriod,
          ),
          const SizedBox(height: 28),
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
            _filterAndRecalculate();
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
    if (_categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF141416),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF222226),
            width: 1,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.pie_chart_outline_rounded,
              color: Color(0xFF8E8E93),
              size: 32,
            ),
            SizedBox(height: 12),
            Text(
              'No spending data yet',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Categorized insights will appear here as you spend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Color(0xFF8E8E93),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

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
