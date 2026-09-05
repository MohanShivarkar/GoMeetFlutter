// lib/stubs/geolocator_stub.dart
//
// Web stub for geolocator package.
// Selected by conditional import when dart.library.html is available.
// Use the browser Geolocation API directly for web; this stub prevents
// compilation errors from the geolocator mobile-only package.

enum LocationPermission {
  denied,
  deniedForever,
  whileInUse,
  always,
  unableToDetermine,
}

enum LocationAccuracy {
  lowest,
  low,
  medium,
  high,
  best,
  bestForNavigation,
  reduced,
}

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final double altitudeAccuracy;
  final double speedAccuracy;
  final DateTime timestamp;

  const Position({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    this.altitude = 0,
    this.speed = 0,
    this.heading = 0,
    this.altitudeAccuracy = 0,
    this.speedAccuracy = 0,
    required this.timestamp,
  });
}

class Geolocator {
  static Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  static Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;

  static Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) async =>
      Position(
        latitude: 0,
        longitude: 0,
        timestamp: DateTime.now(),
      );

  static Stream<Position> getPositionStream({
    LocationAccuracy desiredAccuracy = LocationAccuracy.best,
  }) =>
      const Stream.empty();

  static Future<bool> isLocationServiceEnabled() async => true;
}
