import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/upi_payment_service.dart';
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
  final Map<String, bool> _installedStatus = {};

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    setState(() => _isLoading = true);
    final defaultApp = await UserPreferencesService().getDefaultPaymentApp();

    // Check installed status for all target apps
    for (final app in UpiApps.allApps) {
      final isInstalled = await UpiPaymentService.isPackageInstalled(app.packageName);
      _installedStatus[app.packageName] = isInstalled;
    }

    if (mounted) {
      setState(() {
        _selectedDefaultApp = defaultApp;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchExternalApp(SupportedUpiApp app) async {
    final isInstalled = _installedStatus[app.packageName] ?? false;
    if (!isInstalled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${app.name} is not installed on this device'),
          backgroundColor: const Color(0xFFD93025),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await UpiPaymentService.openApp(app.packageName);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${app.name}'),
          backgroundColor: const Color(0xFFD93025),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _setDefaultApp(String appId) async {
    setState(() => _selectedDefaultApp = appId);
    await UserPreferencesService().setDefaultPaymentApp(appId);
    if (!mounted) return;

    final String appName;
    switch (appId) {
      case 'google_pay':
        appName = 'Google Pay';
        break;
      case 'amazon_pay':
        appName = 'Amazon Pay';
        break;
      case 'phonepe':
        appName = 'PhonePe';
        break;
      case 'paytm':
        appName = 'Paytm';
        break;
      case 'bhim':
        appName = 'BHIM UPI';
        break;
      case 'whatsapp':
        appName = 'WhatsApp';
        break;
      default:
        appName = 'Ask every time (Android Chooser)';
    }
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
                          _buildSectionTitle(colors, 'Payment Applications'),
                          const SizedBox(height: 6),
                          Text(
                            'Select which installed payment application Huly Pay uses by default, or launch them directly.',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Always show "Ask every time" option
                          _buildPaymentAppCard(
                            colors: colors,
                            appId: 'ask_every_time',
                            appName: 'Ask every time (Android Chooser)',
                            subtitle: 'Show system chooser dialog on payment',
                            isDefault: _selectedDefaultApp == 'ask_every_time',
                            iconWidget: Icon(
                              Icons.alt_route_rounded,
                              color: colors.textPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Dynamically build installed apps
                          ..._buildInstalledAppsList(colors),

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

  List<Widget> _buildInstalledAppsList(AppThemeData colors) {
    // Filter only apps that are installed on this device
    final installedApps = UpiApps.allApps.where((app) {
      return _installedStatus[app.packageName] == true;
    }).toList();

    if (installedApps.isEmpty) {
      return [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: colors.textSecondary,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'No standard UPI apps installed',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Install Google Pay, PhonePe, Paytm, or Amazon Pay to select them as your default payment app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ];
    }

    return installedApps.map((app) {
      final isDefault = _selectedDefaultApp == app.id;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDefault ? colors.textPrimary : colors.border,
            width: isDefault ? 1.5 : 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _setDefaultApp(app.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                    child: Center(
                      child: app.iconPath.isNotEmpty
                          ? SvgPicture.asset(
                              app.iconPath,
                              width: 24,
                              height: 24,
                            )
                          : Icon(
                              app.id == 'paytm'
                                  ? Icons.account_balance_wallet_rounded
                                  : (app.id == 'whatsapp' ? Icons.chat_rounded : Icons.payment_rounded),
                              color: app.id == 'paytm'
                                  ? const Color(0xFF00BAF2)
                                  : (app.id == 'whatsapp' ? const Color(0xFF25D366) : colors.textPrimary),
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              app.name,
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: colors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.textPrimary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    color: colors.textPrimary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF34A853),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Installed',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: const Color(0xFF34A853),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Button to directly launch external standalone app
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _launchExternalApp(app),
                    child: Text(
                      'Open',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        color: colors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Radio / check selection for default
                  Icon(
                    isDefault ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isDefault ? colors.textPrimary : colors.textSecondary.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
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
    String? subtitle,
    required bool isDefault,
    required Widget iconWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? colors.textPrimary : colors.border,
          width: isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _setDefaultApp(appId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              appName,
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: colors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colors.textPrimary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: colors.textPrimary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isDefault ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: isDefault ? colors.textPrimary : colors.textSecondary.withValues(alpha: 0.5),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



