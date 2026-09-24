import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/models/dashboard_data.dart';
import 'package:hulypay/screens/home_dashboard_screen.dart';
import 'package:hulypay/screens/scan_and_pay_screen.dart';
import 'package:hulypay/screens/settings_screen.dart';
import 'package:hulypay/services/local_database_service.dart';
import 'package:hulypay/services/user_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;
  late UserPreferencesService prefService;

  const emptyDashboard = DashboardData(
    greeting: 'Hello,',
    userName: 'Tester',
    avatarUrl: '',
    totalSpentFormatted: '₹0',
    changePercent: 0,
    changePeriodLabel: 'this month',
    weeklySpending: [],
    recentTransactions: [],
  );

  setUp(() async {
    dbService = LocalDatabaseService();
    await dbService.initDatabase(inMemory: true);
    prefService = UserPreferencesService();
    await prefService.setQuickScan(false);
  });

  tearDown(() async {
    await prefService.setQuickScan(false);
    await dbService.close();
  });

  group('Quick Scan Feature Tests', () {
    testWidgets('SettingsScreen displays Quick Scan toggle button and updates state when tapped',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await prefService.setQuickScan(false);

      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Quick Scan row exists
      expect(find.text('Quick Scan'), findsOneWidget);
      expect(find.text('Automatically open scanner when launching the app'), findsOneWidget);

      // Verify switch is currently off
      final switchFinder = find.widgetWithText(Row, 'Quick Scan');
      expect(switchFinder, findsOneWidget);

      // Tap on the Quick Scan row to toggle it
      await tester.tap(find.text('Quick Scan'));
      await tester.pumpAndSettle();

      // Verify persisted state is now true
      expect(prefService.cachedQuickScan, isTrue);
      final storedVal = await dbService.getMetadata(UserPreferencesService.keyQuickScan);
      expect(storedVal, equals('true'));

      // Tap again to toggle it off
      await tester.tap(find.text('Quick Scan'));
      await tester.pumpAndSettle();

      expect(prefService.cachedQuickScan, isFalse);
      final storedValOff = await dbService.getMetadata(UserPreferencesService.keyQuickScan);
      expect(storedValOff, equals('false'));
    });

    testWidgets('HomeDashboardScreen automatically launches scanner when quickScan is true',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeDashboardScreen(
            initialData: emptyDashboard,
            quickScan: true,
          ),
        ),
      );

      // Post-frame callback triggers _openScanAndPay
      await tester.pumpAndSettle();

      // ScanAndPayScreen should now be on screen
      expect(find.byType(ScanAndPayScreen), findsOneWidget);
      expect(find.text('Scan any UPI QR code'), findsOneWidget);

      // Back to Home returns to dashboard
      await tester.tap(find.text('Back to Home'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });

    testWidgets('HomeDashboardScreen does NOT auto-launch scanner when quickScan is false',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeDashboardScreen(
            initialData: emptyDashboard,
            quickScan: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ScanAndPayScreen should NOT be opened
      expect(find.byType(ScanAndPayScreen), findsNothing);
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });
  });
}
