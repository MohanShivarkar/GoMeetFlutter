// Web implementation of WebCallHelper
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

class WebCallHelper {
  static void requestNotificationPermission() {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('requestNotificationPermission');
      }
    } catch (_) {}
  }

  static void showWebNotification(String title, String body, [String icon = '']) {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('showWebNotification', [title, body, icon]);
      }
    } catch (_) {}
  }

  static void playRingtone() {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('playRingtone');
      }
    } catch (_) {}
  }

  static void stopRingtone() {
    try {
      if (js.context.hasProperty('agoraWebBridge')) {
        js.context['agoraWebBridge'].callMethod('stopRingtone');
      }
    } catch (_) {}
  }
}
