import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/upi_payment_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

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
        child: Stack(
          children: [
            Positioned.fill(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.accent,
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 68, bottom: 40),
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
                          const SizedBox(height: 18),

                          // Dynamically build installed apps & ask_every_time in Grid / App View
                          _buildInstalledAppsGrid(colors),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstalledAppsGrid(AppThemeData colors) {
    // Filter only apps that are installed on this device
    final installedApps = UpiApps.allApps.where((app) {
      return _installedStatus[app.packageName] == true;
    }).toList();

    if (installedApps.isEmpty) {
      return Container(
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
      );
    }

    final isAskEveryTimeDefault = _selectedDefaultApp == 'ask_every_time';

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // "Ask every time" option as compact icon button
            Tooltip(
              message: 'Ask every time (Android Chooser)',
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _setDefaultApp('ask_every_time'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAskEveryTimeDefault ? colors.accent : colors.border,
                      width: isAskEveryTimeDefault ? 2.0 : 1.0,
                    ),
                    boxShadow: isAskEveryTimeDefault
                        ? [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.25),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.alt_route_rounded,
                      color: isAskEveryTimeDefault ? colors.accent : colors.textPrimary,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
            // Installed apps as compact icon buttons
            ...installedApps.map((app) {
              final isDefault = _selectedDefaultApp == app.id;

              return Tooltip(
                message: app.name,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _setDefaultApp(app.id),
                  onLongPress: () => _launchExternalApp(app),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 54,
                    height: 54,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDefault ? colors.accent : colors.border,
                        width: isDefault ? 2.0 : 1.0,
                      ),
                      boxShadow: isDefault
                          ? [
                              BoxShadow(
                                color: colors.accent.withValues(alpha: 0.25),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: app.iconPath.isNotEmpty
                          ? SvgPicture.asset(
                              app.iconPath,
                              width: 28,
                              height: 28,
                            )
                          : Icon(
                              app.id == 'paytm'
                                  ? Icons.account_balance_wallet_rounded
                                  : (app.id == 'whatsapp'
                                      ? Icons.chat_rounded
                                      : Icons.payment_rounded),
                              color: app.id == 'paytm'
                                  ? const Color(0xFF00BAF2)
                                  : (app.id == 'whatsapp'
                                      ? const Color(0xFF25D366)
                                      : colors.textPrimary),
                              size: 26,
                            ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(AppThemeData colors) {
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
}



