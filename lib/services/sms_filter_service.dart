class SmsFilterService {
  static const List<String> financialKeywords = [
    'debited',
    'credited',
    'paid',
    'payment',
    'upi',
    'transaction',
    'txn',
    'rs',
    'rs.',
    'inr',
    'reference',
    'utr',
    'vpa',
  ];

  /// Returns true if the SMS text contains keywords characteristic of a bank or UPI transaction alert.
  /// Rejects messages that are strictly OTPs without transaction references.
  static bool isFinancialTransactionSms(String? smsBody) {
    if (smsBody == null || smsBody.trim().isEmpty) {
      return false;
    }

    final lower = smsBody.toLowerCase();

    // Check if it contains at least one financial keyword
    bool hasFinancialKeyword = false;
    for (final kw in financialKeywords) {
      if (lower.contains(kw)) {
        hasFinancialKeyword = true;
        break;
      }
    }

    if (!hasFinancialKeyword) {
      return false;
    }

    // Pure OTP filter: if message contains 'otp' or 'one time password' or 'verification code'
    // but DOES NOT contain 'debited', 'paid', 'sent', or 'deducted', ignore it.
    final bool isOtpLike = lower.contains('otp') ||
        lower.contains('one time password') ||
        lower.contains('verification code') ||
        lower.contains('security code');

    final bool isDebitOrPaid = lower.contains('debited') ||
        lower.contains('paid') ||
        lower.contains('sent') ||
        lower.contains('deducted') ||
        lower.contains('failed');

    if (isOtpLike && !isDebitOrPaid) {
      return false;
    }

    return true;
  }
}
