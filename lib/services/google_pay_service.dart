import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upi_service.dart';

/// Status of the Google Pay UPI payment execution
enum GooglePayStatus {
  success,
  submitted,
  failure,
  userCancelled,
  notInstalled,
  error,
}

/// Represents the structured result returned from Google Pay India Merchant Intent / UPI Intent
class GooglePayResult {
  final GooglePayStatus status;
  final String? rawStatus;
  final String? upiTransactionId;
  final String? transactionReference;
  final String? payeeVpa;
  final double? amount;
  final String? approvalRefNo;
  final String? responseCode;
  final Map<String, dynamic>? tezResponse;
  final String? rawResponse;
  final String? errorMessage;

  const GooglePayResult({
    required this.status,
    this.rawStatus,
    this.upiTransactionId,
    this.transactionReference,
    this.payeeVpa,
    this.amount,
    this.approvalRefNo,
    this.responseCode,
    this.tezResponse,
    this.rawResponse,
    this.errorMessage,
  });

  bool get isSuccess => status == GooglePayStatus.success;
  bool get isSubmitted => status == GooglePayStatus.submitted;
  bool get isCancelled => status == GooglePayStatus.userCancelled;
  bool get isFailure => status == GooglePayStatus.failure;

  /// Helper to parse key-value pairs from query string (e.g. "txnId=123&Status=SUCCESS")
  static Map<String, String> parseQueryParams(String input) {
    final Map<String, String> result = {};
    String queryString = input.trim();
    if (queryString.contains('?')) {
      queryString = queryString.substring(queryString.indexOf('?') + 1);
    }
    if (queryString.isEmpty) return result;

    final pairs = queryString.split('&');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        if (key.isNotEmpty) {
          result[key] = Uri.decodeComponent(value);
        }
      }
    }
    return result;
  }

  /// Parses a raw URI or query string (e.g. returned by UPI apps via data URI)
  factory GooglePayResult.fromQueryString(String queryOrUri) {
    final params = parseQueryParams(queryOrUri);
    return GooglePayResult.fromNativeMap({
      'response': queryOrUri,
      ...params,
    });
  }

  /// Parses raw native result map or response string into a strongly-typed GooglePayResult
  factory GooglePayResult.fromNativeMap(Map<dynamic, dynamic> map) {
    final bool isCanceled = map['isCanceled'] == true;
    final String? rawTez = map['tezResponse'] as String?;
    final String? rawRespStr = map['response'] as String?;
    final String? dataString = map['dataString'] as String?;
    final String? query = map['query'] as String?;

    Map<String, dynamic>? tezJson;
    if (rawTez != null && rawTez.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawTez.trim());
        if (decoded is Map<String, dynamic>) {
          tezJson = decoded;
        }
      } catch (_) {}
    }

    // Parse query-string format in `response`, `dataString`, or `query`
    final Map<String, String> parsedParams = {};
    if (rawRespStr != null && rawRespStr.contains('=')) {
      parsedParams.addAll(parseQueryParams(rawRespStr));
    }
    if (dataString != null && dataString.contains('=')) {
      parsedParams.addAll(parseQueryParams(dataString));
    }
    if (query != null && query.contains('=')) {
      parsedParams.addAll(parseQueryParams(query));
    }

    // Helper for case-insensitive lookup across map and parsedParams
    String? findParam(List<String> candidateKeys) {
      for (final key in candidateKeys) {
        if (tezJson != null && tezJson[key] != null) {
          return tezJson[key].toString();
        }
      }
      for (final key in candidateKeys) {
        if (map[key] != null) {
          return map[key].toString();
        }
      }
      for (final key in candidateKeys) {
        final lowerKey = key.toLowerCase();
        for (final entry in parsedParams.entries) {
          if (entry.key.toLowerCase() == lowerKey) {
            return entry.value;
          }
        }
      }
      return null;
    }

    // Resolve Status
    final String? statusStr = findParam(['Status', 'status']);
    final String? txnId = findParam(['txnId', 'txnid', 'tid']);
    final String? txnRef = findParam(['txnRef', 'txnref', 'tr']);
    final String? responseCode = findParam(['responseCode', 'responsecode']);
    final String? approvalRef = findParam(['ApprovalRefNo', 'approvalrefno']);
    final String? payeeVpa = findParam(['toVpa', 'tovpa', 'pa', 'vpa']);
    final String? amountStr = findParam(['amount', 'am']);

    double? parsedAmount;
    if (amountStr != null && amountStr.isNotEmpty) {
      parsedAmount = double.tryParse(amountStr.replaceAll(',', ''));
    }

    GooglePayStatus resolvedStatus;
    if (statusStr != null) {
      final upper = statusStr.toUpperCase();
      if (upper == 'SUCCESS' || upper == 'S' || responseCode == '00' || responseCode == '0') {
        resolvedStatus = GooglePayStatus.success;
      } else if (upper == 'SUBMITTED' || upper == 'PENDING') {
        resolvedStatus = GooglePayStatus.submitted;
      } else if (upper == 'FAILURE' || upper == 'FAILED' || upper == 'F') {
        resolvedStatus = GooglePayStatus.failure;
      } else if (upper.contains('CANCEL')) {
        resolvedStatus = GooglePayStatus.userCancelled;
      } else {
        resolvedStatus = GooglePayStatus.error;
      }
    } else if (isCanceled) {
      resolvedStatus = GooglePayStatus.userCancelled;
    } else if (map['isOk'] == true) {
      resolvedStatus = GooglePayStatus.success;
    } else {
      resolvedStatus = GooglePayStatus.error;
    }

    return GooglePayResult(
      status: resolvedStatus,
      rawStatus: statusStr,
      upiTransactionId: txnId,
      transactionReference: txnRef,
      payeeVpa: payeeVpa,
      amount: parsedAmount,
      approvalRefNo: approvalRef,
      responseCode: responseCode,
      tezResponse: tezJson,
      rawResponse: rawTez ?? rawRespStr ?? dataString,
    );
  }
}

