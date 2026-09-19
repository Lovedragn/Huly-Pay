import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/google_pay_service.dart';
import '../services/location_service.dart';
import '../services/sms_filter_service.dart';
import '../services/upi_payment_service.dart';
import '../services/upi_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import 'payment_methods_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class ScanAndPayScreen extends StatefulWidget {
  const ScanAndPayScreen({super.key});

  @override
  State<ScanAndPayScreen> createState() => _ScanAndPayScreenState();
}

class _ScanAndPayScreenState extends State<ScanAndPayScreen> {
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

  void _handleBack([int? targetIndex]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, targetIndex);
    }
  }

  void _toggleFlash() async {
    try {
      await _scannerController.toggleTorch();
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (_) {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  void _toggleCamera() async {
    try {
      await _scannerController.switchCamera();
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    } catch (_) {
      setState(() {
        _isFrontCamera = !_isFrontCamera;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFrontCamera ? 'Switched to Front Camera' : 'Switched to Rear Camera',
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1E1E24),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  void _handleBarcodeDetected(BarcodeCapture capture) {
    if (_isProcessing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final rawValue = barcode.rawValue!.trim();
    if (rawValue.isEmpty) return;

    final upiData = UpiService.parseUpiUri(rawValue);
    if (upiData != null) {
      _processPaymentFlow(upiData);
    } else {
      _handleInvalidBarcodeDetected();
    }
  }

  void _handleInvalidBarcodeDetected() {
    final now = DateTime.now();
    if (_lastInvalidQrToastTime != null &&
        now.difference(_lastInvalidQrToastTime!) < const Duration(seconds: 3)) {
      return;
    }
    _lastInvalidQrToastTime = now;

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'This is not a valid UPI payment QR.',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFFD93025),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _processPaymentFlow(UpiPaymentData upiData) async {
    setState(() {
      _isProcessing = true;
    });

    if (!mounted) return;

    // Immediately open payment confirmation modal (0ms latency, like Google Pay)
    await _showPaymentConfirmationModal(upiData);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _showPaymentConfirmationModal(
    UpiPaymentData upiData, [
    LocationResult? initialLocationResult,
  ]) async {
    final amountController = TextEditingController(
      text: upiData.amount != null ? upiData.amount!.toStringAsFixed(2) : '',
    );
    final noteController = TextEditingController(
      text: upiData.note ?? '',
    );
    final amountFocusNode = FocusNode();
    PaymentLocation? capturedLocation = initialLocationResult?.location;
    bool isLocationFetching = capturedLocation == null;

    // Immediately open keyboard for typing amount after page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (amountFocusNode.canRequestFocus) {
        amountFocusNode.requestFocus();
      }
    });

    final hasPayeeName = upiData.payeeName != null && upiData.payeeName!.trim().isNotEmpty;
    final primaryTitle = hasPayeeName ? upiData.payeeName!.trim() : upiData.upiId;
    final subtitle = hasPayeeName ? upiData.upiId : 'UPI Payee';

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (pageContext) {
          final colors = AppThemeManager.colors;

          // Concurrent background GPS resolution without blocking UI
          if (isLocationFetching) {
            isLocationFetching = false;
            LocationService().getPaymentLocationWithStatus().then((result) {
              if (pageContext.mounted) {
                capturedLocation = result.location;
              }
            });
          }

          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: colors.textPrimary, size: 20),
                  onPressed: () => Navigator.of(pageContext).pop(),
                  tooltip: 'Cancel',
                ),
              ),
              centerTitle: true,
              title: Text(
                'Payment Details',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: colors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                if (UserPreferencesService().cachedQuickConfirm)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      key: const Key('quick_confirm_appbar_indicator'),
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.surfaceSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.border, width: 0.5),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFFFB300),
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Centered Merchant Avatar
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: colors.surfaceSecondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border, width: 1.5),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              color: colors.accent,
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Centered Merchant Name
                        Text(
                          primaryTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Centered Subtitle & Copy Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: upiData.upiId));
                                ScaffoldMessenger.of(pageContext).showSnackBar(
                                  SnackBar(
                                    content: Text('UPI ID copied: ${upiData.upiId}'),
                                    duration: const Duration(milliseconds: 1500),
                                    backgroundColor: colors.surfaceSecondary,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: colors.surfaceSecondary,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: colors.border, width: 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.copy_rounded, size: 12, color: colors.accent),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copy',
                                      style: TextStyle(
                                        fontFamily: 'Google Sans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colors.accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Centered Amount Entry Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.border, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'PAYING AMOUNT',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: colors.accent,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹',
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      fontSize: 34,
                                      fontWeight: FontWeight.w700,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: TextField(
                                      controller: amountController,
                                      focusNode: amountFocusNode,
                                      autofocus: true,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Google Sans',
                                        color: colors.textPrimary,
                                        fontSize: 40,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        hintStyle: TextStyle(
                                          color: colors.textMuted.withValues(alpha: 0.35),
                                        ),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Centered Note / Message Field
                        TextField(
                          controller: noteController,
                          textInputAction: TextInputAction.done,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            color: colors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Add a note (optional)',
                            hintStyle: TextStyle(color: colors.textMuted, fontSize: 13),
                            prefixIcon: Icon(
                              Icons.edit_note_rounded,
                              color: colors.accent,
                              size: 22,
                            ),
                            filled: true,
                            fillColor: colors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: colors.accent, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),

                        // Quick Confirm banner if enabled
                        if (UserPreferencesService().cachedQuickConfirm) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFB300).withValues(alpha: 0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt_rounded, color: Color(0xFFFFB300), size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Quick Confirm active • Instant auto-confirmation',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFFB300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Button white based on theme color palette
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              side: colors.isDark ? BorderSide.none : BorderSide(color: colors.border, width: 1.5),
                              elevation: colors.isDark ? 2 : 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final parsedAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
                              if (parsedAmount <= 0) {
                                messenger.showSnackBar(
                                  const SnackBar(content: Text('Please enter a valid amount greater than 0')),
                                );
                                return;
                              }

                              final updatedNote = noteController.text.trim();
                              final updatedUpiData = UpiPaymentData(
                                rawUri: upiData.rawUri,
                                upiId: upiData.upiId,
                                payeeName: upiData.payeeName,
                                amount: parsedAmount,
                                currency: upiData.currency,
                                transactionRef: upiData.transactionRef,
                                transactionId: upiData.transactionId,
                                note: updatedNote.isNotEmpty ? updatedNote : upiData.note,
                                merchantCode: upiData.merchantCode,
                              );

                              Navigator.of(pageContext).pop();
                              await _startSmsVerificationWorkflow(updatedUpiData, parsedAmount, capturedLocation);
                            },
                            child: Text(
                              () {
                                final pref = UserPreferencesService().cachedDefaultPaymentApp;
                                final app = UpiApps.findById(pref);
                                final target = app?.name ?? 'UPI App';
                                return 'Pay via $target';
                              }(),
                              style: const TextStyle(
                                fontFamily: 'Google Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static const Duration paymentVerificationTimeout = Duration(minutes: 5);

  Future<void> _startSmsVerificationWorkflow(
    UpiPaymentData upiData,
    double parsedAmount,
    PaymentLocation? capturedLocation,
  ) async {
    final bool isQuickConfirm = UserPreferencesService().cachedQuickConfirm;

    // 1. Check & Request SMS Permission (Part 4) - Bypassed if Quick Confirm is active
    if (!isQuickConfirm) {
      bool hasPermission = await GooglePayService.isSmsPermissionGranted();
      if (!hasPermission) {
        hasPermission = await GooglePayService.requestSmsPermission();
      }

      if (!hasPermission) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E1E24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.sms_failed_rounded, color: Color(0xFFE5A93C), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'SMS Permission Required',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              content: const Text(
                'SMS permission is required to verify this development payment. Payment verification through SMS cannot proceed without it.',
                style: TextStyle(fontFamily: 'Google Sans', color: Color(0xFFD0D0D5), fontSize: 14, height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss', style: TextStyle(color: Color(0xFF8E8E93))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final retryGranted = await GooglePayService.requestSmsPermission();
                    if (retryGranted && mounted) {
                      _startSmsVerificationWorkflow(upiData, parsedAmount, capturedLocation);
                    }
                  },
                  child: const Text('Grant Permission', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
        }
        return;
      }
    }

    // 2. Determine Preferred UPI Application & Check Availability
    final preferredAppId = await UserPreferencesService().getDefaultPaymentApp();
    bool isAppReady = true;
    SupportedUpiApp? targetApp;

    if (preferredAppId != UpiApps.askEveryTime) {
      targetApp = UpiApps.findById(preferredAppId);
      if (targetApp != null) {
        isAppReady = await UpiPaymentService.isAppInstalled(targetApp.id);
      }
    } else {
      // For ask_every_time, check if at least one UPI app exists on Android
      final installed = await UpiPaymentService.getInstalledUpiPackages();
      if (installed.isEmpty) {
        // Fallback: Check if Google Pay or standard intent resolves
        isAppReady = await GooglePayService.isReadyToPay();
      }
    }

    if (!isAppReady) {
      if (mounted) {
        final missingAppName = targetApp?.name ?? 'Preferred UPI App';
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFE5A93C), size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$missingAppName Not Installed',
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              '$missingAppName is not installed on this device. Would you like to use the Android app chooser or select another UPI application?',
              style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFFD0D0D5), fontSize: 14, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  );
                },
                child: const Text('Change Default App', style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.w600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  // Open available payment app standalone
                  await _launchUpiAndStartVerification(
                    upiData: upiData,
                    parsedAmount: parsedAmount,
                    capturedLocation: capturedLocation,
                    forceAskEveryTime: true,
                  );
                },
                child: const Text('Open Any Payment App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }
      return;
    }

    await _launchUpiAndStartVerification(
      upiData: upiData,
      parsedAmount: parsedAmount,
      capturedLocation: capturedLocation,
      forceAskEveryTime: false,
    );
  }

  Future<void> _launchUpiAndStartVerification({
    required UpiPaymentData upiData,
    required double parsedAmount,
    required PaymentLocation? capturedLocation,
    bool forceAskEveryTime = false,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final currentPref = await UserPreferencesService().getDefaultPaymentApp();
    final effectiveAppId = forceAskEveryTime ? UpiApps.askEveryTime : currentPref;
    final bool isQuickConfirm = UserPreferencesService().cachedQuickConfirm;
    final String paymentStatus = isQuickConfirm ? 'CONFIRMED' : 'PENDING';

    // 3. Create Payment in Spring Boot / Local DB (CONFIRMED for Quick Confirm, PENDING for SMS verification)
    final txnRef = 'HULY${DateTime.now().millisecondsSinceEpoch}';
    final nowIso = DateTime.now().toIso8601String();
    final providerName = effectiveAppId == 'google_pay'
        ? 'GOOGLE_PAY'
        : (effectiveAppId == 'amazon_pay'
            ? 'AMAZON_PAY'
            : (effectiveAppId == 'phonepe'
                ? 'PHONEPE'
                : (effectiveAppId == 'bhim' ? 'BHIM' : 'UPI')));

    PaymentModel pendingPayment;
    try {
      pendingPayment = await PaymentRepository().createPayment(CreatePaymentPayload(
        amount: parsedAmount,
        currency: upiData.currency,
        merchantName: upiData.payeeName,
        upiId: upiData.upiId,
        paymentMethod: 'UPI',
        transactionReference: txnRef,
        status: paymentStatus,
        provider: providerName,
        latitude: capturedLocation?.latitude,
        longitude: capturedLocation?.longitude,
        locationAccuracyMeters: capturedLocation?.accuracyMeters,
      ));
    } catch (e) {
      pendingPayment = PaymentModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        amount: parsedAmount,
        currency: upiData.currency,
        merchantName: upiData.payeeName ?? upiData.upiId,
        upiId: upiData.upiId,
        paymentMethod: 'UPI',
        transactionReference: txnRef,
        status: paymentStatus,
        provider: providerName,
        latitude: capturedLocation?.latitude,
        longitude: capturedLocation?.longitude,
        locationAccuracyMeters: capturedLocation?.accuracyMeters,
        createdAt: nowIso,
        updatedAt: nowIso,
      );
    }

    // 4. Launch Standalone External Application Separately (without pre-filled amount)
    // User can manually add amount and pay the user directly inside their payment app
    bool launched = false;
    String? launchedAppName;

    if (effectiveAppId != UpiApps.askEveryTime) {
      final app = UpiApps.findById(effectiveAppId);
      if (app != null) {
        launchedAppName = app.name;
        launched = await UpiPaymentService.openApp(app.packageName);
      }
    } else {
      // For ask_every_time, open first available payment app standalone
      final available = await UpiPaymentService.getAvailableSupportedApps();
      if (available.isNotEmpty) {
        launchedAppName = available.first.name;
        launched = await UpiPaymentService.openApp(available.first.packageName);
      }
    }

    // Fallback: If direct package launch failed or wasn't resolved, use launchStandaloneApp
    if (!launched) {
      launched = await UpiPaymentService.launchStandaloneApp(preferredAppId: effectiveAppId);
    }

    if (!launched) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            launchedAppName != null
                ? 'Could not open $launchedAppName. Please ensure it is installed.'
                : 'Could not open payment application. Please ensure a payment app is installed.',
          ),
          backgroundColor: const Color(0xFFD93025),
        ),
      );
      return;
    }

    // 5. Open Verification Modal or Quick Confirm Dialog
    if (mounted) {
      if (isQuickConfirm) {
        _showQuickConfirmSuccessDialog(pendingPayment, upiData);
      } else {
        _showSmsVerificationDialog(pendingPayment, upiData);
      }
    }
  }

  void _showQuickConfirmSuccessDialog(PaymentModel payment, UpiPaymentData upiData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF28A745).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF28A745),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Payment Successful',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount: ₹${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Merchant: ${payment.merchantName ?? payment.upiId ?? "UPI Merchant"}',
              style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
            ),
            const SizedBox(height: 14),

            // Quick Confirm Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161619),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF28A745).withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: 18,
                    color: Color(0xFFFFB300),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quick Confirm active • Confirmed',
                      style: TextStyle(
                        fontFamily: 'Google Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF28A745),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Payment has been marked as successful and recorded in your ledger without SMS verification.',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Color(0xFFA0A0A8),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF28A745),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _handleBack(0); // Return to home on success
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showSmsVerificationDialog(PaymentModel payment, UpiPaymentData upiData) {
    int remainingSeconds = paymentVerificationTimeout.inSeconds;
    Timer? timer;
    String statusState = 'WAITING'; // 'WAITING', 'VERIFYING', 'SUCCESS', 'FAILED', 'TIMEOUT'
    String? statusMessage;
    String? resolvedUpiTxnId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (timer == null && statusState == 'WAITING') {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (!dialogCtx.mounted) {
                t.cancel();
                GooglePayService.stopSmsListener();
                return;
              }

              if (remainingSeconds > 0) {
                setDialogState(() {
                  remainingSeconds--;
                });
              } else {
                t.cancel();
                GooglePayService.stopSmsListener();
                setDialogState(() {
                  statusState = 'TIMEOUT';
                  statusMessage = 'Payment verification timed out after 5 minutes.';
                });
                PaymentRepository().reconcilePayment(payment.id, 'TIMEOUT');
              }
            });

            // Start listening for incoming SMS
            GooglePayService.startSmsListener((smsData) async {
              final body = smsData['body']?.toString() ?? '';
              final sender = smsData['sender']?.toString();
              final timestamp = smsData['timestamp']?.toString();

              // Preliminary local financial filter (Part 6)
              if (!SmsFilterService.isFinancialTransactionSms(body)) {
                return;
              }

              if (dialogCtx.mounted) {
                setDialogState(() {
                  statusState = 'VERIFYING';
                  statusMessage = 'Analyzing incoming bank transaction SMS...';
                });
              }

              try {
                final result = await PaymentRepository().verifyPaymentSms(
                  paymentId: payment.id,
                  smsBody: body,
                  sender: sender,
                  receivedAt: timestamp,
                );

                final bool isVerified = result['verified'] == true;
                final String? resultStatus = result['status']?.toString();
                final String? upiRef = result['extractedUpiReference']?.toString();

                if (isVerified && dialogCtx.mounted) {
                  timer?.cancel();
                  await GooglePayService.stopSmsListener();

                  if (resultStatus == 'SUCCESS' || resultStatus == 'CONFIRMED') {
                    setDialogState(() {
                      statusState = 'SUCCESS';
                      statusMessage = result['message']?.toString() ?? 'Payment verified successfully';
                      resolvedUpiTxnId = upiRef;
                    });
                  } else if (resultStatus == 'FAILED') {
                    setDialogState(() {
                      statusState = 'FAILED';
                      statusMessage = result['message']?.toString() ?? 'Payment failed according to bank SMS';
                      resolvedUpiTxnId = upiRef;
                    });
                  }
                } else if (dialogCtx.mounted) {
                  setDialogState(() {
                    statusState = 'WAITING';
                    statusMessage = null;
                  });
                }
              } catch (_) {
                if (dialogCtx.mounted) {
                  setDialogState(() {
                    statusState = 'WAITING';
                    statusMessage = null;
                  });
                }
              }
            });
          }

          final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
          final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
          final timerText = '$minutes:$seconds remaining';

          final bool isSuccess = statusState == 'SUCCESS';
          final bool isFailed = statusState == 'FAILED';
          final bool isTimeout = statusState == 'TIMEOUT';
          final bool isVerifying = statusState == 'VERIFYING';

          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? const Color(0xFF28A745).withValues(alpha: 0.15)
                        : (isFailed
                            ? const Color(0xFFD93025).withValues(alpha: 0.15)
                            : (isTimeout
                                ? const Color(0xFFE5A93C).withValues(alpha: 0.15)
                                : const Color(0xFF007AFF).withValues(alpha: 0.15))),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF007AFF),
                            ),
                          )
                        : Icon(
                            isSuccess
                                ? Icons.check_circle_rounded
                                : (isFailed
                                    ? Icons.error_outline_rounded
                                    : (isTimeout
                                        ? Icons.timer_off_rounded
                                        : Icons.hourglass_top_rounded)),
                            color: isSuccess
                                ? const Color(0xFF28A745)
                                : (isFailed
                                    ? const Color(0xFFD93025)
                                    : (isTimeout
                                        ? const Color(0xFFE5A93C)
                                        : const Color(0xFF007AFF))),
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSuccess
                        ? 'Payment Successful'
                        : (isFailed
                            ? 'Payment Failed'
                            : (isTimeout
                                ? 'Verification Timed Out'
                                : (isVerifying
                                    ? 'Verifying SMS...'
                                    : 'Waiting for Confirmation'))),
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount: ₹${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Merchant: ${payment.merchantName ?? payment.upiId ?? "UPI Merchant"}',
                  style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
                ),
                if (resolvedUpiTxnId != null && resolvedUpiTxnId!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'UPI Ref / UTR: $resolvedUpiTxnId',
                    style: const TextStyle(
                      fontFamily: 'Google Sans',
                      color: Color(0xFF007AFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Timer badge & status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161619),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSuccess
                          ? const Color(0xFF28A745).withValues(alpha: 0.3)
                          : (isFailed
                              ? const Color(0xFFD93025).withValues(alpha: 0.3)
                              : (isTimeout
                                  ? const Color(0xFFE5A93C).withValues(alpha: 0.3)
                                  : const Color(0xFF007AFF).withValues(alpha: 0.3))),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSuccess
                            ? Icons.verified_rounded
                            : (isTimeout ? Icons.timer_off_outlined : Icons.schedule_rounded),
                        size: 16,
                        color: isSuccess
                            ? const Color(0xFF28A745)
                            : (isTimeout ? const Color(0xFFE5A93C) : const Color(0xFF007AFF)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isSuccess
                              ? 'Verified via SMS'
                              : (isFailed
                                  ? 'Transaction Failed'
                                  : (isTimeout ? '5-minute window expired' : 'SMS verification active • $timerText')),
                          style: TextStyle(
                            fontFamily: 'Google Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSuccess
                                ? const Color(0xFF28A745)
                                : (isTimeout ? const Color(0xFFE5A93C) : const Color(0xFFD0D0D5)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isSuccess
                      ? 'Payment has been confirmed via bank transaction SMS and recorded in your ledger.'
                      : (isFailed
                          ? (statusMessage ?? 'Payment failed according to bank SMS notification.')
                          : (isTimeout
                              ? 'Payment verification timed out. If money was debited from your account, it will reflect upon refresh.'
                              : 'Complete the payment in Google Pay. Huly.Pay is actively listening for your bank transaction SMS.')),
                  style: const TextStyle(
                    fontFamily: 'Google Sans',
                    color: Color(0xFFA0A0A8),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            actions: [
              if (!isSuccess && !isFailed && !isTimeout)
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    GooglePayService.stopSmsListener();
                    PaymentRepository().reconcilePayment(payment.id, 'CANCELLED');
                    Navigator.of(dialogCtx).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
                  ),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess
                      ? const Color(0xFF28A745)
                      : (isFailed ? const Color(0xFFD93025) : const Color(0xFF007AFF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  timer?.cancel();
                  GooglePayService.stopSmsListener();
                  Navigator.of(dialogCtx).pop();
                  if (isSuccess) {
                    _handleBack(0); // Return to home on success
                  }
                },
                child: Text(
                  isSuccess ? 'Done' : (isFailed || isTimeout ? 'Dismiss' : 'Waiting...'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanBoxSize = 260.0;
          final centerOffset = Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight * 0.40,
          );
          final cutoutRect = Rect.fromCenter(
            center: centerOffset,
            width: scanBoxSize,
            height: scanBoxSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Live Camera Preview Fullscreen
              MobileScanner(
                controller: _scannerController,
                onDetect: _handleBarcodeDetected,
                errorBuilder: (context, error, child) {
                  return const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Color(0xFF55555C),
                      size: 48,
                    ),
                  );
                },
              ),

              // 2. Semi-transparent surrounding overlay with transparent viewfinder cutout
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: ScannerOverlayPainter(
                  cutoutRect: cutoutRect,
                  cornerRadius: 20.0,
                  overlayColor: const Color(0x99000000), // 60% semi-transparent dark surround
                ),
              ),

              // 3. Viewfinder Reticle Frame exactly over the cutout
              Positioned(
                left: cutoutRect.left,
                top: cutoutRect.top,
                width: cutoutRect.width,
                height: cutoutRect.height,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                    child: CustomPaint(
                      size: Size(scanBoxSize, scanBoxSize),
                      painter: ScannerFramePainter(
                        cornerColor: Colors.white,
                        cornerLength: 36.0,
                        strokeWidth: 4.0,
                        cornerRadius: 12.0,
                      ),
                    ),
                  ),
                ),
              ),

              // 4. UI Foreground: Header, instructions, controls, and bottom navigation
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 80,
                  ),
                  child: Column(
                    children: [
                      // Top Bar (Back Button & Quick Confirm Thunder Indicator)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            key: const Key('back_button'),
                            onTap: () => _handleBack(0),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF161619).withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF24242A),
                                  width: 1,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          if (UserPreferencesService().cachedQuickConfirm)
                            GestureDetector(
                              key: const Key('quick_confirm_indicator'),
                              onTap: () {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.bolt_rounded, color: Color(0xFFFFB300), size: 18),
                                        SizedBox(width: 8),
                                        Text('Quick Confirm is active'),
                                      ],
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: const Color(0xFF1F1F24),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Tooltip(
                                message: 'Quick Confirm active',
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF161619).withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF24242A),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.bolt_rounded,
                                      color: Color(0xFFFFB300),
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // Spacing to align with cutout
                      SizedBox(
                        height: (cutoutRect.bottom - (MediaQuery.of(context).padding.top + 54)).clamp(0.0, double.infinity) + 24,
                      ),

                      const Text(
                        'Scan any UPI QR code',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Align the QR code within the frame',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFFD0D0D5),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: () => _handleBack(0),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161619).withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFF2A2A30),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Controls on right side
            Positioned(
              right: 34,
              bottom: 118,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    key: const Key('flash_button'),
                    onTap: _toggleFlash,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isFlashOn
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF161619),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFlashOn
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF24242A),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    key: const Key('switch_camera_button'),
                    onTap: _toggleCamera,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _isFrontCamera
                            ? const Color(0xFF007AFF)
                            : const Color(0xFF161619),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isFrontCamera
                              ? const Color(0xFF007AFF)
                              : const Color(0xFF24242A),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'asserts/icon/switch.svg',
                          width: 20,
                          height: 20,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
        );
      },
    ),
  );
}
}

