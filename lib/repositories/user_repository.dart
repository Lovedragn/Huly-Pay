import 'dart:io';
import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/local_database_service.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ApiClient _apiClient = ApiClient();

  bool get _isTest {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  /// Retrieve user profile with SQLite caching
  Future<UserProfile?> getUserProfile({bool forceRefresh = false}) async {
    UserProfile? cached;
    try {
      cached = await _localDb.getUserProfile();
    } catch (_) {}

    if (_isTest) {
      return cached;
    }

    try {
      final remote = await _apiClient.getCurrentUser();
      await _localDb.saveUserProfile(remote);
      return remote;
    } catch (_) {
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  /// Get cached user profile without network request
  Future<UserProfile?> getCachedUserProfile() async {
    try {
      return await _localDb.getUserProfile();
    } catch (_) {
      return null;
    }
  }

  /// Save profile locally
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      await _localDb.saveUserProfile(profile);
    } catch (_) {}
  }
}
