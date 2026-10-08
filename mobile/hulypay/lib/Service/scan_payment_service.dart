import 'dart:io';

import 'package:flutter/foundation.dart';

import '../Model/transaction_model.dart';
import '../Repository/transaction_repository.dart';
import 'auth_service.dart';
import 'google_pay_service.dart';
import 'local_database_service.dart';
import 'location_service.dart';
import 'qr_service.dart';
import 'upi_payment_service.dart';
import 'upi_service.dart';
import 'user_preferences_service.dart';

/// Result of checking whether the preferred UPI app can be opened.
class UpiAppReadiness {
  final bool isReady;
  final SupportedUpiApp? app;

  const UpiAppReadiness({required this.isReady, this.app});
}

/// Result of launching a UPI app.
class UpiLaunchResult {
  final bool launched;
  final String? appName;

  const UpiLaunchResult({required this.launched, this.appName});
}

/// Business logic for the Scan & Pay flow, kept free of UI code.
class ScanPaymentService {
  ScanPaymentService._();

  static const Map<String, String> _providerById = {
    UpiApps.googlePay: 'GOOGLE_PAY',
    UpiApps.amazonPay: 'AMAZON_PAY',
    UpiApps.phonePe: 'PHONEPE',
    UpiApps.bhim: 'BHIM',
  };

  static bool get isQuickConfirm => UserPreferencesService().cachedQuickConfirm;

  static String get initialStatus => isQuickConfirm ? 'CONFIRMED' : 'PENDING';

  static String _newTxnRef() => 'REF_${DateTime.now().millisecondsSinceEpoch}';

  /// Converts a raw UPI ID or handle into a clean, human-readable merchant name.
  static String formatMerchantFromUpi(String upiId) {
    return TransactionModel.formatMerchantName(upiId);
  }

  /// Formats any payee name or UPI ID into a clean merchant name.
  static String formatMerchantName(String nameOrUpi) {
    return TransactionModel.formatMerchantName(nameOrUpi);
  }

  /// Label shown on the Pay button, e.g. "Google Pay".
  static String payButtonLabel() {
    final pref = UserPreferencesService().cachedDefaultPaymentApp;
    final app = UpiApps.findById(pref);
    final target = app?.name ??
        (pref == UpiApps.askEveryTime ? 'Any App' : 'UPI App');
    return target;
  }

  /// Extracts the best available merchant name for display and persistence.
  static String merchantLabel(UpiPaymentData data) {
    final payee = data.payeeName?.trim();
    if (payee != null && payee.isNotEmpty) return formatMerchantName(payee);
    final upi = data.upiId.trim();
    return upi.isNotEmpty ? formatMerchantFromUpi(upi) : 'UPI Merchant';
  }

  // ---------------------------------------------------------------------------
  // Server-generated QR flow
  // ---------------------------------------------------------------------------

  /// App the generated QR is shared to. "Ask every time" falls back to Google Pay.
  static Future<SupportedUpiApp> resolveShareTargetApp() async {
    final preferredAppId = await UserPreferencesService().getDefaultPaymentApp();
    if (preferredAppId == UpiApps.askEveryTime) return UpiApps.gpay;
    return UpiApps.findById(preferredAppId) ?? UpiApps.gpay;
  }

  /// Generates a new UPI QR code with `am=<amount>` locally on-device via [QrService].
  /// Returns the saved PNG file, or null on failure.
  static Future<File?> generateAmountQr({
    required String rawUri,
    required double amount,
    int size = 512,
  }) async {
    try {
      final localFile = await QrService().getOrGenerateQrFile(
        rawUri: rawUri,
        amount: amount,
        size: size,
      );
      if (localFile != null && await localFile.exists()) {
        debugPrint('[ScanPaymentService] Using client-generated QR: ${localFile.path}');
        return localFile;
      }
    } catch (e) {
      debugPrint('[ScanPaymentService] QR generation failed: $e');
    }
    return null;
  }

