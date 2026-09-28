import 'package:flutter/material.dart';
import '../data/external_data.dart';
import '../theme/app_theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Privacy Policy
                    _buildSectionHeader(
                      title: 'Privacy Policy',
                      icon: Icons.policy_outlined,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ExternalData.privacyPolicyFull.trim(),
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: colors.divider, height: 1),
                    const SizedBox(height: 24),

                    // Terms of Service
                    _buildSectionHeader(
                      title: 'Terms of Service',
                      icon: Icons.gavel_rounded,
                      colors: colors,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ExternalData.termsOfServiceFull.trim(),
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
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
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: colors.textPrimary, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Back',
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              ExternalData.privacySecurityTitle,
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

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required AppThemeData colors,
  }) {
    return Row(
      children: [
        Icon(icon, color: colors.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
