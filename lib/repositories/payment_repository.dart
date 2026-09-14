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

    // 2. Fetch fresh payments from Spring Boot backend
    try {
      final remote = await _apiClient.getPayments();
      if (remote.isNotEmpty) {
        await _localDb.upsertPayments(remote);
        return await _localDb.getPayments();
      }
    } catch (_) {}

    // 3. Direct Supabase query fallback (works on cellular, outside LAN, or direct Supabase cloud)
    try {
      final client = AuthService().client;
      final user = AuthService().currentUser;
      if (client != null && user != null) {
        // Auto-sync any pending local offline payments to Supabase
        final unsynced = cached.where((p) => p.id.startsWith('local_')).toList();
        for (final p in unsynced) {
          try {
            final nowStr = p.createdAt ?? DateTime.now().toUtc().toIso8601String();
            final res = await client.from('payments').insert({
              'user_id': user.id,
              'amount': p.amount,
              'currency': p.currency,
              'merchant_name': p.merchantName,
              'upi_id': p.upiId,
              'payment_method': p.paymentMethod,
              'transaction_reference': p.transactionReference,
              'status': p.status,
              'created_at': nowStr,
              'updated_at': nowStr,
              'payment_date': p.paymentDate,
            }).select().single();
            if (res is Map && res['id'] != null) {
              await _localDb.deletePayment(p.id);
              final synced = PaymentModel.fromJson(Map<String, dynamic>.from(res));
              await _localDb.upsertPayment(synced);
            }
          } catch (_) {}
        }

        final data = await client
            .from('payments')
            .select()
            .order('created_at', ascending: false);

        if (data is List && data.isNotEmpty) {
          final supabasePayments = data
              .map((row) => PaymentModel.fromJson(Map<String, dynamic>.from(row as Map)))
              .where((p) => p.userId == null || p.userId == user.id)
              .toList();

          if (supabasePayments.isNotEmpty) {
            await _localDb.upsertPayments(supabasePayments);
            return await _localDb.getPayments();
          }
        }
      }
    } catch (_) {}

    // 4. Return cached list if remote requests fail
    return cached;
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
    } catch (_) {}

    // Supabase direct fallback
    try {
      final client = AuthService().client;
      if (client != null) {
        final data = await client
            .from('payments')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null) {
          final payment = PaymentModel.fromJson(Map<String, dynamic>.from(data));
          await _localDb.upsertPayment(payment);
          return payment;
        }
      }
    } catch (_) {}

    if (local != null) {
      return local;
    }
    throw Exception('Payment not found');
  }

  /// Create a payment and immediately persist to local SQLite and Supabase
  Future<PaymentModel> createPayment(CreatePaymentPayload payload) async {
    try {
      final payment = await _apiClient.createPayment(payload);
      try {
        await _localDb.upsertPayment(payment);
      } catch (_) {}
      return payment;
    } catch (_) {
      // Direct Supabase sync if backend is offline or unreachable
      try {
        final client = AuthService().client;
        final user = AuthService().currentUser;
        if (client != null && user != null) {
          final now = DateTime.now().toUtc().toIso8601String();
          final response = await client.from('payments').insert({
            'user_id': user.id,
            'amount': payload.amount,
            'currency': payload.currency,
            'merchant_name': payload.merchantName,
            'upi_id': payload.upiId,
            'payment_method': payload.paymentMethod,
            'transaction_reference': payload.transactionReference,
            'status': 'INITIATED',
            'latitude': payload.latitude,
            'longitude': payload.longitude,
            'location_accuracy_meters': payload.locationAccuracyMeters,
            'created_at': now,
            'updated_at': now,
          }).select().single();
          final payment = PaymentModel.fromJson(Map<String, dynamic>.from(response as Map));
          await _localDb.upsertPayment(payment);
          return payment;
        }
      } catch (_) {}

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
