import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../services/qr_service.dart';
import '../services/qr_share_service.dart';
import '../services/upi_payment_service.dart';
import '../services/upi_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';
import '../widgets/card_dialog.dart';

class UploadQrScreen extends StatefulWidget {
  final double? initialAmount;
  final XFile? preselectedImage;
  final String? preScannedRawUri;

  const UploadQrScreen({
    super.key,
    this.initialAmount,
    this.preselectedImage,
    this.preScannedRawUri,
  });

  @override
  State<UploadQrScreen> createState() => _UploadQrScreenState();
}

class _UploadQrScreenState extends State<UploadQrScreen> {
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  XFile? _selectedImage;
  String? _scannedQrUri;
  UpiPaymentData? _parsedUpiData;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? (widget.initialAmount! % 1 == 0
              ? widget.initialAmount!.toInt().toString()
              : widget.initialAmount!.toString())
          : '',
    );

    if (widget.preselectedImage != null) {
      _selectedImage = widget.preselectedImage;
    }
    if (widget.preScannedRawUri != null) {
      _scannedQrUri = widget.preScannedRawUri;
      _parsedUpiData = UpiService.parseUpiUri(widget.preScannedRawUri!);
    }

    _amountController.addListener(_onAmountChanged);

    // Initial pregeneration if raw URI and amount are already known
    final initialAmt = double.tryParse(_amountController.text.trim());
    if (_scannedQrUri != null && initialAmt != null && initialAmt > 0) {
      QrService().schedulePregeneration(
        rawUri: _scannedQrUri!,
        amount: initialAmt,
        debounce: Duration.zero,
      );
    }

    // Auto-focus amount textfield once screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _amountFocusNode.canRequestFocus) {
        _amountFocusNode.requestFocus();
      }
      if (_selectedImage == null && _scannedQrUri == null) {
        _pickImage();
      }
    });
  }

  void _onAmountChanged() {
    final rawUri = _scannedQrUri;
    final amount = double.tryParse(_amountController.text.trim());
    if (rawUri != null && rawUri.isNotEmpty && amount != null && amount > 0) {
      QrService().schedulePregeneration(
        rawUri: rawUri,
        amount: amount,
        debounce: const Duration(milliseconds: 150),
      );
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await QrShareService.pickQrImage(context);
    if (picked != null && mounted) {
      setState(() {
        _selectedImage = picked;
      });

      // Analyze image to decode QR URI
      try {
        final capture = await MobileScannerController().analyzeImage(picked.path);
        if (capture != null && capture.barcodes.isNotEmpty) {
          final raw = capture.barcodes.first.rawValue?.trim();
          if (raw != null && raw.isNotEmpty) {
            final upiData = UpiService.parseUpiUri(raw);
            if (upiData != null) {
              setState(() {
                _scannedQrUri = raw;
                _parsedUpiData = upiData;
                if (upiData.amount != null && upiData.amount! > 0 && _amountController.text.trim().isEmpty) {
                  _amountController.text = upiData.amount! % 1 == 0
                      ? upiData.amount!.toInt().toString()
                      : upiData.amount!.toString();
                }
                if (upiData.note != null && upiData.note!.isNotEmpty && _noteController.text.trim().isEmpty) {
                  _noteController.text = upiData.note!;
                }
              });

              // Rapidly start generating QR in background for the scanned QR & amount
              final targetAmount = double.tryParse(_amountController.text.trim()) ?? upiData.amount;
              if (targetAmount != null && targetAmount > 0) {
                QrService().schedulePregeneration(
                  rawUri: raw,
                  amount: targetAmount,
                  debounce: Duration.zero,
                );
              }
            } else {
              _scannedQrUri = raw;
              final currentAmt = double.tryParse(_amountController.text.trim());
              if (currentAmt != null && currentAmt > 0) {
                QrService().schedulePregeneration(
                  rawUri: raw,
                  amount: currentAmt,
                  debounce: Duration.zero,
                );
              }
            }
          }
        }
      } catch (e) {
        debugPrint('[UploadQrScreen] Analyze QR error: $e');
      }

      if (_amountFocusNode.canRequestFocus) {
        _amountFocusNode.requestFocus();
      }
    }
  }

  Future<void> _handlePayButton() async {
    if (_isProcessing) return;

    if (_selectedImage == null && _scannedQrUri == null) {
      _showFeedbackSnackBar(
        'Please select a QR image first',
        isError: true,
      );
      await _pickImage();
      return;
    }

    final rawText = _amountController.text.trim();
    final parsedAmount = double.tryParse(rawText);
    if (parsedAmount == null || parsedAmount <= 0) {
      _showFeedbackSnackBar(
        'Please enter a valid amount greater than 0',
        isError: true,
      );
      if (_amountFocusNode.canRequestFocus) {
        _amountFocusNode.requestFocus();
      }
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Decode QR if not decoded yet
      String? rawUri = _scannedQrUri;
      if (rawUri == null && _selectedImage != null) {
        try {
          final capture = await MobileScannerController().analyzeImage(_selectedImage!.path);
          if (capture != null && capture.barcodes.isNotEmpty) {
            rawUri = capture.barcodes.first.rawValue?.trim();
            _scannedQrUri = rawUri;
          }
        } catch (_) {}
      }

      if (rawUri == null || rawUri.isEmpty) {
        _showFeedbackSnackBar(
          'Could not detect a valid QR code in the image',
          isError: true,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 2. Determine target UPI app from user preferences / settings (defaulting directly to Google Pay)
      final preferredAppId = await UserPreferencesService().getDefaultPaymentApp();
      final targetApp = (preferredAppId != UpiApps.askEveryTime)
          ? UpiApps.findById(preferredAppId)
          : UpiApps.gpay;
      final String? targetPackage = (preferredAppId != UpiApps.askEveryTime)
          ? (targetApp?.packageName ?? UpiApps.gpay.packageName)
          : null;
      final String appName = targetApp?.name ?? 'Google Pay';

      // 3. Fast on-device QR generation with pretty_qr_code (or instant retrieval from pregeneration cache)
      String shareFilePath = '';
      try {
        final qrFile = await QrService().getOrGenerateQrFile(
          rawUri: rawUri,
          amount: parsedAmount,
          size: 512,
        );
        if (qrFile != null && await qrFile.exists()) {
          shareFilePath = qrFile.path;
          debugPrint('[UploadQrScreen] Using client-generated QR file: $shareFilePath');
        }
      } catch (clientErr) {
        debugPrint('[UploadQrScreen] QR generation error: $clientErr');
      }

      if (shareFilePath.isEmpty) {
        _showFeedbackSnackBar('Failed to prepare QR image for payment', isError: true);
        setState(() => _isProcessing = false);
        return;
      }

      if (!mounted) return;

      // 4. Send newly generated QR image to selected UPI application
      final note = _noteController.text.trim();
      final success = await QrShareService.shareQrImage(
        context: context,
        filePath: shareFilePath,
        amount: parsedAmount,
        note: note.isNotEmpty ? note : null,
        title: 'Pay with $appName',
        targetPackage: targetPackage,
      );

      if (mounted) {
        if (success) {
          final upiData = _parsedUpiData ?? UpiService.parseUpiUri(rawUri);
          final txnRef = 'HULY${DateTime.now().millisecondsSinceEpoch}';
          final payee = upiData?.payeeName?.trim();
          final upi = upiData?.upiId.trim();
          final merchant = (payee != null && payee.isNotEmpty)
              ? payee
              : ((upi != null && upi.isNotEmpty) ? upi : (note.isNotEmpty ? note : 'QR Payment'));

          try {
            await TransactionRepository().createTransaction(CreatePaymentPayload(
              amount: parsedAmount,
              currency: upiData?.currency ?? 'INR',
              merchantName: merchant,
              upiId: upi ?? '',
              paymentMethod: 'UPI',
              transactionReference: txnRef,
              status: UserPreferencesService().cachedQuickConfirm ? 'CONFIRMED' : 'PENDING',
              provider: targetApp?.name.toUpperCase().replaceAll(' ', '_') ?? 'UPI',
            ));
          } catch (_) {}

          _showFeedbackSnackBar(
            'Opening $appName with QR code...',
            isError: false,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showFeedbackSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    showCardNotification(
      context,
      message: message,
      type: isError ? CardNotificationType.error : CardNotificationType.info,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildAppBar(BuildContext context, AppThemeData colors) {
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
              'Upload QR',
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

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 68, bottom: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Centered Amount Entry Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.zero,
                            border: Border.all(color: colors.border, width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '₹',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: colors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: TextField(
                                  controller: _amountController,
                                  focusNode: _amountFocusNode,
                                  autofocus: true,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    color: colors.textPrimary,
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '0',
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
                        ),

                        const SizedBox(height: 16),

                        // Centered Note / Message Field
                        TextField(
                          controller: _noteController,
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

                        // Compact badge when image is attached
                        if (_selectedImage != null) ...[
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF30D158).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF30D158).withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF30D158),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _selectedImage!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontFamily: 'Google Sans',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF30D158),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: colors.accent,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Sticky Upload & Pay Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.isDark ? Colors.white : Colors.black,
                    foregroundColor: colors.isDark ? Colors.black : Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _handlePayButton,
                  child: _isProcessing
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colors.isDark ? Colors.black : Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment_rounded,
                              size: 20,
                              color: colors.isDark ? Colors.black : Colors.white,
                            ),
                            const SizedBox(width: 10),
                            FutureBuilder<String>(
                              future: UserPreferencesService().getDefaultPaymentApp(),
                              builder: (context, snapshot) {
                                final defaultAppId = snapshot.data ?? UserPreferencesService().cachedDefaultPaymentApp;
                                final app = UpiApps.findById(defaultAppId);
                                final appName = app?.name ?? (defaultAppId == UpiApps.askEveryTime ? 'Any App' : 'UPI App');
                                return Text(
                                  _selectedImage != null || _scannedQrUri != null
                                      ? appName
                                      : 'Select QR & Pay',
                                  style: TextStyle(
                                    fontFamily: 'Google Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.isDark ? Colors.black : Colors.white,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAppBar(context, colors),
            ),
          ],
        ),
      ),
    );
  }
}
