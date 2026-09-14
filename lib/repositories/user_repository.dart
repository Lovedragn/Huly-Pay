import '../models/user_profile.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/local_database_service.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  final LocalDatabaseService _localDb = LocalDatabaseService();
  final ApiClient _apiClient = ApiClient();

  /// Retrieve user profile with SQLite caching
  Future<UserProfile?> getUserProfile({bool forceRefresh = false}) async {
    UserProfile? cached;
    try {
      cached = await _localDb.getUserProfile();
    } catch (_) {}

    // Avoid making an unauthenticated network request that triggers a 401 error in DevTools Network tab
    if (!AuthService().hasValidActiveToken) {
      final authProfile = AuthService().currentUserProfile;
      if (authProfile != null) {
        await _localDb.saveUserProfile(authProfile);
        return authProfile;
      }
      return cached;
    }

    try {
      final remote = await _apiClient.getCurrentUser();
      final authProfile = AuthService().currentUserProfile;
      final merged = remote.copyWith(
        fullName: remote.fullName ?? authProfile?.fullName,
        avatarUrl: remote.avatarUrl ?? authProfile?.avatarUrl,
      );
      await _localDb.saveUserProfile(merged);
      return merged;
    } catch (_) {
      // Fallback to real Supabase / Google OAuth user metadata if backend is offline
      final authProfile = AuthService().currentUserProfile;
      if (authProfile != null) {
        await _localDb.saveUserProfile(authProfile);
        return authProfile;
      }
      if (cached != null) {
        return cached;
      }
      return null;
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
