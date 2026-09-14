import '../models/payment_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';

class PaymentRepository {
  static final PaymentRepository _instance = PaymentRepository._internal();
  factory PaymentRepository() => _instance;
  PaymentRepository._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ApiClient _apiClient = ApiClient();

  /// Retrieve payments with offline-first SQLite cache
  /// 1. Immediately returns cached payments from SQLite if available and not forced to refresh
  /// 2. Fetches fresh payments from Spring Boot backend and syncs with SQLite
  Future<List<PaymentModel>> getPayments({bool forceRefresh = false}) async {
    // 1. Check local SQLite cache
    List<PaymentModel> cached = [];
    try {
      cached = await _localDb.getPayments();
    } catch (_) {}

    // Avoid making an unauthenticated network request that triggers a 401 error in DevTools Network tab
    if (!AuthService().hasValidActiveToken) {
      return cached;
    }

    // If we have cached data and not forcing refresh, return immediately or continue background sync
    try {
      final remote = await _apiClient.getPayments();
      if (remote.isNotEmpty) {
        await _localDb.upsertPayments(remote);
        return remote;
      }
      return cached.isNotEmpty ? cached : remote;
    } catch (_) {
      // Return cached list if remote request fails (e.g. offline)
      if (cached.isNotEmpty) {
        return cached;
      }
      rethrow;
    }
  }

  /// Get cached payments directly from SQLite without network call
  Future<List<PaymentModel>> getCachedPayments() async {
    try {
      return await _localDb.getPayments();
    } catch (_) {
      return [];
    }
  }

  /// Retains all payment history in local SQLite
  Future<int> cleanupStalePayments() async {
    return 0;
  }

  /// Retrieve payment by ID with cache fallback
  Future<PaymentModel> getPaymentById(String id) async {
    PaymentModel? local;
    try {
      local = await _localDb.getPaymentById(id);
    } catch (_) {}

    try {
      final remote = await _apiClient.getPaymentById(id);
      await _localDb.upsertPayment(remote);
      return remote;
    } catch (_) {
      if (local != null) {
        return local;
      }
      rethrow;
    }
  }

  /// Create a payment and immediately persist to local SQLite
  Future<PaymentModel> createPayment(CreatePaymentPayload payload) async {
    try {
      final payment = await _apiClient.createPayment(payload);
      try {
        await _localDb.upsertPayment(payment);
      } catch (_) {}
      return payment;
    } catch (_) {
      // Offline / connection fallback: save locally so the user payment flow is never blocked
      final localPayment = PaymentModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        amount: payload.amount,
        currency: payload.currency,
        merchantName: payload.merchantName,
        upiId: payload.upiId,
        paymentMethod: payload.paymentMethod,
        transactionReference: payload.transactionReference,
        status: 'INITIATED',
        latitude: payload.latitude,
        longitude: payload.longitude,
        locationAccuracyMeters: payload.locationAccuracyMeters,
        createdAt: DateTime.now().toIso8601String(),
      );
      try {
        await _localDb.upsertPayment(localPayment);
        return localPayment;
      } catch (_) {
        rethrow;
      }
    }
  }

  /// Reconcile payment status and update SQLite cache
  Future<PaymentModel> reconcilePayment(
    String id,
    String status, {
    String? upiTransactionId,
    String? transactionReference,
  }) async {
    try {
      final payment = await _apiClient.reconcilePayment(
        id,
        status,
        upiTransactionId: upiTransactionId,
        transactionReference: transactionReference,
      );
      try {
        await _localDb.upsertPayment(payment);
      } catch (_) {}
      return payment;
    } catch (_) {
      // Offline fallback: update local record if remote connection fails
      final existing = await _localDb.getPaymentById(id);
      if (existing != null) {
        final updated = existing.copyWith(
          status: status,
          upiTransactionId: upiTransactionId ?? existing.upiTransactionId,
          transactionReference: transactionReference ?? existing.transactionReference,
        );
        try {
          await _localDb.upsertPayment(updated);
        } catch (_) {}
        return updated;
      }
      rethrow;
    }
  }
}
