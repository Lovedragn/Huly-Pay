import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/qr_service.dart';
import '../services/scan_payment_service.dart';
import '../services/upi_service.dart';
import '../services/user_preferences_service.dart';
import '../theme/app_theme.dart';
import 'card_dialog.dart';

/// Values confirmed by the user on [PaymentDetailsPage].
class PaymentDetailsResult {
  final double amount;
  final String? note;

  const PaymentDetailsResult({required this.amount, this.note});
}

/// Full-screen page where the user enters the amount/note for a scanned QR.
/// Pops with a [PaymentDetailsResult] on Pay, or null on cancel.
class PaymentDetailsPage extends StatefulWidget {
  final UpiPaymentData upiData;
  final double? initialAmount;

  const PaymentDetailsPage({
    super.key,
    required this.upiData,
    this.initialAmount,
  });

  static Future<PaymentDetailsResult?> show(
    BuildContext context, {
    required UpiPaymentData upiData,
    double? initialAmount,
  }) {
    return Navigator.of(context).push<PaymentDetailsResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            PaymentDetailsPage(upiData: upiData, initialAmount: initialAmount),
      ),
    );
  }

  @override
  State<PaymentDetailsPage> createState() => _PaymentDetailsPageState();
}

class _PaymentDetailsPageState extends State<PaymentDetailsPage> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final amount = widget.upiData.amount ?? widget.initialAmount;
    _amountController = TextEditingController(
      text: amount != null && amount > 0 ? amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: widget.upiData.note ?? '');

    // Kick off pregeneration immediately if initial amount is present
    if (amount != null && amount > 0) {
      QrService().schedulePregeneration(
        rawUri: widget.upiData.rawUri,
        amount: amount,
        debounce: Duration.zero,
      );
    }

    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final entered = double.tryParse(_amountController.text.trim());
    if (entered != null && entered > 0) {
      QrService().schedulePregeneration(
        rawUri: widget.upiData.rawUri,
        amount: entered,
        debounce: const Duration(milliseconds: 150),
      );
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      showCardNotification(
        context,
        message: 'Please enter a valid amount greater than 0',
        type: CardNotificationType.warning,
      );
      return;
    }
    final note = _noteController.text.trim();
    Navigator.of(context).pop(
      PaymentDetailsResult(amount: amount, note: note.isNotEmpty ? note : null),
    );
  }

  void _copyUpiId() {
    Clipboard.setData(ClipboardData(text: widget.upiData.upiId));
    showCardNotification(
      context,
      message: 'UPI ID copied: ${widget.upiData.upiId}',
      type: CardNotificationType.info,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final upiData = widget.upiData;
    final payee = upiData.payeeName?.trim();
    final hasPayeeName = payee != null && payee.isNotEmpty;
    final primaryTitle = hasPayeeName ? payee : upiData.upiId;
    final subtitle = hasPayeeName ? upiData.upiId : 'UPI Payee';

    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(colors),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              24,
              MediaQuery.of(context).padding.top + kToolbarHeight + 12,
              24,
              20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAvatar(colors),
                  const SizedBox(height: 16),
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
                  _buildSubtitleRow(colors, subtitle),
                  const SizedBox(height: 32),
                  _buildAmountBox(colors),
                  const SizedBox(height: 16),
                  _buildNoteField(colors),
                  const SizedBox(height: 32),
                  _buildPayButton(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppThemeData colors) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: colors.topBarGradient,
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
              child: const Icon(
                Icons.bolt_rounded,
                color: Color(0xFFFFB300),
                size: 22,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(AppThemeData colors) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Icon(Icons.storefront_rounded, color: colors.accent, size: 34),
    );
  }

  Widget _buildSubtitleRow(AppThemeData colors, String subtitle) {
    return Row(
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
          onTap: _copyUpiId,
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
    );
  }

  Widget _buildAmountBox(AppThemeData colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border, width: 1.2),
      ),
      child: Column(
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
                  controller: _amountController,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
    );
  }

  Widget _buildNoteField(AppThemeData colors) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextField(
      controller: _noteController,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _submit(),
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
        border: border(colors.border),
        enabledBorder: border(colors.border),
        focusedBorder: border(colors.accent, 1.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildPayButton(AppThemeData colors) {
    final isDark = colors.isDark;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _submit,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payment_rounded,
              size: 20,
              color: isDark ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 10),
            Text(
              ScanPaymentService.payButtonLabel(),
              style: TextStyle(
                fontFamily: 'Google Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
