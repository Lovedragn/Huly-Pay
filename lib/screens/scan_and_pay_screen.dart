import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_model.dart';
import '../repositories/payment_repository.dart';
import '../services/google_pay_service.dart';
import '../services/local_database_service.dart';
import '../services/location_service.dart';
import '../services/sms_filter_service.dart';
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
    PaymentLocation? capturedLocation = initialLocationResult?.location;
    LocationResult? locationResult = initialLocationResult;
    bool isLocationFetching = capturedLocation == null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalStateContext, setModalState) {
            // Concurrent background GPS resolution without blocking UI
            if (isLocationFetching) {
              isLocationFetching = false;
              LocationService().getPaymentLocationWithStatus().then((result) {
                if (modalContext.mounted) {
                  setModalState(() {
                    locationResult = result;
                    capturedLocation = result.location;
                  });
                }
              });
            }
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
                                      : (locationResult == null
                                          ? 'Acquiring GPS location...'
                                          : (locationResult!.failureReason == LocationFailureReason.serviceDisabled
                                              ? 'Location disabled: Please turn on GPS'
                                              : (locationResult!.failureReason == LocationFailureReason.permissionDenied
                                                  ? 'Location permission denied'
                                                  : (locationResult!.failureReason == LocationFailureReason.permissionDeniedForever
                                                      ? 'Location permission denied forever'
                                                      : 'Location unavailable')))),
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
                                if (locationResult?.failureReason == LocationFailureReason.permissionDeniedForever) {
                                  await LocationService.openAppSettings();
                                } else if (locationResult?.failureReason == LocationFailureReason.serviceDisabled) {
                                  await LocationService.openLocationSettings();
                                } else {
                                  final retry = await LocationService().getPaymentLocationWithStatus();
                                  if (retry.isSuccess && modalContext.mounted) {
                                    setModalState(() {
                                      capturedLocation = retry.location;
                                      locationResult = retry;
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
                                  locationResult?.failureReason == LocationFailureReason.permissionDeniedForever ||
                                          locationResult?.failureReason == LocationFailureReason.serviceDisabled
                                      ? 'Settings'
                                      : (locationResult == null ? '...' : 'Retry'),
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
                        await _startSmsVerificationWorkflow(upiData, parsedAmount, capturedLocation);
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

  static const Duration paymentVerificationTimeout = Duration(minutes: 5);

  Future<void> _startSmsVerificationWorkflow(
    UpiPaymentData upiData,
    double parsedAmount,
    PaymentLocation? capturedLocation,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    // 1. Check & Request SMS Permission (Part 4)
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

    // 2. Check if Google Pay is installed
    final isGPayReady = await GooglePayService.isReadyToPay();
    if (!isGPayReady) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFE5A93C), size: 24),
                SizedBox(width: 10),
                Text(
                  'UPI App Not Found',
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
              'Google Pay is not installed on this device or emulator. To make real UPI payments, please install Google Pay or run on a physical Android device with Google Pay configured.',
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
                  final playStoreUri = Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.google.android.apps.nbu.paisa.user',
                  );
                  try {
                    await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: const Text('Get Google Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 3. Create PENDING Payment in Spring Boot / Local DB (Part 2)
    final txnRef = 'HULY${DateTime.now().millisecondsSinceEpoch}';
    final nowIso = DateTime.now().toIso8601String();

    PaymentModel pendingPayment;
    try {
      pendingPayment = await PaymentRepository().createPayment(CreatePaymentPayload(
        amount: parsedAmount,
        currency: upiData.currency,
        merchantName: upiData.payeeName,
        upiId: upiData.upiId,
        paymentMethod: 'GPAY',
        transactionReference: txnRef,
        status: 'PENDING',
        provider: 'GOOGLE_PAY',
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
        paymentMethod: 'GPAY',
        transactionReference: txnRef,
        status: 'PENDING',
        provider: 'GOOGLE_PAY',
        latitude: capturedLocation?.latitude,
        longitude: capturedLocation?.longitude,
        locationAccuracyMeters: capturedLocation?.accuracyMeters,
        createdAt: nowIso,
        updatedAt: nowIso,
      );
    }

    // 4. Launch Google Pay as a Standalone Application (Part 3 & Part 14)
    try {
      await GooglePayService.launchStandaloneGooglePay();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open Google Pay: $e')),
      );
    }

    // 5. Open 5-Minute Verification Modal and start listening for SMS (Part 5 & 13)
    if (mounted) {
      _showSmsVerificationDialog(pendingPayment, upiData);
    }
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

  void _showPaymentInitiatedDialog(PaymentModel payment, [GooglePayResult? gpayResult]) {
    bool isReconciling = false;
    final bool isGooglePayConfirmed = gpayResult?.isSuccess == true;
    final String? resolvedTxnId = gpayResult?.upiTransactionId ?? payment.upiTransactionId;

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
                    color: isGooglePayConfirmed
                        ? const Color(0xFF28A745).withValues(alpha: 0.15)
                        : (gpayResult?.isFailure == true
                            ? const Color(0xFFD93025).withValues(alpha: 0.15)
                            : const Color(0xFF007AFF).withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      isGooglePayConfirmed
                          ? Icons.check_circle_rounded
                          : (gpayResult?.isFailure == true
                              ? Icons.error_outline_rounded
                              : Icons.send_rounded),
                      color: isGooglePayConfirmed
                          ? const Color(0xFF28A745)
                          : (gpayResult?.isFailure == true
                              ? const Color(0xFFD93025)
                              : const Color(0xFF007AFF)),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isGooglePayConfirmed
                      ? 'Google Pay Confirmed'
                      : (gpayResult?.isFailure == true ? 'Payment Failed' : 'Payment Initiated'),
                  style: const TextStyle(
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
                if (resolvedTxnId != null && resolvedTxnId.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'UPI Txn ID: $resolvedTxnId',
                    style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF007AFF), fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
                if (gpayResult?.payeeVpa != null && gpayResult!.payeeVpa!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Payee VPA: ${gpayResult.payeeVpa}',
                    style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                ],
                if (gpayResult?.responseCode != null && gpayResult!.responseCode!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Response Code: ${gpayResult.responseCode}',
                    style: const TextStyle(fontFamily: 'Google Sans', color: Color(0xFF8E8E93), fontSize: 13),
                  ),
                ],
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
                        color: isGooglePayConfirmed
                            ? const Color(0xFF28A745).withValues(alpha: 0.2)
                            : (gpayResult?.isFailure == true
                                ? const Color(0xFFD93025).withValues(alpha: 0.2)
                                : const Color(0xFF007AFF).withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGooglePayConfirmed
                            ? 'SUCCESS'
                            : (gpayResult?.isFailure == true ? 'FAILED' : payment.status),
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: isGooglePayConfirmed
                              ? const Color(0xFF28A745)
                              : (gpayResult?.isFailure == true
                                  ? const Color(0xFFD93025)
                                  : const Color(0xFF007AFF)),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isGooglePayConfirmed
                      ? 'Payment was verified by Google Pay and recorded in your expense ledger.'
                      : (gpayResult?.isFailure == true
                          ? 'The payment could not be processed by Google Pay or your bank.'
                          : 'Payment was launched in your UPI app. If payment completed successfully, tap "Confirm Payment" to reconcile and create your expense entry.'),
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
              if (!isGooglePayConfirmed && gpayResult?.isFailure != true)
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
                  backgroundColor: (gpayResult?.isFailure == true)
                      ? const Color(0xFFD93025)
                      : (isGooglePayConfirmed ? const Color(0xFF28A745) : const Color(0xFF007AFF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isReconciling
                    ? null
                    : () async {
                        if (isGooglePayConfirmed || gpayResult?.isFailure == true) {
                          Navigator.of(ctx).pop();
                          _handleBack(0); // Return to home
                          return;
                        }

                        setDialogState(() {
                          isReconciling = true;
                        });

                        try {
                          await PaymentRepository().reconcilePayment(
                            payment.id,
                            'CONFIRMED',
                            upiTransactionId: resolvedTxnId,
                            transactionReference: gpayResult?.transactionReference ?? payment.transactionReference,
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
                    : Text(
                        isGooglePayConfirmed
                            ? 'Done'
                            : (gpayResult?.isFailure == true ? 'Dismiss' : 'Confirm Payment'),
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
                    // Top Bar (Back Button)
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
