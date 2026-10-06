import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../data/external_data.dart';
import '../services/location_service.dart';
import '../services/qr_share_service.dart';
import '../services/scan_payment_service.dart';
import '../services/upi_payment_service.dart';
import '../services/upi_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/card_dialog.dart';
import '../widgets/payment_details_page.dart';
import '../widgets/payment_dialogs.dart';
import '../widgets/scanner_circle_button.dart';
import '../widgets/scanner_overlay_painter.dart';
import '../widgets/sms_verification_dialog.dart';
import 'payment_methods_screen.dart';
import 'upload_qr_screen.dart';

class ScanAndPayScreen extends StatefulWidget {
  final double? initialAmount;
  final String? initialNote;

  const ScanAndPayScreen({super.key, this.initialAmount, this.initialNote});

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
  static const Duration _paymentVerificationTimeout = Duration(minutes: 5);
  static const double _scanBoxSize = 260.0;

  late final MobileScannerController _scannerController;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isProcessing = false;
  DateTime? _lastInvalidQrToastTime;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _handleBack([int? targetIndex]) {
    if (Navigator.canPop(context)) Navigator.pop(context, targetIndex);
  }

  Future<void> _pauseScanner() async {
    try {
      await _scannerController.pause();
    } catch (_) {}
  }

  Future<void> _resumeScanner() async {
    if (!mounted) return;
    try {
      await _scannerController.start();
    } catch (_) {}
  }

