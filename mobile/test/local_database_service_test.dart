import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/category_model.dart';
import 'package:mobile/models/payment_model.dart';
import 'package:mobile/models/user_profile.dart';
import 'package:mobile/repositories/payment_repository.dart';
import 'package:mobile/repositories/user_repository.dart';
import 'package:mobile/services/local_database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalDatabaseService dbService;

  setUp(() async {
    dbService = LocalDatabaseService();
    // Initialize in-memory SQLite database for isolated test execution
    await dbService.initDatabase(inMemory: true);
  });

  tearDown(() async {
    await dbService.close();
  });

  group('LocalDatabaseService SQLite Unit Tests', () {
    test('Database is initialized and open in-memory', () async {
      expect(dbService.isOpen, isTrue);
      final db = await dbService.database;
      expect(db.isOpen, isTrue);
    });

    test('Upsert and retrieve cached payment record', () async {
      final payment = PaymentModel(
        id: 'sqlite_pay_1001',
        userId: 'usr_abc_123',
        amount: 349.99,
        currency: 'INR',
        merchantName: 'Blue Tokai Coffee Roasters',
        upiId: 'bluetokai@icici',
        paymentMethod: 'GPAY',
        transactionReference: 'REF-BT-001',
        status: 'CONFIRMED',
        latitude: 12.9345,
        longitude: 77.6101,
        locationAccuracyMeters: 4.2,
        createdAt: '2026-09-13T10:00:00Z',
      );

      await dbService.upsertPayment(payment);

      final retrieved = await dbService.getPaymentById('sqlite_pay_1001');
      expect(retrieved, isNotNull);
      expect(retrieved?.id, equals('sqlite_pay_1001'));
      expect(retrieved?.merchantName, equals('Blue Tokai Coffee Roasters'));
      expect(retrieved?.amount, equals(349.99));
      expect(retrieved?.latitude, equals(12.9345));
      expect(retrieved?.longitude, equals(77.6101));
      expect(retrieved?.status, equals('CONFIRMED'));
    });

    test('Upsert multiple payments and query with chronological ordering', () async {
      final payments = [
        PaymentModel(
          id: 'p_older',
          amount: 150.0,
          currency: 'INR',
          merchantName: 'Metro Station',
          status: 'CONFIRMED',
          createdAt: '2026-09-12T08:00:00Z',
        ),
        PaymentModel(
          id: 'p_newer',
          amount: 520.0,
          currency: 'INR',
          merchantName: 'Bookstore',
          status: 'CONFIRMED',
          createdAt: '2026-09-13T12:00:00Z',
        ),
      ];

      await dbService.upsertPayments(payments);

      final list = await dbService.getPayments();
      expect(list.length, equals(2));
      // Ordered by created_at DESC -> p_newer should be first
      expect(list.first.id, equals('p_newer'));
      expect(list.last.id, equals('p_older'));
    });

    test('Filter payments by status in SQLite', () async {
      final payments = [
        PaymentModel(
          id: 'p_confirmed',
          amount: 200,
          currency: 'INR',
          merchantName: 'Supermarket',
          status: 'CONFIRMED',
          createdAt: '2026-09-13T09:00:00Z',
        ),
        PaymentModel(
          id: 'p_failed',
          amount: 750,
          currency: 'INR',
          merchantName: 'Apparel Store',
          status: 'FAILED',
          createdAt: '2026-09-13T09:30:00Z',
        ),
      ];

      await dbService.upsertPayments(payments);

      final failedList = await dbService.getPayments(status: 'FAILED');
      expect(failedList.length, equals(1));
      expect(failedList.first.id, equals('p_failed'));

      final confirmedList = await dbService.getPayments(status: 'CONFIRMED');
      expect(confirmedList.length, equals(1));
      expect(confirmedList.first.id, equals('p_confirmed'));
    });

    test('Save and retrieve UserProfile in SQLite cache', () async {
      final profile = UserProfile(
        id: 'usr_sqlite_777',
        email: 'developer@hulypay.com',
        fullName: 'Dev Lead',
        firstName: 'Dev',
        lastName: 'Lead',
        phoneNumber: '+919988776655',
        avatarUrl: 'https://hulypay.com/dev.png',
        authProvider: 'google',
        active: true,
      );

      await dbService.saveUserProfile(profile);

      final cached = await dbService.getUserProfile();
      expect(cached, isNotNull);
      expect(cached?.id, equals('usr_sqlite_777'));
      expect(cached?.email, equals('developer@hulypay.com'));
      expect(cached?.fullName, equals('Dev Lead'));
      expect(cached?.displayName, equals('Dev Lead'));
    });

    test('Save and retrieve Categories in SQLite cache', () async {
      final categories = [
        CategoryModel(id: 'c1', name: 'Food & Dining', icon: 'food', color: '#FF9500'),
        CategoryModel(id: 'c2', name: 'Shopping', icon: 'cart', color: '#007AFF'),
      ];

      await dbService.saveCategories(categories);

      final cached = await dbService.getCategories();
      expect(cached.length, equals(2));
      expect(cached.any((c) => c.name == 'Food & Dining'), isTrue);
      expect(cached.any((c) => c.name == 'Shopping'), isTrue);
    });

    test('Save and retrieve Cache Metadata in SQLite', () async {
      await dbService.setMetadata('payments_last_sync', '2026-09-13T14:30:00Z');

      final value = await dbService.getMetadata('payments_last_sync');
      expect(value, equals('2026-09-13T14:30:00Z'));
    });

    test('clearAll wipes SQLite cached tables', () async {
      await dbService.upsertPayment(
        PaymentModel(id: 'temp_p', amount: 10, currency: 'INR', status: 'CONFIRMED'),
      );
      await dbService.saveUserProfile(
        UserProfile(id: 'temp_u', email: 'temp@hulypay.com'),
      );

      await dbService.clearAll();

      final payments = await dbService.getPayments();
      final profile = await dbService.getUserProfile();

      expect(payments, isEmpty);
      expect(profile, isNull);
    });
  });

  group('PaymentRepository & UserRepository SQLite Offline Integration Tests', () {
    test('PaymentRepository getCachedPayments returns local SQLite data without network', () async {
      final payment = PaymentModel(
        id: 'offline_cache_p1',
        amount: 880.0,
        currency: 'INR',
        merchantName: 'Offline Merchant',
        status: 'CONFIRMED',
        createdAt: '2026-09-13T11:15:00Z',
      );

      await dbService.upsertPayment(payment);

      final cached = await PaymentRepository().getCachedPayments();
      expect(cached.length, equals(1));
      expect(cached.first.id, equals('offline_cache_p1'));
      expect(cached.first.merchantName, equals('Offline Merchant'));
    });

    test('UserRepository getCachedUserProfile returns local SQLite profile without network', () async {
      final profile = UserProfile(
        id: 'usr_offline_cache',
        email: 'cached_user@hulypay.com',
        fullName: 'Cached User',
      );

      await dbService.saveUserProfile(profile);

      final cached = await UserRepository().getCachedUserProfile();
      expect(cached, isNotNull);
      expect(cached?.displayName, equals('Cached User'));
    });
  });
}
