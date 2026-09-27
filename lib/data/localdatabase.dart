import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

/// Manages application-level persistent storage with schema versioning
/// and seamless backward-compatibility migrations across app upgrades.
class Preferences {
  static const int currentSchemaVersion = 2;
  static const String schemaVersionKey = "storage_schema_version";
  static const String _userLoginKey = "UserLogin";
  static const String _legacyUserLoginKey = "UserLogn";
  static const String _isLoginKey = "isLogin";
  static const String _onboardingKey = "Onbording";

  /// Saves user session details with guaranteed normalization.
  /// Accepts either a JSON String or a Map.
  /// Guarantees that saved storage is never double-encoded and always contains
  /// standard {"UserLogin": {...}, "Result": "true", "ResponseCode": "200"}.
  static Future<void> saveUserDetails(dynamic userData) async {
    if (userData == null) return;
    SharedPreferences instance = await SharedPreferences.getInstance();

    Map<String, dynamic> normalizedMap = _normalizeUserData(userData);
    String serialized = jsonEncode(normalizedMap);

    await instance.setString(_userLoginKey, serialized);
    await instance.setBool(_isLoginKey, true);
    await instance.setBool(_onboardingKey, false);
    await instance.setInt(schemaVersionKey, currentSchemaVersion);
    await instance.remove(_legacyUserLoginKey);

    log("[Preferences] Normalized user session saved (Schema v$currentSchemaVersion).");
  }

  /// Fetches the user session as a normalized JSON String.
  /// Guaranteed compatible with existing consumers:
  /// - `userModelFromJson(value)`
  /// - `jsonDecode(value)["UserLogin"]["id"]`
  /// Returns empty string `""` if no session exists.
  static Future<String> fetchUserDetails() async {
    SharedPreferences instance = await SharedPreferences.getInstance();

    String? raw = instance.getString(_userLoginKey) ??
        instance.getString(_legacyUserLoginKey);

    if (raw == null || raw.trim().isEmpty || raw == "null") {
      return "";
    }

    try {
      dynamic decoded = jsonDecode(raw);

      // Handle accidental double-encoding
      if (decoded is String) {
        decoded = jsonDecode(decoded);
      }

      if (decoded is Map) {
        Map<String, dynamic> normalized = _normalizeUserData(decoded);
        return jsonEncode(normalized);
      }
    } catch (e) {
      log("[Preferences] Error parsing session details: $e");
    }

    return raw;
  }

  /// Direct helper: returns true if a valid user session is stored.
  static Future<bool> isLoggedIn() async {
    String session = await fetchUserDetails();
    return session.isNotEmpty;
  }

  /// Direct helper: returns current logged-in User ID, or null.
  static Future<String?> getUserId() async {
    String session = await fetchUserDetails();
    if (session.isEmpty) return null;
    try {
      Map decoded = jsonDecode(session);
      return decoded["UserLogin"]?["id"]?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Direct helper: returns the inner UserLogin Map directly.
  static Future<Map<String, dynamic>?> getUserLoginMap() async {
    String session = await fetchUserDetails();
    if (session.isEmpty) return null;
    try {
      Map decoded = jsonDecode(session);
      if (decoded["UserLogin"] is Map) {
        return Map<String, dynamic>.from(decoded["UserLogin"]);
      }
    } catch (_) {}
    return null;
  }

  static Future getDataFromLocal({required var key}) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    return instance.getString(key);
  }

  static Future setDatawithKeyFromLocal(
      {required var key, required var data}) async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.setString(key, jsonEncode(data));
  }

  /// Logs out user by clearing session credentials.
  /// Preserves critical app settings (theme, language, onboarding completed flag, schema version).
  static Future<void> clear() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.remove(_userLoginKey);
    await instance.remove(_legacyUserLoginKey);
    await instance.setBool(_isLoginKey, false);
    // Explicitly keep Onbording: false so returning user goes straight to AuthScreen
    await instance.setBool(_onboardingKey, false);
    log("[Preferences] User session cleared. App preferences preserved.");
  }

  /// Hard factory wipe (only use if resetting the entire app).
  static Future<void> hardReset() async {
    SharedPreferences instance = await SharedPreferences.getInstance();
    await instance.clear();
    log("[Preferences] Storage hard reset complete.");
  }

  /// Normalizes incoming user payload into standard shape.
  static Map<String, dynamic> _normalizeUserData(dynamic input) {
    Map<String, dynamic> source = {};

    if (input is String) {
      try {
        dynamic parsed = jsonDecode(input);
        if (parsed is String) parsed = jsonDecode(parsed);
        if (parsed is Map) source = Map<String, dynamic>.from(parsed);
      } catch (_) {
        return {};
      }
    } else if (input is Map) {
      source = Map<String, dynamic>.from(input);
    }

    Map<String, dynamic>? userLoginData;
    if (source["UserLogin"] is Map) {
      userLoginData = Map<String, dynamic>.from(source["UserLogin"]);
    } else if (source["UserLogn"] is Map) {
      userLoginData = Map<String, dynamic>.from(source["UserLogn"]);
    } else if (source["user_login"] is Map) {
      userLoginData = Map<String, dynamic>.from(source["user_login"]);
    } else if (source.containsKey("id") || source.containsKey("mobile")) {
      userLoginData = Map<String, dynamic>.from(source);
    }

    return {
      "UserLogin": userLoginData ?? {},
      "Result": source["Result"] ?? "true",
      "ResponseCode": source["ResponseCode"] ?? "200",
      "ResponseMsg": source["ResponseMsg"] ?? "Login successfully",
    };
  }
}

/// Runs at app bootstrap to migrate legacy storage versions to the current schema.
class StorageMigrationService {
  static Future<void> runMigrations() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int existingVersion = prefs.getInt(Preferences.schemaVersionKey) ?? 1;

      if (existingVersion < Preferences.currentSchemaVersion) {
        log("[StorageMigration] Upgrading storage schema from v$existingVersion to v${Preferences.currentSchemaVersion}...");

        // Migration step: v1 -> v2 (Legacy UserLogn / payload normalization)
        String? legacyUser = prefs.getString("UserLogn");
        String? currentUser = prefs.getString("UserLogin");

        if ((currentUser == null || currentUser.isEmpty) && legacyUser != null && legacyUser.isNotEmpty) {
          log("[StorageMigration] Migrating legacy UserLogn key to UserLogin...");
          await Preferences.saveUserDetails(legacyUser);
        } else if (currentUser != null && currentUser.isNotEmpty) {
          // Normalize existing session format
          await Preferences.saveUserDetails(currentUser);
        }

        await prefs.remove("UserLogn");
        await prefs.setInt(Preferences.schemaVersionKey, Preferences.currentSchemaVersion);
        log("[StorageMigration] Migration to schema v${Preferences.currentSchemaVersion} completed successfully.");
      }
    } catch (e) {
      log("[StorageMigration] Migration warning: $e");
    }
  }
}
