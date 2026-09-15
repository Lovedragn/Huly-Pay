import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import '../services/user_preferences_service.dart';
import 'home_dashboard_screen.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback? onSignInSuccess;
  final VoidCallback? onSignUpTap;
  final VoidCallback? onBackTap;

  const SignInScreen({
    super.key,
    this.onSignInSuccess,
    this.onSignUpTap,
    this.onBackTap,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with WidgetsBindingObserver {
  bool _isLoadingGoogle = false;
  bool _isLoadingGitHub = false;
  bool _isProcessingAuth = false;
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _authTimeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Listen to real Supabase OAuth callback redirects
    _authSubscription = AuthService().onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (mounted) {
          setState(() => _isProcessingAuth = true);
          await _syncUserWithBackend();
          if (mounted) {
            _finishSignIn();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authTimeoutTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isProcessingAuth) {
      if (AuthService().isAuthenticated) {
        _syncUserWithBackend().then((_) {
          if (mounted) _finishSignIn();
        });
      } else {
        _authTimeoutTimer?.cancel();
        _authTimeoutTimer = Timer(const Duration(seconds: 4), () {
          if (mounted && !AuthService().isAuthenticated) {
            setState(() => _isProcessingAuth = false);
          }
        });
      }
    }
  }

  void _finishSignIn() {
    if (widget.onSignInSuccess != null) {
      widget.onSignInSuccess!();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const HomeDashboardScreen(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        (route) => false,
      );
    }
  }

  Future<void> _syncUserWithBackend() async {
    // 1. Immediately store Supabase / Google OAuth user details in SQLite local DB
    final authProfile = AuthService().currentUserProfile;
    if (authProfile != null) {
      try {
        await UserRepository().saveUserProfile(authProfile);
      } catch (_) {}
    }

    // 2. Fetch fresh user profile from backend (will update SQLite)
    try {
      await UserRepository().getUserProfile(forceRefresh: true);
    } catch (_) {}

    // 3. Pre-fetch payments from backend and cache in SQLite
    try {
      await PaymentRepository().getPayments(forceRefresh: true);
    } catch (_) {}

    // 4. Sync user theme and chart color presets from Supabase users_preference
    try {
      await UserPreferencesService().loadRemotePreferences();
    } catch (_) {}
  }

  void _handleGoogleSignIn() async {
    if (_isLoadingGoogle || _isLoadingGitHub || _isProcessingAuth) return;
    setState(() {
      _isLoadingGoogle = true;
      _isProcessingAuth = true;
    });

    try {
      final success = await AuthService().signInWithGoogle();
      if (success && AuthService().isAuthenticated) {
        await _syncUserWithBackend();
        if (!mounted) return;
        _finishSignIn();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAuth = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: $e'),
            backgroundColor: const Color(0xFF222226),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGoogle = false);
      }
    }
  }

  void _handleGitHubSignIn() async {
    if (_isLoadingGoogle || _isLoadingGitHub || _isProcessingAuth) return;
    setState(() {
      _isLoadingGitHub = true;
      _isProcessingAuth = true;
    });

    try {
      final success = await AuthService().signInWithGitHub();
      if (success && AuthService().isAuthenticated) {
        await _syncUserWithBackend();
        if (!mounted) return;
        _finishSignIn();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAuth = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GitHub Sign-In: $e'),
            backgroundColor: const Color(0xFF222226),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGitHub = false);
      }
    }
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(
            fontFamily: 'Google Sans',
            color: Color(0xFF8E8E93),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Google Sans',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Center: Logo positioned at the EXACT same coordinates as SplashScreen
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'huly_pay_brand_logo',
                  child: SvgPicture.asset(
                    'asserts/logo/logo.svg',
                    width: 155,
                    height: 98,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Opacity(
                  opacity: 0.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hulypay',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Track. Pay. Grow.',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Top Header & Bottom Buttons inside SafeArea
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),

                  // Title and Application Quote
                  const Text(
                    'Experience HulyPay',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Track. Pay. Grow.',
                    style: TextStyle(
                      fontFamily: 'Google Sans',
                      color: Color(0xFF8E8E93),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      height: 1.35,
                    ),
                  ),

                  const Spacer(),

                  // Small loading button / indicator if authentication is actively processing
                  if (_isProcessingAuth) ...[
                    Center(
                      child: InkWell(
                        key: const Key('auth_processing_button'),
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _authTimeoutTimer?.cancel();
                          setState(() => _isProcessingAuth = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E24),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF33333E),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Authenticating... (tap to cancel)',
                                style: TextStyle(
                                  fontFamily: 'Google Sans',
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Google Sign-In Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('google_signin_button'),
                      borderRadius: BorderRadius.circular(28),
                      onTap: _isProcessingAuth ? null : _handleGoogleSignIn,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.center,
                        child: _isLoadingGoogle
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'asserts/icon/google.svg',
                                    width: 22,
                                    height: 22,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Google',
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // GitHub Sign-In Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('github_signin_button'),
                      borderRadius: BorderRadius.circular(28),
                      onTap: _isProcessingAuth ? null : _handleGitHubSignIn,
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF24292E),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0xFF33333E),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: _isLoadingGitHub
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'asserts/icon/github.svg',
                                    width: 22,
                                    height: 22,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'GitHub',
                                    style: TextStyle(
                                      fontFamily: 'Google Sans',
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Bottom Disclaimer: Terms of Service and Privacy Policy
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Color(0xFF71717A),
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showPolicyDialog(
                              'Terms of Service',
                              'By accessing or using Huly Pay, you agree to comply with our user agreement and transaction terms.',
                            ),
                            child: const Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: Color(0xFF9E9EA7),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF71717A),
                                height: 1.5,
                              ),
                            ),
                          ),
                          const Text(
                            ' and\n',
                            style: TextStyle(
                              fontFamily: 'Google Sans',
                              color: Color(0xFF71717A),
                              fontSize: 12.5,
                              height: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showPolicyDialog(
                              'Privacy Policy',
                              'Huly Pay protects your financial data using end-to-end encryption and strict zero-knowledge protocols.',
                            ),
                            child: const Text(
                              'Privacy Policy.',
                              style: TextStyle(
                                fontFamily: 'Google Sans',
                                color: Color(0xFF9E9EA7),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF71717A),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
