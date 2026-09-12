import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';
import 'package:mobile/screens/scan_and_pay_screen.dart';
import 'package:mobile/screens/transactions_screen.dart';
import 'package:mobile/widgets/action_button.dart';
import 'package:mobile/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('HomeDashboardScreen and CustomBottomNavBar smoke test',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HulyPayApp());

    // Verify key elements from the dashboard mockup are present.
    expect(find.text('Good Morning,'), findsOneWidget);
    expect(find.text('Sujith'), findsOneWidget);
    expect(find.text('TOTAL SPENT'), findsOneWidget);
    expect(find.text('₹12,480'), findsOneWidget);

    // Verify quick action buttons
    expect(find.byType(QuickActionButton), findsNWidgets(3));
    expect(find.text('upload'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);

    // Verify spending chart & transactions
    expect(find.text('Spending This Month'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Swiggy'), findsOneWidget);
    expect(find.text('Amazon'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    // Verify CustomBottomNavBar and its tabs
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analyze'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('Navigate to ScanAndPayScreen and return smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // Tap the Scan button
    await tester.tap(find.text('Scan'));
    await tester.pumpAndSettle();

    // Verify ScanAndPayScreen elements
    expect(find.byType(ScanAndPayScreen), findsOneWidget);
    expect(find.text('Scan any UPI QR code'), findsOneWidget);
    expect(find.text('Align the QR code within the frame'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    // Tap Back to Home button to return
    await tester.tap(find.text('Back to Home'));
    await tester.pumpAndSettle();

    // Verify returned to Home
    expect(find.text('TOTAL SPENT'), findsOneWidget);
  });

  testWidgets('Navigate to TransactionsScreen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HulyPayApp());

    // Tap Transactions tab in bottom navigation bar
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Verify TransactionsScreen is loaded
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(find.text('Search transactions'), findsOneWidget);

    // Verify filter chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('UPI'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);

    // Verify group sections
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YESTERDAY'), findsOneWidget);

    // Verify today transactions
    expect(find.text('CRED'), findsOneWidget);
    expect(find.text('Google Play'), findsOneWidget);

    // Verify yesterday transactions
    expect(find.text('Zomato'), findsOneWidget);
    expect(find.text('Metro'), findsOneWidget);
    expect(find.text('Airtel'), findsOneWidget);

    // Filter by UPI
    await tester.tap(find.text('UPI'));
    await tester.pumpAndSettle();
    expect(find.text('Swiggy'), findsOneWidget);
    expect(find.text('CRED'), findsOneWidget);
    expect(find.text('Google Play'), findsNothing); // Non-UPI excluded
  });
}
