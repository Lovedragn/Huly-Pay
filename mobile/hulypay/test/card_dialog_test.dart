import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/theme/app_theme.dart';
import 'package:hulypay/widgets/card_dialog.dart';

void main() {
  testWidgets('CardDialog renders title, icon, content, and actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: Scaffold(
          body: CardDialog(
            icon: const Icon(Icons.check, key: Key('dialog_icon')),
            title: const Text('Success Title'),
            content: const Text('Operation completed successfully.'),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('dialog_icon')), findsOneWidget);
    expect(find.text('Success Title'), findsOneWidget);
    expect(find.text('Operation completed successfully.'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('showCardDialog animates in and displays dialog content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                showCardDialog<void>(
                  context: context,
                  builder: (_) => const CardDialog(
                    title: Text('Animated Card'),
                    content: Text('Slide and fade from bottom test'),
                  ),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 300)); // Finish animation

    expect(find.text('Animated Card'), findsOneWidget);
    expect(find.text('Slide and fade from bottom test'), findsOneWidget);
  });
}
