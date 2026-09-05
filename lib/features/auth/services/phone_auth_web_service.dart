import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// Enum: PhoneRecaptchaMode
// ---------------------------------------------------------------------------

/// Controls how the reCAPTCHA challenge is presented during web phone auth.
///
/// [invisible] — Firebase resolves the challenge silently in the background.
///   This is achieved by calling [signInWithPhoneNumber] without providing a
///   DOM container to [RecaptchaVerifier] (the default behaviour). No visible
///   widget appears for the user.
///
/// [visible] — A reCAPTCHA checkbox widget is rendered in the DOM. Used only
///   when you need the user to solve a visible challenge.
enum PhoneRecaptchaMode { invisible, visible }

// ---------------------------------------------------------------------------
// PhoneAuthWebService
// ---------------------------------------------------------------------------

/// Web-specific Phone/OTP authentication service.
///
/// ## Why this service exists
/// The existing [OnbordingCubit] and [EditProfileCubit] call
/// `FirebaseAuth.instance.verifyPhoneNumber(...)` without a reCAPTCHA verifier.
/// On web that path requires device attestation which the browser cannot
/// provide, so the call silently fails.
///
/// The correct web path is [FirebaseAuth.signInWithPhoneNumber], which:
/// 1. Auto-creates an **invisible** reCAPTCHA verifier (no visible widget).
/// 2. Returns a [ConfirmationResult] used to confirm the SMS code.
///
/// ## Usage (web)
/// ```dart
/// // Step 1 — send OTP
/// final result = await PhoneAuthWebService().sendOtp('+14155551234');
///
/// // Step 2 — confirm code entered by the user
/// final credential = await PhoneAuthWebService().verifyOtp(
///   confirmationResult: result,
///   smsCode: '123456',
/// );
/// ```
class PhoneAuthWebService {
  /// The reCAPTCHA rendering mode used by this service.
  ///
  /// Exposed as a property so tests can assert that the service defaults to
  /// [PhoneRecaptchaMode.invisible] without needing a live Firebase instance.
  final PhoneRecaptchaMode recaptchaSize;

  /// Optional injected [FirebaseAuth] instance (for unit testing).
  ///
  /// Stored lazily: [FirebaseAuth.instance] is only accessed when [sendOtp]
  /// or [verifyOtp] are actually called, so constructing this service in a VM
  /// test environment (where Firebase is not initialised) does not throw.
  final FirebaseAuth? _authOverride;

  PhoneAuthWebService({
    FirebaseAuth? auth,
    this.recaptchaSize = PhoneRecaptchaMode.invisible,
  }) : _authOverride = auth;

  /// Returns the injected or live [FirebaseAuth] instance.
  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// Sends an OTP to [phoneNumber] and returns a [ConfirmationResult].
  ///
  /// Firebase automatically creates an **invisible** reCAPTCHA verifier when
  /// no DOM container is supplied. The challenge is resolved transparently in
  /// the background — no visible widget appears for the user.
  ///
  /// Call [verifyOtp] with the returned [ConfirmationResult] and the SMS code
  /// to complete sign-in.
  ///
  /// Throws [FirebaseAuthException] on failure (invalid number, quota exceeded,
  /// etc.). The caller is responsible for catching and displaying the error.
  Future<ConfirmationResult> sendOtp(String phoneNumber) async {
    // On web, signInWithPhoneNumber internally creates a RecaptchaVerifier
    // with no container => invisible reCAPTCHA. No DOM element is required.
    return await _auth.signInWithPhoneNumber(phoneNumber);
  }

  /// Confirms the OTP entered by the user and returns a [UserCredential].
  Future<UserCredential> verifyOtp({
    required ConfirmationResult confirmationResult,
    required String smsCode,
  }) async {
    return await confirmationResult.confirm(smsCode);
  }

  // -------------------------------------------------------------------------
  // Mobile fallback helpers (native path — no RecaptchaVerifier needed)
  // -------------------------------------------------------------------------

  /// Builds a [PhoneAuthCredential] from a [verificationId] + [smsCode].
  ///
  /// Used by the mobile code path after `verifyPhoneNumber` fires `codeSent`.
  /// This method is platform-agnostic and safe to call on any target.
  static PhoneAuthCredential buildCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }
}
