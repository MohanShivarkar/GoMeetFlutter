import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/google_sign_in_web_service.dart';

/// Email + password account creation screen.
///
/// On success, navigates the user to `/profile/create` so they can
/// complete their profile before entering the Discover flow.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Email / password sign-up ────────────────────────────────────────────────

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) context.go('/profile/create');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Google Sign-Up (web) ────────────────────────────────────────────────────

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      if (kIsWeb) {
        final service = GoogleSignInWebService();
        await service.signIn();
      }
      if (mounted) context.go('/profile/create');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
                  // ── Heading ──
                  const Text(
                    'Create account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join GoMeet and start connecting',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Color(0xFF9E9EAE)),
                  ),
                  const SizedBox(height: 36),

                  // ── Email ──
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

                  // ── Password ──
                  TextFormField(
                    key: const ValueKey('password-field'),
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Password'),
                    validator: (v) =>
                        (v == null || v.length < 6) ? 'Minimum 6 characters' : null,
                  ),
                  const SizedBox(height: 16),

                  // ── Confirm password ──
                  TextFormField(
                    key: const ValueKey('confirm-password-field'),
                    controller: _confirmController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Confirm password'),
                    validator: (v) => v != _passwordController.text
                        ? 'Passwords do not match'
                        : null,
                  ),

                  // ── Error banner ──
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
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

                  // ── Create account button ──
                  ElevatedButton(
                    key: const ValueKey('sign-up-button'),
                    onPressed: _loading ? null : _handleEmailSignUp,
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
                        : const Text('Create Account'),
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

                  // ── Google ──
                  OutlinedButton.icon(
                    key: const ValueKey('google-sign-up-button'),
                    onPressed: _loading ? null : _handleGoogleSignUp,
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

                  // ── Sign-in link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(color: Color(0xFF9E9EAE)),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/sign-in'),
                        child: const Text(
                          'Sign In',
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
