import 'package:flutter_test/flutter_test.dart';
import 'package:dating/platform/location/app_position.dart';
import 'package:dating/platform/location/location_service_web.dart';

void main() {
  group('AppPosition', () {
    test('constructs with latitude and longitude', () {
      const pos = AppPosition(latitude: 19.0760, longitude: 72.8777);
      expect(pos.latitude, closeTo(19.0760, 0.0001));
      expect(pos.longitude, closeTo(72.8777, 0.0001));
    });

    test('equality holds for same coordinates', () {
      const a = AppPosition(latitude: 19.0760, longitude: 72.8777);
      const b = AppPosition(latitude: 19.0760, longitude: 72.8777);
      expect(a, equals(b));
    });

    test('toString contains latitude and longitude', () {
      const pos = AppPosition(latitude: 19.0760, longitude: 72.8777);
      expect(pos.toString(), contains('19.076'));
      expect(pos.toString(), contains('72.8777'));
    });
  });

  group('LocationServiceWeb', () {
    test('LocationServiceWeb can be instantiated', () {
      final sut = LocationServiceWeb();
      expect(sut, isNotNull);
    });

    // Note: getCurrentPosition() calls dart:html window.navigator.geolocation
    // and requires a browser environment. Test the service instantiation here;
    // full integration is verified in p1-010 (flutter run -d chrome).
  });
}
