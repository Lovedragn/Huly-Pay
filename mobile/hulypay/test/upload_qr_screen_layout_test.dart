import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Screen/upload_qr_screen.dart';
import 'package:hulypay/Screen/scan_amount_screen.dart';
import 'package:hulypay/Theme/app_theme.dart';

void main() {
  testWidgets('UploadQrScreen positions AppBar at top, amount in middle, and button at bottom', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: const UploadQrScreen(initialAmount: 150),
      ),
    );
    await tester.pumpAndSettle();

    final appBarFinder = find.text('Upload QR');
    final amountFinder = find.text('₹');
    final buttonFinder = find.byType(ElevatedButton);

    expect(appBarFinder, findsOneWidget);
    expect(amountFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);

    final appBarTop = tester.getTopLeft(appBarFinder).dy;
    final amountTop = tester.getTopLeft(amountFinder).dy;
    final buttonTop = tester.getTopLeft(buttonFinder).dy;

    // Verify ordering and distinct non-overlapping placement
    expect(appBarTop, lessThan(amountTop));
    expect(amountTop, lessThan(buttonTop));

    // Verify button is anchored near bottom (screen height is 800, button height is 54 + padding 14)
    expect(buttonTop, greaterThan(700));
  });

  testWidgets('ScanAmountScreen positions AppBar at top, amount in middle, and button at bottom', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: const ScanAmountScreen(initialAmount: 250),
      ),
    );
    await tester.pumpAndSettle();

    final appBarFinder = find.text('Scan & Pay');
    final amountFinder = find.text('₹');
    final buttonFinder = find.byType(ElevatedButton);

    expect(appBarFinder, findsOneWidget);
    expect(amountFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);

    final appBarTop = tester.getTopLeft(appBarFinder).dy;
    final amountTop = tester.getTopLeft(amountFinder).dy;
    final buttonTop = tester.getTopLeft(buttonFinder).dy;

    // Verify ordering and distinct non-overlapping placement
    expect(appBarTop, lessThan(amountTop));
    expect(amountTop, lessThan(buttonTop));

    // Verify button is anchored near bottom
    expect(buttonTop, greaterThan(700));
  });

  testWidgets('UploadQrScreen: no gap between ₹ and 0, no border color, no note border, and Add note hint', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: const UploadQrScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final rupeeFinder = find.text('₹');
    final zeroFinder = find.text('0');
    expect(rupeeFinder, findsOneWidget);
    expect(zeroFinder, findsOneWidget);

    final rupeeRect = tester.getRect(rupeeFinder);
    final zeroRect = tester.getRect(zeroFinder);
    // Verify no gap between rupee symbol and 0 amount
    expect(zeroRect.left - rupeeRect.right, closeTo(0.0, 1.0));

    // Verify hint text is 'Add note' and not 'Add a note (optional)'
    expect(find.text('Add note'), findsOneWidget);
    expect(find.text('Add a note (optional)'), findsNothing);

    // Verify amount entry has no card background container wrapping it
    final containerAncestor = find.ancestor(
      of: rupeeFinder,
      matching: find.byType(Container),
    );
    expect(containerAncestor, findsNothing);

    // Verify note text field has no background fill and no border
    final noteFieldFinder = find.widgetWithText(TextField, 'Add note');
    final noteTextField = tester.widget<TextField>(noteFieldFinder);
    expect(noteTextField.decoration?.filled, isNot(true));
    expect(noteTextField.decoration?.border, equals(InputBorder.none));
  });
}

