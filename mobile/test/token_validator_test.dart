import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/token_validator.dart';

void main() {
  group('TokenValidator Unit Tests (Step 1 Client-Side Check)', () {
    String generateTestJwt({
      required int expSeconds,
      String sub = 'test_user_123',
      String email = 'user@hulypay.com',
    }) {
      final header = base64Url.encode(utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'}))).replaceAll('=', '');
      final payload = base64Url.encode(utf8.encode(jsonEncode({
        'sub': sub,
        'email': email,
        'exp': expSeconds,
        'user_metadata': {'name': 'Test User'},
      }))).replaceAll('=', '');
      final signature = base64Url.encode(utf8.encode('mock_signature')).replaceAll('=', '');
      return '$header.$payload.$signature';
    }

    test('isExpired returns true for null and empty tokens', () {
      expect(TokenValidator.isExpired(null), isTrue);
      expect(TokenValidator.isExpired(''), isTrue);
      expect(TokenValidator.isExpired('   '), isTrue);
    });

    test('isExpired returns true for malformed JWT strings', () {
      expect(TokenValidator.isExpired('invalid_token_string'), isTrue);
      expect(TokenValidator.isExpired('part1.part2'), isTrue);
      expect(TokenValidator.isExpired('part1.part2.part3.part4'), isTrue);
      expect(TokenValidator.isExpired('header.invalid-base64.signature'), isTrue);
    });

    test('isExpired returns true for expired tokens in the past', () {
      final pastSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - 3600; // 1 hour ago
      final expiredToken = generateTestJwt(expSeconds: pastSeconds);

      expect(TokenValidator.isExpired(expiredToken), isTrue);
    });

    test('isExpired returns true if token expires within the buffer window', () {
      // Expires in 15 seconds, but buffer is default 30 seconds
      final soonSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 15;
      final soonExpiringToken = generateTestJwt(expSeconds: soonSeconds);

      expect(TokenValidator.isExpired(soonExpiringToken, bufferSeconds: 30), isTrue);
    });

    test('isExpired returns false for fresh active tokens in the future', () {
      final futureSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 7200; // 2 hours in future
      final validToken = generateTestJwt(expSeconds: futureSeconds);

      expect(TokenValidator.isExpired(validToken, bufferSeconds: 30), isFalse);
    });

    test('getPayload decodes claims accurately without network round-trips', () {
      final futureSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600;
      final token = generateTestJwt(
        expSeconds: futureSeconds,
        sub: 'user_abc_789',
        email: 'alice@hulypay.com',
      );

      final payload = TokenValidator.getPayload(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals('user_abc_789'));
      expect(payload['email'], equals('alice@hulypay.com'));
      expect(payload['exp'], equals(futureSeconds));

      expect(TokenValidator.getSubject(token), equals('user_abc_789'));
      expect(TokenValidator.getEmail(token), equals('alice@hulypay.com'));
    });

    test('getExpirationDate converts epoch seconds to exact DateTime', () {
      final targetSeconds = 1750000000;
      final token = generateTestJwt(expSeconds: targetSeconds);

      final date = TokenValidator.getExpirationDate(token);
      expect(date, isNotNull);
      expect(date!.millisecondsSinceEpoch, equals(targetSeconds * 1000));
    });
  });
}
