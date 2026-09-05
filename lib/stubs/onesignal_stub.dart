// lib/stubs/onesignal_stub.dart
//
// Web stub for onesignal_flutter.
// Selected by conditional import when dart.library.html is available.
// OneSignal push notifications are not supported on web in Phase 1.

// ignore_for_file: avoid_classes_with_only_static_members

enum OSLogLevel {
  none,
  fatal,
  error,
  warn,
  info,
  debug,
  verbose,
}

class _OneSignalDebug {
  void setLogLevel(OSLogLevel level) {}
}

class _OneSignalNotifications {
  Future<bool> requestPermission(bool fallbackToSettings) async => false;
}

class _OneSignalUser {
  void addTagWithKey(String key, Object value) {}
  void addEmail(String email) {}
}

class OneSignal {
  static final _OneSignalDebug Debug = _OneSignalDebug();
  static final _OneSignalNotifications Notifications = _OneSignalNotifications();
  static final _OneSignalUser User = _OneSignalUser();

  static void initialize(String appId) {}
}
