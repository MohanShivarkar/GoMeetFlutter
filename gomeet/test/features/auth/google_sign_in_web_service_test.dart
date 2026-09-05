import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating/features/auth/services/google_sign_in_web_service.dart';

// ── Fakes ──

class FakeUserCredential extends Fake implements UserCredential {
  @override
  User? get user => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  @override
  AuthCredential? get credential => null;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  bool signInWithPopupCalled = false;
  AuthProvider? capturedProvider;

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) async {
    signInWithPopupCalled = true;
    capturedProvider = provider;
    return FakeUserCredential();
  }
}

// ── Tests ──

void main() {
  group('GoogleSignInWebService', () {
    test('signIn calls FirebaseAuth.signInWithPopup with GoogleAuthProvider',
        () async {
      final fakeAuth = FakeFirebaseAuth();
      final service = GoogleSignInWebService(auth: fakeAuth);

      await service.signIn();

      expect(fakeAuth.signInWithPopupCalled, isTrue);
      expect(fakeAuth.capturedProvider, isA<GoogleAuthProvider>());
    });

    test('signIn returns the UserCredential from signInWithPopup', () async {
      final fakeAuth = FakeFirebaseAuth();
      final service = GoogleSignInWebService(auth: fakeAuth);

      final result = await service.signIn();

      expect(result, isA<UserCredential>());
    });
  });
}
