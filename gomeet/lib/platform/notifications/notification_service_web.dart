// Web stub — flutter_local_notifications is not supported on web.
// On web, in-app notification badges are driven by Firestore real-time
// listeners (StreamBuilder watching unreadCounts in conversations documents).
// Push notifications are deferred to v2 (FCM VAPID + service worker).

class NotificationService {
  /// No-op on web. Firestore listeners handle badge state.
  Future<void> initialize() async {}

  /// No-op on web. In-app UI updates come from Firestore stream.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}

  /// No-op on web.
  Future<void> cancelNotification(int id) async {}

  /// No-op on web.
  Future<void> cancelAllNotifications() async {}
}
