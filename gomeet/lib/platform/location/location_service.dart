// Conditional export: selects the correct location service at compile time.
//
//   dart.library.html  → web  → location_service_web.dart (dart:html geolocation)
//   dart.library.io    → mobile → location_service_mobile.dart (geolocator)
//
// Note: class names differ (LocationServiceWeb / LocationServiceMobile) because
// the two classes have the same public API surface. If your codebase uses
// dependency injection, bind the interface to this export in your DI container.
export 'location_service_mobile.dart'
    if (dart.library.html) 'location_service_web.dart';
