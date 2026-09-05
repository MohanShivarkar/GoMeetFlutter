// lib/stubs/local_notifications_stub.dart
//
// Web stub for flutter_local_notifications package.
// Selected by conditional import when dart.library.html is available.
// Local notifications are not supported on web in Phase 1.

enum Importance {
  none,
  min,
  low,
  defaultImportance,
  high,
  max,
  unspecified,
}

enum Priority { min, low, defaultPriority, high, max }
enum Sound { defaultSound }

class AndroidNotificationChannel {
  final String id;
  final String name;
  final String? description;
  final Importance importance;
  final bool enableVibration;
  const AndroidNotificationChannel(
    this.id,
    this.name, {
    this.description,
    this.importance = Importance.defaultImportance,
    this.enableVibration = true,
  });
}

class AndroidNotificationDetails {
  final String channelId;
  final String channelName;
  final String? channelDescription;
  final Importance importance;
  final Priority priority;
  final String? icon;
  const AndroidNotificationDetails(
    this.channelId,
    this.channelName, {
    this.channelDescription,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
    this.icon,
  });
}

class DarwinNotificationDetails {
  final bool presentAlert;
  final bool presentSound;
  final bool presentBadge;
  const DarwinNotificationDetails({
    this.presentAlert = false,
    this.presentSound = false,
    this.presentBadge = false,
  });
}

class NotificationDetails {
  final AndroidNotificationDetails? android;
  final DarwinNotificationDetails? iOS;
  const NotificationDetails({this.android, this.iOS});
}

class AndroidInitializationSettings {
  final String defaultIcon;
  const AndroidInitializationSettings(this.defaultIcon);
}

class DarwinInitializationSettings {
  final bool requestAlertPermission;
  final bool requestBadgePermission;
  final bool requestSoundPermission;
  const DarwinInitializationSettings({
    this.requestAlertPermission = true,
    this.requestBadgePermission = true,
    this.requestSoundPermission = true,
  });
}

class InitializationSettings {
  final AndroidInitializationSettings? android;
  final DarwinInitializationSettings? iOS;
  final DarwinInitializationSettings? macOS;
  const InitializationSettings({this.android, this.iOS, this.macOS});
}

class NotificationResponse {
  final String? payload;
  const NotificationResponse({this.payload});
}

class AndroidFlutterLocalNotificationsPlugin {
  Future<void> createNotificationChannel(AndroidNotificationChannel channel) async {}
  Future<void> requestNotificationsPermission() async {}
}

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize(
    InitializationSettings initializationSettings, {
    void Function(NotificationResponse)? onDidReceiveNotificationResponse,
    void Function(NotificationResponse)? onDidReceiveBackgroundNotificationResponse,
  }) async =>
      true;

  Future<void> show(
    int id,
    String? title,
    String? body,
    NotificationDetails? notificationDetails, {
    String? payload,
  }) async {}

  Future<void> cancel(int id, {String? tag}) async {}
  Future<void> cancelAll() async {}

  T? resolvePlatformSpecificImplementation<T extends Object>() => null;
}
