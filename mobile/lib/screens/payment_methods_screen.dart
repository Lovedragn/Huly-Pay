import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedDefaultApp = 'google_pay';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() => _isLoading = true);
    final defaultApp = await UserPreferencesService().getDefaultPaymentApp();

    if (mounted) {
      setState(() {
        _selectedDefaultApp = defaultApp;
        _isLoading = false;
      });
    }
  }

  Future<void> _setDefaultApp(String appId) async {
    setState(() => _selectedDefaultApp = appId);
    await UserPreferencesService().setDefaultPaymentApp(appId);
    if (!mounted) return;

    final appName = appId == 'google_pay' ? 'Google Pay' : 'Amazon Pay';
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$appName set as default payment application',
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
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.accent,
                      ),
                    )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(colors, 'Preferred Payment Applications'),
                            const SizedBox(height: 12),
                            _buildPaymentAppCard(
                              colors: colors,
                              appId: 'google_pay',
                              appName: 'Google Pay',
                              isDefault: _selectedDefaultApp == 'google_pay',
                              iconWidget: _buildGPayBrandIcon(),
                            ),
                            const SizedBox(height: 12),
                            _buildPaymentAppCard(
                              colors: colors,
                              appId: 'amazon_pay',
                              appName: 'Amazon Pay',
                              isDefault: _selectedDefaultApp == 'amazon_pay',
                              iconWidget: _buildAmazonPayBrandIcon(),
                            ),
                            const SizedBox(height: 24),
                            _buildPermissionsDisclosureCard(colors),
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
            child: Text(
              'Payment Methods',
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

  Widget _buildSectionTitle(AppThemeData colors, String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Google Sans',
        color: colors.textPrimary,
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildPaymentAppCard({
    required AppThemeData colors,
    required String appId,
    required String appName,
    required bool isDefault,
    required Widget iconWidget,
  }) {
    return Container(
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
          onTap: () => _setDefaultApp(appId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: colors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(child: iconWidget),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    appName,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (isDefault)
                  Icon(
                    Icons.check_circle_rounded,
                    color: colors.textPrimary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGPayBrandIcon() {
    return SvgPicture.asset(
      'asserts/icon/google-pay-icon.svg',
      width: 26,
      height: 26,
    );
  }

  Widget _buildAmazonPayBrandIcon() {
    return SvgPicture.asset(
      'asserts/icon/amazon-icon.svg',
      width: 26,
      height: 26,
    );
  }

  Widget _buildPermissionsDisclosureCard(AppThemeData colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.security_update_good_rounded,
              color: colors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Package Visibility & Opening Permissions',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Package visibility queries are granted for Google Pay (com.google.android.apps.nbu.paisa.user) and Amazon Shopping/Pay (in.amazon.mShop.android.shopping). UPI intent queries permit HulyPay to handoff QR payment payloads seamlessly.',
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
}