  /// Records a transaction after the generated QR was shared to a UPI app.
  static Future<void> recordSharedQrPayment({
    required UpiPaymentData upiData,
    required double amount,
    required SupportedUpiApp app,
  }) async {
    try {
      await TransactionRepository().createTransaction(
        CreatePaymentPayload(
          amount: amount,
          currency: upiData.currency,
          merchantName: merchantLabel(upiData),
          upiId: upiData.upiId.trim(),
          paymentMethod: 'UPI',
          transactionReference: _newTxnRef(),
          status: initialStatus,
          provider: app.name.toUpperCase().replaceAll(' ', '_'),
        ),
      );
    } catch (e) {
      debugPrint('[ScanPaymentService] Failed to record shared payment: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Direct-launch + SMS verification fallback flow
  // ---------------------------------------------------------------------------

  /// Returns true if SMS permission is (or becomes) granted.
  static Future<bool> ensureSmsPermission() async {
    if (await GooglePayService.isSmsPermissionGranted()) return true;
    return GooglePayService.requestSmsPermission();
  }

  static Future<UpiAppReadiness> checkPreferredAppReadiness() async {
    final preferredAppId = await UserPreferencesService().getDefaultPaymentApp();

    if (preferredAppId != UpiApps.askEveryTime) {
      final app = UpiApps.findById(preferredAppId);
      final ready =
          app == null ? true : await UpiPaymentService.isAppInstalled(app.id);
      return UpiAppReadiness(isReady: ready, app: app);
    }

    final installed = await UpiPaymentService.getInstalledUpiPackages();
    final ready = installed.isNotEmpty || await GooglePayService.isReadyToPay();
    return UpiAppReadiness(isReady: ready);
  }

  /// Looks up a category previously assigned to this UPI ID or merchant.
  static Future<String?> resolveAutoCategory(UpiPaymentData data) async {
    try {
      final db = LocalDatabaseService();
      final cleanUpi = data.upiId.toLowerCase().trim();
      if (cleanUpi.isNotEmpty) {
        final byUpi = await db.getMetadata('upi_category_$cleanUpi');
        if (byUpi != null && byUpi.isNotEmpty) return byUpi;
      }
      final merchant = data.payeeName?.toLowerCase().trim();
      if (merchant != null && merchant.isNotEmpty) {
        final byMerchant = await db.getMetadata('merchant_category_$merchant');
        if (byMerchant != null && byMerchant.isNotEmpty) return byMerchant;
      }
    } catch (_) {}
    return null;
  }

  /// Creates the pending payment (remote, or a local placeholder if offline)
  /// and applies any auto-resolved category.
  static Future<PaymentModel> createPendingPayment({
    required UpiPaymentData upiData,
    required double amount,
    required String appId,
    PaymentLocation? location,
  }) async {
    final status = initialStatus;
    final txnRef = _newTxnRef();
    final provider = _providerById[appId] ?? 'UPI';
    final autoCategory = await resolveAutoCategory(upiData);
    final paymentMethod = autoCategory ?? 'UPI';
    final resolvedMerchant = merchantLabel(upiData);

    PaymentModel payment;
    try {
      payment = await TransactionRepository().createTransaction(
        CreatePaymentPayload(
          amount: amount,
          currency: upiData.currency,
          merchantName: resolvedMerchant,
          upiId: upiData.upiId,
          paymentMethod: paymentMethod,
          transactionReference: txnRef,
          status: status,
          provider: provider,
          latitude: location?.latitude,
          longitude: location?.longitude,
          locationAccuracyMeters: location?.accuracyMeters,
        ),
      );
    } catch (_) {
      final nowIso = DateTime.now().toIso8601String();
      payment = PaymentModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        currency: upiData.currency,
        merchantName: resolvedMerchant,
        upiId: upiData.upiId,
        paymentMethod: paymentMethod,
        transactionReference: txnRef,
        status: status,
        provider: provider,
        latitude: location?.latitude,
        longitude: location?.longitude,
        locationAccuracyMeters: location?.accuracyMeters,
        createdAt: nowIso,
        updatedAt: nowIso,
      );
    }

    if (autoCategory != null) {
      await _persistCategory(payment.id, autoCategory);
    }
    return payment;
  }

  static Future<void> _persistCategory(String paymentId, String category) async {
    try {
      await LocalDatabaseService().setMetadata('category_$paymentId', category);
    } catch (_) {}

    final client = AuthService().client;
    if (client == null ||
        paymentId.startsWith('local_') ||
        paymentId.startsWith('tx_')) {
      return;
    }
    try {
      await client.from('transactions').update({
        'category': category,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', paymentId);
    } catch (_) {}
  }

  /// Opens the given UPI app with prefilled payment parameters, falling back to standalone launch.
  static Future<UpiLaunchResult> launchPaymentApp(
    String appId, {
    UpiPaymentData? upiData,
    double? amount,
  }) async {
    final app = UpiApps.findById(appId);
    final appName = app?.name;

    if (upiData != null) {
      final res = await UpiPaymentService.launchPayment(
        paymentData: upiData,
        customAmount: amount,
        preferredAppId: appId,
      );
      if (res.success) {
        return UpiLaunchResult(launched: true, appName: appName);
      }
    }

    var launched = false;
    if (appId != UpiApps.askEveryTime) {
      if (app != null) {
        launched = await UpiPaymentService.openApp(app.packageName);
      }
    } else {
      final available = await UpiPaymentService.getAvailableSupportedApps();
      if (available.isNotEmpty) {
        launched = await UpiPaymentService.openApp(available.first.packageName);
      }
    }

    if (!launched) {
      launched = await UpiPaymentService.launchStandaloneApp(
        preferredAppId: appId,
      );
    }
    return UpiLaunchResult(launched: launched, appName: appName);
  }

  /// Fire-and-forget status update; failures are logged, not thrown.
  static Future<void> reconcile(
    String paymentId,
    String status, {
    String? upiTransactionId,
  }) async {
    try {
      await TransactionRepository().reconcileTransaction(
        paymentId,
        status,
        upiTransactionId: upiTransactionId,
      );
    } catch (e) {
      debugPrint('[ScanPaymentService] reconcile($status) failed: $e');
    }
  }
}
