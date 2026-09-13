import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/mock_data.dart';
import '../models/dashboard_data.dart';
import '../widgets/action_button.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
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

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _selectedNavIndex = 0;
  late DashboardData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.initialData ?? MockData.dashboardData;
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
    return SingleChildScrollView(
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
          const SizedBox(height: 20),
          _buildTotalSpentCard(),
          const SizedBox(height: 24),
          _buildQuickActions(),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedNavIndex = 1;
              });
            },
            behavior: HitTestBehavior.opaque,
            child: SpendingChart(data: _data.weeklySpending),
          ),
          const SizedBox(height: 28),
          _buildRecentTransactionsSection(),
        ],
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
                      child: Image.asset(
                        'asserts/pictures/profile.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF00C076),
                          child: const Center(
                            child: Text(
                              'SS',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
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
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _openSettings,
          behavior: HitTestBehavior.opaque,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Text(
              _data.userName,
              style: const TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
          ),
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

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedNavIndex = 2;
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6B6B70),
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF141416),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF222226),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _data.recentTransactions.length; i++) ...[
                TransactionTile(transaction: _data.recentTransactions[i]),
                if (i < _data.recentTransactions.length - 1)
                  const Divider(
                    color: Color(0xFF202024),
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
    );
  }
}
