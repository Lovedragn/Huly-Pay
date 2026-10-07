import 'dart:async';

import 'package:flutter/material.dart';

import '../Data/external_data.dart';
import '../Model/transaction_model.dart';
import '../Repository/transaction_repository.dart';
import '../Service/google_pay_service.dart';
import '../Service/scan_payment_service.dart';
import '../Service/sms_filter_service.dart';
import '../Theme/app_theme.dart';
import 'dialog.dart';
import 'Transaction/payment_dialogs.dart';

enum _VerifyState { waiting, verifying, success, failed, timeout }

/// Visual config per verification state.
class _StateStyle {
  final Color Function(AppThemeData) colorResolver;
  final IconData icon;
  final String title;

  const _StateStyle(this.colorResolver, this.icon, this.title);
}

final _styles = {
  _VerifyState.waiting: _StateStyle(
    (c) => c.info,
    Icons.hourglass_top_rounded,
    'Waiting for Confirmation',
  ),
  _VerifyState.verifying: _StateStyle(
    (c) => c.info,
    Icons.hourglass_top_rounded,
    'Verifying SMS...',
  ),
  _VerifyState.success: _StateStyle(
    (c) => c.success,
    Icons.check_circle_rounded,
    'Payment Successful',
  ),
  _VerifyState.failed: _StateStyle(
    (c) => c.error,
    Icons.error_outline_rounded,
    'Payment Failed',
  ),
  _VerifyState.timeout: _StateStyle(
    (c) => c.warning,
    Icons.timer_off_rounded,
    'Verification Timed Out',
  ),
};

/// Listens for the bank SMS and verifies the payment with the backend.
/// Pops `true` when the user dismisses after a successful verification.
class SmsVerificationDialog extends StatefulWidget {
  final PaymentModel payment;
  final Duration timeout;

  const SmsVerificationDialog({
    super.key,
    required this.payment,
    this.timeout = const Duration(minutes: 5),
  });

  static Future<bool> show(
    BuildContext context,
    PaymentModel payment, {
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final result = await showCardDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SmsVerificationDialog(payment: payment, timeout: timeout),
    );
    return result ?? false;
  }

  @override
  State<SmsVerificationDialog> createState() => _SmsVerificationDialogState();
}

class _SmsVerificationDialogState extends State<SmsVerificationDialog> {
  late int _remainingSeconds;
  Timer? _timer;
  _VerifyState _state = _VerifyState.waiting;
  String? _statusMessage;
  String? _upiRef;

  bool get _isTerminal =>
      _state == _VerifyState.success ||
      _state == _VerifyState.failed ||
      _state == _VerifyState.timeout;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeout.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    GooglePayService.startSmsListener(_onSms);
  }

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }

  void _stopListening() {
    _timer?.cancel();
    _timer = null;
    GooglePayService.stopSmsListener();
  }

  void _onTick(Timer t) {
    if (!mounted) return;
    if (_remainingSeconds > 0) {
      setState(() => _remainingSeconds--);
      return;
    }
    _stopListening();
    setState(() {
      _state = _VerifyState.timeout;
      _statusMessage = ExternalData.paymentVerificationTimeoutMsg;
    });
    ScanPaymentService.reconcile(widget.payment.id, 'TIMEOUT');
  }

  Future<void> _onSms(Map<String, dynamic> sms) async {
    if (_isTerminal || !mounted) return;
    final body = sms['body']?.toString() ?? '';
    if (!SmsFilterService.isFinancialTransactionSms(body)) return;

    setState(() {
      _state = _VerifyState.verifying;
      _statusMessage = ExternalData.verifyingSmsStatus;
    });

    try {
      final result = await TransactionRepository().verifyTransactionSms(
        paymentId: widget.payment.id,
        smsBody: body,
        sender: sms['sender']?.toString(),
        receivedAt: sms['timestamp']?.toString(),
      );
      if (!mounted) return;

      final status = result['status']?.toString();
      final upiRef = result['extractedUpiReference']?.toString();
      final message = result['message']?.toString();
      final verified = result['verified'] == true;

      final _VerifyState? next = !verified
          ? null
          : (status == 'SUCCESS' || status == 'CONFIRMED')
              ? _VerifyState.success
              : status == 'FAILED'
                  ? _VerifyState.failed
                  : null;

      if (next == null) {
        setState(() {
          _state = _VerifyState.waiting;
          _statusMessage = null;
        });
        return;
      }

      _stopListening();
      final isSuccess = next == _VerifyState.success;
      await ScanPaymentService.reconcile(
        widget.payment.id,
        isSuccess ? 'CONFIRMED' : 'FAILED',
        upiTransactionId: upiRef,
      );
      if (!mounted) return;
      setState(() {
        _state = next;
        _upiRef = upiRef;
        _statusMessage = message ??
            (isSuccess
                ? ExternalData.paymentVerifiedSuccess
                : ExternalData.paymentFailedBankSms);
      });
    } catch (_) {
      if (mounted && !_isTerminal) {
        setState(() {
          _state = _VerifyState.waiting;
          _statusMessage = null;
        });
      }
    }
  }

  void _cancel() {
    _stopListening();
    ScanPaymentService.reconcile(widget.payment.id, 'CANCELLED');
    Navigator.of(context).pop(false);
  }

  void _close() {
    _stopListening();
    Navigator.of(context).pop(_state == _VerifyState.success);
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s remaining';
  }

  String get _badgeText => switch (_state) {
        _VerifyState.success => 'Verified via SMS',
        _VerifyState.failed => 'Transaction Failed',
        _VerifyState.timeout => '5-minute window expired',
        _ => 'SMS verification active • $_timerText',
      };

  String get _bodyText => switch (_state) {
        _VerifyState.success => ExternalData.smsVerifiedSuccessBody,
        _VerifyState.failed =>
          _statusMessage ?? ExternalData.paymentFailedBankSms,
        _VerifyState.timeout => ExternalData.paymentTimeoutBody,
        _ => ExternalData.listeningForSmsBody,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = _styles[_state]!;
    final stateColor = style.colorResolver(colors);
    final isSuccess = _state == _VerifyState.success;
    final isTimeout = _state == _VerifyState.timeout;
    final badgeColor = isSuccess
        ? colors.success
        : (isTimeout ? colors.warning : colors.info);

    return CardDialog(
      icon: CardDialogTitleIcon(
        color: stateColor,
        child: _state == _VerifyState.verifying
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: stateColor,
                ),
              )
            : Icon(style.icon, color: stateColor, size: 20),
      ),
      title: Text(
        style.title,
        style: TextStyle(
          fontFamily: 'Google Sans',
          color: colors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 17,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PaymentSummaryLines(payment: widget.payment),
          if (_upiRef != null && _upiRef!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'UPI Ref / UTR: $_upiRef',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.info,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stateColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isSuccess
                      ? Icons.verified_rounded
                      : (isTimeout
                          ? Icons.timer_off_outlined
                          : Icons.schedule_rounded),
                  size: 16,
                  color: badgeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _badgeText,
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (isSuccess || isTimeout)
                          ? badgeColor
                          : colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _bodyText,
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
        if (!_isTerminal)
          TextButton(
            onPressed: _cancel,
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ElevatedButton(
          style: filledDialogButton(
            isSuccess
                ? colors.success
                : (_state == _VerifyState.failed ? colors.error : colors.info),
          ),
          onPressed: _close,
          child: Text(
            isSuccess ? 'Done' : (_isTerminal ? 'Dismiss' : 'Waiting...'),
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
