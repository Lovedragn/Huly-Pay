import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/external_data.dart';
import '../services/app_update_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_update_dialog.dart';

class AboutHulyPayScreen extends StatefulWidget {
  final String appVersion;

  const AboutHulyPayScreen({
    super.key,
    this.appVersion = ExternalData.defaultAppVersion,
  });

  @override
  State<AboutHulyPayScreen> createState() => _AboutHulyPayScreenState();
}

class _AboutHulyPayScreenState extends State<AboutHulyPayScreen> {
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates(silentIfLatest: true);
    });
  }

  Future<void> _checkForUpdates({bool silentIfLatest = false}) async {
    if (_isCheckingUpdate) return;
    setState(() {
      _isCheckingUpdate = true;
    });

    if (!silentIfLatest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checking for updates...', style: TextStyle(fontFamily: 'Google Sans')),
          duration: Duration(seconds: 1),
        ),
      );
    }

    try {
      final updateInfo = await AppUpdateService().checkAppVersion();
      if (!mounted) return;

      if (updateInfo != null) {
        if (updateInfo.updateAvailable) {
          AppUpdateDialog.show(context, updateInfo);
        } else if (!silentIfLatest) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You are using the latest version (${updateInfo.currentVersion}).',
                style: const TextStyle(fontFamily: 'Google Sans'),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else if (!silentIfLatest) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not check for updates. Please try again later.',
              style: TextStyle(fontFamily: 'Google Sans'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!silentIfLatest && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not check for updates. Please try again later.',
              style: TextStyle(fontFamily: 'Google Sans'),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $urlString'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 68, bottom: 40),
                child: Column(
                  children: [
                    _buildHeroBrandCard(colors),
                    const SizedBox(height: 20),
                    _buildCreatorSection(context, colors),
                    const SizedBox(height: 20),
                    _buildSpecsCard(colors),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(context, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppThemeData colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: colors.topBarGradient,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'About',
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
      ),
    );
  }

  Widget _buildHeroBrandCard(AppThemeData colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            colors.isDark
                ? 'assets/logo/Logo-Dark.svg'
                : 'assets/logo/logo-Light.svg',
            width: 56,
            height: 56,
          ),
          const SizedBox(height: 16),
          Text(
            ExternalData.appName,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _checkForUpdates(silentIfLatest: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCheckingUpdate) ...[
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: colors.accent,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.appVersion,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            ExternalData.appDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorSection(BuildContext context, AppThemeData colors) {
    return Container(
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
          Row(
            children: [
              Icon(Icons.code_rounded, color: colors.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'Creator & Developer',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ExternalData.creatorBio,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _launchUrl(context, ExternalData.creatorWebsiteUrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ExternalData.creatorWebsiteDisplay,
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.accent,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: colors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsCard(AppThemeData colors) {
    final specs = [
      const TechSpecItem(label: 'Application', value: ExternalData.appName),
      TechSpecItem(label: 'Version', value: widget.appVersion),
      const TechSpecItem(label: 'Category', value: 'Personal Finance & Analytics'),
      const TechSpecItem(label: 'Platform', value: 'Android & iOS'),
      const TechSpecItem(label: 'Data Protection', value: 'Encrypted Device Storage'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < specs.length; i++) ...[
            if (i > 0) Divider(color: colors.divider, height: 20),
            _buildSpecRow(colors, specs[i].label, specs[i].value),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecRow(AppThemeData colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
