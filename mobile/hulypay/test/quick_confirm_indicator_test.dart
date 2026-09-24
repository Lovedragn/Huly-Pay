import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/screens/scan_and_pay_screen.dart';
import 'package:hulypay/services/local_database_service.dart';
import 'package:hulypay/services/user_preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;
  late UserPreferencesService prefService;

  setUp(() async {
    dbService = LocalDatabaseService();
    await dbService.initDatabase(inMemory: true);
    prefService = UserPreferencesService();
    await prefService.setQuickConfirm(false);
  });

  tearDown(() async {
    await prefService.setQuickConfirm(false);
    await dbService.close();
  });

  group('Quick Confirm Thunder Indicator Tests', () {
    testWidgets('Does not show thunder indicator when Quick Confirm is disabled', (tester) async {
      await prefService.setQuickConfirm(false);

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanAndPayScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify back button exists
      expect(find.byKey(const Key('back_button')), findsOneWidget);

      // Verify thunder indicator does NOT exist
      expect(find.byKey(const Key('quick_confirm_indicator')), findsNothing);
      expect(find.byIcon(Icons.bolt_rounded), findsNothing);
    });

    testWidgets('Shows circular thunder indicator in top bar when Quick Confirm is enabled', (tester) async {
      await prefService.setQuickConfirm(true);

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanAndPayScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify back button exists
      expect(find.byKey(const Key('back_button')), findsOneWidget);

      // Verify thunder indicator exists with bolt icon
      final indicator = find.byKey(const Key('quick_confirm_indicator'));
      expect(indicator, findsOneWidget);
      expect(find.byIcon(Icons.bolt_rounded), findsOneWidget);

      // Tap indicator and verify feedback snackbar
      await tester.tap(indicator);
      await tester.pump();
      expect(find.text('Quick Confirm is active'), findsOneWidget);
    });
  });
}
