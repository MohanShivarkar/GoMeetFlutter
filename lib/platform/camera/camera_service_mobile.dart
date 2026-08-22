// Mobile camera service — delegates to the image_picker package.
//
// Selected on non-web platforms via the conditional-import shim
// (camera_service.dart). Never compiled into web builds.

import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';

class CameraServiceMobile {
  final ImagePicker _picker = ImagePicker();

  /// Opens the device photo gallery and returns the selected image.
  /// Returns null if the user cancels.
  Future<XFile?> pickImageFromGallery() async {
    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
  }

  /// Captures a photo using the device camera (front-facing by default).
  /// Returns null if the user cancels.
  Future<XFile?> capturePhoto() async {
    return await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
  }

  /// Not applicable on mobile — live camera streams are managed via the
  /// [camera] package directly (used in video call flows). Returns null.
  Future<dynamic> openCameraStream() async => null;
}
