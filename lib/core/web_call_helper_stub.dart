// Stub for non-web platforms
class WebCallHelper {
  static void requestNotificationPermission() {}
  static void showWebNotification(String title, String body, [String icon = '']) {}
  static void playRingtone() {}
  static void stopRingtone() {}
}
