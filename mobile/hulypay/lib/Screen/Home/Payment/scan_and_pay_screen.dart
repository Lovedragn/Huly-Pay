import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../Data/external_data.dart';
import '../../../Service/location_service.dart';
import '../../../Service/qr_share_service.dart';
import '../../../Service/scan_payment_service.dart';
import '../../../Service/upi_payment_service.dart';
import '../../../Service/upi_service.dart';
import '../../../Service/user_preferences_service.dart';
import '../../../Theme/app_theme.dart';
import '../../../Widget/dialog.dart';
import '../../../Widget/Transaction/payment_details_page.dart';
import '../../../Widget/Transaction/payment_dialogs.dart';
import '../../../Widget/Components/round_button.dart';
import '../../../Widget/sms_verification_dialog.dart';
import '../Settings/payment_methods_screen.dart';
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
    final palette = ScannerPalette.from(AppThemeManager.colors);
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
                    RoundButton.back(
                      key: const Key('back_button'),
                      onTap: () => _handleBack(0),
                      backgroundColor: palette.buttonBg,
                      borderColor: palette.buttonBorder,
                      iconColor: palette.buttonIcon,
                    ),
                    if (ScanPaymentService.isQuickConfirm)
                      RoundButton(
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
                        backgroundColor: palette.buttonBg,
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

              // 5. Amount badge
              if (initialAmount != null && initialAmount > 0)
                Positioned(
                  top: svgRect.bottom + 20,
                  left: 20,
                  right: 20,
                  child: Center(
                    child: _AmountBadge(
                      amount: initialAmount,
                      palette: palette,
                      labelColor: palette.isDark
                          ? const Color(0xFFD0D0D5)
                          : colors.textSecondary,
                    ),
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
                    RoundButton(
                      key: const Key('flash_button'),
                      onTap: _toggleFlash,
                      isActive: _isFlashOn,
                      backgroundColor: palette.buttonBg,
                      activeBackgroundColor: colors.accent,
                      borderColor:
                          _isFlashOn ? colors.accent : palette.buttonBorder,
                      iconColor: _isFlashOn ? Colors.white : palette.buttonIcon,
                      icon: Icons.bolt_rounded,
                      iconSize: 18,
                    ),
                    RoundButton(
                      key: const Key('switch_camera_button'),
                      onTap: _toggleCamera,
                      isActive: _isFrontCamera,
                      backgroundColor: palette.buttonBg,
                      activeBackgroundColor: colors.accent,
                      borderColor:
                          _isFrontCamera ? colors.accent : palette.buttonBorder,
                      iconColor:
                          _isFrontCamera ? Colors.white : palette.buttonIcon,
                      svgAsset: 'assets/icon/switch.svg',
                      iconSize: 18,
                    ),
                    RoundButton(
                      key: const Key('upload_gallery_button'),
                      onTap: _openUploadFromScanner,
                      backgroundColor: palette.buttonBg,
                      borderColor: palette.buttonBorder,
                      iconColor: palette.buttonIcon,
                      icon: Icons.photo_library_rounded,
                      iconSize: 18,
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
class ScannerPalette {
  final bool isDark;
  final Color scaffold;
  final Color overlay;
  final Color scannerSvg;
  final Color buttonBg;
  final Color buttonBorder;
  final Color buttonIcon;

  const ScannerPalette({
    required this.isDark,
    required this.scaffold,
    required this.overlay,
    required this.scannerSvg,
    required this.buttonBg,
    required this.buttonBorder,
    required this.buttonIcon,
  });

  factory ScannerPalette.from(AppThemeData colors) {
    final isDark = colors.isDark;
    final name = colors.name.toLowerCase();
    final isRedVelvet = name.contains('red') || name.contains('velvet');
    final isMilkWhite = name.contains('milk') || (!isDark && !isRedVelvet);

    if (isDark && !isRedVelvet) {
      return ScannerPalette(
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
      return ScannerPalette(
        isDark: isDark,
        scaffold: isDark
            ? const Color(0xFF000000)
            : colors.background,
        overlay: isDark
            ? const Color(0xC7000000)
            : const Color(0xE6FFFFFF), // White overlay ~90%
        scannerSvg: colors.accent,
        buttonBg: isDark
            ? const Color(0xFF161619).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.92),
        buttonBorder: isDark
            ? const Color(0xFF24242A)
            : colors.border,
        buttonIcon:
            isDark ? Colors.white : colors.textPrimary,
      );
    }
    return ScannerPalette(
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
  final ScannerPalette palette;
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

/// Paints a translucent overlay over the camera with a rounded-rect cutout.
class ScannerOverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  final double cornerRadius;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.cutoutRect,
    this.cornerRadius = 20.0,
    this.overlayColor = const Color(0xC7000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(cutoutRect, Radius.circular(cornerRadius)),
        ),
    );

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = overlayColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.cutoutRect != cutoutRect ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.overlayColor != overlayColor;
}
