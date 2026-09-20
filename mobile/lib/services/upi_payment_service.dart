import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'upi_service.dart';

/// Supported UPI Applications in Huly Pay
class SupportedUpiApp {
  final String id;
  final String name;
  final String packageName;
  final String iconPath;

  const SupportedUpiApp({
    required this.id,
    required this.name,
    required this.packageName,
    required this.iconPath,
  });
}

/// Known standard UPI Applications in India
class UpiApps {
  static const String askEveryTime = 'ask_every_time';
  static const String googlePay = 'google_pay';
  static const String amazonPay = 'amazon_pay';
  static const String phonePe = 'phonepe';
  static const String paytm = 'paytm';
  static const String bhim = 'bhim';
  static const String whatsapp = 'whatsapp';

  static const SupportedUpiApp gpay = SupportedUpiApp(
    id: googlePay,
    name: 'Google Pay',
    packageName: 'com.google.android.apps.nbu.paisa.user',
    iconPath: 'assets/icon/google-pay.svg',
  );

  static const SupportedUpiApp phonepeApp = SupportedUpiApp(
    id: phonePe,
    name: 'PhonePe',
    packageName: 'com.phonepe.app',
    iconPath: 'assets/icon/phonepe.svg',
  );

  static const SupportedUpiApp paytmApp = SupportedUpiApp(
    id: paytm,
    name: 'Paytm',
    packageName: 'net.one97.paytm',
    iconPath: '',
  );

  static const SupportedUpiApp amazon = SupportedUpiApp(
    id: amazonPay,
    name: 'Amazon Pay',
    packageName: 'in.amazon.mShop.android.shopping',
    iconPath: 'assets/icon/amazon-icon.svg',
  );

  static const SupportedUpiApp bhimApp = SupportedUpiApp(
    id: bhim,
    name: 'BHIM',
    packageName: 'in.org.npci.upiapp',
    iconPath: 'assets/icon/bhim.svg',
  );

  static const SupportedUpiApp whatsappApp = SupportedUpiApp(
    id: whatsapp,
    name: 'WhatsApp',
    packageName: 'com.whatsapp',
    iconPath: '',
  );

  static const List<SupportedUpiApp> allApps = [
    gpay,
    phonepeApp,
    paytmApp,
    amazon,
    bhimApp,
    whatsappApp,
  ];

  static SupportedUpiApp? findById(String id) {
    for (final app in allApps) {
      if (app.id == id) return app;
    }
    return null;
  }

  static SupportedUpiApp? findByPackage(String packageName) {
    for (final app in allApps) {
      if (app.packageName == packageName) return app;
    }
    return null;
  }
}

/// Result of launching an external UPI app
class UpiLaunchResult {
  final bool success;
  final bool appNotInstalled;
  final String? launchedPackage;
  final String? errorMessage;
  final Map<dynamic, dynamic>? rawResponse;

  const UpiLaunchResult({
    required this.success,
    this.appNotInstalled = false,
    this.launchedPackage,
    this.errorMessage,
    this.rawResponse,
  });
}

/// Dedicated UPI Payment Service for external app launches and availability detection
class UpiPaymentService {
  static const MethodChannel _channel = MethodChannel('com.hulypay.app/google_pay');

