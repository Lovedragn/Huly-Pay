import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/local_database_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';
import '../widgets/analysis_category_pie_chart.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/spending_heatmap.dart';
import 'home_dashboard_screen.dart';
import 'transactions_screen.dart';

enum SpendingClassificationMode {
  byMerchant,
  byCategory,
}

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
  Map<String, String> _categoryOverrides = {};
  SpendingClassificationMode _classificationMode = SpendingClassificationMode.byMerchant;
  String _selectedPeriod = 'Month';
  final List<String> _periodOptions = const [
    'Day',
    'Week',
    'Month',
    'Quarter',
    'Year',
  ];

  static const Map<String, Color> _kCategoryColors = {
    'Food & Dining': Color(0xFFFF9500),
    'Shopping': Color(0xFF007AFF),
    'Bills & Utilities': Color(0xFFAF52DE),
    'Transportation': Color(0xFF30D158),
    'Entertainment': Color(0xFFFF2D55),
    'Groceries': Color(0xFF34C759),
    'Health & Fitness': Color(0xFF5AC8FA),
    'Travel': Color(0xFFFFCC00),
    'Personal Care': Color(0xFFFF6482),
    'Education': Color(0xFF5856D6),
    'Other': Color(0xFF8E8E93),
  };

  @override
  void initState() {
    super.initState();
    AppThemeManager.currentChartPalette.addListener(_onThemeOrPaletteChanged);
    AppThemeManager.currentTheme.addListener(_onThemeOrPaletteChanged);
    final cached = UserPreferencesService().cachedAnalysisPeriod;
    if (cached != null && _periodOptions.contains(cached)) {
      _selectedPeriod = cached;
    }
    _loadSavedPeriod();
    _loadCategoryOverrides();
    if (widget.initialPayments != null && widget.initialPayments!.isNotEmpty) {
      _allPayments = List.from(widget.initialPayments!);
      _filterAndRecalculate();
    } else if (widget.initialCategories != null) {
      _categories = widget.initialCategories!;
      _totalSpent = widget.totalSpent ?? '₹0';
      _loadData();
    } else {
      _categories = [];
      _totalSpent = widget.totalSpent ?? '₹0';
      _loadData();
    }
  }

  void _onThemeOrPaletteChanged() {
    if (mounted) {
      _filterAndRecalculate();
    }
  }

  @override
  void dispose() {
    AppThemeManager.currentChartPalette.removeListener(_onThemeOrPaletteChanged);
    AppThemeManager.currentTheme.removeListener(_onThemeOrPaletteChanged);
    super.dispose();
  }

  Future<void> _loadCategoryOverrides() async {
    try {
      final overrides = await LocalDatabaseService().getAllCategoryMetadata();
      if (mounted) {
        setState(() {
          _categoryOverrides = overrides;
        });
        if (_classificationMode == SpendingClassificationMode.byCategory) {
          _filterAndRecalculate();
        }
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant AnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPayments != null &&
        widget.initialPayments != oldWidget.initialPayments) {
      _allPayments = List.from(widget.initialPayments!);
      _filterAndRecalculate();
    }
  }

  Future<void> _loadSavedPeriod() async {
    try {
      final saved = await UserPreferencesService().getAnalysisPeriod();
      if (saved != null && _periodOptions.contains(saved) && mounted) {
        setState(() {
          _selectedPeriod = saved;
        });
        _filterAndRecalculate();
      }
    } catch (_) {}
  }

  Future<void> _loadData() async {
    // 1. Read category overrides
    try {
      final overrides = await LocalDatabaseService().getAllCategoryMetadata();
      if (mounted) {
        _categoryOverrides = overrides;
      }
    } catch (_) {}

    // 2. Read SQLite cached payments first
    try {
      final cached = await PaymentRepository().getCachedPayments();
      if (mounted && cached.isNotEmpty) {
        _setAllPayments(cached);
      }
    } catch (_) {}

    // 3. Fetch fresh payments from backend and update SQLite
    try {
      final payments = await PaymentRepository().getPayments(forceRefresh: true);
      if (mounted && payments.isNotEmpty) {
        _setAllPayments(payments);
      }
    } catch (_) {}
  }

  void _setAllPayments(List<PaymentModel> payments) {
    _allPayments = payments.where((p) => p.isSuccessful).toList();
    _filterAndRecalculate();
  }

  String _resolvePaymentCategory(PaymentModel p) {
    // 1. Check local metadata override
    final override = _categoryOverrides[p.id];
    if (override != null && override.isNotEmpty) {
      return override;
    }

    // 2. Fallback to paymentMethod if it's already an explicit category name
    final pm = p.paymentMethod?.trim();
    if (pm != null && pm.isNotEmpty && pm.toUpperCase() != 'UPI' && pm.toUpperCase() != 'UNKNOWN') {
      for (final catName in _kCategoryColors.keys) {
        if (catName.toLowerCase() == pm.toLowerCase()) {
          return catName;
        }
      }
    }

    // 3. Infer from merchant name / UPI details
    final title = (p.merchantName != null && p.merchantName!.trim().isNotEmpty)
        ? p.merchantName!.trim()
        : (p.upiId != null && p.upiId!.trim().isNotEmpty ? p.upiId!.trim() : '');
    final tLower = title.toLowerCase();

    if (tLower.contains('swiggy') ||
        tLower.contains('zomato') ||
        tLower.contains('restaurant') ||
        tLower.contains('cafe') ||
        tLower.contains('coffee') ||
        tLower.contains('starbucks') ||
        tLower.contains('food') ||
        tLower.contains('dining') ||
        tLower.contains('kitchen') ||
        tLower.contains('bistro')) {
      return 'Food & Dining';
    } else if (tLower.contains('amazon') ||
        tLower.contains('flipkart') ||
        tLower.contains('myntra') ||
        tLower.contains('store') ||
        tLower.contains('mall') ||
        tLower.contains('retail') ||
        tLower.contains('shop')) {
      return 'Shopping';
    } else if (tLower.contains('uber') ||
        tLower.contains('ola') ||
        tLower.contains('fuel') ||
        tLower.contains('petrol') ||
        tLower.contains('metro') ||
        tLower.contains('transit') ||
        tLower.contains('cab')) {
      return 'Transportation';
    } else if (tLower.contains('bill') ||
        tLower.contains('electric') ||
        tLower.contains('water') ||
        tLower.contains('recharge') ||
        tLower.contains('airtel') ||
        tLower.contains('jio') ||
        tLower.contains('broadband') ||
        tLower.contains('utility')) {
      return 'Bills & Utilities';
    } else if (tLower.contains('grocer') ||
        tLower.contains('supermarket') ||
        tLower.contains('blinkit') ||
        tLower.contains('zepto') ||
        tLower.contains('instamart') ||
        tLower.contains('bigbasket')) {
      return 'Groceries';
    } else if (tLower.contains('netflix') ||
        tLower.contains('spotify') ||
        tLower.contains('cinema') ||
        tLower.contains('movie') ||
        tLower.contains('theatre') ||
        tLower.contains('prime video') ||
        tLower.contains('hotstar') ||
        tLower.contains('game')) {
      return 'Entertainment';
    } else if (tLower.contains('pharmacy') ||
        tLower.contains('apollo') ||
        tLower.contains('med') ||
        tLower.contains('clinic') ||
        tLower.contains('hospital') ||
        tLower.contains('cult') ||
        tLower.contains('gym') ||
        tLower.contains('fitness')) {
      return 'Health & Fitness';
    } else if (tLower.contains('flight') ||
        tLower.contains('airline') ||
        tLower.contains('hotel') ||
        tLower.contains('makemytrip') ||
        tLower.contains('irctc') ||
        tLower.contains('stay') ||
        tLower.contains('travel')) {
      return 'Travel';
    } else if (tLower.contains('salon') ||
        tLower.contains('spa') ||
        tLower.contains('beauty') ||
        tLower.contains('barber')) {
      return 'Personal Care';
    } else if (tLower.contains('school') ||
        tLower.contains('college') ||
        tLower.contains('university') ||
        tLower.contains('course') ||
        tLower.contains('udemy') ||
        tLower.contains('coursera') ||
        tLower.contains('tuition') ||
        tLower.contains('education')) {
      return 'Education';
    }

    if (pm != null && pm.isNotEmpty && pm.toUpperCase() != 'UPI') {
      return pm;
    }

    return 'Other';
  }

  DateTime _getCutoffForPeriod(String period) {
    final now = DateTime.now();
    final clean = period.toLowerCase().trim();
    if (clean.contains('day') || clean.contains('today')) {
      return DateTime(now.year, now.month, now.day);
    } else if (clean.contains('week')) {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return DateTime(monday.year, monday.month, monday.day);
    } else if (clean.contains('quarter') || clean.contains('3') || clean.contains('three')) {
      return DateTime(now.year, now.month - 2, 1);
    } else if (clean.contains('year')) {
      return DateTime(now.year - 1, now.month, 1);
    } else {
      // Month
      return DateTime(now.year, now.month, 1);
    }
  }

  String _getCenterLabel(String period) {
    final clean = period.toLowerCase().trim();
    if (clean.contains('day') || clean.contains('today')) {
      return 'Spent today';
    } else if (clean.contains('week')) {
      return 'Spent this week';
    } else if (clean.contains('quarter') || clean.contains('3') || clean.contains('three')) {
      return 'Spent this quarter';
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
      if (!p.isSuccessful) return false;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr == null) return false;
      try {
        final dt = DateTime.parse(dateStr).toLocal();
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
      String groupKey;
      if (_classificationMode == SpendingClassificationMode.byCategory) {
        groupKey = _resolvePaymentCategory(p);
      } else {
        groupKey = p.merchantName?.trim() ?? 'Other';
        if (groupKey.isEmpty) groupKey = 'Other';
      }
      categorySums[groupKey] = (categorySums[groupKey] ?? 0) + p.amount;
    }

    final colors = AppChartColors.globalPalette;

    int colorIdx = 0;
    final List<CategorySpendingItem> computed = [];

    final sortedEntries = categorySums.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (final entry in sortedEntries) {
      final pct = total > 0 ? ((entry.value / total) * 100).round() : 0;
      final amt = '₹${entry.value.toStringAsFixed(entry.value.truncateToDouble() == entry.value ? 0 : 2)}';
      final Color itemColor;
      if (_classificationMode == SpendingClassificationMode.byCategory) {
        itemColor = _kCategoryColors[entry.key] ?? colors[colorIdx % colors.length];
      } else {
        itemColor = colors[colorIdx % colors.length];
      }
      computed.add(
        CategorySpendingItem(
          title: entry.key,
          percentage: pct,
          amount: amt,
          color: itemColor,
        ),
      );
      colorIdx++;
    }

    setState(() {
      _totalSpent = '₹${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)}';
      _categories = computed;
    });
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
    final colors = AppThemeManager.colors;

    final content = RefreshIndicator(
      onRefresh: _loadData,
      color: colors.accent,
      backgroundColor: colors.surfaceSecondary,
      displacement: 28,
      child: Column(
        children: [
          Container(
            color: colors.background,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _buildHeader(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 4,
                bottom: 110, // padding for bottom nav
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnalysisCategoryPieChart(
                    items: _categories,
                    totalAmount: _totalSpent,
                    centerLabel: _getCenterLabel(_selectedPeriod),
                    bottomRightAction: _buildClassificationToggleButton(),
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
            ),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: colors.background,
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
                onItemSelected: (index) {
                  if (index == 0) {
                    _openHome();
                  } else if (index == 2) {
                    _openTransactions();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final colors = AppThemeManager.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Spending Insights',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textPrimary,
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
            UserPreferencesService().saveAnalysisPeriod(val);
            _filterAndRecalculate();
          },
          color: colors.surfaceSecondary,
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
                        ? colors.accent
                        : colors.textSecondary,
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
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.border,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedPeriod,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.textPrimary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassificationToggleButton() {
    final colors = AppThemeManager.colors;
    final isCategory = _classificationMode == SpendingClassificationMode.byCategory;

    return GestureDetector(
      key: const Key('analysis_classification_toggle_button'),
      onTap: () {
        setState(() {
          _classificationMode = isCategory
              ? SpendingClassificationMode.byMerchant
              : SpendingClassificationMode.byCategory;
        });
        _filterAndRecalculate();
      },
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: isCategory
            ? 'Switch to Payment Breakdown'
            : 'Switch to Category Breakdown',
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isCategory
                ? colors.accent.withValues(alpha: 0.2)
                : colors.surfaceSecondary,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCategory
                  ? colors.accent.withValues(alpha: 0.8)
                  : colors.border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              isCategory
                  ? Icons.category_rounded
                  : Icons.receipt_long_rounded,
              color: isCategory
                  ? colors.accent
                  : colors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final colors = AppThemeManager.colors;

    if (_categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
            Icon(
              Icons.pie_chart_outline_rounded,
              color: colors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No spending data yet',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Categorized insights will appear here as you spend.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textSecondary,
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
            color: colors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.border,
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
              Expanded(
                child: Text(
                  cat.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${cat.percentage}%',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                cat.amount,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
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
