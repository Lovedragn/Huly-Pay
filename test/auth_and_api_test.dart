import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/screens/sign_in_screen.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Tests', () {
    final auth = AuthService();

    test('Unconfigured Supabase authentication throws AuthException on sign in', () async {
      expect(
        () => auth.signInWithPassword(
          email: 'test@hulypay.com',
          password: 'password123',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('Unconfigured OAuth throws AuthException', () async {
      expect(() => auth.signInWithGoogle(), throwsA(isA<AuthException>()));
      expect(() => auth.signInWithGitHub(), throwsA(isA<AuthException>()));
    });

    test('signOut clears user session cleanly', () async {
      await auth.signOut();
      expect(auth.currentUser, isNull);
      expect(auth.currentAccessToken, isNull);
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('UserProfile Model Tests', () {
    test('fromJson and toJson deserialize and serialize accurately', () {
      final json = {
        'id': 'a194c4b7-8076-4ffe-9f3e-6fe8f934a15e',
        'email': 'user@hulypay.com',
        'fullName': 'Jane Doe',
        'firstName': 'Jane',
        'lastName': 'Doe',
        'phoneNumber': '+919876543210',
        'avatarUrl': 'https://hulypay.com/avatar.png',
        'authProvider': 'email',
        'active': true,
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, equals('a194c4b7-8076-4ffe-9f3e-6fe8f934a15e'));
      expect(profile.email, equals('user@hulypay.com'));
      expect(profile.fullName, equals('Jane Doe'));
      expect(profile.firstName, equals('Jane'));
      expect(profile.lastName, equals('Doe'));
      expect(profile.phoneNumber, equals('+919876543210'));
      expect(profile.avatarUrl, equals('https://hulypay.com/avatar.png'));
      expect(profile.authProvider, equals('email'));
      expect(profile.active, isTrue);

      final outJson = profile.toJson();
      expect(outJson['email'], equals('user@hulypay.com'));
      expect(outJson['fullName'], equals('Jane Doe'));
    });
  });

  group('ApiClient Interceptor Tests', () {
    test('ApiClient contains Authorization Bearer header interceptor', () {
      final client = ApiClient();
      expect(client.dio.interceptors.isNotEmpty, isTrue);
      expect(client.dio.options.baseUrl, isNotEmpty);
    });
  });

  group('SignInScreen Integration Tests', () {
    testWidgets('SignInScreen displays Experience HulyPay, quote, and OAuth buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      // Verify new title and application quote
      expect(find.text('Experience HulyPay'), findsOneWidget);
      expect(find.text('Track. Pay. Grow.'), findsOneWidget);

      // Verify top back and sign up buttons are removed
      expect(find.byKey(const Key('signin_back_button')), findsNothing);
      expect(find.text('Sign Up'), findsNothing);

      // Verify OAuth buttons exist and email button is removed
      expect(find.byKey(const Key('google_signin_button')), findsOneWidget);
      expect(find.byKey(const Key('github_signin_button')), findsOneWidget);
      expect(find.byKey(const Key('email_signin_button')), findsNothing);
      expect(find.byKey(const Key('auth_processing_button')), findsNothing);
    });
  });
}
