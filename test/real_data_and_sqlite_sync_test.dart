import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/models/dashboard_data.dart';
import 'package:hulypay/models/payment_model.dart';
import 'package:hulypay/models/user_profile.dart';
import 'package:hulypay/repositories/payment_repository.dart';
import 'package:hulypay/repositories/user_repository.dart';
import 'package:hulypay/screens/analysis_screen.dart';
import 'package:hulypay/screens/home_dashboard_screen.dart';
import 'package:hulypay/screens/transactions_screen.dart';
import 'package:hulypay/services/local_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;

  setUp(() async {
    dbService = LocalDatabaseService();
    await dbService.initDatabase(inMemory: true);
  });

  tearDown(() async {
    await dbService.close();
  });

  group('Real Data & SQLite Local Database Synchronization Tests', () {
    test('User profile metadata stores and retrieves accurately in SQLite', () async {
      final userProfile = UserProfile(
        id: 'usr_real_001',
        email: 'user@hulypay.com',
        fullName: 'Huly Real User',
        authProvider: 'google',
        active: true,
      );

      // Persist to local SQLite
      await UserRepository().saveUserProfile(userProfile);

      // Verify retrieval directly from SQLite
      final cached = await UserRepository().getCachedUserProfile();
      expect(cached, isNotNull);
      expect(cached!.fullName, equals('Huly Real User'));
      expect(cached.displayName, equals('Huly Real User'));
      expect(cached.authProvider, equals('google'));
    });

    test('SQLite Cache-First: getCachedPayments and getCachedUserProfile return instant offline data', () async {
      // Seed SQLite with a user profile and payment
      final user = UserProfile(
        id: 'user_gmail_101',
        email: 'alex.developer@gmail.com',
        fullName: 'Alex Developer',
        avatarUrl: 'https://lh3.googleusercontent.com/a/photo123',
        authProvider: 'google',
      );
      await UserRepository().saveUserProfile(user);

      final payment = PaymentModel(
        id: 'pay_real_999',
        amount: 850.50,
        currency: 'INR',
        merchantName: 'Starbucks Coffee',
        status: 'CONFIRMED',
        createdAt: DateTime.now().toIso8601String(),
      );
      await LocalDatabaseService().upsertPayment(payment);

      // Verify cache-first instant retrieval without network
      final cachedProfile = await UserRepository().getCachedUserProfile();
      expect(cachedProfile, isNotNull);
      expect(cachedProfile!.email, equals('alex.developer@gmail.com'));
      expect(cachedProfile.displayName, equals('Alex Developer'));

      final cachedPayments = await PaymentRepository().getCachedPayments();
      expect(cachedPayments.length, equals(1));
      expect(cachedPayments.first.merchantName, equals('Starbucks Coffee'));
      expect(cachedPayments.first.amount, equals(850.50));
    });

    testWidgets('HomeDashboardScreen displays clean empty state when no transactions exist', (tester) async {
      // Build HomeDashboardScreen with empty initial data
      const emptyData = DashboardData(
        greeting: 'Good Morning,',
        userName: 'Alex Developer',
        avatarUrl: '',
        totalSpentFormatted: '₹0',
        changePercent: 0,
        changePeriodLabel: 'this month',
        weeklySpending: [
          SpendingBarData(day: 'M', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'T', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'W', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'T', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'F', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'S', height: 4, color: Color(0xFF26262B)),
          SpendingBarData(day: 'S', height: 4, color: Color(0xFF26262B)),
        ],
        recentTransactions: [],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeDashboardScreen(initialData: emptyData),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dummy data is NOT shown
      expect(find.text('₹12,480'), findsNothing);
      expect(find.text('Swiggy'), findsNothing);
      expect(find.text('Amazon'), findsNothing);

      // Verify real empty metrics and state
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('Alex Developer'), findsNothing);
      expect(find.text('Recent Transactions'), findsNothing);
    });

    testWidgets('TransactionsScreen displays clean empty state when transactions list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TransactionsScreen(initialGroups: []),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dummy mock transactions are NOT displayed
      expect(find.text('CRED'), findsNothing);
      expect(find.text('Zomato'), findsNothing);
      expect(find.text('Airtel Fiber'), findsNothing);

      // Verify empty state container
      expect(find.text('No transactions found'), findsOneWidget);
      expect(find.text('Transactions will appear here once you make payments.'), findsOneWidget);
    });

    testWidgets('AnalysisScreen displays ₹0 and empty spending message when no categories exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AnalysisScreen(
            initialCategories: [],
            totalSpent: '₹0',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify dummy mock categories are NOT displayed
      expect(find.text('Food & Dining'), findsNothing);
      expect(find.text('Shopping'), findsNothing);
      expect(find.text('₹12,480'), findsNothing);

      // Verify clean zero state
      expect(find.text('₹0'), findsOneWidget);
      expect(find.text('No spending data yet'), findsOneWidget);
      expect(find.text('Categorized insights will appear here as you spend.'), findsOneWidget);
    });
  });
}
