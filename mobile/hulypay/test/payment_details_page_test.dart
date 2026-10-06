import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/services/upi_service.dart';
import 'package:hulypay/theme/app_theme.dart';
import 'package:hulypay/widgets/payment_details_page.dart';

void main() {
  testWidgets('PaymentDetailsPage: layout, zero gap, copy icon without text, bottom-anchored pay button', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    const upiData = UpiPaymentData(
      rawUri: 'upi://pay?pa=merchant@upi&pn=SuperStore&cu=INR',
      upiId: 'merchant@upi',
      payeeName: 'SuperStore',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: const PaymentDetailsPage(upiData: upiData),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify AppBar and payee info
    expect(find.text('SuperStore'), findsOneWidget);
    expect(find.text('merchant@upi'), findsOneWidget);

    // 2. Verify copy button has icon and NO 'Copy' text
    expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    expect(find.text('Copy'), findsNothing);

    // 3. Verify Rupee symbol and 0 have zero gap
    final rupeeFinder = find.text('₹');
    final zeroFinder = find.text('0');
    expect(rupeeFinder, findsOneWidget);
    expect(zeroFinder, findsOneWidget);

    final rupeeRect = tester.getRect(rupeeFinder);
    final zeroRect = tester.getRect(zeroFinder);
    expect(zeroRect.left - rupeeRect.right, closeTo(0.0, 1.0));

    // 4. Verify no card background container wrapping the amount
    final amountContainerAncestor = find.ancestor(
      of: rupeeFinder,
      matching: find.byType(Container),
    );
    expect(amountContainerAncestor, findsNothing);

    // 5. Verify Add note has no background and 'Add note' hint
    expect(find.text('Add note'), findsOneWidget);
    expect(find.text('Add a note (optional)'), findsNothing);

    // 6. Verify pay button is anchored near the bottom
    final buttonFinder = find.byType(ElevatedButton);
    expect(buttonFinder, findsOneWidget);
    final buttonTop = tester.getTopLeft(buttonFinder).dy;
    expect(buttonTop, greaterThan(700));
  });
}
