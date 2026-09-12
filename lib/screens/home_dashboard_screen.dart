import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/mock_data.dart';
import '../models/dashboard_data.dart';
import '../widgets/action_button.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/spending_chart.dart';
import '../widgets/transaction_tile.dart';
import 'scan_and_pay_screen.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SingleChildScrollView(
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
                    SpendingChart(data: _data.weeklySpending),
                    const SizedBox(height: 28),
                    _buildRecentTransactionsSection(),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: _selectedNavIndex,
                onItemSelected: (index) {
                  if (index == 2) {
                    _openTransactions();
                  } else {
                    setState(() {
                      _selectedNavIndex = index;
                    });
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

  void _openScanAndPay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScanAndPayScreen(),
      ),
    );
  }

  void _openTransactions() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TransactionsScreen(),
      ),
    );
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
            Container(
              width: 44,
              height: 44,
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
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white70,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _data.greeting,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          _data.userName,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              SvgPicture.asset(
                'asserts/logo/logo.svg',
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF383842),
                  BlendMode.srcIn,
                ),
              ),
            ],
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
            onTap: () {},
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
          onTap: _openTransactions,
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
