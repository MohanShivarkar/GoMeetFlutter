import 'package:permission_handler/permission_handler.dart';
import 'package:gomeet/platform/permission/app_permission_status.dart';

class PermissionService {
  Future<AppPermissionStatus> requestLocationPermission() async {
    final status = await Permission.location.request();
    return _map(status);
  }

  Future<AppPermissionStatus> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return _map(status);
  }

  Future<AppPermissionStatus> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return _map(status);
  }

  Future<AppPermissionStatus> checkLocationPermission() async {
    final status = await Permission.location.status;
    return _map(status);
  }

  Future<AppPermissionStatus> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return _map(status);
  }

  AppPermissionStatus _map(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return AppPermissionStatus.granted;
      case PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case PermissionStatus.restricted:
        return AppPermissionStatus.restricted;
      case PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      case PermissionStatus.limited:
        return AppPermissionStatus.limited;
      case PermissionStatus.provisional:
        return AppPermissionStatus.provisional;
    }
  }
}
