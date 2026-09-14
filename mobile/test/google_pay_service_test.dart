import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/google_pay_service.dart';
import 'package:mobile/services/upi_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GooglePayResult parsing tests', () {
    test('Correctly parses tezResponse JSON from Google Pay India', () {
      final nativeMap = {
        'resultCode': -1, // Activity.RESULT_OK
        'isOk': true,
        'isCanceled': false,
        'tezResponse': '{"Status":"SUCCESS","txnId":"TXN-123456","responseCode":"00","txnRef":"REF-789","amount":"250.00","toVpa":"merchant@okaxis"}',
      };

      final result = GooglePayResult.fromNativeMap(nativeMap);
      expect(result.status, GooglePayStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.upiTransactionId, 'TXN-123456');
      expect(result.transactionReference, 'REF-789');
      expect(result.responseCode, '00');
      expect(result.payeeVpa, 'merchant@okaxis');
      expect(result.amount, 250.0);
      expect(result.tezResponse?['toVpa'], 'merchant@okaxis');
    });

    test('Correctly handles user cancellation', () {
      final nativeMap = {
        'resultCode': 0, // Activity.RESULT_CANCELED
        'isOk': false,
        'isCanceled': true,
      };

      final result = GooglePayResult.fromNativeMap(nativeMap);
      expect(result.status, GooglePayStatus.userCancelled);
      expect(result.isCancelled, isTrue);
      expect(result.isSuccess, isFalse);
    });

    test('Correctly parses fallback query-string UPI response format', () {
      final nativeMap = {
        'resultCode': -1,
        'isOk': true,
        'isCanceled': false,
        'response': 'txnId=UPI-987654&responseCode=00&Status=SUCCESS&txnRef=REF-111&ApprovalRefNo=APP-999&toVpa=vendor@upi&amount=100.50',
      };

      final result = GooglePayResult.fromNativeMap(nativeMap);
      expect(result.status, GooglePayStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.upiTransactionId, 'UPI-987654');
      expect(result.transactionReference, 'REF-111');
      expect(result.approvalRefNo, 'APP-999');
      expect(result.responseCode, '00');
      expect(result.payeeVpa, 'vendor@upi');
      expect(result.amount, 100.50);
    });

    test('Correctly parses raw URI query string via fromQueryString', () {
      final result = GooglePayResult.fromQueryString(
        'upi://pay?Status=SUCCESS&txnId=UPI-333&responseCode=00&txnRef=REF-333&toVpa=merchant@icici&amount=75.0',
      );
      expect(result.status, GooglePayStatus.success);
      expect(result.upiTransactionId, 'UPI-333');
      expect(result.payeeVpa, 'merchant@icici');
      expect(result.amount, 75.0);
    });

    test('Correctly parses SUBMITTED status and processUpiResponse', () {
      final result = GooglePayService.processUpiResponse(
        'txnId=TXN-PENDING&Status=SUBMITTED&responseCode=01&txnRef=REF-999&toVpa=bank@upi',
      );
      expect(result.status, GooglePayStatus.submitted);
      expect(result.isSubmitted, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.upiTransactionId, 'TXN-PENDING');
      expect(result.payeeVpa, 'bank@upi');
    });

    test('Correctly identifies failure status', () {
      final nativeMap = {
        'resultCode': -1,
        'isOk': true,
        'isCanceled': false,
        'tezResponse': '{"Status":"FAILURE","txnId":"TXN-ERR","responseCode":"ZM"}',
      };

      final result = GooglePayResult.fromNativeMap(nativeMap);
      expect(result.status, GooglePayStatus.failure);
      expect(result.isFailure, isTrue);
      expect(result.isSuccess, isFalse);
      expect(result.responseCode, 'ZM');
    });
  });

  group('GooglePayService MethodChannel mock tests', () {
    const channel = MethodChannel('com.hulypay.app/google_pay');

    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'isReadyToPay') {
          return true;
        } else if (methodCall.method == 'launchGooglePay') {
          return {
            'resultCode': -1,
            'isOk': true,
            'isCanceled': false,
            'tezResponse': '{"Status":"SUCCESS","txnId":"TXN-TEST-001","responseCode":"00","txnRef":"REF-TEST"}',
          };
        }
        return null;
      });
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('isReadyToPay queries channel properly', () async {
      final ready = await GooglePayService.isReadyToPay();
      expect(ready, isTrue);
    });

    test('payWithGooglePay returns valid GooglePayResult from mock', () async {
      final paymentData = UpiPaymentData(
        rawUri: 'upi://pay?pa=merchant@okaxis&pn=Shop',
        upiId: 'merchant@okaxis',
        payeeName: 'Shop',
        amount: 50.0,
      );

      final result = await GooglePayService.payWithGooglePay(
        paymentData: paymentData,
        customAmount: 50.0,
      );

      expect(result.status, GooglePayStatus.success);
      expect(result.isSuccess, isTrue);
      expect(result.upiTransactionId, 'TXN-TEST-001');
    });
  });
}
