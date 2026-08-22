// Conditional export: selects the correct NotificationService implementation.
//
//   dart.library.html  → web  → notification_service_web.dart   (no-op)
//   dart.library.io    → mobile → notification_service_mobile.dart
export 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart';
