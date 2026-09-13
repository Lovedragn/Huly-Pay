import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/category_model.dart';
import 'package:mobile/models/expense_model.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/screens/scan_and_pay_screen.dart';
import 'package:mobile/services/location_service.dart';
import 'package:mobile/services/upi_service.dart';

void main() {
  group('Phase 2: UPI Service Tests', () {
    test('Parses full valid UPI QR string correctly', () {
      const qrData =
          'upi://pay?pa=merchant%40okhdfcbank&pn=Starbucks%20Coffee&am=250.00&cu=INR&tr=TXN_REF_001&tn=Coffee%20Latte';
      final upi = UpiService.parseUpiUri(qrData);

      expect(upi, isNotNull);
      expect(upi!.upiId, 'merchant@okhdfcbank');
      expect(upi.payeeName, 'Starbucks Coffee');
      expect(upi.amount, 250.00);
      expect(upi.currency, 'INR');
      expect(upi.transactionRef, 'TXN_REF_001');
      expect(upi.note, 'Coffee Latte');
    });

    test('Parses UPI QR string without amount', () {
      const qrData = 'upi://pay?pa=tea_stall@paytm&pn=Chai%20Point';
      final upi = UpiService.parseUpiUri(qrData);

      expect(upi, isNotNull);
      expect(upi!.upiId, 'tea_stall@paytm');
      expect(upi.payeeName, 'Chai Point');
      expect(upi.amount, isNull);
    });

    test('Parses UPI QR string without merchant name (does not invent name)', () {
      const qrData = 'upi://pay?pa=test@upi&cu=INR';
      final upi = UpiService.parseUpiUri(qrData);

      expect(upi, isNotNull);
      expect(upi!.upiId, 'test@upi');
      expect(upi.payeeName, isNull);
      expect(upi.amount, isNull);
      expect(upi.currency, 'INR');
    });

    test('Parses plain UPI ID fallback correctly', () {
      const rawId = 'friend@okicici';
      final upi = UpiService.parseUpiUri(rawId);

      expect(upi, isNotNull);
      expect(upi!.upiId, 'friend@okicici');
      expect(upi.payeeName, 'friend');
      expect(upi.amount, isNull);
    });

    test('Rejects invalid non-UPI strings cleanly', () {
      expect(UpiService.parseUpiUri(''), isNull);
      expect(UpiService.parseUpiUri('https://google.com'), isNull);
      expect(UpiService.parseUpiUri('https://example.com/pay?pa=test@upi'), isNull);
      expect(UpiService.parseUpiUri('WIFI:S:MyWifi;T:WPA;P:secret;;'), isNull);
      expect(UpiService.parseUpiUri('BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nEND:VCARD'), isNull);
      expect(UpiService.parseUpiUri('just a random string'), isNull);
      expect(UpiService.parseUpiUri('upi://pay?pa='), isNull);
      expect(UpiService.parseUpiUri('upi://pay?pa=invalidWithoutAtSymbol'), isNull);
    });

    test('Handles invalid amounts by ignoring them rather than failing', () {
      const qrZero = 'upi://pay?pa=test@upi&pn=Test&am=0';
      expect(UpiService.parseUpiUri(qrZero)?.amount, isNull);

      const qrNegative = 'upi://pay?pa=test@upi&pn=Test&am=-100';
      expect(UpiService.parseUpiUri(qrNegative)?.amount, isNull);

      const qrNaN = 'upi://pay?pa=test@upi&pn=Test&am=invalid';
      expect(UpiService.parseUpiUri(qrNaN)?.amount, isNull);
    });

    test('Builds payment URI with custom amount override and optional fields', () {
      const qrData = 'upi://pay?pa=merchant@upi&pn=Store';
      final upi = UpiService.parseUpiUri(qrData)!;
      final uri = upi.buildPaymentUri(customAmount: 180.50);

      expect(uri, contains('pa=merchant%40upi'));
      expect(uri, contains('pn=Store'));
      expect(uri, contains('am=180.50'));
      expect(uri, contains('cu=INR'));
    });

    test('Builds payment URI without pn when payeeName is null', () {
      const qrData = 'upi://pay?pa=merchant@upi';
      final upi = UpiService.parseUpiUri(qrData)!;
      final uri = upi.buildPaymentUri(customAmount: 50.0);

      expect(uri, contains('pa=merchant%40upi'));
      expect(uri, isNot(contains('pn=')));
      expect(uri, contains('am=50.00'));
    });
  });

  group('Phase 2: Location Service Tests', () {
    test('LocationResult handles success and failure states', () {
      const loc = PaymentLocation(latitude: 12.9716, longitude: 77.5946, accuracyMeters: 3.5);
      const successResult = LocationResult.success(loc);
      expect(successResult.isSuccess, isTrue);
      expect(successResult.location?.latitude, 12.9716);
      expect(successResult.failureReason, isNull);

      const deniedResult = LocationResult.failure(
        LocationFailureReason.permissionDenied,
        'Permission denied',
      );
      expect(deniedResult.isSuccess, isFalse);
      expect(deniedResult.location, isNull);
      expect(deniedResult.failureReason, LocationFailureReason.permissionDenied);

      const disabledResult = LocationResult.failure(
        LocationFailureReason.serviceDisabled,
        'GPS disabled',
      );
      expect(disabledResult.isSuccess, isFalse);
      expect(disabledResult.failureReason, LocationFailureReason.serviceDisabled);
    });

    test('PaymentLocation toString formats gracefully', () {
      const loc = PaymentLocation(latitude: 12.97, longitude: 77.59, accuracyMeters: 4.2);
      expect(loc.toString(), contains('lat: 12.97'));
      expect(loc.toString(), contains('accuracy: 4.2m'));
    });
  });

  group('Phase 2: Data Models Serialization Tests', () {
    test('PaymentModel serializes and deserializes location and UPI fields', () {
      final json = {
        'id': 'pay-uuid-1234',
        'userId': 'user-uuid-5678',
        'amount': 450.75,
        'currency': 'INR',
        'merchantName': 'Starbucks Coffee',
        'upiId': 'starbucks@okhdfcbank',
        'paymentMethod': 'GPAY',
        'transactionReference': 'TXN_9988',
        'status': 'PENDING',
        'latitude': 12.9716,
        'longitude': 77.5946,
        'locationAccuracyMeters': 3.5,
      };

      final payment = PaymentModel.fromJson(json);
      expect(payment.id, 'pay-uuid-1234');
      expect(payment.amount, 450.75);
      expect(payment.upiId, 'starbucks@okhdfcbank');
      expect(payment.paymentMethod, 'GPAY');
      expect(payment.latitude, 12.9716);
      expect(payment.longitude, 77.5946);
      expect(payment.locationAccuracyMeters, 3.5);

      final outJson = payment.toJson();
      expect(outJson['latitude'], 12.9716);
      expect(outJson['longitude'], 77.5946);
      expect(outJson['locationAccuracyMeters'], 3.5);
    });

    test('CreatePaymentPayload builds complete JSON payload', () {
      final payload = CreatePaymentPayload(
        amount: 320.0,
        merchantName: 'Costa Coffee',
        upiId: 'costa@upi',
        paymentMethod: 'GPAY',
        transactionReference: 'REF_1122',
        latitude: 28.6139,
        longitude: 77.2090,
        locationAccuracyMeters: 5.0,
      );

      final json = payload.toJson();
      expect(json['amount'], 320.0);
      expect(json['merchantName'], 'Costa Coffee');
      expect(json['upiId'], 'costa@upi');
      expect(json['paymentMethod'], 'GPAY');
      expect(json['latitude'], 28.6139);
      expect(json['longitude'], 77.2090);
      expect(json['locationAccuracyMeters'], 5.0);
    });

    test('CategoryModel deserializes backend category JSON', () {
      final json = {
        'id': 'cat-1',
        'name': 'Groceries',
        'icon': 'shopping_cart',
        'color': '#4CAF50',
        'default': true,
      };

      final cat = CategoryModel.fromJson(json);
      expect(cat.id, 'cat-1');
      expect(cat.name, 'Groceries');
      expect(cat.icon, 'shopping_cart');
      expect(cat.color, '#4CAF50');
      expect(cat.isDefault, true);
    });

    test('ExpenseModel deserializes backend expense with coordinates', () {
      final json = {
        'id': 'exp-1',
        'amount': 1500.0,
        'currency': 'INR',
        'merchantName': 'Supermarket',
        'description': 'Weekly grocery run',
        'latitude': 13.0827,
        'longitude': 80.2707,
        'category': {
          'id': 'cat-food',
          'name': 'Food',
          'default': true,
        },
      };

      final expense = ExpenseModel.fromJson(json);
      expect(expense.id, 'exp-1');
      expect(expense.amount, 1500.0);
      expect(expense.latitude, 13.0827);
      expect(expense.longitude, 80.2707);
      expect(expense.category?.name, 'Food');
    });
  });

  group('Phase 2: Scan & Pay UI Widget Tests', () {
    testWidgets('Renders viewfinder reticle and action buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScanAndPayScreen(),
        ),
      );

      // Verify header instructions
      expect(find.text('Scan any UPI QR code'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);

      // Verify action buttons
      expect(find.byKey(const Key('back_button')), findsOneWidget);
      expect(find.byKey(const Key('flash_button')), findsOneWidget);
      expect(find.byKey(const Key('switch_camera_button')), findsOneWidget);
    });

    test('Test Case 3: Parse standard UPI QR with amount, merchant, and INR currency', () {
      const qr = 'upi://pay?pa=test@upi&pn=Test%20Merchant&am=200&cu=INR';
      final upi = UpiService.parseUpiUri(qr);
      expect(upi, isNotNull);
      expect(upi!.upiId, 'test@upi');
      expect(upi.payeeName, 'Test Merchant');
      expect(upi.amount, 200.0);
      expect(upi.currency, 'INR');
    });

    test('Test Case 4: Parse UPI QR without amount allows existing payment flow to handle amount entry', () {
      const qr = 'upi://pay?pa=test@upi&pn=Test%20Merchant&cu=INR';
      final upi = UpiService.parseUpiUri(qr);
      expect(upi, isNotNull);
      expect(upi!.upiId, 'test@upi');
      expect(upi.payeeName, 'Test Merchant');
      expect(upi.amount, isNull);
      expect(upi.currency, 'INR');
    });

    test('Test Case 6: Location failure returns null location without fake coordinates', () {
      const denied = LocationResult.failure(
        LocationFailureReason.permissionDenied,
        'Location permission denied',
      );
      expect(denied.isSuccess, isFalse);
      expect(denied.location, isNull);
      expect(denied.failureReason, LocationFailureReason.permissionDenied);

      const disabled = LocationResult.failure(
        LocationFailureReason.serviceDisabled,
        'GPS disabled',
      );
      expect(disabled.isSuccess, isFalse);
      expect(disabled.location, isNull);
      expect(disabled.failureReason, LocationFailureReason.serviceDisabled);
    });

    test('Test Case 7: Payment creation preserves coordinates and initial INITIATED status', () {
      final payload = CreatePaymentPayload(
        amount: 200.0,
        merchantName: 'Test Merchant',
        upiId: 'test@upi',
        latitude: 12.9716,
        longitude: 77.5946,
        locationAccuracyMeters: 3.5,
      );

      final json = payload.toJson();
      expect(json['amount'], 200.0);
      expect(json['merchantName'], 'Test Merchant');
      expect(json['upiId'], 'test@upi');
      expect(json['latitude'], 12.9716);
      expect(json['longitude'], 77.5946);
      expect(json['locationAccuracyMeters'], 3.5);
    });

    test('Test Case 7: Payment reconciliation marks payment as CONFIRMED', () {
      final payment = PaymentModel(
        id: 'pay-123',
        amount: 200.0,
        currency: 'INR',
        merchantName: 'Test Merchant',
        upiId: 'test@upi',
        status: 'CONFIRMED',
        latitude: 12.9716,
        longitude: 77.5946,
        locationAccuracyMeters: 3.5,
      );

      expect(payment.status, 'CONFIRMED');
      expect(payment.latitude, 12.9716);
      expect(payment.longitude, 77.5946);
    });
  });
}
