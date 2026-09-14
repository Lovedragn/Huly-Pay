import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/dashboard_data.dart';
import '../models/payment_model.dart';
import '../models/user_profile.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../widgets/action_button.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/home_spend_trend_line_chart.dart';
import '../widgets/home_today_spend_gauge.dart';
import '../widgets/home_weekly_bar_chart.dart';
import 'analysis_screen.dart';
import 'scan_and_pay_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  final DashboardData? initialData;

  const HomeDashboardScreen({
    super.key,
    this.initialData,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with WidgetsBindingObserver {
  int _selectedNavIndex = 0;
  late DashboardData _data;
  List<PaymentModel> _payments = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.initialData != null) {
      _data = widget.initialData!;
      _payments = [];
    } else {
      final authProfile = AuthService().currentUserProfile;
      _data = DashboardData(
        greeting: 'Good Morning,',
        userName: authProfile?.displayName ?? 'User',
        avatarUrl: authProfile?.avatarUrl ?? '',
        totalSpentFormatted: '₹0',
        changePercent: 0,
        changePeriodLabel: 'this month',
        weeklySpending: _computeWeeklySpending([]),
        recentTransactions: const [],
      );
      _loadRealData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-fetch fresh data every time user opens or resumes our application
      _loadRealData();
    }
  }

  Future<void> _loadRealData() async {
    // 1. Immediately render cached data from SQLite if available
    try {
      final cachedPayments = await PaymentRepository().getCachedPayments();
      final cachedUser = await UserRepository().getCachedUserProfile();
      if (mounted) {
        _applyData(cachedUser, cachedPayments);
      }
    } catch (_) {}

    // 2. Fetch fresh data from backend & sync SQLite cache
    try {
      final user = await UserRepository().getUserProfile(forceRefresh: true).catchError((_) => null);
      final payments = await PaymentRepository().getPayments(forceRefresh: true).catchError((_) => <PaymentModel>[]);
      if (mounted) {
        _applyData(user, payments);
      }
    } catch (_) {}
  }

  void _applyData(UserProfile? user, List<PaymentModel> payments) {
    if (!mounted) return;

    String userName = _data.userName;
    if (user != null && user.displayName.isNotEmpty) {
      userName = user.displayName;
    } else {
      final authProfile = AuthService().currentUserProfile;
      if (authProfile != null && authProfile.displayName.isNotEmpty) {
        userName = authProfile.displayName;
      }
    }

    String avatarUrl = user?.avatarUrl ?? AuthService().currentUserProfile?.avatarUrl ?? _data.avatarUrl;

    final confirmedPayments = payments.where((p) {
      final s = p.status.toUpperCase();
      return s == 'CONFIRMED' || s == 'SUCCESS';
    }).toList();

    double sum = 0;
    for (final p in confirmedPayments) {
      sum += p.amount;
    }
    final String totalSpent = '₹${sum.toStringAsFixed(sum.truncateToDouble() == sum ? 0 : 2)}';

    List<TransactionItem> recentTxs = [];
    if (payments.isNotEmpty) {
      final sorted = List<PaymentModel>.from(payments)
        ..sort((a, b) {
          final aDate = a.createdAt ?? '';
          final bDate = b.createdAt ?? '';
          return bDate.compareTo(aDate);
        });
      recentTxs = sorted.take(5).map((p) => p.toTransactionItem()).toList();
    }

    final weeklyBars = _computeWeeklySpending(confirmedPayments);

    setState(() {
      _payments = payments;
      _data = DashboardData(
        greeting: _data.greeting,
        userName: userName,
        avatarUrl: avatarUrl,
        totalSpentFormatted: totalSpent,
        changePercent: _data.changePercent,
        changePeriodLabel: _data.changePeriodLabel,
        weeklySpending: weeklyBars,
        recentTransactions: recentTxs,
      );
    });
  }

  List<SpendingBarData> _computeWeeklySpending(List<PaymentModel> payments) {
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayTotals = List<double>.filled(7, 0.0);

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);

    for (final p in payments) {
      final s = p.status.toUpperCase();
      if (s != 'CONFIRMED' && s != 'SUCCESS') continue;
      if (p.createdAt == null) continue;
      try {
        final dt = DateTime.parse(p.createdAt!);
        if (dt.isAfter(weekStart.subtract(const Duration(seconds: 1)))) {
          final dayIdx = dt.weekday - 1;
          if (dayIdx >= 0 && dayIdx < 7) {
            dayTotals[dayIdx] += p.amount;
          }
        }
      } catch (_) {}
    }

    double maxTotal = 0;
    for (final t in dayTotals) {
      if (t > maxTotal) maxTotal = t;
    }

    return List.generate(7, (i) {
      final total = dayTotals[i];
      final double h = maxTotal > 0 ? (total / maxTotal) * 110 + 4 : 4.0;
      final bool isToday = (i == now.weekday - 1);
      return SpendingBarData(
        day: dayLabels[i],
        height: h,
        color: isToday
            ? const Color(0xFFFFFFFF)
            : (total > 0 ? const Color(0xFF6B6B70) : const Color(0xFF26262B)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedNavIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedNavIndex != 0) {
          setState(() {
            _selectedNavIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Screen Body depending on active tab
              Positioned.fill(
                child: _buildBody(),
              ),

              // Sticky Bottom Navigation Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: CustomBottomNavBar(
                  selectedIndex: _selectedNavIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                  onQrScanTap: _openScanAndPay,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 1:
        return const AnalysisScreen(isEmbedded: true);
      case 2:
        return const TransactionsScreen(isEmbedded: true);
      case 0:
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    return RefreshIndicator(
      onRefresh: _loadRealData,
      color: Colors.white,
      backgroundColor: const Color(0xFF1C1C1E),
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
            _buildTotalSpentCard(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            HomeSpendTrendLineChart(payments: _payments),
            const SizedBox(height: 20),
            HomeTodaySpendGaugeChart(payments: _payments),
            const SizedBox(height: 20),
            HomeWeeklyBarChart(
              payments: _payments,
              onTap: () {
                setState(() {
                  _selectedNavIndex = 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openScanAndPay() async {
    final targetIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => const ScanAndPayScreen(),
      ),
    );
    if (targetIndex != null && mounted) {
      setState(() {
        _selectedNavIndex = targetIndex;
      });
    }
  }

  Future<void> _openSettings() async {
    final targetIndex = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
    if (targetIndex != null && mounted) {
      setState(() {
        _selectedNavIndex = targetIndex;
      });
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'asserts/logo/logo.svg',
              height: 24,
            ),
            Tooltip(
              message: 'Profile & Settings',
              child: GestureDetector(
                key: const Key('profile_button'),
                onTap: _openSettings,
                behavior: HitTestBehavior.opaque,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A2A30),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: _data.avatarUrl.isNotEmpty && _data.avatarUrl.startsWith('http')
                          ? Image.network(
                              _data.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
                            )
                          : Image.asset(
                              'asserts/pictures/profile.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSpentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            'TOTAL SPENT',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _data.totalSpentFormatted,
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.north,
                color: Color(0xFF30D158),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                '${_data.changePercent.toInt()}% ',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF30D158),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _data.changePeriodLabel,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: QuickActionButton(
            svgAsset: 'asserts/icon/upload.svg',
            label: 'upload',
            onTap: () {},
          ),
        ),
        Expanded(
          child: QuickActionButton(
            svgAsset: 'asserts/icon/qr.svg',
            label: 'Scan',
            onTap: _openScanAndPay,
          ),
        ),
        Expanded(
          child: QuickActionButton(
            svgAsset: 'asserts/icon/more.svg',
            label: 'More',
            onTap: _openSettings,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarFallback() {
    final initials = _getInitials(_data.userName);
    return Container(
      color: const Color(0xFF00C076),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SS';
  }
}
