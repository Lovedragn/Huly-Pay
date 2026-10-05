import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction_model.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic data;

  ApiException({
    this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'ApiException(status: $statusCode, message: $message)';
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  static const String defaultAndroidHost = 'http://10.0.2.2:8080';

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return defaultAndroidHost;
    } catch (_) {
      // Platform check may fail on web or non-standard hosts
    }
    return 'http://localhost:8080';
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }

  ApiClient._internal() {
    String baseUrl = defaultBaseUrl;
    if (dotenv.isInitialized && dotenv.env['API_BASE_URL'] != null && dotenv.env['API_BASE_URL']!.isNotEmpty) {
      final envUrl = dotenv.env['API_BASE_URL']!;
      bool isAndroid = false;
      try {
        isAndroid = !kIsWeb && Platform.isAndroid;
      } catch (_) {}

      if (!isAndroid && envUrl.contains('10.0.2.2')) {
        baseUrl = envUrl.replaceAll('10.0.2.2', 'localhost');
      } else {
        baseUrl = envUrl;
      }
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthService().currentAccessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            if (kDebugMode) {
              print('ApiClient: 401 Unauthorized encountered on ${error.requestOptions.path}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await dio.get('/api/health');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> checkAppVersion({
    required String platform,
    required String installedVersion,
  }) async {
    try {
      final response = await dio.get(
        '/api/app/version',
        queryParameters: {
          'platform': platform,
        },
        options: Options(
          headers: {
            'X-App-Version': installedVersion,
          },
        ),
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getDatabaseHealth() async {
    try {
      final response = await dio.get('/api/health/database');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserProfile> getCurrentUser() async {
    try {
      final response = await dio.get('/api/v1/users/me');
      return UserProfile.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<UserProfile> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
  }) async {
    try {
      final response = await dio.put(
        '/api/v1/users/me',
        data: {
          'firstName': ?firstName,
          'lastName': ?lastName,
          'avatarUrl': ?avatarUrl,
        },
      );
      return UserProfile.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // --- Transaction Endpoints ---

  Future<PaymentModel> createPayment(CreatePaymentPayload payload) async {
    try {
      final response = await dio.post(
        '/api/v1/transactions',
        data: payload.toJson(),
      );
      return PaymentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<PaymentModel>> getPayments() async {
    try {
      final response = await dio.get('/api/v1/transactions');
      final list = response.data as List;
      return list
          .map((item) => PaymentModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaymentModel> getPaymentById(String id) async {
    try {
      final response = await dio.get('/api/v1/transactions/$id');
      return PaymentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<PaymentModel> reconcilePayment(
    String id,
    String status, {
    String? upiTransactionId,
    String? transactionReference,
  }) async {
    try {
      final payload = ReconcilePaymentPayload(
        status: status,
        upiTransactionId: upiTransactionId,
        transactionReference: transactionReference,
      );
      final response = await dio.put(
        '/api/v1/transactions/$id/reconcile',
        data: payload.toJson(),
      );
      return PaymentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyPaymentSms({
    required String paymentId,
    required String smsBody,
    String? sender,
    String? receivedAt,
  }) async {
    try {
      final response = await dio.post(
        '/api/v1/transactions/$paymentId/sms-verification',
        data: {
          'smsBody': smsBody,
          'sender': ?sender,
          'receivedAt': ?receivedAt,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Requests the backend to generate a QR PNG image with the specified amount injected
  Future<List<int>> generateQrCode({
    required String uri,
    double? amount,
    int size = 512,
  }) async {
    try {
      final response = await dio.post<List<int>>(
        '/api/v1/qr/generate',
        data: {
          'uri': uri,
          'amount': ?amount,
          'size': size,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/png',
          },
        ),
      );
      return response.data ?? <int>[];
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  ApiException _handleDioError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    String message = 'API request failed';

    if (data is Map && data.containsKey('message')) {
      message = data['message'].toString();
    } else if (error.message != null && error.message!.isNotEmpty) {
      message = error.message!;
    }

    return ApiException(
      statusCode: status,
      message: message,
      data: data,
    );
  }
}

