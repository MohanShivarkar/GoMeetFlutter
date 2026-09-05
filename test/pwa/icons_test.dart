import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  group('PWA Icons — existence and dimensions', () {
    const iconSpecs = [
      {'path': 'web/icons/Icon-192.png', 'size': 192},
      {'path': 'web/icons/Icon-512.png', 'size': 512},
      {'path': 'web/icons/Icon-maskable-192.png', 'size': 192},
      {'path': 'web/icons/Icon-maskable-512.png', 'size': 512},
    ];

    for (final spec in iconSpecs) {
      final path = spec['path'] as String;
      final size = spec['size'] as int;

      test('$path exists', () {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: '$path must be present in the repository',
        );
      });

      test('$path is a valid PNG with ${size}x$size dimensions', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File must exist before checking dimensions');

        final bytes = file.readAsBytesSync();
        expect(bytes.isNotEmpty, isTrue, reason: '$path must not be empty');

        final decoded = img.decodePng(bytes);
        expect(decoded, isNotNull, reason: '$path must be a valid PNG');
        expect(decoded!.width, equals(size), reason: 'Width must be $size px');
        expect(decoded.height, equals(size), reason: 'Height must be $size px');
      });
    }
  });
}
