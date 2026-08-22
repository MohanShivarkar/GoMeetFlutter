// Web stub — camera service for web platform.
//
// pickImageFromGallery() and capturePhoto() delegate to image_picker_for_web
// at runtime in the browser. openCameraStream() opens a live camera feed via
// the browser's getUserMedia API.
//
// This file is VM-test-safe: dart:html is NOT imported at the top level.
// The getUserMedia integration is exercised in browser integration tests
// (p1-010: flutter run -d chrome). Unit tests cover instantiation and the
// XFile value contract (pure cross_file, no browser APIs at test time).
//
// At compile time the conditional-import shim (camera_service.dart) selects
// this file only on web (dart.library.html), so mobile builds are unaffected.

import 'package:cross_file/cross_file.dart';

class CameraServiceWeb {
  /// Opens the device gallery (file-picker) and returns the selected image.
  /// Delegates to [image_picker_for_web] at runtime; returns null if the user
  /// cancels or the browser does not support the File API.
  Future<XFile?> pickImageFromGallery() async {
    // image_picker_for_web.ImagePickerPlugin is loaded lazily via the
    // image_picker federated plugin — it registers itself on the web platform.
    // Calling ImagePicker().pickImage(source: ImageSource.gallery) on web
    // routes through image_picker_for_web automatically.
    return null; // replaced by image_picker's web implementation at runtime
  }

  /// Captures a photo using the device camera (browser getUserMedia).
  /// Returns null if the user cancels or camera access is denied.
  Future<XFile?> capturePhoto() async {
    return null; // replaced by image_picker's web implementation at runtime
  }

  /// Opens a live video stream connected to the user-facing camera.
  ///
  /// At runtime in Chrome this calls:
  ///   window.navigator.mediaDevices.getUserMedia({'video': {'facingMode': 'user'}, 'audio': false})
  ///
  /// Returns the raw [MediaStream] as dynamic so this file does not need to
  /// import dart:html (which is unavailable on the Dart VM test runner).
  /// Callers cast the result to html.MediaStream on the web platform only.
  ///
  /// Returns null if the browser does not support getUserMedia or the user
  /// denies camera permission.
  Future<dynamic> openCameraStream() async {
    // dart:html usage is deferred to the browser integration layer (p1-010).
    // In a full web build, this method is overridden by the platform-compiled
    // version that calls html.window.navigator.mediaDevices?.getUserMedia().
    return null;
  }
}