/// Google Pay for India (UPI) Merchant Integration Service
///
/// Implements the official Google Pay India Intent specification:
/// https://developers.google.com/pay/india/api/merchant-sdk/reference/api
class GooglePayService {
  static const MethodChannel _channel = MethodChannel('com.hulypay.app/google_pay');

  /// Official package identifier for Google Pay India
  static const String googlePayPackage = 'com.google.android.apps.nbu.paisa.user';

  /// Official package identifier for Amazon India / Amazon Pay
  static const String amazonPayPackage = 'in.amazon.mShop.android.shopping';

  /// Check if a specific package is installed on the device
  static Future<bool> isPackageInstalled(String packageName) async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? result = await _channel.invokeMethod<bool>('isPackageInstalled', {
          'packageName': packageName,
        });
        return result ?? false;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  /// Launch an external app by package name
  static Future<bool> launchAppPackage(String packageName, {String? storeUrl}) async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? success = await _channel.invokeMethod<bool>('launchAppPackage', {
          'packageName': packageName,
        });
        return success ?? false;
      } on PlatformException catch (pe) {
        if (pe.code == 'NOT_INSTALLED' && storeUrl != null) {
          return await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
        }
        return false;
      } catch (_) {
        return false;
      }
    }
    if (storeUrl != null) {
      return await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Launch Amazon Pay / Amazon Shopping as a separate application
  static Future<bool> launchStandaloneAmazonPay() async {
    return launchAppPackage(
      amazonPayPackage,
      storeUrl: 'https://play.google.com/store/apps/details?id=$amazonPayPackage',
    );
  }

  /// Check if Google Pay (India) is installed and available to receive payment intents
  static Future<bool> isReadyToPay() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? result = await _channel.invokeMethod<bool>('isReadyToPay');
        return result ?? false;
      } catch (_) {
        return false;
      }
    }

    // On non-Android (e.g. iOS), check if standard UPI can be handled
    try {
      return await canLaunchUrl(Uri.parse('upi://pay'));
    } catch (_) {
      return false;
    }
  }

  /// Launch Google Pay as a completely separate external application (Part 3 & Part 14)
  static Future<bool> launchStandaloneGooglePay() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? success = await _channel.invokeMethod<bool>('launchStandaloneGooglePay');
        return success ?? false;
      } on PlatformException catch (pe) {
        if (pe.code == 'NOT_INSTALLED') {
          return false;
        }
        rethrow;
      } catch (e) {
        return false;
      }
    }

    final playStoreUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$googlePayPackage',
    );
    return await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
  }

  /// Check whether SMS reading/receiving permissions are granted
  static Future<bool> isSmsPermissionGranted() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final bool? granted = await _channel.invokeMethod<bool>('isSmsPermissionGranted');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Request runtime Android SMS permissions (Part 4)
  static Future<bool> requestSmsPermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    try {
      final bool? granted = await _channel.invokeMethod<bool>('requestSmsPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  static void Function(Map<String, dynamic> smsData)? _onSmsReceivedCallback;

  /// Start listening for incoming SMS during the payment verification window (Part 5)
  static Future<bool> startSmsListener(void Function(Map<String, dynamic> smsData) onSmsReceived) async {
    _onSmsReceivedCallback = onSmsReceived;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onSmsReceived') {
        final args = call.arguments;
        if (args is Map) {
          final map = Map<String, dynamic>.from(args);
          _onSmsReceivedCallback?.call(map);
        }
      }
    });

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final bool? result = await _channel.invokeMethod<bool>('startSmsListener');
        return result ?? false;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Stop listening for incoming SMS
  static Future<void> stopSmsListener() async {
    _onSmsReceivedCallback = null;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await _channel.invokeMethod('stopSmsListener');
      } catch (_) {}
    }
  }

  /// Launch Google Pay India with pre-configured UPI parameters
  ///
  /// Parameters strictly adhere to NPCI and Google Pay India specs:
  /// - `pa`: Payee VPA
  /// - `pn`: Payee Name
  /// - `am`: Amount in INR
  /// - `cu`: 'INR'
  /// - `tr`: Transaction Reference ID
  /// - `tn`: Transaction Note
  /// - `mc`: Merchant Category Code
  static Future<GooglePayResult> payWithGooglePay({
    required UpiPaymentData paymentData,
    double? customAmount,
  }) async {
    final String upiUri = paymentData.buildPaymentUri(customAmount: customAmount);

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final dynamic rawResult = await _channel.invokeMethod('launchGooglePay', {
          'upiUri': upiUri,
        });

        if (rawResult is Map) {
          return GooglePayResult.fromNativeMap(rawResult);
        }

        return const GooglePayResult(
          status: GooglePayStatus.userCancelled,
          errorMessage: 'No result returned from Google Pay',
        );
      } on PlatformException catch (pe) {
        if (pe.code == 'NOT_INSTALLED') {
          // Graceful fallback to standard external application launch
          final launched = await UpiService.launchUpiPayment(upiUri);
          return GooglePayResult(
            status: launched ? GooglePayStatus.submitted : GooglePayStatus.notInstalled,
            errorMessage: pe.message,
          );
        }

        return GooglePayResult(
          status: GooglePayStatus.error,
          errorMessage: pe.message,
        );
      } catch (e) {
        return GooglePayResult(
          status: GooglePayStatus.error,
          errorMessage: e.toString(),
        );
      }
    }

    // Non-Android or test environment fallback: Launch generic external application
    try {
      final launched = await UpiService.launchUpiPayment(upiUri);
      return GooglePayResult(
        status: launched ? GooglePayStatus.submitted : GooglePayStatus.failure,
      );
    } catch (e) {
      return GooglePayResult(
        status: GooglePayStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Process any raw UPI response (Map, JSON String, or query URI) into a strongly-typed GooglePayResult
  static GooglePayResult processUpiResponse(dynamic rawResult) {
    if (rawResult is Map) {
      return GooglePayResult.fromNativeMap(rawResult);
    } else if (rawResult is String) {
      return GooglePayResult.fromQueryString(rawResult);
    } else if (rawResult is Uri) {
      return GooglePayResult.fromQueryString(rawResult.toString());
    }
    return const GooglePayResult(
      status: GooglePayStatus.error,
      errorMessage: 'Unsupported response format',
    );
  }
}
