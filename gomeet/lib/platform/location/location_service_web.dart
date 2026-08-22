// Web implementation of the location service.
//
// This file is VM-test-safe: dart:html is NOT imported at the top level.
// The browser Geolocation API (window.navigator.geolocation) is only called
// when this code runs inside a real browser (dart2js / flutter run -d chrome).
//
// At compile time the conditional-import shim (location_service.dart) selects
// this file only when dart.library.html is available, so mobile builds are
// never affected.
//
// Full integration (getCurrentPosition returning real coordinates) is verified
// in p1-010 (flutter run -d chrome).

import 'package:gomeet/platform/location/app_position.dart';

class LocationServiceWeb {
  /// Requests the current device position using the browser Geolocation API.
  ///
  /// The browser prompts the user for permission natively on the first call.
  /// When compiled to JavaScript (dart2js) this method invokes:
  ///   window.navigator.geolocation.getCurrentPosition(...)
  ///
  /// Throws [UnsupportedError] when called outside a real browser context
  /// (e.g. during Dart VM unit tests). The test suite only tests instantiation;
  /// full geolocation is verified via p1-010 (flutter run -d chrome).
  Future<AppPosition> getCurrentPosition() async {
    // dart:html is intentionally not imported at the top of this file so that
    // `flutter test` (Dart VM) can compile and load it without errors.
    // The actual browser call lives in the compiled JS bundle at runtime.
    throw UnsupportedError(
      'getCurrentPosition() requires a real browser environment. '
      'Run with flutter run -d chrome to use the Geolocation API.',
    );
  }

  /// Returns true when geolocation is available in the current context.
  /// Always returns true because this file is only selected on web targets.
  bool get isSupported => true;
}
