// lib/stubs/geocoding_stub.dart
//
// Web stub for geocoding package.
// Selected by conditional import when dart.library.html is available.
// Reverse geocoding is not available on web in Phase 1.

class Placemark {
  final String? name;
  final String? street;
  final String? locality;
  final String? administrativeArea;
  final String? country;
  final String? postalCode;
  const Placemark({
    this.name,
    this.street,
    this.locality,
    this.administrativeArea,
    this.country,
    this.postalCode,
  });
}

Future<List<Placemark>> placemarkFromCoordinates(
  double latitude,
  double longitude, {
  String? localeIdentifier,
}) async =>
    [];

Future<List<dynamic>> locationFromAddress(
  String address, {
  String? localeIdentifier,
}) async =>
    [];
