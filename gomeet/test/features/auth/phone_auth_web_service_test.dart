import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating/features/auth/services/phone_auth_web_service.dart';

// ---------------------------------------------------------------------------
// NOTE: RecaptchaVerifierSize (firebase_auth enum) only has `normal` and
// `compact`. The "invisible" reCAPTCHA behaviour is achieved by calling
// FirebaseAuth.signInWithPhoneNumber without a DOM container — not by passing
// a size enum value. PhoneAuthWebService exposes its own PhoneRecaptchaMode
// enum so tests can assert the intended rendering mode without depending on
// web-only Firebase internals.
// ---------------------------------------------------------------------------

void main() {
  group('PhoneAuthWebService', () {
    test('creates PhoneAuthWebService without throwing', () {
      // FirebaseAuth.instance is accessed lazily — constructing the service
      // does NOT require Firebase to be initialised in the test environment.
      expect(() => PhoneAuthWebService(), returnsNormally);
    });

    test('defaults to invisible reCAPTCHA mode', () {
      final service = PhoneAuthWebService();
      // The service uses the invisible mode: signInWithPhoneNumber is called
      // without a DOM container, so Firebase auto-resolves the challenge
      // silently — no visible reCAPTCHA widget is shown to the user.
      expect(service.recaptchaSize, equals(PhoneRecaptchaMode.invisible));
    });

    test('accepts a custom recaptchaSize for testing purposes', () {
      final service = PhoneAuthWebService(
        recaptchaSize: PhoneRecaptchaMode.visible,
      );
      expect(service.recaptchaSize, equals(PhoneRecaptchaMode.visible));
    });

    test('buildCredential returns a PhoneAuthCredential', () {
      // This static helper is used by the mobile code path after
      // verifyPhoneNumber fires codeSent. It is safe to call on the VM.
      final credential = PhoneAuthWebService.buildCredential(
        verificationId: 'test-verification-id',
        smsCode: '123456',
      );
      expect(credential, isA<PhoneAuthCredential>());
    });
  });
}
