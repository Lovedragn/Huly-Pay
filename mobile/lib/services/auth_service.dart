import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

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
  User? get currentUser => _client?.auth.currentUser;

  String? get currentAccessToken => _client?.auth.currentSession?.accessToken;

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

    throw const AuthException(
      'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
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

    throw const AuthException(
      'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
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

    throw const AuthException(
      'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
    );
  }

  Future<bool> signInWithGitHub({String? redirectTo}) async {
    final client = _client;
    if (client != null) {
      return await client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectTo ?? 'io.supabase.hulypay://login-callback',
      );
    }

    throw const AuthException(
      'Supabase authentication is not configured. Please configure SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
    );
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
  }
}
