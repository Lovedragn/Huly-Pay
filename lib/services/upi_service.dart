import 'package:url_launcher/url_launcher.dart';

class UpiPaymentData {
  final String rawUri;
  final String upiId;
  final String? payeeName;
  final double? amount;
  final String currency;
  final String? transactionRef;
  final String? transactionId;
  final String? note;
  final String? merchantCode;

  const UpiPaymentData({
    required this.rawUri,
    required this.upiId,
    this.payeeName,
    this.amount,
    this.currency = 'INR',
    this.transactionRef,
    this.transactionId,
    this.note,
    this.merchantCode,
  });

  String buildPaymentUri({double? customAmount}) {
    final finalAmount = customAmount ?? amount;
    final params = <String, String>{
      'pa': upiId,
      'cu': currency,
    };
    if (payeeName != null && payeeName!.trim().isNotEmpty) {
      params['pn'] = payeeName!.trim();
    }
    if (finalAmount != null && finalAmount > 0) {
      params['am'] = finalAmount.toStringAsFixed(2);
    }
    // Modern NPCI and Google Pay intent standard requires 'tr' (Transaction Reference ID).
    // 'tid' (Terminal ID) is deprecated for mobile app intents and is reserved only for physical POS hardware.
    final ref = (transactionRef != null && transactionRef!.isNotEmpty)
        ? transactionRef!
        : 'REF-${DateTime.now().millisecondsSinceEpoch}';
    params['tr'] = ref;

    if (note != null && note!.isNotEmpty) {
      params['tn'] = note!;
    }
    if (merchantCode != null && merchantCode!.isNotEmpty) {
      params['mc'] = merchantCode!;
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return 'upi://pay?$query';
  }
}

class UpiService {
  /// Official package identifier for Google Pay India on Android
  static const String googlePayPackageName = 'com.google.android.apps.nbu.paisa.user';

  /// Official package identifier for Amazon Pay / Amazon Shopping on Android
  static const String amazonPayPackageName = 'in.amazon.mShop.android.shopping';

  /// Checks whether a raw string represents a valid UPI payment QR or UPI ID.
  static bool isUpiUri(String rawString) => parseUpiUri(rawString) != null;

  /// Parses a raw QR scan string into structured UpiPaymentData.
  /// Strictly accepts valid `upi://pay?...` URIs or standard UPI VPAs (user@bank).
  /// Rejects arbitrary URLs, Wi-Fi codes, plain text, and non-UPI formats.
  static UpiPaymentData? parseUpiUri(String rawString) {
    final trimmed = rawString.trim();
    if (trimmed.isEmpty) return null;

    final lower = trimmed.toLowerCase();

    // 1. Standard UPI Payment URI: upi://pay?...
    if (lower.startsWith('upi://pay') || lower.startsWith('upi:')) {
      try {
        final uri = Uri.parse(trimmed);
        if (uri.scheme.toLowerCase() != 'upi') {
          return null;
        }

        final pathAndHost = '${uri.host}${uri.path}'.toLowerCase();
        if (!pathAndHost.contains('pay')) {
          return null;
        }

        final params = uri.queryParameters;
        final pa = params['pa']?.trim();
        // Mandatory UPI ID (must be non-empty and contain @)
        if (pa == null || pa.isEmpty || !pa.contains('@')) {
          return null;
        }

        // Payee/Merchant name (do not invent if absent)
        final pn = params['pn']?.trim();
        final String? payeeName = (pn != null && pn.isNotEmpty) ? pn : null;

        // Amount handling: only accept if valid positive number
        final amStr = params['am']?.trim();
        double? amount;
        if (amStr != null && amStr.isNotEmpty) {
          final parsed = double.tryParse(amStr);
          if (parsed != null && parsed > 0) {
            amount = parsed;
          }
        }

        final cu = params['cu']?.trim();
        final currency = (cu != null && cu.isNotEmpty) ? cu : 'INR';

        return UpiPaymentData(
          rawUri: trimmed,
          upiId: pa,
          payeeName: payeeName,
          amount: amount,
          currency: currency,
          transactionRef: params['tr']?.trim(),
          transactionId: params['tid']?.trim(),
          note: params['tn']?.trim(),
          merchantCode: params['mc']?.trim(),
        );
      } catch (_) {
        return null;
      }
    }

    // 2. Fallback: If scanned code is a simple UPI ID pattern like `user@bank`
    final upiPattern = RegExp(r'^[\w\.\-]+@[\w\-]+$');
    if (upiPattern.hasMatch(trimmed)) {
      return UpiPaymentData(
        rawUri: 'upi://pay?pa=$trimmed&cu=INR',
        upiId: trimmed,
        payeeName: trimmed.split('@').first,
        amount: null,
        currency: 'INR',
      );
    }

    return null;
  }

  /// Launches an external UPI payment application using standard Android/iOS intent
  static Future<bool> launchUpiPayment(String upiUri) async {
    try {
      final uri = Uri.parse(upiUri);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
