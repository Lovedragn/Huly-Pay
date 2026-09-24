import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/services/sms_filter_service.dart';

void main() {
  group('SmsFilterService Tests', () {
    test('identifies debit banking SMS as financial transaction', () {
      const sms = 'Dear Customer, Rs.500.00 has been debited from account **1234 to VPA merchant@okaxis. UPI Ref: 425612345678.';
      expect(SmsFilterService.isFinancialTransactionSms(sms), isTrue);
    });

    test('identifies UPI payment SMS as financial transaction', () {
      const sms = 'Paid Rs 250 to Chai Point via UPI. Txn ref 123456789.';
      expect(SmsFilterService.isFinancialTransactionSms(sms), isTrue);
    });

    test('identifies failed transaction SMS as financial transaction', () {
      const sms = 'UPI payment of INR 199.00 failed due to bank timeout.';
      expect(SmsFilterService.isFinancialTransactionSms(sms), isTrue);
    });

    test('rejects pure OTP messages without transaction keywords', () {
      const sms = 'Your OTP for login is 894512. Do not share this one time password with anyone.';
      expect(SmsFilterService.isFinancialTransactionSms(sms), isFalse);
    });

    test('rejects promotional and spam messages', () {
      const sms = 'Congratulations! You won 50% discount on your next ride. Tap here to claim.';
      expect(SmsFilterService.isFinancialTransactionSms(sms), isFalse);
    });

    test('rejects null and empty messages', () {
      expect(SmsFilterService.isFinancialTransactionSms(null), isFalse);
      expect(SmsFilterService.isFinancialTransactionSms(''), isFalse);
      expect(SmsFilterService.isFinancialTransactionSms('   '), isFalse);
    });
  });
}
