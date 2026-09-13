import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/screens/single_transaction_screen.dart';
import 'package:mobile/widgets/transaction_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Connection Matrix Unit Tests', () {
    test('PaymentModel toTransactionItem maps real backend fields accurately', () {
      final payment = PaymentModel(
        id: 'pay_test_12345',
        amount: 450.0,
        currency: 'INR',
        merchantName: 'Starbucks Coffee',
        upiId: 'starbucks@upi',
        paymentMethod: 'GPAY',
        status: 'CONFIRMED',
        latitude: 12.9716,
        longitude: 77.5946,
        locationAccuracyMeters: 5.0,
        createdAt: '2026-09-13T10:30:00Z',
      );

      final item = payment.toTransactionItem();

      expect(item.id, equals('pay_test_12345'));
      expect(item.title, equals('Starbucks Coffee'));
      expect(item.amount, equals('- ₹450'));
      expect(item.category, equals('GPAY'));
      expect(item.isFailed, isFalse);
      expect(item.payment, isNotNull);
      expect(item.payment?.latitude, equals(12.9716));
      expect(item.payment?.longitude, equals(77.5946));
    });

    test('PaymentModel toTransactionItem maps FAILED status correctly', () {
      final payment = PaymentModel(
        id: 'pay_failed_678',
        amount: 1200.50,
        currency: 'INR',
        merchantName: 'Nike Store',
        upiId: 'nike@upi',
        status: 'FAILED',
        createdAt: '2026-09-13T11:00:00Z',
      );

      final item = payment.toTransactionItem();

      expect(item.id, equals('pay_failed_678'));
      expect(item.category, equals('Failed'));
      expect(item.isFailed, isTrue);
      expect(item.amount, equals('₹1200.50'));
      expect(item.iconColor, equals(const Color(0xFFFF453A)));
    });

    test('PaymentModel groupPayments organizes payments into chronological groups', () {
      final now = DateTime.now();
      final todayStr = now.toIso8601String();
      final yesterdayStr = now.subtract(const Duration(days: 1)).toIso8601String();
      final earlierStr = now.subtract(const Duration(days: 5)).toIso8601String();

      final payments = [
        PaymentModel(
          id: 'p1',
          amount: 100,
          currency: 'INR',
          merchantName: 'Today Tx',
          status: 'CONFIRMED',
          createdAt: todayStr,
        ),
        PaymentModel(
          id: 'p2',
          amount: 200,
          currency: 'INR',
          merchantName: 'Yesterday Tx',
          status: 'CONFIRMED',
          createdAt: yesterdayStr,
        ),
        PaymentModel(
          id: 'p3',
          amount: 300,
          currency: 'INR',
          merchantName: 'Earlier Tx',
          status: 'CONFIRMED',
          createdAt: earlierStr,
        ),
      ];

      final groups = PaymentModel.groupPayments(payments);

      expect(groups.length, equals(3));
      expect(groups[0].title, equals('Today'));
      expect(groups[0].transactions.first.title, equals('Today Tx'));
      expect(groups[1].title, equals('Yesterday'));
      expect(groups[1].transactions.first.title, equals('Yesterday Tx'));
      expect(groups[2].title, equals('Earlier'));
      expect(groups[2].transactions.first.title, equals('Earlier Tx'));
    });

    test('UserProfile displayName generates appropriate fallback names', () {
      final p1 = UserProfile(id: '1', email: 'alex@example.com', fullName: 'Alex Mercer');
      expect(p1.displayName, equals('Alex Mercer'));

      final p2 = UserProfile(id: '2', email: 'bruce@wayne.com', firstName: 'Bruce', lastName: 'Wayne');
      expect(p2.displayName, equals('Bruce Wayne'));

      final p3 = UserProfile(id: '3', email: 'clark.kent@dailyplanet.com');
      expect(p3.displayName, equals('clark.kent'));
    });

    testWidgets('TransactionTile passes real payment and ID to SingleTransactionScreen',
        (WidgetTester tester) async {
      final payment = PaymentModel(
        id: 'real_payment_uuid_999',
        amount: 890.0,
        currency: 'INR',
        merchantName: 'Whole Foods Market',
        upiId: 'wf@icici',
        paymentMethod: 'GPAY',
        status: 'CONFIRMED',
        latitude: 13.0827,
        longitude: 80.2707,
        createdAt: DateTime.now().toIso8601String(),
      );

      final item = payment.toTransactionItem();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransactionTile(transaction: item),
          ),
        ),
      );

      expect(find.text('Whole Foods Market'), findsOneWidget);
      expect(find.text('- ₹890'), findsOneWidget);

      await tester.tap(find.byType(TransactionTile));
      await tester.pumpAndSettle();

      expect(find.byType(SingleTransactionScreen), findsOneWidget);
      expect(find.text('Paid to Whole Foods Market'), findsOneWidget);
      expect(find.text('₹890.00'), findsOneWidget);
    });
  });
}