  void _showSnack(
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    Widget? leading,
    CardNotificationType type = CardNotificationType.info,
  }) {
    if (!mounted) return;
    showCardNotification(
      context,
      message: message,
      leading: leading,
      type: type,
      duration: duration,
    );
  }

  // ---------------------------------------------------------------------------
  // Camera controls
  // ---------------------------------------------------------------------------

  Future<void> _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
    } catch (_) {}
    if (mounted) setState(() => _isFlashOn = !_isFlashOn);
  }

  Future<void> _toggleCamera() async {
    try {
      await _scannerController.switchCamera();
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isFrontCamera = !_isFrontCamera);
    _showSnack(
      _isFrontCamera
          ? ExternalData.switchedToFrontCamera
          : ExternalData.switchedToRearCamera,
    );
  }

  Future<void> _openUploadFromScanner() async {
    await _pauseScanner();
    if (!mounted) return;
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const UploadQrScreen()));
    await _resumeScanner();
  }

  // ---------------------------------------------------------------------------
  // Detection
  // ---------------------------------------------------------------------------

  Future<void> _handleBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) return;

    final upiData = UpiService.parseUpiUri(rawValue);
    if (upiData == null) {
      if (!rawValue.toLowerCase().startsWith('upi:')) {
        _handleInvalidBarcodeDetected();
      }
      return;
    }

    setState(() => _isProcessing = true);
    await _pauseScanner();
    try {
      await _runPaymentFlow(upiData);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        await _resumeScanner();
      }
    }
  }

  void _handleInvalidBarcodeDetected() {
    final now = DateTime.now();
    final last = _lastInvalidQrToastTime;
    if (last != null && now.difference(last) < const Duration(seconds: 3)) {
      return;
    }
    _lastInvalidQrToastTime = now;
    _showSnack(
      ExternalData.invalidQrMessage,
      type: CardNotificationType.error,
      duration: const Duration(seconds: 2),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment flow
  // ---------------------------------------------------------------------------

  Future<void> _runPaymentFlow(UpiPaymentData upiData) async {
    // Fetch location in the background while the user types the amount.
    PaymentLocation? location;
    unawaited(() async {
      try {
        location = (await LocationService().getPaymentLocationWithStatus())
            .location;
      } catch (_) {}
    }());

    final details = await PaymentDetailsPage.show(
      context,
      upiData: upiData,
      initialAmount: widget.initialAmount,
    );
    if (details == null || !mounted) return;

    // Primary flow: server generates a QR with am=<amount>, share it to the UPI app.
    if (await _payViaGeneratedQr(upiData, details)) return;

    // Fallback: launch the UPI app directly and verify via SMS.
    if (!mounted) return;
    final payData = UpiPaymentData(
      rawUri: upiData.rawUri,
      upiId: upiData.upiId,
      payeeName: upiData.payeeName,
      amount: details.amount,
      currency: upiData.currency,
      transactionRef: upiData.transactionRef,
      transactionId: upiData.transactionId,
      note: details.note ?? upiData.note,
      merchantCode: upiData.merchantCode,
    );
    await _startSmsVerificationWorkflow(payData, details.amount, location);
  }

  /// Returns true if the generated QR was shared successfully.
  Future<bool> _payViaGeneratedQr(
    UpiPaymentData upiData,
    PaymentDetailsResult details,
  ) async {
    final preferredAppId = await UserPreferencesService().getDefaultPaymentApp();
    final app = await ScanPaymentService.resolveShareTargetApp();
    final qrFile = await ScanPaymentService.generateAmountQr(
      rawUri: upiData.rawUri,
      amount: details.amount,
    );
    if (qrFile == null || !mounted) return false;

    final shared = await QrShareService.shareQrImage(
      context: context,
      filePath: qrFile.path,
      amount: details.amount,
      note: details.note,
      title: 'Pay with ${app.name}',
      targetPackage: (preferredAppId != UpiApps.askEveryTime) ? app.packageName : null,
    );
    if (!shared) return false;

    await ScanPaymentService.recordSharedQrPayment(
      upiData: upiData,
      amount: details.amount,
      app: app,
    );
    _showSnack('Opening ${app.name} with QR code...');
    if (mounted) _handleBack();
    return true;
  }

  Future<void> _startSmsVerificationWorkflow(
    UpiPaymentData upiData,
    double amount,
    PaymentLocation? location,
  ) async {
    if (!ScanPaymentService.isQuickConfirm &&
        !await ScanPaymentService.ensureSmsPermission()) {
      if (!mounted) return;
      final retry = await showSmsPermissionDialog(context);
      if (retry && await ScanPaymentService.ensureSmsPermission() && mounted) {
        await _startSmsVerificationWorkflow(upiData, amount, location);
      }
      return;
    }

    var forceAskEveryTime = false;
    final readiness = await ScanPaymentService.checkPreferredAppReadiness();
    if (!readiness.isReady) {
      if (!mounted) return;
      final action = await showAppNotInstalledDialog(
        context,
        readiness.app?.name ?? 'Preferred UPI App',
      );
      if (!mounted) return;
      if (action == MissingAppAction.changeDefault) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
        );
        return;
      }
      if (action != MissingAppAction.openAnyApp) return;
      forceAskEveryTime = true;
    }

    await _launchUpiAndStartVerification(
      upiData: upiData,
      amount: amount,
      location: location,
      forceAskEveryTime: forceAskEveryTime,
    );
  }

  Future<void> _launchUpiAndStartVerification({
    required UpiPaymentData upiData,
    required double amount,
    required PaymentLocation? location,
    bool forceAskEveryTime = false,
  }) async {
    final isQuickConfirm = ScanPaymentService.isQuickConfirm;
    final appId = forceAskEveryTime
        ? UpiApps.askEveryTime
        : await UserPreferencesService().getDefaultPaymentApp();

    final payment = await ScanPaymentService.createPendingPayment(
      upiData: upiData,
      amount: amount,
      appId: appId,
      location: location,
    );

    final launch = await ScanPaymentService.launchPaymentApp(
      appId,
      upiData: upiData,
      amount: amount,
    );
    if (!launch.launched) {
      _showSnack(
        launch.appName != null
            ? 'Could not open ${launch.appName}. Please ensure it is installed.'
            : 'Could not open payment application. Please ensure a payment app is installed.',
        type: CardNotificationType.error,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    if (!mounted) return;

    final bool goHome;
    if (isQuickConfirm) {
      await showQuickConfirmSuccessDialog(context, payment);
      goHome = true;
    } else {
      goHome = await SmsVerificationDialog.show(
        context,
        payment,
        timeout: _paymentVerificationTimeout,
      );
    }
    if (goHome && mounted) _handleBack(0);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final palette = _ScannerPalette.from(AppThemeManager.colors);
    final colors = AppThemeManager.colors;
    final padding = MediaQuery.paddingOf(context);
    final initialAmount = widget.initialAmount;

    return Scaffold(
      backgroundColor: palette.scaffold,
      body: LayoutBuilder(
        builder: (_, constraints) {
          final svgRect = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              constraints.maxHeight * 0.40,
            ),
            width: _scanBoxSize,
            height: _scanBoxSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live camera preview
              MobileScanner(
                controller: _scannerController,
                onDetect: _handleBarcodeDetected,
                errorBuilder: (_, _, _) => Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: palette.isDark
                        ? const Color(0xFF55555C)
                        : colors.textMuted,
                    size: 48,
                  ),
                ),
              ),

              // 2. Overlay with transparent cutout (inset so it sits inside the SVG frame)
              CustomPaint(
                size: constraints.biggest,
                painter: ScannerOverlayPainter(
                  cutoutRect: svgRect.deflate(5.0),
                  cornerRadius: 22.0,
                  overlayColor: palette.overlay,
                ),
              ),

              // 3. Reticle frame
              Positioned.fromRect(
                rect: svgRect,
                child: IgnorePointer(
                  child: SvgPicture.asset(
                    'assets/icon/Scanner.svg',
                    fit: BoxFit.fill,
                    colorFilter: ColorFilter.mode(
                      palette.scannerSvg,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              // 4. Top bar
              Positioned(
                top: padding.top + 10,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScannerCircleButton(
                      key: const Key('back_button'),
                      onTap: () => _handleBack(0),
                      background: palette.buttonBg,
                      borderColor: palette.buttonBorder,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: palette.buttonIcon,
                        size: 18,
                      ),
                    ),
                    if (ScanPaymentService.isQuickConfirm)
                      ScannerCircleButton(
                        key: const Key('quick_confirm_indicator'),
                        tooltip: ExternalData.quickConfirmActiveTitle,
                        onTap: () => _showSnack(
                          ExternalData.quickConfirmActiveTitle,
                          duration: const Duration(seconds: 2),
                          leading: const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFFFB300),
                            size: 18,
                          ),
                        ),
                        background: palette.buttonBg,
                        borderColor: palette.buttonBorder,
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFFFB300),
                          size: 22,
                        ),
                      ),
                  ],
                ),
              ),

              // 5. Amount badge & Back to Home
              Positioned(
                top: svgRect.bottom + 20,
                left: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (initialAmount != null && initialAmount > 0) ...[
                      _AmountBadge(
                        amount: initialAmount,
                        palette: palette,
                        labelColor: palette.isDark
                            ? const Color(0xFFD0D0D5)
                            : colors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                    ],
                    GestureDetector(
                      onTap: () => _handleBack(0),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: palette.buttonBg,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: palette.buttonBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Back to Home',
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: palette.isDark
                                ? Colors.white
                                : colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. Right-side camera controls
              Positioned(
                right: 34,
                bottom: padding.bottom + 36,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    ScannerCircleButton(
                      key: const Key('flash_button'),
                      onTap: _toggleFlash,
                      background: _isFlashOn ? colors.accent : palette.buttonBg,
                      borderColor:
                          _isFlashOn ? colors.accent : palette.buttonBorder,
                      child: Icon(
                        Icons.bolt_rounded,
                        color: _isFlashOn ? Colors.white : palette.buttonIcon,
                        size: 20,
                      ),
                    ),
                    ScannerCircleButton(
                      key: const Key('switch_camera_button'),
                      onTap: _toggleCamera,
                      background:
                          _isFrontCamera ? colors.accent : palette.buttonBg,
                      borderColor:
                          _isFrontCamera ? colors.accent : palette.buttonBorder,
                      child: SvgPicture.asset(
                        'assets/icon/switch.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          _isFrontCamera ? Colors.white : palette.buttonIcon,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    ScannerCircleButton(
                      key: const Key('upload_gallery_button'),
                      onTap: _openUploadFromScanner,
                      background: palette.buttonBg,
                      borderColor: palette.buttonBorder,
                      child: Icon(
                        Icons.photo_library_rounded,
                        color: palette.buttonIcon,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Theme-dependent colors for the scanner overlay.
class _ScannerPalette {
  final bool isDark;
  final Color scaffold;
  final Color overlay;
  final Color scannerSvg;
  final Color buttonBg;
  final Color buttonBorder;
  final Color buttonIcon;

  const _ScannerPalette({
    required this.isDark,
    required this.scaffold,
    required this.overlay,
    required this.scannerSvg,
    required this.buttonBg,
    required this.buttonBorder,
    required this.buttonIcon,
  });

  factory _ScannerPalette.from(AppThemeData colors) {
    final isDark = colors.isDark;
    final name = colors.name.toLowerCase();
    final isRedVelvet = name.contains('red') || name.contains('velvet');
    final isMilkWhite = name.contains('milk') || (!isDark && !isRedVelvet);

    if (isDark && !isRedVelvet) {
      return _ScannerPalette(
        isDark: true,
        scaffold: const Color(0xFF000000),
        overlay: const Color(0xC7000000), // OLED black ~78%
        scannerSvg: Colors.white,
        buttonBg: const Color(0xFF161619).withValues(alpha: 0.85),
        buttonBorder: const Color(0xFF24242A),
        buttonIcon: Colors.white,
      );
    }
    if (isRedVelvet) {
      return _ScannerPalette(
        isDark: isDark,
        scaffold: isDark
            ? const Color(0xFF000000)
            : const Color.fromARGB(255, 255, 14, 14),
        overlay: const Color.fromARGB(217, 255, 0, 0), // red velvet ~85%
        scannerSvg: Colors.white,
        buttonBg: isDark
            ? const Color(0xFF161619).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.92),
        buttonBorder: isDark
            ? const Color(0xFF24242A)
            : Colors.white.withValues(alpha: 0.4),
        buttonIcon:
            isDark ? Colors.white : const Color.fromARGB(255, 255, 0, 0),
      );
    }
    return _ScannerPalette(
      isDark: false,
      scaffold: colors.background,
      overlay: isMilkWhite ? const Color(0xE6FFFFFF) : const Color(0xC7000000),
      scannerSvg: isMilkWhite ? const Color(0xFF007AFF) : Colors.white,
      buttonBg: Colors.white.withValues(alpha: 0.92),
      buttonBorder: colors.border,
      buttonIcon: colors.textPrimary,
    );
  }
}

class _AmountBadge extends StatelessWidget {
  final double amount;
  final _ScannerPalette palette;
  final Color labelColor;

  const _AmountBadge({
    required this.amount,
    required this.palette,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: palette.buttonBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF30D158).withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Paying:',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Color(0xFF30D158),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
