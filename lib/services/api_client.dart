import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  static String get defaultBaseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {
      // Platform check may fail on web or non-standard hosts
    }
    return 'http://localhost:8080';
  }

  ApiClient._internal() {
    final baseUrl = dotenv.isInitialized
        ? (dotenv.env['API_BASE_URL'] ?? defaultBaseUrl)
        : defaultBaseUrl;

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
        onError: (DioException error, handler) {
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
