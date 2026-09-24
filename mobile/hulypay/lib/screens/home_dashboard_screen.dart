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
import 'analysis_screen.dart';
import 'scan_and_pay_screen.dart';
import 'settings_screen.dart';
import 'transactions_screen.dart';
import 'notifications_screen.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';

class HomeDashboardScreen extends StatefulWidget {
  final DashboardData? initialData;
  final bool? quickScan;

  const HomeDashboardScreen({
    super.key,
    this.initialData,
    this.quickScan,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  late DashboardData _data;
  List<PaymentModel> _payments = [];
  double _dailyLimit = 5000.0;

  // Scroll-aware scanner button
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _scannerAnimController;
  late final Animation<Offset> _scannerSlideAnimation;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _dailyLimit = UserPreferencesService().cachedDailyLimit ?? 5000.0;

    _scannerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scannerSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 2.5), // slide down out of view
    ).animate(CurvedAnimation(
      parent: _scannerAnimController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);

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

    final shouldQuickScan = widget.quickScan ?? UserPreferencesService().cachedQuickScan;
    if (shouldQuickScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _openScanAndPay();
        }
      });
    }
  }

  void _onScroll() {
    final current = _scrollController.offset;
    final delta = current - _lastScrollOffset;
    if (delta > 4 && _scannerAnimController.status != AnimationStatus.forward) {
      // scrolling down → hide
      _scannerAnimController.forward();
    } else if (delta < -4 && _scannerAnimController.status != AnimationStatus.reverse) {
      // scrolling up → show
      _scannerAnimController.reverse();
    }
    _lastScrollOffset = current;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scannerAnimController.dispose();
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
        if (payments.isNotEmpty || _payments.isEmpty) {
          _applyData(user, payments);
        } else if (user != null) {
          _applyData(user, _payments);
        }
      }
    } catch (_) {}

    // 3. Load daily spending limit from UserPreferencesService (local SQLite & remote Supabase)
    try {
      final limit = await UserPreferencesService().getDailyLimit(forceRefresh: true);
      if (mounted && _dailyLimit != limit) {
        setState(() {
          _dailyLimit = limit;
        });
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

    final confirmedPayments = payments.where((p) => p.isSuccessful).toList();

    double sum = 0;
    for (final p in confirmedPayments) {
      sum += p.amount;
    }
    final String totalSpent = '₹${sum.toStringAsFixed(sum.truncateToDouble() == sum ? 0 : 2)}';

    List<TransactionItem> recentTxs = [];
    if (payments.isNotEmpty) {
      final sorted = List<PaymentModel>.from(payments)
        ..sort((a, b) {
          final aDate = a.createdAt ?? a.paymentDate ?? '';
          final bDate = b.createdAt ?? b.paymentDate ?? '';
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
      if (!p.isSuccessful) continue;
      final dateStr = p.createdAt ?? p.paymentDate;
      if (dateStr == null) continue;
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        if (dt.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(weekStart.add(const Duration(days: 7)))) {
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
        backgroundColor: AppThemeManager.colors.background,
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
                ),
              ),

              // Floating Scanner Button — centered above bottom nav bar
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).padding.bottom + 62,
                child: SlideTransition(
                  position: _scannerSlideAnimation,
                  child: Center(
                    child: GestureDetector(
                      onTap: _openScanAndPay,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppThemeManager.colors.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppThemeManager.colors.accent.withValues(alpha: 0.35),
                              blurRadius: 16,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icon/qr.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
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
        return AnalysisScreen(isEmbedded: true, initialPayments: _payments);
      case 2:
        return const TransactionsScreen(isEmbedded: true);
      case 0:
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildDashboardContent() {
    final colors = AppThemeManager.colors;

    return RefreshIndicator(
      onRefresh: _loadRealData,
      color: colors.accent,
      backgroundColor: colors.surfaceSecondary,
      displacement: 28,
      child: SingleChildScrollView(
        controller: _scrollController,
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
            HomeTodaySpendGaugeChart(
              payments: _payments,
              dailyBudget: _dailyLimit,
              onLimitChanged: _loadRealData,
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
    // Refresh dashboard data so new transaction reflects in Daily Limit chart immediately
    _loadRealData();
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
    final colors = AppThemeManager.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              colors.isDark
                  ? 'assets/logo/Logo-Dark.svg'
                  : 'assets/logo/logo-Light.svg',
              height: 24,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Notifications (In Dev)',
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.notifications_outlined,
                            color: colors.textPrimary,
                            size: 22,
                          ),
                          Positioned(
                            top: 10,
                            right: 11,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF9500),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                            color: colors.border,
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
                                  'assets/pictures/profile.png',
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
        ),
      ],
    );
  }

  Widget _buildTotalSpentCard() {
    final colors = AppThemeManager.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _data.totalSpentFormatted,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 50,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.north,
                color: Color(0xFF30D158),
                size: 16,
              ),
              const SizedBox(width: 2),
              Text(
                '${_data.changePercent.toInt()}%',
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF30D158),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
            svgAsset: 'assets/icon/upload.svg',
            label: 'upload',
            onTap: () {},
          ),
        ),
        Expanded(
          child: QuickActionButton(
            svgAsset: 'assets/icon/qr.svg',
            label: 'Scan',
            onTap: _openScanAndPay,
          ),
        ),
        Expanded(
          child: QuickActionButton(
            svgAsset: 'assets/icon/more.svg',
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
