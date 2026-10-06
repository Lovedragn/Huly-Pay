import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/theme/app_theme.dart';
import 'package:hulypay/widgets/custom_bottom_nav_bar.dart';

void main() {
  testWidgets('CustomBottomNavBar renders black gradient in dark theme and slides pill smoothly', (tester) async {
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

    // Verify black gradient below the navbar for Oled black theme using from/to theme values
    final gradientFinder = find.byKey(const Key('bottom_nav_gradient'));
    expect(gradientFinder, findsOneWidget);
    final gradientContainer = tester.widget<Container>(gradientFinder);
    final gradientDeco = gradientContainer.decoration as BoxDecoration;
    final gradient = gradientDeco.gradient as LinearGradient;
    expect(gradient.begin, Alignment.bottomCenter);
    expect(gradient.end, Alignment.topCenter);
    expect(gradient.colors.first, AppThemeData.oledBlack.navBarGradientFrom);
    expect(gradient.colors.last, AppThemeData.oledBlack.navBarGradientTo);

    // Verify Floating Navbar Container has rounded border radius of 32
    final navbarContainerFinder = find.byKey(const Key('floating_navbar_container'));
    expect(navbarContainerFinder, findsOneWidget);
    final navbarContainer = tester.widget<Container>(navbarContainerFinder);
    final navDecoration = navbarContainer.decoration as BoxDecoration;
    expect(navDecoration.borderRadius, BorderRadius.circular(32));

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

  testWidgets('CustomBottomNavBar renders white gradient in Milk white and Red velvet themes from app_theme.dart', (tester) async {
    // 1. Milk white theme
    AppThemeManager.setTheme('Milk white');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Milk white'),
        home: Scaffold(
          body: CustomBottomNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      ),
    );

    final milkGradientFinder = find.byKey(const Key('bottom_nav_gradient'));
    expect(milkGradientFinder, findsOneWidget);
    final milkGradientContainer = tester.widget<Container>(milkGradientFinder);
    final milkGradientDeco = milkGradientContainer.decoration as BoxDecoration;
    final milkGradient = milkGradientDeco.gradient as LinearGradient;
    expect(milkGradient.colors.first, AppThemeData.milkWhite.navBarGradientFrom);
    expect(milkGradient.colors.last, AppThemeData.milkWhite.navBarGradientTo);

    // 2. Red velvet theme
    AppThemeManager.setTheme('Red velvet');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Red velvet'),
        home: Scaffold(
          body: CustomBottomNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      ),
    );

    final redGradientFinder = find.byKey(const Key('bottom_nav_gradient'));
    expect(redGradientFinder, findsOneWidget);
    final redGradientContainer = tester.widget<Container>(redGradientFinder);
    final redGradientDeco = redGradientContainer.decoration as BoxDecoration;
    final redGradient = redGradientDeco.gradient as LinearGradient;
    expect(redGradient.colors.first, AppThemeData.redVelvet.navBarGradientFrom);
    expect(redGradient.colors.last, AppThemeData.redVelvet.navBarGradientTo);

    // Reset back to Oled black
    AppThemeManager.setTheme('Oled black');
  });
}
