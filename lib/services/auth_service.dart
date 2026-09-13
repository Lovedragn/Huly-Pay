import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  // Development mock fallback if Supabase client is uninitialized or anon key is missing
  static User? _devUser;
  static String? _devToken;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (anonKey.trim().isEmpty) {
      if (kDebugMode) {
        print('AuthService: SUPABASE_ANON_KEY is empty. Supabase client will run in dev/mock mode.');
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
  User? get currentUser => _client?.auth.currentUser ?? _devUser;

  String? get currentAccessToken {
    return _client?.auth.currentSession?.accessToken ?? _devToken;
  }

  bool get isAuthenticated => currentAccessToken != null && currentAccessToken!.isNotEmpty;

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

    // Local dev mock mode
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

    // Local dev mock mode
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

    // Local dev fallback
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

    // Local dev fallback
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
