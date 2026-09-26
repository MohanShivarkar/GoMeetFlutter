import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/google_sign_in_web_service.dart';

/// Email + password and Google Sign-In screen.
///
/// Google Sign-In path:
/// - Web  → [GoogleSignInWebService.signIn] (signInWithPopup, no native plugin)
/// - Mobile → disabled in this overlay; native flow lives in the legacy
///   `auth_cubit.dart` / `LoginScreen` in `lib/presentation/`.
///
/// Firebase Auth persistence is set to LOCAL (default on web), so the
/// session survives page refreshes without a "remember me" toggle.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Email / password ────────────────────────────────────────────────────────

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/discover');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Google Sign-In (web) ────────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      if (kIsWeb) {
        // Web: open Google OAuth popup — no native plugin required.
        final service = GoogleSignInWebService();
        await service.signIn();
      }
      // Mobile: native GoogleSignIn lives in the legacy auth_cubit flow.
      // This overlay is web-only for now; mobile falls through gracefully.
      if (mounted) context.go('/discover');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Password reset ───────────────────────────────────────────────────────────

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter your email address above first.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent — check your inbox.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo / heading ──
                  const Text(
                    'LoveCloud',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9E9EAE),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Email field ──
                  TextFormField(
                    key: const ValueKey('email-field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email address'),
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ──
                  TextFormField(
                    key: const ValueKey('password-field'),
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Password'),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                  ),
                  const SizedBox(height: 8),

                  // ── Forgot password ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _handlePasswordReset,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(color: Color(0xFFFF4458)),
                      ),
                    ),
                  ),

                  // ── Error banner ──
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B1A1D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFF8080),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // ── Sign in button ──
                  ElevatedButton(
                    key: const ValueKey('sign-in-button'),
                    onPressed: _loading ? null : _handleEmailSignIn,
                    style: _primaryButtonStyle(),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),

                  // ── Divider ──
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFF2A2A3E))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: TextStyle(color: Color(0xFF9E9EAE)),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFF2A2A3E))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Google Sign-In button ──
                  OutlinedButton.icon(
                    key: const ValueKey('google-sign-in-button'),
                    onPressed: _loading ? null : _handleGoogleSignIn,
                    icon: const Icon(
                      Icons.g_mobiledata_rounded,
                      color: Color(0xFF4285F4),
                      size: 22,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2A2A3E)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Sign-up navigation ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Color(0xFF9E9EAE)),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/sign-up'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFFFF4458),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF9E9EAE)),
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFF4458), width: 1.5),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF4458),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
