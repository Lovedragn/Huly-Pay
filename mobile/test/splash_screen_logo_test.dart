import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/splash_screen.dart';

void main() {
  testWidgets(
    'SplashScreen and AnimatedHulyLogo render and animate seamlessly',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(
            initializeAuth: false,
            duration: Duration(seconds: 5),
          ),
        ),
      );

      // Initial frame (Start state)
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(AnimatedHulyLogo), findsOneWidget);
      expect(find.text('Hulypay'), findsOneWidget);
      expect(find.text('Track. Pay. Grow.'), findsOneWidget);

      // Mid animation
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AnimatedHulyLogo), findsOneWidget);

      // Completion / End state
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byType(AnimatedHulyLogo), findsOneWidget);
    },
  );
}
