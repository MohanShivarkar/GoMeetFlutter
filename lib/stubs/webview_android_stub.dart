// lib/stubs/webview_android_stub.dart
//
// Web stub for webview_flutter_android package.
// Selected by conditional import when dart.library.html is available.

// ignore_for_file: avoid_classes_with_only_static_members

class AndroidWebViewControllerCreationParams {
  const AndroidWebViewControllerCreationParams();
}

class AndroidNavigationDelegate {
  const AndroidNavigationDelegate();
}

class AndroidWebViewController {
  const AndroidWebViewController();

  static Future<void> enableDebugging(bool enabled) async {}
  Future<void> setMediaPlaybackRequiresUserGesture(bool require) async {}
}

// Needed to use (controller.platform as AndroidWebViewController)
extension AndroidWebViewControllerExtension on Object {
  bool get isAndroidWebViewController => false;
}
