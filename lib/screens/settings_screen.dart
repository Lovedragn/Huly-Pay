import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../theme/chart_colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'scan_and_pay_screen.dart';
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
    this.appVersion = 'v1.0.0',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _displayName;
  late String _displayEmail;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    final authProfile = AuthService().currentUserProfile;
    _displayName = widget.userName ?? authProfile?.displayName ?? 'User';
    _displayEmail = widget.userEmail ?? authProfile?.email ?? '';
    _avatarUrl = authProfile?.avatarUrl ?? '';
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

  void _openScanAndPay() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScanAndPayScreen(),
      ),
    );
  }

  /// Transferred Customization modal presenting both App Themes and Chart Colors presets
  void _showCustomizationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppThemeManager.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colors = AppThemeManager.colors;
            final currentAppTheme = AppThemeManager.currentTheme.value;
            final currentChartPalette = AppThemeManager.currentChartPalette.value;

            // Transferred Theme presets from previous Themes & Skins section
            final List<Map<String, dynamic>> themePresets = const [
              {
                'id': 'Black',
                'name': 'OLED Black',
                'label': 'Black',
                'description': 'Pure black for AMOLED displays (Default)',
              },
              {
                'id': 'White',
                'name': 'Clean White',
                'label': 'White',
                'description': 'Crisp daytime light mode with high clarity',
              },
              {
                'id': 'Blue',
                'name': 'Midnight Dark',
                'label': 'Blue',
                'description': 'Deep navy and titanium tones (Blue aesthetic)',
              },
            ];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Sheet Drag Handle
                      Center(
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.textSecondary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Customization',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: colors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Themes & Chart Color Palettes',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: colors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: colors.surfaceSecondary,
                              shape: BoxShape.circle,
                              border: Border.all(color: colors.border),
                            ),
                            child: IconButton(
                              icon: Icon(Icons.close_rounded, color: colors.textPrimary, size: 18),
                              onPressed: () => Navigator.of(ctx).pop(),
                              tooltip: 'Close',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Section 1: App Theme Presets
                      Text(
                        'APP THEME',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      for (final theme in themePresets) ...[
                        _buildThemeOptionCard(
                          name: theme['name'] as String,
                          label: theme['label'] as String,
                          description: theme['description'] as String,
                          isSelected: currentAppTheme == theme['id'],
                          onTap: () {
                            final selectedTheme = theme['id'] as String;
                            AppThemeManager.setTheme(selectedTheme);
                            UserPreferencesService().savePreferences(
                              theme: selectedTheme,
                              chartPalette: AppThemeManager.chartPalette,
                            );
                            setState(() {});
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      const SizedBox(height: 16),
                      Divider(color: colors.divider, height: 1, thickness: 1),
                      const SizedBox(height: 16),

                      // Section 2: Chart Color & Skin Presets
                      Text(
                        'CHART COLORS',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: colors.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      for (final paletteName in kChartPaletteNames) ...[
                        _buildChartPaletteOptionCard(
                          name: paletteName,
                          isSelected: currentChartPalette == paletteName,
                          onTap: () {
                            AppThemeManager.setChartPalette(paletteName);
                            UserPreferencesService().savePreferences(
                              theme: AppThemeManager.theme,
                              chartPalette: paletteName,
                            );
                            setState(() {});
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOptionCard({
    required String name,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;

    return Material(
      color: isSelected ? colors.surfaceSecondary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: colors.border, width: 0.5),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.accent,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPaletteOptionCard({
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = AppThemeManager.colors;
    final swatches = AppChartColors.allPalettes[name] ?? AppChartColors.defaultPalette;
    final String description;

    switch (name) {
      case 'Emerald Mint':
      case 'Emerald Slate':
        description = 'Mint and emerald accents for growth and tracking';
        break;
      case 'Cyber Purple':
        description = 'Neon violet highlights and cyberpunk glow';
        break;
      case 'Sunset Gold':
        description = 'Warm amber, golden orange and coral radiant gradients';
        break;
      case 'Ocean Blue':
        description = 'Sky cyan, electric blue and sapphire marine curves';
        break;
      case 'Default':
      default:
        description = 'Electric Blue, vibrant Cyan, Mint, Amber & Rose (Default)';
        break;
    }

    return Material(
      color: isSelected ? colors.surfaceSecondary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Swatches row (5 dots)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 5 && i < swatches.length; i++)
                    Container(
                      margin: const EdgeInsets.only(right: 3),
                      width: 9,
                      height: 20,
                      decoration: BoxDecoration(
                        color: swatches[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.accent,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
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
            // Scrollable Settings Content
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 110, // padding for bottom nav
                ),
                child: Column(
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildProfileCard(),
                    const SizedBox(height: 16),
                    _buildAccountSection(),
                    const SizedBox(height: 16),
                    _buildPreferencesSection(),
                    const SizedBox(height: 16),
                    _buildSupportSection(),
                    const SizedBox(height: 16),
                    _buildLogoutCard(),
                    const SizedBox(height: 12),
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
        title: 'Payment Methods',
        trailingText: UserPreferencesService().cachedDefaultPaymentApp == 'amazon_pay'
            ? 'Amazon Pay'
            : 'Google Pay',
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
      _buildSettingRow(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        trailingText: 'In Dev',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(),
            ),
          );
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 52),
      // Customization option with both transferred Themes and Chart Colors presets
      _buildSettingRow(
        icon: Icons.tune_rounded,
        title: 'Customization',
        trailingText: '${AppThemeManager.theme} • ${AppThemeManager.chartPalette}',
        onTap: _showCustomizationModal,
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.shield_outlined,
        title: 'Privacy & Security',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PrivacySecurityScreen(),
            ),
          );
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const HelpSupportScreen(),
            ),
          );
        },
      ),
      Divider(color: AppThemeManager.colors.divider, height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.info_outline_rounded,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF453A),
                  size: 22,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: colors.textPrimary,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
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
}
