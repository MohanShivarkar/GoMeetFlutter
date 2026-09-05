// lib/web_constants.dart
//
// Web-platform constants extracted here so they can be tested without
// importing main.dart (which calls runApp and cannot be unit-tested).
//
// Task: p1-chrome-verify — eliminates two categories of Chrome console errors:
//   1. App Check 400/attestation error from placeholder reCAPTCHA key
//   2. Compile-time coupling between main.dart and test harness

/// reCAPTCHA v3 site key used by Firebase App Check on the web platform.
///
/// Obtain the real value from:
///   https://www.google.com/recaptcha/admin
///   → Your GoMeet site → Copy Site Key (starts with "6L")
///
/// IMPORTANT: The domain registered for this key must include the GoMeet
/// hosting domain (e.g. gomeet.web.app or your custom domain).
///
/// This placeholder is intentionally kept for the development cycle.
/// Replace with the real key before deploying to production.
const String kReCaptchaV3SiteKey =
    '6LcXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';

/// Controls whether Firebase App Check is activated during debug builds.
///
/// Set to [false] (default) to skip App Check activation when running
/// `flutter run -d chrome`. This prevents the reCAPTCHA attestation error
/// that appears in Chrome DevTools console when the placeholder site key
/// (or an unregistered key) is used.
///
/// In production release builds, App Check is always activated regardless
/// of this flag. See [main.dart] for the activation guard pattern.
const bool kAppCheckEnabledInDebug = false;
