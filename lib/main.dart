// GoMeet — Application Entry Point
//
// Firebase initialisation strategy (p1-002):
//   • Firebase.initializeApp() is called unconditionally on ALL platforms.
//     The previous `if (!kIsWeb)` guard was incorrect and prevented Firebase
//     from initialising on the web target entirely.
//   • FirebaseAppCheck is activated on web only, using ReCaptchaV3Provider in
//     monitoring mode. Switch to enforcement mode before public launch.
//   • FirebaseAuth persistence is explicitly set to LOCAL on web (p2-auth-email-google).
//     LOCAL is the Firebase default, but we call it explicitly so the intent
//     is clear and verifiable in code review.
//
// App Check monitoring mode: tokens are generated and logged but requests are
// NOT blocked when a token is absent or invalid. This is safe for QA/staging.
// To enforce: set enforcement=true in Firebase Console → App Check.

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:dating/features/shell/widgets/offline_banner.dart';
import 'package:dating/firebase_options.dart';

import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use path-based URLs (e.g. /sign-in) instead of hash-based (/#/sign-in).
  // Required for Firebase Hosting catch-all rewrite to work correctly.
  usePathUrlStrategy();

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

    // ── Firebase Auth — LOCAL persistence (web) ────────────────────────────
    // Explicitly set LOCAL persistence so the Firebase Auth session survives
    // browser refreshes. Firebase defaults to LOCAL on web, but we call this
    // explicitly to make the intent clear and auditable in code review.
    // SESSION persistence would clear the token on tab close (wrong for a PWA).
    // NONE persistence would clear on every refresh (wrong for a dating app).
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(
    OfflineBanner(
      child: const GoMeetApp(),
    ),
  );
}

class GoMeetApp extends StatelessWidget {
  const GoMeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'GoMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4458),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F1A),
        ),
        useMaterial3: true,
      ),
    );
  }
}
