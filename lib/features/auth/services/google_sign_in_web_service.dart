import 'package:firebase_auth/firebase_auth.dart';

/// Web-specific Google Sign-In service.
///
/// Uses [FirebaseAuth.signInWithPopup] which opens a Google OAuth popup
/// in the browser. This avoids the native `google_sign_in` Flutter plugin
/// which does not work on web.
///
/// Call [signIn] from the sign-in screen when running on web ([kIsWeb] == true).
/// The mobile sign-in path (GoogleSignIn plugin) remains unchanged.
class GoogleSignInWebService {
  final FirebaseAuth _auth;

  GoogleSignInWebService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  /// Opens a Google OAuth popup and signs the user into Firebase Auth.
  ///
  /// Returns the [UserCredential] on success.
  /// Throws [FirebaseAuthException] on failure (popup closed, network error, etc.).
  Future<UserCredential> signIn() async {
    final provider = GoogleAuthProvider();
    // Optional scopes — uncomment to request contacts access:
    // provider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    return await _auth.signInWithPopup(provider);
  }
}
