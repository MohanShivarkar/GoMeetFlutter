// lib/stubs/webview_wkwebview_stub.dart
//
// Web stub for webview_flutter_wkwebview package.
// Selected by conditional import when dart.library.html is available.

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class WebKitWebViewPlatform {
  const WebKitWebViewPlatform();
}

class WebKitWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  final bool allowsInlineMediaPlayback;
  final Set<Object>? mediaTypesRequiringUserAction;
  const WebKitWebViewControllerCreationParams({
    this.allowsInlineMediaPlayback = false,
    this.mediaTypesRequiringUserAction,
  });
}

enum PlaybackMediaTypes {
  audio,
  video,
}
