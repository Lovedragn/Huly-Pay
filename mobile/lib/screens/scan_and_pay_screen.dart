import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/location_service.dart';
import '../services/upi_service.dart';
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
      detectionSpeed: DetectionSpeed.noDuplicates,
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

    try {
      await _scannerController.stop();
    } catch (_) {}

    if (!mounted) return;

    // Capture GPS location before opening payment confirmation
    final locationResult = await LocationService().getPaymentLocationWithStatus();

    if (!mounted) return;
    await _showPaymentConfirmationModal(upiData, locationResult);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      try {
        await _scannerController.start();
      } catch (_) {}
    }
  }

  Future<void> _showPaymentConfirmationModal(
    UpiPaymentData upiData,
    LocationResult locationResult,
  ) async {
    final amountController = TextEditingController(
      text: upiData.amount != null ? upiData.amount!.toStringAsFixed(2) : '',
    );
    PaymentLocation? capturedLocation = locationResult.location;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasPayeeName = upiData.payeeName != null && upiData.payeeName!.trim().isNotEmpty;
            final primaryTitle = hasPayeeName ? upiData.payeeName!.trim() : upiData.upiId;
            final subtitle = hasPayeeName ? upiData.upiId : 'UPI Payee';

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Color(0xFF161619),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2A2A30), width: 1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF33333A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF24242A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront_rounded,
                              color: Color(0xFF007AFF),
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                primaryTitle,
                                style: const TextStyle(
                                  fontFamily: 'Google Sans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontFamily: 'Google Sans',
                                  fontSize: 13,
                                  color: Color(0xFF8E8E93),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Amount Field
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontFamily: 'Google Sans',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Amount (INR)',
                        hintText: 'Enter amount',
                        hintStyle: const TextStyle(color: Color(0xFF55555C)),
                        labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                        prefixText: '₹ ',
                        prefixStyle: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1E1E24),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // GPS Location Capture Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: capturedLocation != null
                              ? const Color(0xFF28A745).withValues(alpha: 0.4)
                              : const Color(0xFFE5A93C).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            capturedLocation != null
                                ? Icons.location_on_rounded
                                : Icons.location_off_rounded,
                            color: capturedLocation != null
                                ? const Color(0xFF28A745)
                                : const Color(0xFFE5A93C),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Builder(
                            builder: (context) {
                              final currentLoc = capturedLocation;
                              return Expanded(
                                child: Text(
                                  currentLoc != null
                                      ? 'GPS: ${currentLoc.latitude.toStringAsFixed(4)}, ${currentLoc.longitude.toStringAsFixed(4)} (±${currentLoc.accuracyMeters.toStringAsFixed(1)}m)'
                                      : (locationResult.failureReason == LocationFailureReason.serviceDisabled
                                          ? 'Location disabled: Please turn on GPS'
                                          : (locationResult.failureReason == LocationFailureReason.permissionDenied
                                              ? 'Location permission denied'
                                              : (locationResult.failureReason == LocationFailureReason.permissionDeniedForever
                                                  ? 'Location permission denied forever'
                                                  : 'Location unavailable'))),
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 12,
                                    color: currentLoc != null
                                        ? const Color(0xFFD0D0D5)
                                        : const Color(0xFFE5A93C),
                                  ),
                                ),
                              );
                            },
                          ),
                          if (capturedLocation == null)
                            GestureDetector(
                              onTap: () async {
                                if (locationResult.failureReason == LocationFailureReason.permissionDeniedForever) {
                                  await LocationService.openAppSettings();
                                } else if (locationResult.failureReason == LocationFailureReason.serviceDisabled) {
                                  await LocationService.openLocationSettings();
                                } else {
                                  final retry = await LocationService().getPaymentLocationWithStatus();
                                  if (retry.isSuccess && modalContext.mounted) {
                                    setModalState(() {
                                      capturedLocation = retry.location;
                                    });
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  locationResult.failureReason == LocationFailureReason.permissionDeniedForever ||
                                          locationResult.failureReason == LocationFailureReason.serviceDisabled
                                      ? 'Settings'
                                      : 'Retry',
                                  style: const TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Proceed to Pay Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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

                        Navigator.of(modalContext).pop();

                        // 1. Record pending payment on Spring Boot backend (Payment Status: INITIATED)
                        try {
                          final payload = CreatePaymentPayload(
                            amount: parsedAmount,
                            currency: upiData.currency,
                            merchantName: upiData.payeeName,
                            upiId: upiData.upiId,
                            paymentMethod: 'GPAY',
                            transactionReference: upiData.transactionRef ?? 'REF-${DateTime.now().millisecondsSinceEpoch}',
                            provider: 'GOOGLE_PAY',
                            latitude: capturedLocation?.latitude,
                            longitude: capturedLocation?.longitude,
                            locationAccuracyMeters: capturedLocation?.accuracyMeters,
                          );

                          final payment = await PaymentRepository().createPayment(payload);

                          // 2. Open external UPI app (Huly.Pay is the intelligent financial layer, not processor)
                          final uri = upiData.buildPaymentUri(customAmount: parsedAmount);
                          await UpiService.launchUpiPayment(uri);

                          // 3. User returns from external UPI application
                          if (mounted) {
                            _showPaymentInitiatedDialog(payment);
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Payment initiation error: $e'),
                                backgroundColor: const Color(0xFFD93025),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Proceed to Pay via UPI / GPay',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPaymentInitiatedDialog(PaymentModel payment) {
    bool isReconciling = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.send_rounded, color: Color(0xFF007AFF), size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Initiated',
                  style: TextStyle(
                    fontFamily: 'Google Sans',
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
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
                  style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Location: ${payment.latitude != null ? "${payment.latitude!.toStringAsFixed(4)}, ${payment.longitude!.toStringAsFixed(4)}" : "Not captured"}',
                  style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        payment.status,
                        style: const TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Payment was launched in your UPI app. If payment completed successfully, tap "Confirm Payment" to reconcile and create your expense entry.',
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
              TextButton(
                onPressed: isReconciling
                    ? null
                    : () {
                        Navigator.of(ctx).pop();
                        _handleBack(0); // Return to home
                      },
                child: const Text(
                  'I\'ll Reconcile Later',
                  style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w500),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isReconciling
                    ? null
                    : () async {
                        setDialogState(() {
                          isReconciling = true;
                        });

                        try {
                          await PaymentRepository().reconcilePayment(
                            payment.id,
                            'CONFIRMED',
                            transactionReference: payment.transactionReference,
                          );

                          if (dialogCtx.mounted) {
                            Navigator.of(ctx).pop();
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Payment confirmed and reconciled to expense successfully!',
                                  style: TextStyle(fontFamily: 'Google Sans', color: Colors.white),
                                ),
                                backgroundColor: const Color(0xFF28A745),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                            _handleBack(0); // Return to home
                          }
                        } catch (e) {
                          setDialogState(() {
                            isReconciling = false;
                          });
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reconciliation error: $e'),
                                backgroundColor: const Color(0xFFD93025),
                              ),
                            );
                          }
                        }
                      },
                child: isReconciling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm Payment',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _simulateDemoScan() {
    final demoUpi = UpiService.parseUpiUri(
      'upi://pay?pa=starbucks@okhdfcbank&pn=Starbucks%20Coffee&am=240.00&cu=INR&tr=TXN_DEMO_123',
    );
    if (demoUpi != null) {
      _processPaymentFlow(demoUpi);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 80,
                ),
                child: Column(
                  children: [
                    // Top Bar (Back Button & Demo Trigger)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          key: const Key('back_button'),
                          onTap: _handleBack,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF161619),
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
                        // Demo QR trigger button for emulators
                        GestureDetector(
                          key: const Key('demo_qr_button'),
                          onTap: _simulateDemoScan,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161619),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2A2A30),
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.qr_code_2_rounded, color: Color(0xFF007AFF), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Demo QR',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(flex: 1),

                    // Scanner Viewfinder Box with Live MobileScanner and Reticle
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: const Color(0xFF141416),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: MobileScanner(
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
                            ),
                            CustomPaint(
                              size: const Size(250, 250),
                              painter: ScannerFramePainter(
                                cornerColor: Colors.white,
                                cornerLength: 36.0,
                                strokeWidth: 4.0,
                                cornerRadius: 8.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

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
                        color: Color(0xFF8E8E93),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => _handleBack(0),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161619),
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

                    const Spacer(flex: 2),
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
                isQrActive: true,
                onItemSelected: (index) {
                  _handleBack(index);
                },
                onQrScanTap: () {},
              ),
            ),
          ],
        ),
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
