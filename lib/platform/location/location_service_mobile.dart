import 'package:geolocator/geolocator.dart';
import 'package:dating/platform/location/app_position.dart';

class LocationServiceMobile {
  Future<AppPosition> getCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return AppPosition(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      accuracy: position.accuracy,
      speed: position.speed,
    );
  }

  bool get isSupported => true;
}
