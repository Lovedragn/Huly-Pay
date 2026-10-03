import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';
import '../services/api_client.dart';
import '../services/qr_share_service.dart';
import '../services/upi_payment_service.dart';
import '../services/upi_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';

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
  String? _selectedAppId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );

    if (widget.preselectedImage != null) {
      _selectedImage = widget.preselectedImage;
    }
    if (widget.preScannedRawUri != null) {
      _scannedQrUri = widget.preScannedRawUri;
      _parsedUpiData = UpiService.parseUpiUri(widget.preScannedRawUri!);
    }

    _loadDefaultApp();

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

  Future<void> _loadDefaultApp() async {
    final defaultApp = await UserPreferencesService().getDefaultPaymentApp();
    if (mounted) {
      setState(() {
        _selectedAppId = defaultApp;
      });
    }
  }

  @override
  void dispose() {
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
                  _amountController.text = upiData.amount!.toStringAsFixed(2);
                }
                if (upiData.note != null && upiData.note!.isNotEmpty && _noteController.text.trim().isEmpty) {
                  _noteController.text = upiData.note!;
                }
              });
            } else {
              _scannedQrUri = raw;
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

      // 2. Determine target UPI app (use explicitly selected app or default from preferences)
      String effectiveAppId = _selectedAppId ?? await UserPreferencesService().getDefaultPaymentApp();
      final targetApp = UpiApps.findById(effectiveAppId);
      final String? targetPackage = (targetApp != null && targetApp.id != UpiApps.askEveryTime)
          ? targetApp.packageName
          : null;
      final String appName = targetApp?.name ?? 'UPI App';

      // 3. Request backend to generate new QR PNG image containing uri with am=parsedAmount
      String shareFilePath = _selectedImage?.path ?? '';
      try {
        final imageBytes = await ApiClient().generateQrCode(
          uri: rawUri,
          amount: parsedAmount,
          size: 512,
        );

        if (imageBytes.isNotEmpty) {
          final tempDir = await getTemporaryDirectory();
          final newQrFile = File('${tempDir.path}/qr_generated_${DateTime.now().millisecondsSinceEpoch}.png');
          await newQrFile.writeAsBytes(imageBytes, flush: true);
          shareFilePath = newQrFile.path;
        }
      } catch (backendErr) {
        debugPrint('[UploadQrScreen] Backend QR generation fallback: $backendErr');
        // If backend fails or offline, fallback to existing image
        if (shareFilePath.isEmpty && _selectedImage != null) {
          shareFilePath = _selectedImage!.path;
        }
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
            targetPackage != null ? 'Opening $appName with QR code...' : 'Opening app chooser...',
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
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFD93025) : const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeManager.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Upload QR',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Center the amount text area in available vertical and horizontal space
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                            borderRadius: BorderRadius.circular(24),
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
                              const SizedBox(height: 14),
                              Row(
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

                        const SizedBox(height: 20),

                        // UPI App Selector
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SHARE & PAY VIA',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildAppChoiceChip(
                                id: UpiApps.askEveryTime,
                                name: 'Any App',
                                icon: Icons.alt_route_rounded,
                                colors: colors,
                              ),
                              ...UpiApps.allApps.map((app) => _buildAppChoiceChip(
                                    id: app.id,
                                    name: app.name,
                                    icon: app.id == 'whatsapp'
                                        ? Icons.chat_rounded
                                        : (app.id == 'paytm'
                                            ? Icons.account_balance_wallet_rounded
                                            : Icons.payment_rounded),
                                    colors: colors,
                                  )),
                            ],
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
                            Text(
                              () {
                                if (_selectedImage == null && _scannedQrUri == null) {
                                  return 'Select QR & Pay';
                                }
                                final app = _selectedAppId != null ? UpiApps.findById(_selectedAppId!) : null;
                                final appName = app?.name ?? (_selectedAppId == UpiApps.askEveryTime ? 'Any App' : 'UPI App');
                                return 'Pay via $appName';
                              }(),
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppChoiceChip({
    required String id,
    required String name,
    required IconData icon,
    required AppThemeData colors,
  }) {
    final isSelected = (_selectedAppId ?? UpiApps.askEveryTime) == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedAppId = id;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colors.textPrimary : colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.textPrimary : colors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (colors.isDark ? Colors.black : Colors.white)
                    : colors.textPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (colors.isDark ? Colors.black : Colors.white)
                      : colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
