import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/models/payment_model.dart';
import 'package:hulypay/services/local_database_service.dart';
import 'package:hulypay/services/user_preferences_service.dart';
import 'package:hulypay/widgets/home_today_spend_gauge.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late LocalDatabaseService dbService;

  setUp(() async {
    dbService = LocalDatabaseService();
    dbService.setTestMode(true);
    await dbService.initDatabase(inMemory: true);
    await UserPreferencesService().saveDailyLimit(5000.0);
  });

  tearDown(() async {
    await dbService.clearAll();
    await UserPreferencesService().saveDailyLimit(5000.0);
  });

  group('Daily Limit Chart & Real Data Fetching Tests', () {
    testWidgets('Reconciles UTC server timestamps with local timezone for today spend', (tester) async {
      final nowUtc = DateTime.now().toUtc();
      final nowUtcStr = nowUtc.toIso8601String();

      final payments = [
        PaymentModel(
          id: 'pay_utc_1',
          amount: 1200.0,
          currency: 'INR',
          status: 'CONFIRMED',
          createdAt: nowUtcStr,
        ),
        PaymentModel(
          id: 'pay_utc_2',
          amount: 800.0,
          currency: 'INR',
          status: 'SUCCESS',
          createdAt: nowUtcStr,
        ),
        PaymentModel(
          id: 'pay_yesterday',
          amount: 5000.0,
          currency: 'INR',
          status: 'CONFIRMED',
          createdAt: DateTime.now().toUtc().subtract(const Duration(days: 2)).toIso8601String(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: payments,
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Daily Limit"), findsOneWidget);
      expect(find.text('₹2000'), findsOneWidget);
      expect(find.text('Within Budget'), findsOneWidget);
      expect(find.text('₹3000 left of ₹5000'), findsOneWidget);
    });

    testWidgets('Handles paymentDate fallback and diverse successful statuses', (tester) async {
      final now = DateTime.now();
      final todayDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final payments = [
        PaymentModel(
          id: 'p_completed',
          amount: 500.0,
          currency: 'INR',
          status: 'COMPLETED',
          paymentDate: todayDateStr,
        ),
        PaymentModel(
          id: 'p_paid',
          amount: 700.0,
          currency: 'INR',
          status: 'PAID',
          createdAt: todayDateStr,
        ),
        PaymentModel(
          id: 'p_failed',
          amount: 9999.0,
          currency: 'INR',
          status: 'FAILED',
          paymentDate: todayDateStr,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: payments,
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹1200'), findsOneWidget);
      expect(find.text('Within Budget'), findsOneWidget);
      expect(find.text('₹3800 left of ₹5000'), findsOneWidget);
    });

    testWidgets('Transitions properly to Limit Exceeded when spend exceeds max limit', (tester) async {
      final nowStr = DateTime.now().toIso8601String();

      final payments = [
        PaymentModel(
          id: 'p_heavy',
          amount: 6500.0,
          currency: 'INR',
          status: 'CONFIRMED',
          createdAt: nowStr,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: payments,
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹6500'), findsOneWidget);
      expect(find.text('Limit Exceeded'), findsOneWidget);
      expect(find.text('₹1500 over limit'), findsOneWidget);
    });

    testWidgets('Transitions properly to Near Limit when spend is between 80% and 100%', (tester) async {
      final nowStr = DateTime.now().toIso8601String();

      final payments = [
        PaymentModel(
          id: 'p_near',
          amount: 4200.0,
          currency: 'INR',
          status: 'CONFIRMED',
          createdAt: nowStr,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: payments,
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('₹4200'), findsOneWidget);
      expect(find.text('Near Limit'), findsOneWidget);
      expect(find.text('₹800 left of ₹5000'), findsOneWidget);
    });

    testWidgets('Persists custom daily limit in UserPreferencesService and updates UI', (tester) async {
      double savedLimit = 5000.0;
      await tester.runAsync(() async {
        await UserPreferencesService().saveDailyLimit(10000.0);
        savedLimit = await UserPreferencesService().getDailyLimit();
        expect(savedLimit, equals(10000.0));
      });

      final nowStr = DateTime.now().toIso8601String();
      final payments = [
        PaymentModel(
          id: 'p_custom',
          amount: 6000.0,
          currency: 'INR',
          status: 'CONFIRMED',
          createdAt: nowStr,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: payments,
              dailyBudget: savedLimit,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With 10000 limit, 6000 is 60% -> Moderate Spend (not Limit Exceeded)
      expect(find.text('₹6000'), findsOneWidget);
      expect(find.text('Moderate Spend'), findsOneWidget);
      expect(find.text('₹4000 left of ₹10000'), findsOneWidget);
    });

    testWidgets('Tapping daily limit pill opens Set Daily Spending Limit bottom sheet', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeTodaySpendGaugeChart(
              payments: [],
              dailyBudget: 5000.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Daily Limit"), findsOneWidget);
      expect(find.text("₹5000"), findsOneWidget);

      // Tap on the daily limit header pill
      await tester.tap(find.text("Daily Limit"));
      await tester.pumpAndSettle();

      // Verify modal sheet is displayed with preset chips
      expect(find.text('Set Daily Spending Limit'), findsOneWidget);
      expect(find.text('₹2000'), findsOneWidget);
      expect(find.text('₹10000'), findsOneWidget);
      expect(find.text('₹25000'), findsOneWidget);
      expect(find.text('Save Limit'), findsOneWidget);
    });
  });
}
