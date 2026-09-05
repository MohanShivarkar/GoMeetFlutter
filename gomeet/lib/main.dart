// GoMeet — Application Entry Point
//
// Firebase initialisation strategy (p1-002):
//   • Firebase.initializeApp() is called unconditionally on ALL platforms.
//     The previous `if (!kIsWeb)` guard was incorrect and prevented Firebase
//     from initialising on the web target entirely.
//   • FirebaseAppCheck is activated on web only, using ReCaptchaV3Provider in
//     monitoring mode. Switch to enforcement mode before public launch.
//
// App Check monitoring mode: tokens are generated and logged but requests are
// NOT blocked when a token is absent or invalid. This is safe for QA/staging.
// To enforce: set enforcement=true in Firebase Console → App Check.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gomeet/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase Core ──────────────────────────────────────────────────────────
  // Initialise on ALL platforms. The kIsWeb guard that previously wrapped this
  // call has been removed (p1-002 fix): web needs Firebase for Firestore,
  // Auth, and Storage just as mobile does.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Firebase App Check (web only) ──────────────────────────────────────────
  // Uses reCAPTCHA v3 on web. Mobile uses the device attestation provider
  // registered in Firebase Console (Play Integrity / DeviceCheck).
  // Current mode: monitoring (non-enforcing) — safe for QA.
  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      // Replace with the reCAPTCHA v3 site key from Google reCAPTCHA Admin
      // Console (https://www.google.com/recaptcha/admin). The key must be
      // registered for the domain(s) where GoMeet is hosted.
      webProvider: ReCaptchaV3Provider('6LcXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),
    );
  }

  runApp(const GoMeetApp());
}

class GoMeetApp extends StatelessWidget {
  const GoMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E8C)),
        useMaterial3: true,
      ),
      home: const _AppShellPlaceholder(),
    );
  }
}

/// Temporary placeholder — replaced by the real router/shell in phase 2.
class _AppShellPlaceholder extends StatelessWidget {
  const _AppShellPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('GoMeet is loading…'),
      ),
    );
  }
}
