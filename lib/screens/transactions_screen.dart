import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/transaction_tile.dart';
import 'analysis_screen.dart';
import 'home_dashboard_screen.dart';
import 'scan_and_pay_screen.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  final List<TransactionGroup>? initialGroups;
  final bool isEmbedded;

  const TransactionsScreen({
    super.key,
    this.initialGroups,
    this.isEmbedded = false,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0;
  final List<String> _filters = const [
    'All',
    'Pending',
    'Failed',
    'Food',
    'Internet',
    'Shopping',
    'Bills',
  ];
  late List<TransactionGroup> _allGroups;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialGroups != null) {
      _allGroups = widget.initialGroups!;
    } else {
      _allGroups = [];
      _loadPayments();
    }
  }

  Future<void> _loadPayments() async {
    // 1. Instantly display cached payments from SQLite
    try {
      final cached = await PaymentRepository().getCachedPayments();
      if (mounted) {
        final sorted = List<PaymentModel>.from(cached)
          ..sort((a, b) {
            final aDate = a.createdAt ?? '';
            final bDate = b.createdAt ?? '';
            return bDate.compareTo(aDate);
          });
        setState(() {
          _allGroups = PaymentModel.groupPayments(sorted);
        });
      }
    } catch (_) {}

    // 2. Fetch fresh payments from backend and update SQLite cache
    try {
      final payments = await PaymentRepository().getPayments(forceRefresh: true);
      if (!mounted) return;
      final sorted = List<PaymentModel>.from(payments)
        ..sort((a, b) {
          final aDate = a.createdAt ?? '';
          final bDate = b.createdAt ?? '';
          return bDate.compareTo(aDate);
        });
      setState(() {
        _allGroups = PaymentModel.groupPayments(sorted);
      });
    } catch (_) {
      // Graceful fallback to cached groups
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionGroup> get _filteredGroups {
    final selectedFilter = _filters[_selectedFilterIndex];
    final query = _searchQuery.trim().toLowerCase();

    List<TransactionGroup> result = [];

    for (final group in _allGroups) {
      final filteredTx = group.transactions.where((tx) {
        // Filter by category
        bool matchesType = true;
        if (selectedFilter == 'Pending') {
          matchesType = tx.isPending;
        } else if (selectedFilter == 'Failed') {
          matchesType = tx.isFailed;
        } else if (selectedFilter == 'Food') {
          matchesType = tx.category.toLowerCase().contains('food');
        } else if (selectedFilter == 'Internet') {
          matchesType = tx.category.toLowerCase().contains('internet') ||
              tx.title.toLowerCase().contains('fiber') ||
              tx.title.toLowerCase().contains('broadband') ||
              tx.title.toLowerCase().contains('wifi');
        } else if (selectedFilter == 'Shopping') {
          matchesType = tx.category.toLowerCase().contains('shopping');
        } else if (selectedFilter == 'Bills') {
          matchesType = tx.category.toLowerCase().contains('bill');
        } else if (selectedFilter != 'All') {
          matchesType = tx.category.toLowerCase().contains(selectedFilter.toLowerCase());
        }

        // Filter by search query
        bool matchesQuery = true;
        if (query.isNotEmpty) {
          matchesQuery = tx.title.toLowerCase().contains(query) ||
              tx.category.toLowerCase().contains(query) ||
              tx.amount.toLowerCase().contains(query);
        }

        return matchesType && matchesQuery;
      }).toList();

      if (filteredTx.isNotEmpty) {
        result.add(TransactionGroup(
          title: group.title,
          transactions: filteredTx,
        ));
      }
    }

    return result;
  }

  void _openScanAndPay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScanAndPayScreen(),
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

  void _openAnalysis() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const AnalysisScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;
    final groupsToDisplay = _filteredGroups;

    final content = RefreshIndicator(
      onRefresh: _loadPayments,
      color: colors.accent,
      backgroundColor: colors.surfaceSecondary,
      displacement: 28,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 18),
            _buildFilterChips(),
            const SizedBox(height: 26),
            _buildGroupedTransactions(groupsToDisplay),
          ],
        ),
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

            // Bottom Navigation Bar (Transactions active)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: 2, // Transactions active
                isQrActive: false,
                onItemSelected: (index) {
                  if (index == 0) {
                    _openHome();
                  } else if (index == 1) {
                    _openAnalysis();
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
    final colors = AppThemeManager.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Transactions',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.iconBackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.search_rounded,
              color: colors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final colors = AppThemeManager.colors;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: colors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search transactions',
                hintStyle: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textMuted,
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Icon(
                Icons.close_rounded,
                color: colors.textSecondary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final colors = AppThemeManager.colors;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: EdgeInsets.only(
              right: index < _filters.length - 1 ? 10 : 0,
            ),
            child: GestureDetector(
              key: Key('filter_chip_${_filters[index]}'),
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.accent : colors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: colors.border,
                          width: 1,
                        ),
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: isSelected ? Colors.white : colors.textSecondary,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGroupedTransactions(List<TransactionGroup> groups) {
    final colors = AppThemeManager.colors;

    if (groups.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
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
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.iconBackground,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: colors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Transactions will appear here once you make payments.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.title,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
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
                    for (int i = 0; i < group.transactions.length; i++) ...[
                      TransactionTile(transaction: group.transactions[i]),
                      if (i < group.transactions.length - 1)
                        Divider(
                          color: colors.divider,
                          height: 1,
                          thickness: 1,
                          indent: 74,
                          endIndent: 16,
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
