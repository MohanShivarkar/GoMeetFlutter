/// Platform-agnostic position model.
/// Replaces the `Position` type from `geolocator` so that neither the
/// web stub nor the callers need to import the mobile-only package.
class AppPosition {
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;

  const AppPosition({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
  });

  @override
  bool operator ==(Object other) =>
      other is AppPosition &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() =>
      'AppPosition(latitude: $latitude, longitude: $longitude)';
}
