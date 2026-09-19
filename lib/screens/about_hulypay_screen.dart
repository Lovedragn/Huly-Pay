import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class AboutHulyPayScreen extends StatelessWidget {
  final String appVersion;

  const AboutHulyPayScreen({
    super.key,
    this.appVersion = 'v1.0.0 (Build 2026.09.1)',
  });

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
        child: Column(
          children: [
            _buildAppBar(context, colors),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    _buildHeroBrandCard(colors),
                    const SizedBox(height: 20),
                    _buildEnvironmentNoticeCard(colors),
                    const SizedBox(height: 20),
                    _buildFeatureHighlights(colors),
                    const SizedBox(height: 20),
                    _buildCreatorSection(context, colors),
                    const SizedBox(height: 20),
                    _buildSpecsCard(colors),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppThemeData colors) {
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
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'About HulyPay',
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
        border: Border.all(color: colors.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceSecondary.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.35),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.accent.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                'asserts/logo/Logo-Dark.png',
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.account_balance_wallet_rounded,
                  color: colors.accent,
                  size: 38,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'HulyPay',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              appVersion,
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Next-generation intelligent fintech application crafted for frictionless transactions, analytical intelligence, and secure offline-first financial ledger logging.',
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

  Widget _buildEnvironmentNoticeCard(AppThemeData colors) {
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
              Icons.science_outlined,
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
                  'Test & Development Release',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFFFF9500),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This version of HulyPay is an active preview and development environment build. All payment gateways, scanner decoders, heatmaps, and simulated transfers are intended for testing, demonstration, and architectural prototyping.',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textSecondary,
                    fontSize: 13,
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

  Widget _buildFeatureHighlights(AppThemeData colors) {
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
          Text(
            'Core Highlights',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            colors,
            Icons.qr_code_scanner_rounded,
            'Scan & Pay Scanner',
            'Ultra-fast QR decoding with simulated camera testing and flashlight assistance.',
          ),
          Divider(color: colors.divider, height: 24),
          _buildFeatureItem(
            colors,
            Icons.insights_rounded,
            'Spending Insights & Heatmap',
            'Multi-theme visual analytics with category donut charts and temporal activity matrices.',
          ),
          Divider(color: colors.divider, height: 24),
          _buildFeatureItem(
            colors,
            Icons.sync_rounded,
            'Offline-First Local Sync',
            'Robust SQLite offline transaction storage backed by cloud sync engines.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    AppThemeData colors,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colors.accent, size: 20),
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
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
            'HulyPay is designed and developed with precision by Sujith Sappani. Learn more about the developer and explore other engineering projects below:',
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
            onTap: () => _launchUrl(context, 'https://sujithsappani.vercel.app'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.language_rounded, color: colors.accent, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sujith Sappani',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'sujithsappani.vercel.app',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.accent,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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
          _buildSpecRow(colors, 'Framework', 'Flutter & Dart'),
          Divider(color: colors.divider, height: 20),
          _buildSpecRow(colors, 'Database Engine', 'SQLite (Local) & Supabase'),
          Divider(color: colors.divider, height: 20),
          _buildSpecRow(colors, 'Design System', 'Huly Premium UI / Material 3'),
          Divider(color: colors.divider, height: 20),
          _buildSpecRow(colors, 'Environment', 'Staging / Development Build'),
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
