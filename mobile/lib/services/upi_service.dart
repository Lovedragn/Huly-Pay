import 'package:url_launcher/url_launcher.dart';

class UpiPaymentData {
  final String rawUri;
  final String upiId;
  final String payeeName;
  final double? amount;
  final String currency;
  final String? transactionRef;
  final String? transactionId;
  final String? note;
  final String? merchantCode;

  const UpiPaymentData({
    required this.rawUri,
    required this.upiId,
    required this.payeeName,
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
      'pn': payeeName,
      'cu': currency,
    };
    if (finalAmount != null && finalAmount > 0) {
      params['am'] = finalAmount.toStringAsFixed(2);
    }
    if (transactionRef != null && transactionRef!.isNotEmpty) {
      params['tr'] = transactionRef!;
    }
    if (transactionId != null && transactionId!.isNotEmpty) {
      params['tid'] = transactionId!;
    }
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
  /// Parses a raw QR scan string into structured UpiPaymentData.
  /// Handles standard `upi://pay?...` URIs as well as plain UPI IDs.
  static UpiPaymentData? parseUpiUri(String rawString) {
    final trimmed = rawString.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('upi://pay') || trimmed.contains('pa=')) {
      try {
        final uri = Uri.parse(trimmed);
        final params = uri.queryParameters;

        final pa = params['pa'];
        if (pa == null || pa.isEmpty) {
          return null;
        }

        final pn = params['pn'] ?? 'Merchant';
        final amStr = params['am'];
        double? amount;
        if (amStr != null) {
          amount = double.tryParse(amStr);
        }

        return UpiPaymentData(
          rawUri: trimmed,
          upiId: pa,
          payeeName: pn,
          amount: amount,
          currency: params['cu'] ?? 'INR',
          transactionRef: params['tr'],
          transactionId: params['tid'],
          note: params['tn'],
          merchantCode: params['mc'],
        );
      } catch (_) {
        return null;
      }
    }

    // Fallback: If scanned code is a simple UPI ID pattern like `user@bank`
    final upiPattern = RegExp(r'^[\w\.\-]+@[\w\-]+$');
    if (upiPattern.hasMatch(trimmed)) {
      return UpiPaymentData(
        rawUri: 'upi://pay?pa=$trimmed&pn=Merchant&cu=INR',
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
