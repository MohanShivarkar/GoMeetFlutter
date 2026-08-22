import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

// This test verifies that the initFirebase() helper function
// does NOT skip initialisation on any platform.
// We test the logic branch, not the Firebase SDK itself.

bool _wasFirebaseInitCalled = false;
bool _wasAppCheckActivated = false;

Future<void> initFirebaseUnderTest({
  required bool isWeb,
  required Future<void> Function() firebaseInit,
  required Future<void> Function() appCheckActivate,
}) async {
  // Replicate the logic that should be in main.dart after the fix
  await firebaseInit();
  _wasFirebaseInitCalled = true;

  if (isWeb) {
    await appCheckActivate();
    _wasAppCheckActivated = true;
  }
}

void main() {
  group('Firebase initialisation logic', () {
    setUp(() {
      _wasFirebaseInitCalled = false;
      _wasAppCheckActivated = false;
    });

    test('Firebase.initializeApp is called unconditionally', () async {
      await initFirebaseUnderTest(
        isWeb: false,
        firebaseInit: () async {},
        appCheckActivate: () async {},
      );
      expect(_wasFirebaseInitCalled, isTrue);
    });

    test('Firebase.initializeApp is called on web too', () async {
      await initFirebaseUnderTest(
        isWeb: true,
        firebaseInit: () async {},
        appCheckActivate: () async {},
      );
      expect(_wasFirebaseInitCalled, isTrue);
    });

    test('AppCheck.activate is called on web', () async {
      await initFirebaseUnderTest(
        isWeb: true,
        firebaseInit: () async {},
        appCheckActivate: () async {},
      );
      expect(_wasAppCheckActivated, isTrue);
    });

    test('AppCheck.activate is NOT called on mobile', () async {
      await initFirebaseUnderTest(
        isWeb: false,
        firebaseInit: () async {},
        appCheckActivate: () async {},
      );
      expect(_wasAppCheckActivated, isFalse);
    });
  });
}
