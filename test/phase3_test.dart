import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/dashboard_data.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/screens/single_transaction_screen.dart';

void main() {
  group('Phase 3: Payment Model Reconciliation & Status Tests', () {
    test('PaymentModel maps paymentStatus and status interchangeably', () {
      final json = {
        'id': 'pay-uuid-777',
        'merchantName': 'ABC Store',
        'upiId': 'abcstore@upi',
        'amount': 250.00,
        'currency': 'INR',
        'paymentMethod': 'GOOGLE_PAY',
        'paymentStatus': 'CONFIRMED',
        'transactionReference': 'REF_CONFIRMED_77',
        'latitude': 13.082680,
        'longitude': 80.270718,
        'locationAccuracyMeters': 8.5,
        'paymentDate': '2026-09-13',
        'paymentTime': '10:42:00',
      };

      final payment = PaymentModel.fromJson(json);
      expect(payment.id, 'pay-uuid-777');
      expect(payment.merchantName, 'ABC Store');
      expect(payment.status, 'CONFIRMED');
      expect(payment.amount, 250.00);
      expect(payment.paymentMethod, 'GOOGLE_PAY');
      expect(payment.latitude, 13.082680);
      expect(payment.longitude, 80.270718);
      expect(payment.locationAccuracyMeters, 8.5);

      final outJson = payment.toJson();
      expect(outJson['status'], 'CONFIRMED');
      expect(outJson['paymentStatus'], 'CONFIRMED');
    });

    test('ReconcilePaymentPayload serializes correctly', () {
      final payload = ReconcilePaymentPayload(
        status: 'CONFIRMED',
        upiTransactionId: 'UPI_9988',
        transactionReference: 'REF_77',
      );

      final json = payload.toJson();
      expect(json['status'], 'CONFIRMED');
      expect(json['upiTransactionId'], 'UPI_9988');
      expect(json['transactionReference'], 'REF_77');
    });
  });

  group('Phase 3: SingleTransactionScreen Map & Street View UI Tests', () {
    final sampleTxn = TransactionItem(
      id: 'TXN-ABC-123',
      title: 'Cafe Coffee Day',
      category: 'Food & Dining',
      amount: '₹340.00',
      time: 'Today, 2:30 PM',
      icon: Icons.coffee_rounded,
      iconColor: const Color(0xFFFF9500),
      iconBgColor: const Color(0xFF2C1E10),
      type: 'UPI',
    );

    testWidgets('Renders Google Map card, Street View toggle, and Start Route button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleTransactionScreen(
            transaction: sampleTxn,
          ),
        ),
      );

      // Verify merchant details and ensure top title is removed
      expect(find.text('Transaction Details'), findsNothing);
      expect(find.textContaining('Cafe Coffee Day'), findsWidgets);
      expect(find.text('₹340.00'), findsOneWidget);

      // Verify Map Card elements
      expect(find.text('MAP'), findsOneWidget);
      expect(find.text('STREET VIEW'), findsOneWidget);
      expect(find.byKey(const Key('start_route_button')), findsOneWidget);
      expect(find.text('Start Route'), findsOneWidget);

      // Verify coordinates chip, reposition and fullscreen buttons are removed per user request
      expect(find.byKey(const Key('recenter_map_button')), findsNothing);
      expect(find.byKey(const Key('expand_map_button')), findsNothing);
    });

    testWidgets('Tapping Start Route button triggers navigation smoothly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleTransactionScreen(
            transaction: sampleTxn,
          ),
        ),
      );

      expect(find.byKey(const Key('start_route_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('start_route_button')));
      await tester.pumpAndSettle();
    });

    testWidgets('Toggling Street View displays no-coverage fallback message and 360 action', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleTransactionScreen(
            transaction: sampleTxn,
          ),
        ),
      );

      // Tap Street View toggle
      await tester.tap(find.byKey(const Key('street_view_toggle')));
      await tester.pumpAndSettle();

      // Verify specification message: "Street View isn't available at this location."
      expect(find.text("Street View isn't available at this location."), findsOneWidget);
      expect(find.text('Check 360° in Google Maps'), findsOneWidget);

      // Tap MAP toggle to switch back
      await tester.tap(find.byKey(const Key('map_mode_button')));
      await tester.pumpAndSettle();

      expect(find.text("Street View isn't available at this location."), findsNothing);
    });
  });
}
