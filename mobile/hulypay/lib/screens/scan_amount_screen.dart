import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'scan_and_pay_screen.dart';

class ScanAmountScreen extends StatefulWidget {
  final double? initialAmount;

  const ScanAmountScreen({
    super.key,
    this.initialAmount,
  });

  @override
  State<ScanAmountScreen> createState() => _ScanAmountScreenState();
}

class _ScanAmountScreenState extends State<ScanAmountScreen> {
  late final TextEditingController _amountController;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );

    // Auto-focus amount textfield once screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _amountFocusNode.canRequestFocus) {
        _amountFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleScanButton() async {
    final rawText = _amountController.text.trim();
    final parsedAmount = double.tryParse(rawText);

    if (rawText.isNotEmpty && (parsedAmount == null || parsedAmount <= 0)) {
      _showFeedbackSnackBar(
        'Please enter a valid amount greater than 0',
        isError: true,
      );
      if (_amountFocusNode.canRequestFocus) {
        _amountFocusNode.requestFocus();
      }
      return;
    }

    final note = _noteController.text.trim();

    // Open scanner with entered amount
    final result = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ScanAndPayScreen(
          initialAmount: (parsedAmount != null && parsedAmount > 0) ? parsedAmount : null,
          initialNote: note.isNotEmpty ? note : null,
        ),
      ),
    );

    // If payment/scan was launched or back returned with a target index, pop back to dashboard
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
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
          'Scan & Pay',
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
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Sticky Scan Button
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
                  onPressed: _handleScanButton,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icon/qr.svg',
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          colors.isDark ? Colors.black : Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Scan QR Code',
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
}
