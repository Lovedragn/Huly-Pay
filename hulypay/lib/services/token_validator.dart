import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Fast, client-side JWT decoder and validator.
///
/// Decodes Base64Url JWT payloads in memory without making any network calls (0ms, 0 KB Network).
class TokenValidator {
  TokenValidator._();

  /// Step 1: Decode JWT and verify expiration locally.
  ///
  /// Returns `true` if the token is null, empty, malformed, or if the current
  /// time is past (or within [bufferSeconds] of) the `exp` timestamp.
  static bool isExpired(String? token, {int bufferSeconds = 30}) {
    if (token == null || token.trim().isEmpty) return true;

    try {
      final payload = getPayload(token);
      if (payload == null || !payload.containsKey('exp')) return true;

      final expValue = payload['exp'];
      int? expSeconds;
      if (expValue is int) {
        expSeconds = expValue;
      } else if (expValue is num) {
        expSeconds = expValue.toInt();
      } else if (expValue is String) {
        expSeconds = int.tryParse(expValue);
      }

      if (expSeconds == null) return true;

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
      final nowWithBuffer = DateTime.now().add(Duration(seconds: bufferSeconds));

      final isPastExpiry = nowWithBuffer.isAfter(expiryDate);
      if (isPastExpiry && kDebugMode) {
        debugPrint('TokenValidator: Token expired locally at $expiryDate (buffer: ${bufferSeconds}s).');
      }

      return isPastExpiry;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('TokenValidator error: $e');
      }
      return true; // Malformed tokens are treated as expired
    }
  }

  /// Extracts and decodes the JSON payload (claims) from a JWT string without network round-trips.
  static Map<String, dynamic>? getPayload(String? token) {
    if (token == null || token.trim().isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final normalized = base64Url.normalize(parts[1]);
      final decodedString = utf8.decode(base64Url.decode(normalized));
      final decodedJson = jsonDecode(decodedString);

      if (decodedJson is Map<String, dynamic>) {
        return decodedJson;
      } else if (decodedJson is Map) {
        return Map<String, dynamic>.from(decodedJson);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns the expiration DateTime if present in the token payload.
  static DateTime? getExpirationDate(String? token) {
    final payload = getPayload(token);
    if (payload == null || !payload.containsKey('exp')) return null;

    final expValue = payload['exp'];
    int? expSeconds;
    if (expValue is int) {
      expSeconds = expValue;
    } else if (expValue is num) {
      expSeconds = expValue.toInt();
    } else if (expValue is String) {
      expSeconds = int.tryParse(expValue);
    }

    if (expSeconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
  }

  /// Returns the subject (`sub`), usually the user ID.
  static String? getSubject(String? token) {
    return getPayload(token)?['sub'] as String?;
  }

  /// Returns the email if included in user metadata or claims.
  static String? getEmail(String? token) {
    final payload = getPayload(token);
    if (payload == null) return null;
    return (payload['email'] as String?) ??
        (payload['user_metadata'] is Map
            ? (payload['user_metadata'] as Map)['email'] as String?
            : null);
  }
}
