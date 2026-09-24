import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock notification state toggles for development demo
  bool _pushNotifications = true;
  bool _transactionAlerts = true;
  bool _securityAlerts = true;
  bool _budgetExceededWarnings = false;

  final List<Map<String, dynamic>> _mockActivityNotifications = [
    {
      'title': 'Development Sandbox Active',
      'body': 'You are operating in the test and developer preview build. Payment simulations are enabled.',
      'time': 'Just now',
      'icon': Icons.science_outlined,
      'color': Color(0xFFFF9500),
      'isRead': false,
    },
    {
      'title': 'Daily Spending Limit Synced',
      'body': 'Your local database budget threshold was updated and cached offline successfully.',
      'time': '15m ago',
      'icon': Icons.track_changes_rounded,
      'color': Color(0xFF0A84FF),
      'isRead': false,
    },
    {
      'title': 'Offline SQLite Cache Ready',
      'body': 'Local storage engine initialized with zero uncommitted transactions.',
      'time': '2h ago',
      'icon': Icons.sync_rounded,
      'color': Color(0xFF34C759),
      'isRead': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(colors),
            _buildTabBar(colors),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildInboxTab(colors),
                  _buildPreferencesTab(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppThemeData colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.textPrimary,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF9500),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Preview / Dev Prototype',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppThemeData colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: colors.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: 'Google Sans',
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Google Sans',
          fontWeight: FontWeight.w500,
          fontSize: 13.5,
        ),
        tabs: const [
          Tab(text: 'Activity Feed'),
          Tab(text: 'Push Channels'),
        ],
      ),
    );
  }

  Widget _buildInboxTab(AppThemeData colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildDevNoticeBanner(colors),
          const SizedBox(height: 18),
          ..._mockActivityNotifications.map((n) => _buildNotificationCard(colors, n)),
          const SizedBox(height: 20),
          _buildWipFooter(colors),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDevNoticeBanner(AppThemeData colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9500).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF9500).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.construction_rounded,
              color: Color(0xFFFF9500),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notification Service In Development',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFFFF9500),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Push notification dispatchers and WebSocket real-time triggers are currently being integrated with our cloud backends. Sample alerts shown below illustrate the upcoming ledger events interface.',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppThemeData colors, Map<String, dynamic> item) {
    final bool isRead = item['isRead'] as bool;
    final Color itemColor = item['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRead ? colors.border : itemColor.withValues(alpha: 0.4),
          width: isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: itemColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'] as IconData,
              color: itemColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      item['time'] as String,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['body'] as String,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesTab(AppThemeData colors) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Notification Channels',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure how HulyPay alerts you when background syncing completes.',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSwitchTile(
                  colors: colors,
                  title: 'Push Notifications',
                  subtitle: 'Enable system alerts for payments and receipts',
                  value: _pushNotifications,
                  onChanged: (v) => setState(() => _pushNotifications = v),
                ),
                Divider(color: colors.divider, height: 24),
                _buildSwitchTile(
                  colors: colors,
                  title: 'Instant Transaction Alerts',
                  subtitle: 'Get notified immediately after QR payment completes',
                  value: _transactionAlerts,
                  onChanged: (v) => setState(() => _transactionAlerts = v),
                ),
                Divider(color: colors.divider, height: 24),
                _buildSwitchTile(
                  colors: colors,
                  title: 'Security & Auth Notices',
                  subtitle: 'Alerts for unrecognized device logins and token expiry',
                  value: _securityAlerts,
                  onChanged: (v) => setState(() => _securityAlerts = v),
                ),
                Divider(color: colors.divider, height: 24),
                _buildSwitchTile(
                  colors: colors,
                  title: 'Daily Budget Warnings',
                  subtitle: 'Receive a reminder when approaching 90% of your daily limit',
                  value: _budgetExceededWarnings,
                  onChanged: (v) => setState(() => _budgetExceededWarnings = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildWipFooter(colors),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required AppThemeData colors,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeThumbColor: colors.accent,
          activeTrackColor: colors.accent.withValues(alpha: 0.3),
          inactiveThumbColor: colors.textMuted,
          inactiveTrackColor: colors.surfaceSecondary,
          onChanged: (val) {
            onChanged(val);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Notification setting saved (Development Sandbox)',
                  style: TextStyle(fontFamily: 'Google Sans'),
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF222226),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWipFooter(AppThemeData colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: colors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Remote Firebase FCM and APNs push service connections will be activated in the upcoming production sprint.',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
