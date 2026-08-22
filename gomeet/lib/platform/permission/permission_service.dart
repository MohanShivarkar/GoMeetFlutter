// Conditional export: selects the correct PermissionService implementation
// at compile time based on the target platform.
//
//   dart.library.html  → web  → permission_service_web.dart   (no-op stubs)
//   dart.library.io    → mobile/desktop → permission_service_mobile.dart
//
// Callers import THIS file only. They never import mobile or web directly.
export 'permission_service_mobile.dart'
    if (dart.library.html) 'permission_service_web.dart';
