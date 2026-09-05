// lib/stubs/permission_stub.dart
//
// Web stub for permission_handler package (direct imports, not via platform shim).
// Selected by conditional import when dart.library.html is available.
// Browser handles permissions natively via getUserMedia / Geolocation API prompts.

// ignore_for_file: avoid_classes_with_only_static_members

enum PermissionStatus {
  denied,
  granted,
  restricted,
  limited,
  permanentlyDenied,
  provisional,
}

class _Permission {
  final int value;
  const _Permission(this.value);

  Future<PermissionStatus> request() async => PermissionStatus.granted;
  Future<PermissionStatus> get status async => PermissionStatus.granted;
}

class Permission {
  static const _Permission microphone = _Permission(0);
  static const _Permission camera = _Permission(1);
  static const _Permission location = _Permission(2);
  static const _Permission storage = _Permission(3);
  static const _Permission photos = _Permission(4);
  static const _Permission contacts = _Permission(5);
  static const _Permission notification = _Permission(6);

  const Permission._();
}

// Extension to allow [Permission.camera, Permission.microphone].request()
extension PermissionListExtension on List<_Permission> {
  Future<Map<_Permission, PermissionStatus>> request() async =>
      {for (final p in this) p: PermissionStatus.granted};
}
