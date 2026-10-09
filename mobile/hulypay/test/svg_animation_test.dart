import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hulypay/Screen/splash_screen.dart';
import 'package:hulypay/Theme/app_theme.dart';
import 'package:hulypay/Widget/animated_huly_logo.dart';

void main() {
  testWidgets('renders Logo-Dark.svg without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(
            'assets/logo/Logo-Dark.svg',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('renders Logo-Light.svg without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(
            'assets/logo/Logo-Light.svg',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('renders Logo-Dark-Animation.svg without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(
            'assets/logo/Logo-Dark-Animation.svg',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('renders Logo-Light-Animation.svg without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SvgPicture.asset(
            'assets/logo/Logo-Light-Animation.svg',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('AnimatedHulyLogo paints across progress timeline in forward mode', (tester) async {
    for (double p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHulyLogo(
              progress: p,
              reverse: false,
              color: Colors.white,
              size: 120,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AnimatedHulyLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });

  testWidgets('AnimatedHulyLogo paints across progress timeline in reverse mode', (tester) async {
    for (double p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHulyLogo(
              progress: p,
              reverse: true,
              color: Colors.white,
              size: 120,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(AnimatedHulyLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    }
  });

  testWidgets('SplashScreen uses AnimatedHulyLogo with reverse: true in Oled black theme', (tester) async {
    AppThemeManager.setTheme('Oled black');
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          initializeAuth: false,
          duration: Duration(seconds: 10),
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Hulypay'), findsNothing);
    expect(find.text('Track. Pay. Grow.'), findsNothing);

    final logoFinder = find.byType(AnimatedHulyLogo);
    expect(logoFinder, findsOneWidget);
    final logoWidget = tester.widget<AnimatedHulyLogo>(logoFinder);
    expect(logoWidget.color, Colors.white);
    expect(logoWidget.reverse, isTrue);
  });

  testWidgets('SplashScreen uses AnimatedHulyLogo with reverse: true in Funky theme', (tester) async {
    AppThemeManager.setTheme('Funky');
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          initializeAuth: false,
          duration: Duration(seconds: 10),
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    final logoFinder = find.byType(AnimatedHulyLogo);
    expect(logoFinder, findsOneWidget);
    final logoWidget = tester.widget<AnimatedHulyLogo>(logoFinder);
    expect(logoWidget.color, Colors.black);
    expect(logoWidget.reverse, isTrue);
  });

  testWidgets('SplashScreen animates progress over 1 sec duration', (tester) async {
    AppThemeManager.setTheme('Oled black');
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          initializeAuth: false,
          duration: Duration(seconds: 1),
        ),
      ),
    );

    // Initial state: progress should be near 0
    AnimatedHulyLogo logo = tester.widget<AnimatedHulyLogo>(find.byType(AnimatedHulyLogo));
    expect(logo.progress, lessThanOrEqualTo(0.1));
    expect(logo.reverse, isTrue);

    // Halfway through 1 sec (500ms): progress should be near 0.5
    await tester.pump(const Duration(milliseconds: 500));
    logo = tester.widget<AnimatedHulyLogo>(find.byType(AnimatedHulyLogo));
    expect(logo.progress, greaterThan(0.2));
    expect(logo.progress, lessThan(0.8));

    // Finished 1 sec (additional 500ms)
    await tester.pump(const Duration(milliseconds: 500));
    logo = tester.widget<AnimatedHulyLogo>(find.byType(AnimatedHulyLogo));
    expect(logo.progress, equals(1.0));
  });

  testWidgets('SplashScreen navigates to next screen upon tap', (tester) async {
    const nextKey = Key('next_screen_content');
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(
          initializeAuth: false,
          duration: Duration(seconds: 10),
          nextScreen: Scaffold(key: nextKey, body: Text('Next Screen')),
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byKey(nextKey), findsNothing);

    await tester.tap(find.byKey(const Key('splash_gesture_detector')));
    await tester.pumpAndSettle();

    expect(find.byKey(nextKey), findsOneWidget);
  });
}