  /// Safely constructs a standard UPI URL conforming to NPCI specification
  /// using Dart's Uri class and proper URL component encoding.
  static Uri buildSafeUpiUri({
    required String upiId,
    String? payeeName,
    double? amount,
    String currency = 'INR',
    String? transactionRef,
    String? transactionId,
    String? note,
    String? merchantCode,
  }) {
    final queryParameters = <String, String>{
      'pa': upiId.trim(),
      'cu': currency.trim().isNotEmpty ? currency.trim() : 'INR',
    };

    if (payeeName != null && payeeName.trim().isNotEmpty) {
      queryParameters['pn'] = payeeName.trim();
    }

    if (amount != null && amount > 0) {
      queryParameters['am'] = amount.toStringAsFixed(2);
    }

    final ref = (transactionRef != null && transactionRef.trim().isNotEmpty)
        ? transactionRef.trim()
        : 'REF-${DateTime.now().millisecondsSinceEpoch}';
    queryParameters['tr'] = ref;

    if (transactionId != null && transactionId.trim().isNotEmpty) {
      queryParameters['tid'] = transactionId.trim();
    }

    if (note != null && note.trim().isNotEmpty) {
      queryParameters['tn'] = note.trim();
    }

    if (merchantCode != null && merchantCode.trim().isNotEmpty) {
      queryParameters['mc'] = merchantCode.trim();
    }

    return Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: queryParameters,
    );
  }

  /// Checks if a specific app by ID (e.g. 'google_pay', 'phonepe') is installed
  static Future<bool> isAppInstalled(String appId) async {
    if (appId == UpiApps.askEveryTime) return true;
    final app = UpiApps.findById(appId);
    if (app == null) return false;

    return isPackageInstalled(app.packageName);
  }

  /// Launches an Android app by package name strictly as an external standalone application.
  /// First checks if the package is installed before attempting to launch.
  /// Returns `true` if launched successfully, `false` if not installed or launch failed.
  static Future<bool> openApp(String packageName) async {
    final installed = await isPackageInstalled(packageName);
    if (!installed) {
      return false;
    }

    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }

    try {
      final bool? success = await _channel.invokeMethod<bool>('launchAppPackage', {
        'packageName': packageName,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Launches the standalone external UPI application without inserting amount or intent parameters.
  /// The user can manually enter the amount and pay the payee directly in their preferred app.
  static Future<bool> launchStandaloneApp({String? preferredAppId}) async {
    final appId = preferredAppId ?? UpiApps.askEveryTime;
    if (appId != UpiApps.askEveryTime) {
      final app = UpiApps.findById(appId);
      if (app != null) {
        return openApp(app.packageName);
      }
    }

    // If 'ask_every_time', try launching first available installed UPI app
    final available = await getAvailableSupportedApps();
    if (available.isNotEmpty) {
      return openApp(available.first.packageName);
    }
    return false;
  }

  /// Check if an Android package is installed and can handle intents
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
    // Fallback on iOS / web
    return false;
  }

  /// Queries all installed packages capable of handling upi://pay on this device
  static Future<List<String>> getInstalledUpiPackages() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return [];
    }

    try {
      final List<dynamic>? packages = await _channel.invokeMethod<List<dynamic>>('getInstalledUpiApps');
      if (packages != null) {
        return packages.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Returns which supported apps are actually installed on the current device
  static Future<List<SupportedUpiApp>> getAvailableSupportedApps() async {
    final installedPackages = await getInstalledUpiPackages();
    final List<SupportedUpiApp> available = [];

    for (final app in UpiApps.allApps) {
      if (installedPackages.contains(app.packageName)) {
        available.add(app);
      } else {
        // Fallback individual check
        final installed = await isPackageInstalled(app.packageName);
        if (installed) {
          available.add(app);
        }
      }
    }
    return available;
  }

  /// Launches the external payment application strictly as a separate Android app.
  /// Does NOT use a WebView, embedded browser, or in-app payment screen.
  ///
  /// If [preferredAppId] is 'ask_every_time' or null:
  /// -> Launches Android generic intent chooser.
  ///
  /// If [preferredAppId] is a specific app (e.g. 'google_pay', 'phonepe'):
  /// -> Attempts direct launch of that package.
  /// -> If not installed, returns UpiLaunchResult with appNotInstalled = true.
  static Future<UpiLaunchResult> launchPayment({
    required UpiPaymentData paymentData,
    double? customAmount,
    String? preferredAppId,
  }) async {
    final uri = buildSafeUpiUri(
      upiId: paymentData.upiId,
      payeeName: paymentData.payeeName,
      amount: customAmount ?? paymentData.amount,
      currency: paymentData.currency,
      transactionRef: paymentData.transactionRef,
      transactionId: paymentData.transactionId,
      note: paymentData.note,
      merchantCode: paymentData.merchantCode,
    );

    final upiUriString = uri.toString();
    final targetAppId = preferredAppId ?? UpiApps.askEveryTime;

    // 1. Android Platform Intent Launch
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      String? targetPackage;
      if (targetAppId != UpiApps.askEveryTime) {
        final app = UpiApps.findById(targetAppId);
        if (app != null) {
          final isInstalled = await isPackageInstalled(app.packageName);
          if (!isInstalled) {
            return UpiLaunchResult(
              success: false,
              appNotInstalled: true,
              errorMessage: '${app.name} is not installed on this device.',
            );
          }
          targetPackage = app.packageName;
        }
      }

      try {
        final dynamic rawResult = await _channel.invokeMethod('launchUpiIntent', {
          'upiUri': upiUriString,
          'packageName': targetPackage,
        });

        return UpiLaunchResult(
          success: true,
          launchedPackage: targetPackage,
          rawResponse: rawResult is Map ? rawResult : null,
        );
      } on PlatformException catch (pe) {
        if (pe.code == 'NOT_INSTALLED') {
          return UpiLaunchResult(
            success: false,
            appNotInstalled: true,
            errorMessage: pe.message,
          );
        }
        // Fallback to url_launcher external application
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return UpiLaunchResult(
          success: launched,
          errorMessage: launched ? null : pe.message,
        );
      } catch (e) {
        // Fallback to external application
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        return UpiLaunchResult(
          success: launched,
          errorMessage: launched ? null : e.toString(),
        );
      }
    }

    // 2. Non-Android (e.g. iOS or Desktop): Standard external application launch
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      return UpiLaunchResult(
        success: launched,
        errorMessage: launched ? null : 'Could not launch UPI application',
      );
    } catch (e) {
      return UpiLaunchResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}
