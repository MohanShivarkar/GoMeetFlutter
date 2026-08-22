// Conditional export: selects the correct CameraService implementation
// at compile time based on the target platform.
//
//   dart.library.html  → web  → camera_service_web.dart
//                               (image_picker federated web plugin + getUserMedia)
//   dart.library.io    → mobile/desktop → camera_service_mobile.dart
//                               (image_picker native)
//
// Callers import THIS file only. They never import mobile or web directly.
// The class name exposed on each platform:
//   Web:    CameraServiceWeb
//   Mobile: CameraServiceMobile
//
// Both expose the same public API surface:
//   Future<XFile?>   pickImageFromGallery()
//   Future<XFile?>   capturePhoto()
//   Future<dynamic>  openCameraStream()
//
// If your app uses dependency injection, bind the concrete type returned by
// this export to a shared interface in your DI container.
export 'camera_service_mobile.dart'
    if (dart.library.html) 'camera_service_web.dart';
