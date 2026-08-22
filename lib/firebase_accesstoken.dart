import 'package:googleapis_auth/auth_io.dart';
import 'package:dating/core/config.dart';
import 'package:flutter/foundation.dart';

class FirebaseAccesstoken {
  static String firebaseMessageScope = "https://www.googleapis.com/auth/firebase.messaging";

  Map<String, String> _serviceAccountEnv() {
    return {
      "type": const String.fromEnvironment("SA_TYPE", defaultValue: "service_account"),
      "project_id": const String.fromEnvironment("SA_PROJECT_ID"),
      "private_key_id": const String.fromEnvironment("SA_PRIVATE_KEY_ID"),
      "private_key": const String.fromEnvironment("SA_PRIVATE_KEY"),
      "client_email": const String.fromEnvironment("SA_CLIENT_EMAIL"),
      "client_id": const String.fromEnvironment("SA_CLIENT_ID"),
      "auth_uri": const String.fromEnvironment("SA_AUTH_URI", defaultValue: "https://accounts.google.com/o/oauth2/auth"),
      "token_uri": const String.fromEnvironment("SA_TOKEN_URI", defaultValue: "https://oauth2.googleapis.com/token"),
      "auth_provider_x509_cert_url": const String.fromEnvironment("SA_AUTH_PROVIDER_X509_CERT_URL", defaultValue: "https://www.googleapis.com/oauth2/v1/certs"),
      "client_x509_cert_url": const String.fromEnvironment("SA_CLIENT_X509_CERT_URL"),
      "universe_domain": const String.fromEnvironment("SA_UNIVERSE_DOMAIN", defaultValue: "googleapis.com"),
    };
  }

  Future<String> getAccessToken() async {
    try {
      final env = _serviceAccountEnv();
      final missing = env.entries.where((e) => e.key.endsWith("PRIVATE_KEY") || e.key.endsWith("PROJECT_ID") || e.key.endsWith("CLIENT_EMAIL")).where((e) => e.value.isEmpty).map((e) => e.key).toList();
      if (missing.isNotEmpty) {
        debugPrint("FirebaseAccesstoken missing env: $missing");
        return "";
      }

      final credentials = ServiceAccountCredentials.fromJson(env);
      final client = await clientViaServiceAccount(credentials, [firebaseMessageScope]);
      final accessToken = client.credentials.accessToken.data;
      Config.firebaseKey = accessToken;
      return accessToken;
    } catch (e) {
      debugPrint("FirebaseAccesstoken error: $e");
      return "";
    }
  }
}