class ScannerFramePainter extends CustomPainter {
  final Color cornerColor;
  final double cornerLength;
  final double strokeWidth;
  final double cornerRadius;

  ScannerFramePainter({
    this.cornerColor = Colors.white,
    this.cornerLength = 36.0,
    this.strokeWidth = 4.0,
    this.cornerRadius = 8.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cornerColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final r = cornerRadius;
    final l = cornerLength;

    // Top-Left
    final tl = Path();
    tl.moveTo(0, l);
    tl.lineTo(0, r);
    tl.arcToPoint(Offset(r, 0), radius: Radius.circular(r));
    tl.lineTo(l, 0);
    canvas.drawPath(tl, paint);

    // Top-Right
    final tr = Path();
    tr.moveTo(w - l, 0);
    tr.lineTo(w - r, 0);
    tr.arcToPoint(Offset(w, r), radius: Radius.circular(r));
    tr.lineTo(w, l);
    canvas.drawPath(tr, paint);

    // Bottom-Left
    final bl = Path();
    bl.moveTo(0, h - l);
    bl.lineTo(0, h - r);
    bl.arcToPoint(Offset(r, h), radius: Radius.circular(r));
    bl.lineTo(l, h);
    canvas.drawPath(bl, paint);

    // Bottom-Right
    final br = Path();
    br.moveTo(w - l, h);
    br.lineTo(w - r, h);
    br.arcToPoint(Offset(w, h - r), radius: Radius.circular(r));
    br.lineTo(w, h - l);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerFramePainter oldDelegate) =>
      oldDelegate.cornerColor != cornerColor ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.cornerRadius != cornerRadius;
}

class ScannerOverlayPainter extends CustomPainter {
  final Rect cutoutRect;
  final double cornerRadius;
  final Color overlayColor;

  ScannerOverlayPainter({
    required this.cutoutRect,
    this.cornerRadius = 20.0,
    this.overlayColor = const Color(0xB3000000), // ~70% black semi-transparent
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          cutoutRect,
          Radius.circular(cornerRadius),
        ),
      );

    // Subtract the cutout from the full screen background
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.cutoutRect != cutoutRect ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.overlayColor != overlayColor;
}

