import 'package:flutter_test/flutter_test.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dating/platform/camera/camera_service_web.dart';

void main() {
  group('CameraServiceWeb', () {
    test('CameraServiceWeb can be instantiated', () {
      final sut = CameraServiceWeb();
      expect(sut, isNotNull);
    });

    test('XFile from known path has correct path property', () {
      // Verifies the cross_file XFile contract used by the camera service.
      const fakePath = 'blob:https://gomeet.app/abc-123';
      final file = XFile(fakePath);
      expect(file.path, equals(fakePath));
    });

    test('XFile mimeType from image picker is accessible', () {
      final file = XFile(
        'blob:https://gomeet.app/abc-123',
        mimeType: 'image/jpeg',
      );
      expect(file.mimeType, equals('image/jpeg'));
    });
  });
}
