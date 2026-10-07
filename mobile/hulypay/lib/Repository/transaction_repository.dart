import '../Model/transaction_model.dart';
import '../Service/api_client.dart';
import '../Service/auth_service.dart';
import '../Service/local_database_service.dart';

class TransactionRepository {
  static final TransactionRepository _instance = TransactionRepository._internal();
  factory TransactionRepository() => _instance;
  TransactionRepository._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ApiClient _apiClient = ApiClient();

  /// Retrieve transactions with offline-first SQLite cache
  /// 1. Immediately returns cached transactions from SQLite if available and not forced to refresh
  /// 2. Fetches fresh transactions from Spring Boot backend and syncs with SQLite
  Future<List<PaymentModel>> getTransactions({bool forceRefresh = false}) async {
    // 1. Check local SQLite cache
    List<PaymentModel> cached = [];
    try {
      cached = await _localDb.getPayments();
    } catch (_) {}

    // Avoid making an unauthenticated network request that triggers a 401 error in DevTools Network tab
    if (!AuthService().hasValidActiveToken) {
      return cached;
    }

    // 2. Fetch fresh transactions from Spring Boot backend
    try {
      final remote = await _apiClient.getPayments();
      if (remote.isNotEmpty) {
        await _localDb.upsertPayments(remote);
        return await _localDb.getPayments();
      }
    } catch (_) {}

    // 3. Auto-sync pending local transactions to Supabase & query fresh cloud transactions
    try {
      final client = AuthService().client;
      final user = AuthService().currentUser;
      if (client != null && user != null) {
        await syncLocalTransactionsToSupabase();

        final data = await client
            .from('transactions')
            .select()
            .order('created_at', ascending: false);

        if (data.isNotEmpty) {
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

  // Alias for backward compatibility
  Future<List<PaymentModel>> getPayments({bool forceRefresh = false}) =>
      getTransactions(forceRefresh: forceRefresh);

  /// Sync all pending/unsynced local SQLite transactions to Supabase & Spring Boot
  Future<int> syncLocalTransactionsToSupabase() async {
    final unsynced = await _localDb.getUnsyncedPayments();
    if (unsynced.isEmpty) return 0;

    int syncedCount = 0;
    final client = AuthService().client;
    final user = AuthService().currentUser;

    for (final p in unsynced) {
      bool synced = false;

      // 1. Try syncing to Spring Boot backend first if authenticated
      if (AuthService().hasValidActiveToken) {
        try {
          final payload = CreatePaymentPayload(
            amount: p.amount,
            currency: p.currency,
            merchantName: p.merchantName,
            upiId: p.upiId,
            paymentMethod: p.paymentMethod,
            transactionReference: p.transactionReference,
            upiTransactionId: p.upiTransactionId,
            status: p.status,
            provider: p.provider,
            latitude: p.latitude,
            longitude: p.longitude,
            locationAccuracyMeters: p.locationAccuracyMeters,
          );
          final remote = await _apiClient.createPayment(payload);
          await _localDb.markPaymentSynced(p.id, remote);
          synced = true;
          syncedCount++;
        } catch (_) {}
      }

      // 2. Fallback to direct Supabase insert if backend didn't handle it
      if (!synced && client != null && user != null) {
        try {
          final nowStr = p.createdAt ?? DateTime.now().toUtc().toIso8601String();
          final res = await client.from('transactions').insert({
            'user_id': user.id,
            'amount': p.amount,
            'currency': p.currency,
            'merchant_name': p.merchantName,
            'category': (p.category != null && p.category!.isNotEmpty) ? p.category : 'Others',
            'description': p.merchantName ?? (p.paymentMethod ?? 'UPI'),
            'upi_id': p.upiId,
            'payment_method': p.paymentMethod,
            'transaction_reference': p.transactionReference,
            'upi_transaction_id': p.upiTransactionId,
            'status': p.status,
            'provider': p.provider ?? 'GOOGLE_PAY',
            'latitude': p.latitude,
            'longitude': p.longitude,
            'location_accuracy_meters': p.locationAccuracyMeters,
            'transaction_time': nowStr,
            'created_at': nowStr,
            'updated_at': nowStr,
          }).select().single();

          if (res['id'] != null) {
            final syncedModel = PaymentModel.fromJson(Map<String, dynamic>.from(res));
            await _localDb.markPaymentSynced(p.id, syncedModel);
            syncedCount++;
          }
        } catch (_) {}
      }
    }

    return syncedCount;
  }

  // Alias for backward compatibility
  Future<int> syncLocalPaymentsToSupabase() => syncLocalTransactionsToSupabase();

  /// Get cached transactions directly from SQLite without network call
  Future<List<PaymentModel>> getCachedTransactions() async {
    try {
      return await _localDb.getPayments();
    } catch (_) {
      return [];
    }
  }

  // Alias for backward compatibility
  Future<List<PaymentModel>> getCachedPayments() => getCachedTransactions();

  /// Purges failed/cancelled transactions and pending transactions older than 1 day
  Future<int> cleanupStaleTransactions() async {
    try {
      return await _localDb.cleanupStalePayments();
    } catch (_) {
      return 0;
    }
  }

  // Alias for backward compatibility
  Future<int> cleanupStalePayments() => cleanupStaleTransactions();

  /// Retrieve transaction by ID with cache fallback
  Future<PaymentModel> getTransactionById(String id) async {
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
            .from('transactions')
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
    throw Exception('Transaction not found');
  }

  // Alias for backward compatibility
  Future<PaymentModel> getPaymentById(String id) => getTransactionById(id);

  /// Create a transaction and immediately persist to local SQLite and Supabase
  Future<PaymentModel> createTransaction(CreatePaymentPayload payload) async {
    // Only attempt remote API if user has a valid active token
    if (AuthService().hasValidActiveToken) {
      try {
        final payment = await _apiClient.createPayment(payload);
        try {
          await _localDb.upsertPayment(payment);
        } catch (_) {}
        return payment;
      } catch (_) {}
    }

    // Direct Supabase sync if backend is offline or unreachable
    try {
      final client = AuthService().client;
      final user = AuthService().currentUser;
      if (client != null && user != null) {
        final now = DateTime.now().toUtc().toIso8601String();
        final response = await client.from('transactions').insert({
          'user_id': user.id,
          'amount': payload.amount,
          'currency': payload.currency,
          'merchant_name': payload.merchantName,
          'category': (payload.category != null && payload.category!.isNotEmpty) ? payload.category : 'Others',
          'description': payload.merchantName ?? payload.paymentMethod,
          'upi_id': payload.upiId,
          'payment_method': payload.paymentMethod,
          'transaction_reference': payload.transactionReference,
          'upi_transaction_id': payload.upiTransactionId,
          'status': payload.status ?? 'CONFIRMED',
          'provider': payload.provider ?? 'GOOGLE_PAY',
          'latitude': payload.latitude,
          'longitude': payload.longitude,
          'location_accuracy_meters': payload.locationAccuracyMeters,
          'transaction_time': now,
          'created_at': now,
          'updated_at': now,
        }).select().single();
        final payment = PaymentModel.fromJson(Map<String, dynamic>.from(response as Map));
        await _localDb.upsertPayment(payment, syncStatus: 'SYNCED');
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
      upiTransactionId: payload.upiTransactionId,
      status: payload.status ?? 'CONFIRMED',
      provider: payload.provider ?? 'GOOGLE_PAY',
      latitude: payload.latitude,
      longitude: payload.longitude,
      locationAccuracyMeters: payload.locationAccuracyMeters,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    try {
      await _localDb.upsertPayment(localPayment, syncStatus: 'PENDING');
      return localPayment;
    } catch (_) {
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<PaymentModel> createPayment(CreatePaymentPayload payload) =>
      createTransaction(payload);

  /// Reconcile transaction status and update SQLite cache and Supabase
  Future<PaymentModel> reconcileTransaction(
    String id,
    String status, {
    String? upiTransactionId,
    String? transactionReference,
  }) async {
    // 1. Update Spring Boot backend
    try {
      final payment = await _apiClient.reconcilePayment(
        id,
        status,
        upiTransactionId: upiTransactionId,
        transactionReference: transactionReference,
      );
      try {
        await _localDb.upsertPayment(payment, syncStatus: 'SYNCED');
      } catch (_) {}
      return payment;
    } catch (_) {
      // 2. Direct Supabase update fallback
      final client = AuthService().client;
      if (client != null && !id.startsWith('local_')) {
        try {
          final Map<String, dynamic> updateFields = {
            'status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          };
          if (upiTransactionId != null) {
            updateFields['upi_transaction_id'] = upiTransactionId;
          }
          if (transactionReference != null) {
            updateFields['transaction_reference'] = transactionReference;
          }
          final res = await client.from('transactions').update(updateFields).eq('id', id).select().maybeSingle();

          if (res != null) {
            final updatedSupabase = PaymentModel.fromJson(Map<String, dynamic>.from(res as Map));
            await _localDb.upsertPayment(updatedSupabase, syncStatus: 'SYNCED');
            return updatedSupabase;
          }
        } catch (_) {}
      }

      // 3. Offline fallback: update local record in SQLite
      final existing = await _localDb.getPaymentById(id);
      if (existing != null) {
        final updated = existing.copyWith(
          status: status,
          upiTransactionId: upiTransactionId ?? existing.upiTransactionId,
          transactionReference: transactionReference ?? existing.transactionReference,
        );
        try {
          await _localDb.upsertPayment(updated, syncStatus: 'PENDING');
        } catch (_) {}
        return updated;
      }
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<PaymentModel> reconcilePayment(
    String id,
    String status, {
    String? upiTransactionId,
    String? transactionReference,
  }) =>
      reconcileTransaction(
        id,
        status,
        upiTransactionId: upiTransactionId,
        transactionReference: transactionReference,
      );

  /// Verify an incoming transaction SMS against a pending transaction with Spring Boot
  Future<Map<String, dynamic>> verifyTransactionSms({
    required String paymentId,
    required String smsBody,
    String? sender,
    String? receivedAt,
  }) async {
    try {
      final res = await _apiClient.verifyPaymentSms(
        paymentId: paymentId,
        smsBody: smsBody,
        sender: sender,
        receivedAt: receivedAt,
      );

      if (res['payment'] != null && res['payment'] is Map) {
        final paymentMap = Map<String, dynamic>.from(res['payment'] as Map);
        final payment = PaymentModel.fromJson(paymentMap);
        await _localDb.upsertPayment(payment, syncStatus: 'SYNCED');
      } else if (res['verified'] == true) {
        final newStatus = (res['status']?.toString().toUpperCase() == 'FAILED') ? 'FAILED' : 'CONFIRMED';
        try {
          await reconcileTransaction(
            paymentId,
            newStatus,
            upiTransactionId: res['extractedUpiReference']?.toString(),
          );
        } catch (_) {}
      }
      return res;
    } catch (_) {
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<Map<String, dynamic>> verifyPaymentSms({
    required String paymentId,
    required String smsBody,
    String? sender,
    String? receivedAt,
  }) =>
      verifyTransactionSms(
        paymentId: paymentId,
        smsBody: smsBody,
        sender: sender,
        receivedAt: receivedAt,
      );

  /// Update transaction amount in local SQLite and Supabase
  Future<PaymentModel?> updateTransactionAmount(String id, double newAmount) async {
    // 1. Update local SQLite cache
    PaymentModel? updatedPayment;
    try {
      final existing = await _localDb.getPaymentById(id);
      if (existing != null) {
        updatedPayment = existing.copyWith(
          amount: newAmount,
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );
        await _localDb.upsertPayment(
          updatedPayment,
          syncStatus: id.startsWith('local_') ? 'PENDING' : 'SYNCED',
        );
      }
    } catch (_) {}

    // 2. Update Supabase if connected
    try {
      final client = AuthService().client;
      if (client != null && !id.startsWith('local_') && !id.startsWith('tx_')) {
        final res = await client
            .from('transactions')
            .update({
              'amount': newAmount,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .select()
            .maybeSingle();

        if (res != null) {
          final synced = PaymentModel.fromJson(Map<String, dynamic>.from(res as Map));
          await _localDb.upsertPayment(synced, syncStatus: 'SYNCED');
          return synced;
        }
      }
    } catch (_) {}

    return updatedPayment;
  }

  /// Delete a transaction from local SQLite and Supabase
  Future<void> deleteTransaction(String id) async {
    // 1. Delete from local SQLite cache
    try {
      await _localDb.deletePayment(id);
    } catch (_) {}

    // 2. Delete from Supabase if connected
    try {
      final client = AuthService().client;
      if (client != null && !id.startsWith('local_')) {
        await client.from('transactions').delete().eq('id', id);
      }
    } catch (_) {}
  }

  // Alias for backward compatibility
  Future<void> deletePayment(String id) => deleteTransaction(id);
}

// Global alias for compatibility
typedef PaymentRepository = TransactionRepository;
