// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:gomeet/platform/location/app_position.dart';

class LocationServiceWeb {
  /// Requests the current device position using the browser Geolocation API.
  /// The browser will prompt the user for permission natively on first call.
  /// Throws [StateError] if the browser does not support geolocation.
  Future<AppPosition> getCurrentPosition() async {
    final geolocation = html.window.navigator.geolocation;

    final geoPosition = await geolocation.getCurrentPosition(
      enableHighAccuracy: false,
      timeout: const Duration(seconds: 15),
    );

    final coords = geoPosition.coords;
    if (coords == null) {
      throw StateError('Browser returned null coordinates from geolocation.');
    }

    return AppPosition(
      latitude: (coords.latitude as num).toDouble(),
      longitude: (coords.longitude as num).toDouble(),
      accuracy: coords.accuracy != null
          ? (coords.accuracy as num).toDouble()
          : null,
    );
  }

  /// Returns whether geolocation is supported in the current browser.
  bool get isSupported => html.window.navigator.geolocation != null;
}
