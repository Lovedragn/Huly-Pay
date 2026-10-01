import 'dart:async';
import 'package:flutter/material.dart';
import '../data/external_data.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/customization_bottom_sheet.dart';
import 'sign_in_screen.dart';
import 'about_hulypay_screen.dart';
import 'help_support_screen.dart';
import 'privacy_security_screen.dart';
import 'notifications_screen.dart';
import 'payment_methods_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String appVersion;

  const SettingsScreen({
    super.key,
    this.userName,
    this.userEmail,
    this.appVersion = ExternalData.defaultAppVersion,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _displayName;
  late String _displayEmail;
  String _avatarUrl = '';
  bool _quickConfirm = false;
  bool _quickScan = false;
  bool _pushNotifications = true;
  bool _dailyBudgetWarnings = false;

  @override
  void initState() {
    super.initState();
    final authProfile = AuthService().currentUserProfile;
    _displayName = widget.userName ?? authProfile?.displayName ?? 'User';
    _displayEmail = widget.userEmail ?? authProfile?.email ?? '';
    _avatarUrl = authProfile?.avatarUrl ?? '';
    _quickConfirm = UserPreferencesService().cachedQuickConfirm;
    _quickScan = UserPreferencesService().cachedQuickScan;
    _resolveUser();
  }

  Future<void> _resolveUser() async {
    // 1. Try local SQLite profile cache first
    try {
      final cachedProfile = await UserRepository().getCachedUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _displayName = cachedProfile.displayName;
          if (cachedProfile.email.isNotEmpty) {
            _displayEmail = cachedProfile.email;
          }
          if (cachedProfile.avatarUrl != null && cachedProfile.avatarUrl!.isNotEmpty) {
            _avatarUrl = cachedProfile.avatarUrl!;
          }
        });
      }
    } catch (_) {}

    // 2. Check active auth user session
    final authProfile = AuthService().currentUserProfile;
    if (authProfile != null && mounted) {
      setState(() {
        if (authProfile.displayName.isNotEmpty) {
          _displayName = authProfile.displayName;
        }
        if (authProfile.email.isNotEmpty) {
          _displayEmail = authProfile.email;
        }
        if (authProfile.avatarUrl != null && authProfile.avatarUrl!.isNotEmpty) {
          _avatarUrl = authProfile.avatarUrl!;
        }
      });
    }

    // 3. Fetch fresh user profile from backend & sync SQLite cache
    try {
      final remote = await UserRepository().getUserProfile(forceRefresh: true);
      if (remote != null && mounted) {
        setState(() {
          _displayName = remote.displayName;
          if (remote.email.isNotEmpty) {
            _displayEmail = remote.email;
          }
          if (remote.avatarUrl != null && remote.avatarUrl!.isNotEmpty) {
            _avatarUrl = remote.avatarUrl!;
          }
        });
      }
    } catch (_) {}
  }

  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'HP';
  }

  void _handleBack([int? targetIndex]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, targetIndex);
    }
  }

  /// Customization modal presenting both App Themes and Chart Colors presets
  void _showCustomizationModal() {
    CustomizationBottomSheet.show(
      context,
      onThemeChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  void _showLogoutDialog() {
    final colors = AppThemeManager.colors;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to log out of Huly Pay?',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await AuthService().signOut();
                try {
                  await LocalDatabaseService().clearAll();
                } catch (_) {}
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Logged out successfully',
                      style: TextStyle(fontFamily: 'Google Sans'),
                    ),
                    backgroundColor: const Color(0xFF222226),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const SignInScreen(),
                    transitionsBuilder: (_, animation, _, child) =>
                        FadeTransition(opacity: animation, child: child),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFFFF453A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Settings Layout with Sticky Top Bar
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    color: colors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: _buildTopBar(),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 4,
                        bottom: 110, // padding for bottom nav
                      ),
                      child: Column(
                        children: [
                          _buildProfileCard(),
                          const SizedBox(height: 16),
                          _buildAccountSection(),
                          const SizedBox(height: 16),
                          _buildPreferencesSection(),
                          const SizedBox(height: 16),
                          _buildNotificationsSection(),
                          const SizedBox(height: 16),
                          _buildSupportSection(),
                          const SizedBox(height: 16),
                          _buildLogoutCard(),
                          const SizedBox(height: 24),
                          _buildAppInfoFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                selectedIndex: -1,
                onItemSelected: (index) {
                  _handleBack(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final colors = AppThemeManager.colors;
    return Row(
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
            onPressed: () => _handleBack(),
            tooltip: 'Back',
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            'Profile & Settings',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00C076),
            ),
            child: ClipOval(
              child: _avatarUrl.isNotEmpty && _avatarUrl.startsWith('http')
                  ? Image.network(
                      _avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            fontFamily: 'Google Sans',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        _initials,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayEmail,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.credit_card_rounded,
        iconColor: const Color(0xFF0A84FF),
        title: 'Payment Methods',
        trailingText: () {
          final pref = UserPreferencesService().cachedDefaultPaymentApp;
          switch (pref) {
            case 'google_pay':
              return 'Google Pay';
            case 'amazon_pay':
              return 'Amazon Pay';
            case 'phonepe':
              return 'PhonePe';
            case 'bhim':
              return 'BHIM';
            default:
              return 'Ask every time';
          }
        }(),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PaymentMethodsScreen(),
            ),
          );
          if (mounted) setState(() {});
        },
      ),
    ]);
  }

  Widget _buildPreferencesSection() {
    return _buildGroupCard([
      _buildSwitchSettingRow(
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFFFB300),
        title: 'Quick Confirm',
        subtitle: 'Bypass SMS check & auto-confirm QR payments',
        value: _quickConfirm,
        onChanged: (bool value) async {
          setState(() {
            _quickConfirm = value;
          });
          await UserPreferencesService().setQuickConfirm(value);
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      _buildSwitchSettingRow(
        icon: Icons.qr_code_scanner_rounded,
        iconColor: const Color(0xFF00C076),
        title: 'Quick Scan',
        subtitle: 'Automatically open scanner when launching the app',
        value: _quickScan,
        onChanged: (bool value) async {
          setState(() {
            _quickScan = value;
          });
          await UserPreferencesService().setQuickScan(value);
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      // Customization option with unified theme
      _buildSettingRow(
        icon: Icons.palette_outlined,
        iconColor: const Color(0xFFAF52DE),
        title: 'Theme & Style',
        trailingText: AppThemeManager.theme,
        onTap: _showCustomizationModal,
      ),
    ]);
  }

  Widget _buildNotificationsSection() {
    return _buildGroupCard([
      _buildSwitchSettingRow(
        icon: Icons.notifications_active_rounded,
        iconColor: const Color(0xFF0A84FF),
        title: 'Push Notifications',
        subtitle: 'Enable system alerts for payments and receipts',
        value: _pushNotifications,
        onChanged: (bool value) {
          setState(() {
            _pushNotifications = value;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'Push notifications enabled'
                    : 'Push notifications disabled',
                style: const TextStyle(fontFamily: 'Google Sans'),
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
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      _buildSwitchSettingRow(
        icon: Icons.track_changes_rounded,
        iconColor: const Color(0xFFFF9500),
        title: 'Daily Budget Warnings',
        subtitle: 'Alert when approaching 90% of daily limit',
        value: _dailyBudgetWarnings,
        onChanged: (bool value) {
          setState(() {
            _dailyBudgetWarnings = value;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                value
                    ? 'Daily budget warnings enabled'
                    : 'Daily budget warnings disabled',
                style: const TextStyle(fontFamily: 'Google Sans'),
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
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      _buildSettingRow(
        icon: Icons.notifications_none_rounded,
        iconColor: const Color(0xFF5856D6),
        title: 'Notification Center',
        trailingText: 'In Dev',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.shield_outlined,
        iconColor: const Color(0xFF34C759),
        title: 'Privacy & Security',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PrivacySecurityScreen(),
            ),
          );
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      _buildSettingRow(
        icon: Icons.help_outline_rounded,
        iconColor: const Color(0xFFFF9500),
        title: 'Help & Support',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const HelpSupportScreen(),
            ),
          );
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 66),
      _buildSettingRow(
        icon: Icons.info_outline_rounded,
        iconColor: const Color(0xFF64D2FF),
        title: 'About Hulypay',
        trailingText: widget.appVersion,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AboutHulyPayScreen(
                appVersion: widget.appVersion,
              ),
            ),
          );
        },
      ),
    ]);
  }

  Widget _buildLogoutCard() {
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _showLogoutDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFFF453A),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFFFF453A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoFooter() {
    final colors = AppThemeManager.colors;

    return Column(
      children: [
        Text(
          '${ExternalData.appName} ${widget.appVersion}',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ExternalData.appTagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textMuted,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Crafted by ${ExternalData.creatorName}',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textMuted.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildGroupCard(List<Widget> children) {
    final colors = AppThemeManager.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? colors.textPrimary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor ?? colors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchSettingRow({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colors = AppThemeManager.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (iconColor ?? colors.accent).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor ?? colors.accent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: () {
                  final theme = AppThemeManager.theme;
                  if (theme == 'Red velvet') {
                    return const Color(0xFFEB0029); // Red
                  } else if (theme == 'Milk white') {
                    return const Color(0xFF007AFF); // Blue
                  } else {
                    return const Color(0xFF34C759); // Green (Oled black default)
                  }
                }(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
