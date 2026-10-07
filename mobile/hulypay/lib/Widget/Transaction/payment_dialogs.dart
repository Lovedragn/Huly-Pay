import 'package:flutter/material.dart';

import '../../Data/external_data.dart';
import '../../Model/transaction_model.dart';
import '../../Theme/app_theme.dart';
import '../dialog.dart';

/// Amount + merchant lines shown in result dialogs.
class PaymentSummaryLines extends StatelessWidget {
  final PaymentModel payment;

  const PaymentSummaryLines({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Amount: ₹${payment.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Merchant: ${payment.merchantName ?? payment.upiId ?? "UPI Merchant"}',
          style: TextStyle(
            fontFamily: 'Google Sans',
            color: colors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Helper for filled action buttons matching theme styling
ButtonStyle filledDialogButton(Color color) => ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
    );

/// Returns true if the user tapped "Grant Permission".
Future<bool> showSmsPermissionDialog(BuildContext context) async {
  final colors = AppThemeManager.colors;
  final result = await showCardDialog<bool>(
    context: context,
    builder: (ctx) => CardDialog(
      icon: CardDialogTitleIcon(
        color: colors.warning,
        child: Icon(Icons.sms_failed_rounded, color: colors.warning, size: 20),
      ),
      title: Text(
        ExternalData.smsPermissionRequiredTitle,
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Text(
        ExternalData.smsPermissionRequiredContent,
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            'Dismiss',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: filledDialogButton(colors.info),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Grant Permission',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return result ?? false;
}

enum MissingAppAction { changeDefault, openAnyApp }

/// Shown when the preferred UPI app isn't installed.
Future<MissingAppAction?> showAppNotInstalledDialog(
  BuildContext context,
  String appName,
) {
  final colors = AppThemeManager.colors;
  return showCardDialog<MissingAppAction>(
    context: context,
    builder: (ctx) => CardDialog(
      icon: CardDialogTitleIcon(
        color: colors.warning,
        child: Icon(
          Icons.warning_amber_rounded,
          color: colors.warning,
          size: 20,
        ),
      ),
      title: Text(
        '$appName Not Installed',
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: Text(
        '$appName is not installed on this device. Would you like to use the '
        'Android app chooser or select another UPI application?',
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(MissingAppAction.changeDefault),
          child: Text(
            'Change Default App',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.info,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 6),
        ElevatedButton(
          style: filledDialogButton(colors.info),
          onPressed: () => Navigator.of(ctx).pop(MissingAppAction.openAnyApp),
          child: const Text(
            'Open Any App',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Success dialog for Quick Confirm mode (no SMS verification).
Future<void> showQuickConfirmSuccessDialog(
  BuildContext context,
  PaymentModel payment,
) {
  final colors = AppThemeManager.colors;
  return showCardDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => CardDialog(
      icon: CardDialogTitleIcon(
        color: colors.success,
        child: Icon(
          Icons.check_circle_rounded,
          color: colors.success,
          size: 22,
        ),
      ),
      title: Text(
        'Payment Successful',
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummaryLines(payment: payment),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: colors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFFFB300)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Quick Confirm active • Confirmed',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ExternalData.quickConfirmSuccessBody,
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: colors.textMuted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: filledDialogButton(colors.success).copyWith(
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
          ),
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text(
            'Done',
            style: TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}
