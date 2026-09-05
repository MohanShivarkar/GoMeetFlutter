// test/chrome_runtime_guard_test.dart
//
// Purpose: Catch runtime errors that would appear in Chrome DevTools console
// before they reach a live browser session.
//
// These tests correspond to task p1-chrome-verify. Each assertion mirrors a
// console error category observed (or expected) during `flutter run -d chrome`.
//
// Run with:
//   flutter test test/chrome_runtime_guard_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:dating/firebase_options.dart';
import 'package:dating/web_constants.dart'; // created in GREEN step

void main() {
  // ─── Firebase Analytics ─────────────────────────────────────────────────────
  //
  // Chrome console error WITHOUT fix:
  //   FirebaseError: Analytics: "measurementId" not found in Firebase config.
  //
  // Fix: remove the placeholder measurementId from firebase_options.dart so
  // Analytics initialisation is skipped until a real G-XXXXXXXXXX ID is
  // registered in Firebase Console → Analytics → Data streams.
  group('Firebase Analytics — no placeholder measurementId', () {
    final opts = DefaultFirebaseOptions.web;

    test('measurementId is null when Analytics is not yet configured', () {
      // A null measurementId tells the Firebase SDK to skip Analytics init.
      // This is safe and produces ZERO console errors.
      // If Analytics IS configured the ID must start with "G-" and not be "G-PENDING".
      if (opts.measurementId != null) {
        expect(
          opts.measurementId,
          isNot(equals('G-PENDING')),
          reason: 'G-PENDING is a placeholder — replace with a real Measurement '
              'ID from Firebase Console → Analytics → Data streams, '
              'or remove the measurementId field to disable Analytics.',
        );
        expect(
          opts.measurementId!.startsWith('G-'),
          isTrue,
          reason: 'Firebase Analytics measurement IDs always start with G-',
        );
      }
      // null is the CORRECT value when Analytics is not yet configured.
    });

    test('appId matches the Firebase web App ID format', () {
      expect(
        RegExp(r'^\d+:\d+:web:[a-f0-9]+$').hasMatch(opts.appId),
        isTrue,
        reason: 'appId must follow the format "1:PROJECT_NUMBER:web:HEX_SUFFIX"',
      );
    });

    test('apiKey is non-empty and not the generic placeholder', () {
      expect(opts.apiKey, isNotEmpty);
      expect(opts.apiKey, isNot(equals('YOUR_API_KEY')));
      expect(opts.apiKey, isNot(equals('PLACEHOLDER')));
    });

    test('authDomain ends with .firebaseapp.com', () {
      expect(
        opts.authDomain!.endsWith('.firebaseapp.com'),
        isTrue,
        reason: 'authDomain must be the Firebase-provisioned domain for CORS to work',
      );
    });

    test('projectId is non-empty', () {
      expect(opts.projectId, isNotEmpty);
    });
  });

  // ─── App Check / reCAPTCHA ──────────────────────────────────────────────────
  //
  // Chrome console error WITHOUT fix:
  //   ERROR: AppCheck: App attestation failed.
  //   net::ERR_FAILED (POST https://recaptchaenterprise.googleapis.com/...)
  //
  // Fix A: Extract the site key to web_constants.dart (this file).
  // Fix B: Guard App Check activation with kReleaseMode so that
  //        `flutter run -d chrome` (debug) never hits the reCAPTCHA endpoint.
  group('App Check — reCAPTCHA site key guards', () {
    test('kReCaptchaV3SiteKey is defined and non-empty', () {
      expect(kReCaptchaV3SiteKey, isNotEmpty);
    });

    test('kReCaptchaV3SiteKey starts with "6L" (reCAPTCHA v3 format)', () {
      expect(
        kReCaptchaV3SiteKey.startsWith('6L'),
        isTrue,
        reason: 'All reCAPTCHA v3 site keys begin with "6L"',
      );
    });

    test('kAppCheckEnabledInDebug is false — prevents App Check in dev builds', () {
      // When false, main.dart skips FirebaseAppCheck.activate() during
      // `flutter run -d chrome`. This eliminates the App Check 400 error
      // caused by the placeholder reCAPTCHA site key in development.
      expect(
        kAppCheckEnabledInDebug,
        isFalse,
        reason: 'App Check must be disabled in debug mode to avoid reCAPTCHA '
            'attestation errors when running flutter run -d chrome.',
      );
    });
  });

  // ─── App Shell rendering ─────────────────────────────────────────────────────
  //
  // Chrome console error WITHOUT fix:
  //   Unhandled Exception: Null check operator used on a null value
  //   (from a service initialised only on mobile, called unconditionally)
  //
  // The app shell (main.dart → MyApp) must not throw on web.
  // This is verified at the widget level by existing widget_test.dart.
  // Here we just confirm the config is sane enough to reach runApp().
  group('App shell — configuration sanity', () {
    test('projectId matches authDomain prefix', () {
      final opts = DefaultFirebaseOptions.web;
      // authDomain should be "PROJECT_ID.firebaseapp.com"
      expect(
        opts.authDomain!.startsWith(opts.projectId),
        isTrue,
        reason: 'authDomain and projectId mismatch would cause Firebase Auth '
            'to reject requests with a CORS error',
      );
    });

    test('storageBucket contains projectId', () {
      final opts = DefaultFirebaseOptions.web;
      expect(
        opts.storageBucket!.contains(opts.projectId),
        isTrue,
        reason: 'storageBucket must belong to the same Firebase project',
      );
    });
  });
}
