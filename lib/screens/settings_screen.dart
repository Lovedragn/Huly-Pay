import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'scan_and_pay_screen.dart';
import 'sign_in_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String appVersion;

  const SettingsScreen({
    super.key,
    this.userName = 'Sujit Saha',
    this.userEmail = 'sujit@example.com',
    this.appVersion = 'v1.0.0',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTheme = 'OLED Black';
  late String _displayName;
  late String _displayEmail;

  @override
  void initState() {
    super.initState();
    _displayName = widget.userName;
    _displayEmail = widget.userEmail;
    _resolveUser();
  }

  Future<void> _resolveUser() async {
    // 1. Try local SQLite profile cache
    try {
      final cachedProfile = await UserRepository().getCachedUserProfile();
      if (cachedProfile != null && mounted) {
        setState(() {
          _displayName = cachedProfile.displayName;
          if (cachedProfile.email.isNotEmpty) {
            _displayEmail = cachedProfile.email;
          }
        });
      }
    } catch (_) {}

    // 2. Then check authUser session
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      final name = authUser.userMetadata?['full_name'] ?? authUser.userMetadata?['name'];
      if (mounted) {
        setState(() {
          if (name != null && name.toString().isNotEmpty) {
            _displayName = name.toString();
          }
          if (authUser.email != null && authUser.email!.isNotEmpty) {
            _displayEmail = authUser.email!;
          }
        });
      }
    }
  }

  String get _initials {
    final parts = _displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'SS';
  }

  final List<Map<String, dynamic>> _themeOptions = const [
    {
      'name': 'OLED Black',
      'description': 'Pure black for AMOLED displays',
      'previewColor': Color(0xFF000000),
      'accentColor': Color(0xFF007AFF),
    },
    {
      'name': 'Midnight Dark',
      'description': 'Deep navy and titanium tones',
      'previewColor': Color(0xFF0D1117),
      'accentColor': Color(0xFF58A6FF),
    },
    {
      'name': 'Cyber Purple',
      'description': 'Neon violet highlights',
      'previewColor': Color(0xFF140D20),
      'accentColor': Color(0xFFAF52DE),
    },
    {
      'name': 'Emerald Slate',
      'description': 'Mint and emerald accents',
      'previewColor': Color(0xFF0C1914),
      'accentColor': Color(0xFF00C076),
    },
  ];

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

  void _showThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Themes & Skins',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93)),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final theme in _themeOptions) ...[
                    Material(
                      color: _selectedTheme == theme['name']
                          ? const Color(0xFF1E1E24)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            _selectedTheme = theme['name'] as String;
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _selectedTheme == theme['name']
                                  ? const Color(0xFF383842)
                                  : const Color(0xFF222226),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme['previewColor'] as Color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme['accentColor'] as Color,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      theme['name'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Google Sans',
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      theme['description'] as String,
                                      style: const TextStyle(
                                        fontFamily: 'Google Sans',
                                        color: Color(0xFF8E8E93),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_selectedTheme == theme['name'])
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF30D158),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of Huly Pay?',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF8E8E93),
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
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
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
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
                isQrActive: false,
                onItemSelected: (index) {
                  _handleBack(index);
                },
                onQrScanTap: _openScanAndPay,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _handleBack(),
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Profile & Settings',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32), // balancing arrow width
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
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
            child: Center(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _displayEmail,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF6B6B70),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.person_outline_rounded,
        title: 'Personal Information',
        onTap: () {},
      ),
      const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.credit_card_rounded,
        title: 'Payment Methods',
        onTap: () {},
      ),
    ]);
  }

  Widget _buildPreferencesSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.notifications_none_rounded,
        title: 'Notifications',
        onTap: () {},
      ),
      const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.palette_outlined,
        title: 'Themes & Skins',
        trailingText: _selectedTheme,
        onTap: _showThemeSelector,
      ),
    ]);
  }

  Widget _buildSupportSection() {
    return _buildGroupCard([
      _buildSettingRow(
        icon: Icons.shield_outlined,
        title: 'Privacy & Security',
        onTap: () {},
      ),
      const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.help_outline_rounded,
        title: 'Help & Support',
        onTap: () {},
      ),
      const Divider(color: Color(0xFF202024), height: 1, thickness: 1, indent: 52),
      _buildSettingRow(
        icon: Icons.info_outline_rounded,
        title: 'About Hulypay',
        trailingText: widget.appVersion,
        onTap: () {},
      ),
    ]);
  }

  Widget _buildLogoutCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _showLogoutDialog,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFFF453A),
                  size: 22,
                ),
                SizedBox(width: 14),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFFFF453A),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6B6B70),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF141416),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF222226),
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
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF6B6B70),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
