import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/platform/permission/app_permission_status.dart';
import 'package:gomeet/platform/permission/permission_service_web.dart';

void main() {
  group('PermissionServiceWeb', () {
    late PermissionService sut;

    setUp(() {
      sut = PermissionService();
    });

    test('requestLocationPermission returns granted', () async {
      final result = await sut.requestLocationPermission();
      expect(result, AppPermissionStatus.granted);
    });

    test('requestCameraPermission returns granted', () async {
      final result = await sut.requestCameraPermission();
      expect(result, AppPermissionStatus.granted);
    });

    test('requestNotificationPermission returns granted', () async {
      final result = await sut.requestNotificationPermission();
      expect(result, AppPermissionStatus.granted);
    });

    test('checkLocationPermission returns granted', () async {
      final result = await sut.checkLocationPermission();
      expect(result, AppPermissionStatus.granted);
    });

    test('checkCameraPermission returns granted', () async {
      final result = await sut.checkCameraPermission();
      expect(result, AppPermissionStatus.granted);
    });
  });
}
