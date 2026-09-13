import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
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

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoadingGoogle = false;
  bool _isLoadingGitHub = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen to real Supabase OAuth callback redirects
    _authSubscription = AuthService().onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        if (mounted) {
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
    _authSubscription?.cancel();
    super.dispose();
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
  }

  void _handleGoogleSignIn() async {
    if (_isLoadingGoogle || _isLoadingGitHub) return;
    setState(() => _isLoadingGoogle = true);

    try {
      final success = await AuthService().signInWithGoogle();
      if (success && AuthService().isAuthenticated) {
        await _syncUserWithBackend();
        if (!mounted) return;
        _finishSignIn();
      }
    } catch (e) {
      if (mounted) {
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
    if (_isLoadingGoogle || _isLoadingGitHub) return;
    setState(() => _isLoadingGitHub = true);

    try {
      final success = await AuthService().signInWithGitHub();
      if (success && AuthService().isAuthenticated) {
        await _syncUserWithBackend();
        if (!mounted) return;
        _finishSignIn();
      }
    } catch (e) {
      if (mounted) {
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

  void _handleBack() {
    if (widget.onBackTap != null) {
      widget.onBackTap!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
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

  void _showEmailAuthDialog({bool isSignUp = false}) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    bool dialogLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isSignUp ? 'Create Account' : 'Sign In with Email',
            style: const TextStyle(
              fontFamily: 'Google Sans',
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (isSignUp) ...[
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      hintStyle: const TextStyle(color: Color(0xFF71717A)),
                      filled: true,
                      fillColor: const Color(0xFF141416),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF26262B)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    hintStyle: const TextStyle(color: Color(0xFF71717A)),
                    filled: true,
                    fillColor: const Color(0xFF141416),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF26262B)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Color(0xFF71717A)),
                    filled: true,
                    fillColor: const Color(0xFF141416),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF26262B)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: dialogLoading ? null : () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E8E93))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: dialogLoading
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      final password = passwordController.text;
                      if (email.isEmpty || password.isEmpty) {
                        setDialogState(() => errorMessage = 'Please enter email and password');
                        return;
                      }

                      setDialogState(() {
                        dialogLoading = true;
                        errorMessage = null;
                      });

                      try {
                        if (isSignUp) {
                          await AuthService().signUpWithPassword(
                            email: email,
                            password: password,
                            fullName: nameController.text.trim(),
                          );
                        } else {
                          await AuthService().signInWithPassword(
                            email: email,
                            password: password,
                          );
                        }
                        await _syncUserWithBackend();
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                        }
                        if (mounted) {
                          _finishSignIn();
                        }
                      } catch (e) {
                        setDialogState(() {
                          dialogLoading = false;
                          errorMessage = e.toString();
                        });
                      }
                    },
              child: dialogLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : Text(isSignUp ? 'Sign Up' : 'Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Top Bar: Circular Back button on left, Sign Up on right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    key: const Key('signin_back_button'),
                    onTap: _handleBack,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF141416),
                        border: Border.all(
                          color: const Color(0xFF26262B),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  GestureDetector(
                    key: const Key('signin_signup_button'),
                    onTap: () {
                      if (widget.onSignUpTap != null) {
                        widget.onSignUpTap!();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Sign up is currently invitation only',
                              style: TextStyle(fontFamily: 'Google Sans'),
                            ),
                            backgroundColor: const Color(0xFF222226),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontFamily: 'Google Sans',
                          color: Color(0xFF8E8E93),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 38),

              // Title and Subtitle matching design
              const Text(
                'Welcome Back',
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
                'Enter your credentials to access your account.',
                style: TextStyle(
                  fontFamily: 'Google Sans',
                  color: Color(0xFF8E8E93),
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),

              const Spacer(flex: 3),

              // Brand Emblem: Large centered circuit/maze loop
              Center(
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

              const Spacer(flex: 4),

              // Google Sign-In Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('google_signin_button'),
                  borderRadius: BorderRadius.circular(28),
                  onTap: _handleGoogleSignIn,
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
                  onTap: _handleGitHubSignIn,
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF24292E),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF333940),
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

              const SizedBox(height: 14),

              // Email Sign-In Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const Key('email_signin_button'),
                  borderRadius: BorderRadius.circular(28),
                  onTap: () => _showEmailAuthDialog(isSignUp: false),
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141416),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF26262B),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mail_outline, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Continue with Email',
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
    );
  }
}
