import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/category_model.dart';
import '../models/payment_model.dart';
import '../models/user_profile.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal() {
    _ensureFfiInitialized();
  }

  static const String dbName = 'huly_pay.db';
  static const int dbVersion = 1;

  Database? _db;
  bool _isFfiInitialized = false;

  /// Check if the database instance is open
  bool get isOpen => _db != null && _db!.isOpen;

  /// Ensure FFI is initialized for Desktop and Test environments
  void _ensureFfiInitialized() {
    if (_isFfiInitialized) return;

    bool needsFfi = kIsWeb ? false : (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        needsFfi = true;
      }
    } catch (_) {}

    if (needsFfi) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _isFfiInitialized = true;
  }

  /// Initialize and open the SQLite database
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) {
      return _db!;
    }
    _db = await initDatabase();
    return _db!;
  }

  /// Opens the database, allowing an optional custom path or inMemory mode for testing
  Future<Database> initDatabase({String? customPath, bool inMemory = false}) async {
    _ensureFfiInitialized();

    String path;
    if (inMemory) {
      path = inMemoryDatabasePath;
    } else if (customPath != null && customPath.isNotEmpty) {
      path = customPath;
    } else {
      path = await _resolveDefaultDbPath();
    }

    final db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _db = db;
    return db;
  }

  bool get _isTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  Future<String> _resolveDefaultDbPath() async {
    if (_isTest) {
      return inMemoryDatabasePath;
    }
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      final databasesPath = await getDatabasesPath();
      return p.join(databasesPath, dbName);
    } else {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        return p.join(docsDir.path, 'HulyPay', dbName);
      } catch (_) {
        final databasesPath = await getDatabasesPath();
        return p.join(databasesPath, dbName);
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Cached Payments Table
    await db.execute('''
      CREATE TABLE cached_payments (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        merchant_name TEXT,
        upi_id TEXT,
        payment_method TEXT,
        transaction_reference TEXT,
        upi_transaction_id TEXT,
        status TEXT NOT NULL,
        provider TEXT,
        latitude REAL,
        longitude REAL,
        location_accuracy_meters REAL,
        payment_date TEXT,
        payment_time TEXT,
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'SYNCED'
      )
    ''');

    // Index on created_at for fast descending queries
    await db.execute('''
      CREATE INDEX idx_cached_payments_created_at ON cached_payments (created_at DESC)
    ''');

    // Index on status
    await db.execute('''
      CREATE INDEX idx_cached_payments_status ON cached_payments (status)
    ''');

    // 2. Cached User Profile Table
    await db.execute('''
      CREATE TABLE cached_user_profile (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        full_name TEXT,
        first_name TEXT,
        last_name TEXT,
        phone_number TEXT,
        avatar_url TEXT,
        auth_provider TEXT,
        active INTEGER DEFAULT 1,
        cached_at TEXT NOT NULL
      )
    ''');

    // 3. Cached Categories Table
    await db.execute('''
      CREATE TABLE cached_categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        is_default INTEGER DEFAULT 0
      )
    ''');

    // 4. Cache Metadata Table
    await db.execute('''
      CREATE TABLE cache_metadata (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Schema migration logic for future versions
  }

  // ==========================================
  // PAYMENT OPERATIONS
  // ==========================================

  Future<void> upsertPayment(PaymentModel payment, {String syncStatus = 'SYNCED'}) async {
    final db = await database;
    await db.insert(
      'cached_payments',
      {
        'id': payment.id,
        'user_id': payment.userId,
        'amount': payment.amount,
        'currency': payment.currency,
        'merchant_name': payment.merchantName,
        'upi_id': payment.upiId,
        'payment_method': payment.paymentMethod,
        'transaction_reference': payment.transactionReference,
        'upi_transaction_id': payment.upiTransactionId,
        'status': payment.status,
        'provider': payment.provider,
        'latitude': payment.latitude,
        'longitude': payment.longitude,
        'location_accuracy_meters': payment.locationAccuracyMeters,
        'payment_date': payment.paymentDate,
        'payment_time': payment.paymentTime,
        'created_at': payment.createdAt ?? DateTime.now().toIso8601String(),
        'updated_at': payment.updatedAt ?? DateTime.now().toIso8601String(),
        'sync_status': syncStatus,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertPayments(List<PaymentModel> payments, {String syncStatus = 'SYNCED'}) async {
    if (payments.isEmpty) return;
    final db = await database;
    final batch = db.batch();

    for (final payment in payments) {
      batch.insert(
        'cached_payments',
        {
          'id': payment.id,
          'user_id': payment.userId,
          'amount': payment.amount,
          'currency': payment.currency,
          'merchant_name': payment.merchantName,
          'upi_id': payment.upiId,
          'payment_method': payment.paymentMethod,
          'transaction_reference': payment.transactionReference,
          'upi_transaction_id': payment.upiTransactionId,
          'status': payment.status,
          'provider': payment.provider,
          'latitude': payment.latitude,
          'longitude': payment.longitude,
          'location_accuracy_meters': payment.locationAccuracyMeters,
          'payment_date': payment.paymentDate,
          'payment_time': payment.paymentTime,
          'created_at': payment.createdAt ?? DateTime.now().toIso8601String(),
          'updated_at': payment.updatedAt ?? DateTime.now().toIso8601String(),
          'sync_status': syncStatus,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Retains all payments in SQLite history without purging stale records.
  /// Returns 0 as no records are deleted.
  Future<int> cleanupStalePayments() async {
    return 0;
  }

  Future<List<PaymentModel>> getPayments({String? status, int? limit, int? offset}) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (status != null && status.isNotEmpty) {
      whereClause = 'status = ?';
      whereArgs = [status];
    }

    final rows = await db.query(
      'cached_payments',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map((row) => _mapRowToPayment(row)).toList();
  }

  Future<PaymentModel?> getPaymentById(String id) async {
    final db = await database;
    final rows = await db.query(
      'cached_payments',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _mapRowToPayment(rows.first);
  }

  Future<int> deletePayment(String id) async {
    final db = await database;
    return await db.delete(
      'cached_payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> clearPayments() async {
    final db = await database;
    return await db.delete('cached_payments');
  }

  PaymentModel _mapRowToPayment(Map<String, dynamic> row) {
    return PaymentModel(
      id: row['id'] as String,
      userId: row['user_id'] as String?,
      amount: (row['amount'] as num).toDouble(),
      currency: row['currency'] as String? ?? 'INR',
      merchantName: row['merchant_name'] as String?,
      upiId: row['upi_id'] as String?,
      paymentMethod: row['payment_method'] as String?,
      transactionReference: row['transaction_reference'] as String?,
      upiTransactionId: row['upi_transaction_id'] as String?,
      status: row['status'] as String,
      provider: row['provider'] as String?,
      latitude: (row['latitude'] as num?)?.toDouble(),
      longitude: (row['longitude'] as num?)?.toDouble(),
      locationAccuracyMeters: (row['location_accuracy_meters'] as num?)?.toDouble(),
      paymentDate: row['payment_date'] as String?,
      paymentTime: row['payment_time'] as String?,
      createdAt: row['created_at'] as String?,
      updatedAt: row['updated_at'] as String?,
    );
  }

  // ==========================================
  // USER PROFILE OPERATIONS
  // ==========================================

  Future<void> saveUserProfile(UserProfile profile) async {
    final db = await database;
    await db.insert(
      'cached_user_profile',
      {
        'id': profile.id,
        'email': profile.email,
        'full_name': profile.fullName,
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'phone_number': profile.phoneNumber,
        'avatar_url': profile.avatarUrl,
        'auth_provider': profile.authProvider,
        'active': profile.active ? 1 : 0,
        'cached_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final rows = await db.query(
      'cached_user_profile',
      orderBy: 'cached_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    final row = rows.first;
    return UserProfile(
      id: row['id'] as String,
      email: row['email'] as String,
      fullName: row['full_name'] as String?,
      firstName: row['first_name'] as String?,
      lastName: row['last_name'] as String?,
      phoneNumber: row['phone_number'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      authProvider: row['auth_provider'] as String?,
      active: (row['active'] as int? ?? 1) == 1,
    );
  }

  Future<int> clearUserProfile() async {
    final db = await database;
    return await db.delete('cached_user_profile');
  }

  // ==========================================
  // CATEGORIES OPERATIONS
  // ==========================================

  Future<void> saveCategories(List<CategoryModel> categories) async {
    if (categories.isEmpty) return;
    final db = await database;
    final batch = db.batch();

    for (final cat in categories) {
      batch.insert(
        'cached_categories',
        {
          'id': cat.id,
          'name': cat.name,
          'icon': cat.icon,
          'color': cat.color,
          'is_default': cat.isDefault ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await database;
    final rows = await db.query('cached_categories', orderBy: 'name ASC');

    return rows.map((row) {
      return CategoryModel(
        id: row['id'] as String,
        name: row['name'] as String,
        icon: row['icon'] as String?,
        color: row['color'] as String?,
        isDefault: (row['is_default'] as int? ?? 0) == 1,
      );
    }).toList();
  }

  // ==========================================
  // METADATA OPERATIONS
  // ==========================================

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'cache_metadata',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final rows = await db.query(
      'cache_metadata',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  // ==========================================
  // CLEANUP & RESET
  // ==========================================

  Future<void> clearAll() async {
    if (_isTest && (_db == null || !_db!.isOpen)) {
      return;
    }
    final db = await database;
    await db.delete('cached_payments');
    await db.delete('cached_user_profile');
    await db.delete('cached_categories');
    await db.delete('cache_metadata');
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
