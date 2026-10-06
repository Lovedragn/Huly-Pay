import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/theme/app_theme.dart';
import 'package:hulypay/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('CustomBottomNavBar renders sliding background pill card with smooth animation', (tester) async {
    int selectedIndex = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return CustomBottomNavBar(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Verify CustomBottomNavBar renders
    expect(find.byType(CustomBottomNavBar), findsOneWidget);

    // Verify Container has rounded border radius of 32
    final containerFinder = find.descendant(
      of: find.byType(CustomBottomNavBar),
      matching: find.byType(Container),
    );
    expect(containerFinder, findsWidgets);

    final outerContainer = tester.widget<Container>(containerFinder.first);
    final decoration = outerContainer.decoration as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(32));

    // Verify AnimatedPositioned sliding pill exists
    final animatedPositionedFinder = find.byType(AnimatedPositioned);
    expect(animatedPositionedFinder, findsOneWidget);

    final pillChildFinder = find.descendant(
      of: animatedPositionedFinder,
      matching: find.byType(AnimatedOpacity),
    );
    expect(pillChildFinder, findsOneWidget);

    final initialRenderX = tester.getTopLeft(pillChildFinder).dx;

    // Tap on second item (Analysis - index 1)
    final gestureDetectors = find.descendant(
      of: find.byType(CustomBottomNavBar),
      matching: find.byType(GestureDetector),
    );
    expect(gestureDetectors, findsNWidgets(3));

    await tester.tap(gestureDetectors.at(1));
    await tester.pump(); // Start slide animation

    // Advance halfway through animation
    await tester.pump(const Duration(milliseconds: 130));
    final midRenderX = tester.getTopLeft(pillChildFinder).dx;
    expect(midRenderX, greaterThan(initialRenderX));

    // Complete animation
    await tester.pumpAndSettle();
    expect(selectedIndex, 1);

    final finalRenderX = tester.getTopLeft(pillChildFinder).dx;
    expect(finalRenderX, greaterThan(midRenderX));
  });
}
