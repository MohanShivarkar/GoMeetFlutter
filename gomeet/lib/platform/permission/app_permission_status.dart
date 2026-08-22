/// Platform-agnostic permission status.
/// Used by both mobile and web PermissionService implementations
/// so neither needs to import the other's native SDK.
enum AppPermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
  limited,
  provisional,
}
