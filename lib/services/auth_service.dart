import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  // Development / test mock fallback, strictly isolated from real application flow
  static bool _allowDevMock = false;
  static bool get isTestEnvironment {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }
  static bool get isDevMockAllowed => _allowDevMock || isTestEnvironment;

  static void enableMockForTesting([bool allow = true]) {
    _allowDevMock = allow;
  }

  static User? _devUser;
  static String? _devToken;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (anonKey.trim().isEmpty) {
      if (kDebugMode) {
        print('AuthService: SUPABASE_ANON_KEY is empty. Supabase authentication is not configured.');
      }
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        // ignore: deprecated_member_use
        anonKey: anonKey,
      );
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('AuthService: Supabase.initialize error: $e');
      }
      _initialized = false;
    }
  }

  SupabaseClient? get _client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Session? get currentSession => _client?.auth.currentSession;
  User? get currentUser => _client?.auth.currentUser ?? (isDevMockAllowed ? _devUser : null);

  String? get currentAccessToken {
    if (_client?.auth.currentSession?.accessToken != null) {
      return _client!.auth.currentSession!.accessToken;
    }
    return isDevMockAllowed ? _devToken : null;
  }

  bool get isAuthenticated => currentAccessToken != null && currentAccessToken!.isNotEmpty;

  UserProfile? get currentUserProfile {
    final user = currentUser;
    if (user == null) return null;

    final meta = user.userMetadata ?? {};
    final fullName = meta['full_name'] as String? ?? meta['name'] as String?;
    final avatar = meta['avatar_url'] as String? ?? meta['picture'] as String?;

    return UserProfile(
      id: user.id,
      email: user.email ?? '',
      fullName: fullName,
      avatarUrl: avatar,
      authProvider: user.appMetadata['provider'] as String? ?? 'google',
      active: true,
    );
  }

  Stream<AuthState> get onAuthStateChange {
    if (_client != null) {
      return _client!.auth.onAuthStateChange;
    }
    return const Stream<AuthState>.empty();
  }

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client != null) {
      return await client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    }

    if (!isDevMockAllowed) {
      throw const AuthException(
        'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }

    // Isolated test mock mode
    _devUser = User(
      id: '00000000-0000-0000-0000-000000000001',
      appMetadata: {'provider': 'email'},
      userMetadata: {'full_name': 'Huly User', 'first_name': 'Huly', 'last_name': 'User'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _devToken = 'mock_dev_token_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResponse(
      session: Session(
        accessToken: _devToken!,
        tokenType: 'bearer',
        user: _devUser!,
      ),
      user: _devUser,
    );
  }

  Future<AuthResponse> signUpWithPassword({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = _client;
    if (client != null) {
      return await client.auth.signUp(
        email: email.trim(),
        password: password,
        data: fullName != null ? {'full_name': fullName.trim()} : null,
      );
    }

    if (!isDevMockAllowed) {
      throw const AuthException(
        'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }

    // Isolated test mock mode
    _devUser = User(
      id: '00000000-0000-0000-0000-000000000001',
      appMetadata: {'provider': 'email'},
      userMetadata: {'full_name': fullName ?? 'Huly User'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _devToken = 'mock_dev_token_${DateTime.now().millisecondsSinceEpoch}';

    return AuthResponse(
      session: Session(
        accessToken: _devToken!,
        tokenType: 'bearer',
        user: _devUser!,
      ),
      user: _devUser,
    );
  }

  Future<bool> signInWithGoogle({String? redirectTo}) async {
    final client = _client;
    if (client != null) {
      return await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo ?? 'io.supabase.hulypay://login-callback',
      );
    }

    if (!isDevMockAllowed) {
      throw const AuthException(
        'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }

    // Isolated test fallback only
    _devUser = User(
      id: '00000000-0000-0000-0000-000000000002',
      appMetadata: {'provider': 'google'},
      userMetadata: {'full_name': 'Google User', 'avatar_url': 'https://i.pravatar.cc/150?img=12'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _devToken = 'mock_google_token_${DateTime.now().millisecondsSinceEpoch}';
    return true;
  }

  Future<bool> signInWithGitHub({String? redirectTo}) async {
    final client = _client;
    if (client != null) {
      return await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectTo ?? 'io.supabase.hulypay://login-callback',
      );
    }

    if (!isDevMockAllowed) {
      throw const AuthException(
        'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }

    // Isolated test fallback only
    _devUser = User(
      id: '00000000-0000-0000-0000-000000000003',
      appMetadata: {'provider': 'github'},
      userMetadata: {'full_name': 'GitHub User', 'avatar_url': 'https://i.pravatar.cc/150?img=60'},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    );
    _devToken = 'mock_github_token_${DateTime.now().millisecondsSinceEpoch}';
    return true;
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        if (kDebugMode) {
          print('AuthService: signOut error: $e');
        }
      }
    }
    _devUser = null;
    _devToken = null;
  }
}
