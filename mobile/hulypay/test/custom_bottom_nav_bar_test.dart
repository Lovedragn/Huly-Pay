import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hulypay/Theme/app_theme.dart';
import 'package:hulypay/Widget/Components/Navbar/bottom_navbar.dart';

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

  testWidgets('CustomBottomNavBar renders gradient in Coffee paper and Red velvet themes from app_theme.dart', (tester) async {
    // 1. Coffee paper theme
    AppThemeManager.setTheme('Coffee paper');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Coffee paper'),
        home: Scaffold(
          body: CustomBottomNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      ),
    );

    final coffeeGradientFinder = find.byKey(const Key('bottom_nav_gradient'));
    expect(coffeeGradientFinder, findsOneWidget);
    final coffeeGradientContainer = tester.widget<Container>(coffeeGradientFinder);
    final coffeeGradientDeco = coffeeGradientContainer.decoration as BoxDecoration;
    final coffeeGradient = coffeeGradientDeco.gradient as LinearGradient;
    expect(coffeeGradient.colors.first, AppThemeData.coffeePaper.navBarGradientFrom);
    expect(coffeeGradient.colors.last, AppThemeData.coffeePaper.navBarGradientTo);

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

    // 3. Funky theme
    AppThemeManager.setTheme('Funky');
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Funky'),
        home: Scaffold(
          body: CustomBottomNavBar(
            selectedIndex: 0,
            onItemSelected: (_) {},
          ),
        ),
      ),
    );

    final funkyGradientFinder = find.byKey(const Key('bottom_nav_gradient'));
    expect(funkyGradientFinder, findsOneWidget);
    final funkyGradientContainer = tester.widget<Container>(funkyGradientFinder);
    final funkyGradientDeco = funkyGradientContainer.decoration as BoxDecoration;
    final funkyGradient = funkyGradientDeco.gradient as LinearGradient;
    expect(funkyGradient.colors.first, AppThemeData.funky.navBarGradientFrom);
    expect(funkyGradient.colors.last, AppThemeData.funky.navBarGradientTo);

    // Reset back to Oled black
    AppThemeManager.setTheme('Oled black');
  });

  testWidgets('CustomBottomNavBar ordering: Analyze left, Home center, Transactions right', (tester) async {
    int tappedIndex = -1;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeManager.getMaterialTheme('Oled black'),
        home: Scaffold(
          body: CustomBottomNavBar(
            selectedIndex: 1, // Home active in center
            onItemSelected: (index) {
              tappedIndex = index;
            },
          ),
        ),
      ),
    );

    final gestureDetectors = find.descendant(
      of: find.byType(CustomBottomNavBar),
      matching: find.byType(GestureDetector),
    );
    expect(gestureDetectors, findsNWidgets(3));

    // Verify ordering from left to right:
    final leftX = tester.getCenter(gestureDetectors.at(0)).dx;
    final centerX = tester.getCenter(gestureDetectors.at(1)).dx;
    final rightX = tester.getCenter(gestureDetectors.at(2)).dx;
    expect(leftX, lessThan(centerX));
    expect(centerX, lessThan(rightX));

    // Tap left item (Analyze)
    await tester.tap(gestureDetectors.at(0));
    expect(tappedIndex, 0);

    // Tap center item (Home)
    await tester.tap(gestureDetectors.at(1));
    expect(tappedIndex, 1);

    // Tap right item (Transactions)
    await tester.tap(gestureDetectors.at(2));
    expect(tappedIndex, 2);
  });
}
