import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/models/dashboard_data.dart';
import 'package:hulypay/models/payment_model.dart';
import 'package:hulypay/screens/analysis_screen.dart';
import 'package:hulypay/screens/single_transaction_screen.dart';
import 'package:hulypay/screens/transactions_screen.dart';
import 'package:hulypay/services/local_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    LocalDatabaseService().setTestMode(true);
    await LocalDatabaseService().initDatabase(inMemory: true);
  });

  tearDown(() async {
    try {
      await LocalDatabaseService().clearAll();
      await LocalDatabaseService().close();
    } catch (_) {}
  });

  const sampleTx = TransactionItem(
    id: 'tx_categorize_test_1',
    title: 'Starbucks Coffee',
    category: 'UPI',
    amount: '- ₹450',
    time: '02:30 PM',
    icon: Icons.restaurant_rounded,
    iconColor: Color(0xFFFF9500),
    iconBgColor: Color(0xFF2C2014),
    isIncome: false,
    type: 'Expense',
  );

  testWidgets('SingleTransactionScreen displays Category button and allows categorizing payment',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: SingleTransactionScreen(
          transaction: sampleTx,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Category quick action button is displayed
    expect(find.text('Category'), findsWidgets);

    // 2. Open Category Picker Bottom Sheet by tapping Category action button
    final categoryBtn = find.widgetWithText(Material, 'Category').first;
    await tester.ensureVisible(categoryBtn);
    await tester.pumpAndSettle();
    await tester.tap(categoryBtn);
    await tester.pumpAndSettle();

    // 3. Verify modal bottom sheet has header and categories list
    expect(find.text('Categorize Payment'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Transportation'), findsOneWidget);
    expect(find.text('Bills & Utilities'), findsOneWidget);

    // 4. Select 'Food & Dining' category
    final foodItem = find.text('Food & Dining');
    await tester.ensureVisible(foodItem);
    await tester.tap(foodItem);
    await tester.pump(); // trigger frame for tap and dismiss sheet
    await tester.pump(const Duration(milliseconds: 100)); // snackbar appears

    // 5. Verify modal dismissed and category is updated in UI
    expect(find.text('Food & Dining'), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Categorize Payment'), findsNothing);

    // 6. Test tapping category row directly in transaction details
    final editCategoryRow = find.text('Food & Dining');
    await tester.tap(editCategoryRow.first);
    await tester.pumpAndSettle();

    // 7. Verify category picker sheet re-opens
    expect(find.text('Categorize Payment'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // 8. Select 'Shopping'
    final shoppingItem = find.text('Shopping');
    await tester.ensureVisible(shoppingItem);
    await tester.tap(shoppingItem);
    await tester.pumpAndSettle();

    expect(find.text('Categorize Payment'), findsNothing);
    expect(find.text('Shopping'), findsWidgets);

    // Let sqflite lock release timers settle
    await tester.pump(const Duration(seconds: 15));
  });

  testWidgets('TransactionsScreen displays custom category and reflects update',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final payment = PaymentModel(
      id: 'pay_cat_sync_test_99',
      amount: 450.0,
      currency: 'INR',
      merchantName: 'Starbucks Coffee',
      status: 'CONFIRMED',
      paymentMethod: 'UPI',
      createdAt: DateTime.now().toIso8601String(),
    );

    final groups = PaymentModel.groupPayments(
      [payment],
      {'pay_cat_sync_test_99': 'Food & Dining'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionsScreen(initialGroups: groups),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify transaction appears with custom category 'Food & Dining'
    expect(find.text('Starbucks Coffee'), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);

    // Tap into SingleTransactionScreen
    await tester.tap(find.text('Starbucks Coffee'));
    await tester.pumpAndSettle();

    expect(find.byType(SingleTransactionScreen), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Food & Dining'), findsOneWidget);
  });

  testWidgets('AnalysisScreen circular toggle button switches between payments and category classification',
      (WidgetTester tester) async {
    final now = DateTime.now().toIso8601String();
    final p1 = PaymentModel(
      id: 'p1',
      amount: 350.0,
      currency: 'INR',
      merchantName: 'Swiggy',
      paymentMethod: 'UPI',
      status: 'CONFIRMED',
      createdAt: now,
    );
    final p2 = PaymentModel(
      id: 'p2',
      amount: 1200.0,
      currency: 'INR',
      merchantName: 'Amazon',
      paymentMethod: 'UPI',
      status: 'CONFIRMED',
      createdAt: now,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnalysisScreen(
            initialPayments: [p1, p2],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Default mode: byMerchant -> displays 'Swiggy' and 'Amazon'
    expect(find.text('Swiggy'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);
    expect(find.text('Food & Dining'), findsNothing);
    expect(find.text('Shopping'), findsNothing);

    // Find circular toggle button
    final toggleBtn = find.byKey(const Key('analysis_classification_toggle_button'));
    expect(toggleBtn, findsOneWidget);

    // Tap circular toggle button to switch to Category mode
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    // Now in byCategory mode -> displays 'Food & Dining' and 'Shopping'
    expect(find.text('Food & Dining'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);

    // Tap circular toggle button again to switch back to Merchant mode
    await tester.tap(toggleBtn);
    await tester.pumpAndSettle();

    expect(find.text('Swiggy'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);

    // Flush any pending sqflite transaction lock warning timers
    await tester.pump(const Duration(seconds: 11));
  });
}
