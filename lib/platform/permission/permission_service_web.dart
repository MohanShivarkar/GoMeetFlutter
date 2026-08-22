// Web stub — no native permission_handler needed.
// Browser handles location/camera permission prompts natively via the
// Geolocation API and getUserMedia. We return granted here because
// the browser will prompt at the point of use; a denied result there
// will surface as an exception in the relevant service call.

import 'package:dating/platform/permission/app_permission_status.dart';

class PermissionService {
  Future<AppPermissionStatus> requestLocationPermission() async {
    return AppPermissionStatus.granted;
  }

  Future<AppPermissionStatus> requestCameraPermission() async {
    return AppPermissionStatus.granted;
  }

  Future<AppPermissionStatus> requestNotificationPermission() async {
    return AppPermissionStatus.granted;
  }

  Future<AppPermissionStatus> checkLocationPermission() async {
    return AppPermissionStatus.granted;
  }

  Future<AppPermissionStatus> checkCameraPermission() async {
    return AppPermissionStatus.granted;
  }
}
