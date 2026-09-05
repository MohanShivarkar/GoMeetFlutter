/// Generates GoMeet brand placeholder icons for the PWA manifest.
///
/// Produces four PNG files in web/icons/ using the GoMeet brand palette:
///   Background: #0F0F1A (dark navy)
///   Brand accent: #FF4458 (rose-coral)
///
/// Standard icons (no padding): Icon-192.png, Icon-512.png
/// Maskable icons (~10 % safe-zone padding): Icon-maskable-192.png, Icon-maskable-512.png
///
/// Run with: dart run tool/generate_icons.dart
library;

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  Directory('web/icons').createSync(recursive: true);

  // Standard icons — no safe-zone padding, icon fills the full canvas
  _generateIcon('web/icons/Icon-192.png', 192, safePadding: 0);
  _generateIcon('web/icons/Icon-512.png', 512, safePadding: 0);

  // Maskable icons — ~10 % safe-zone padding on all sides
  // 10% of 192 = 19.2  → 19 px
  // 10% of 512 = 51.2  → 51 px
  _generateIcon('web/icons/Icon-maskable-192.png', 192, safePadding: 19);
  _generateIcon('web/icons/Icon-maskable-512.png', 512, safePadding: 51);

  print('✓ All icons generated in web/icons/');
}

/// Creates a single square PNG icon.
///
/// [path]        – Output file path.
/// [size]        – Canvas size in pixels (width == height).
/// [safePadding] – Pixels of safe-zone to leave clear on each edge (maskable icons).
void _generateIcon(String path, int size, {required int safePadding}) {
  final image = img.Image(width: size, height: size);

  // Fill entire canvas with brand background #0F0F1A
  img.fill(image, color: img.ColorRgb8(0x0F, 0x0F, 0x1A));

  final center = size ~/ 2;

  // Outer brand circle — #FF4458 (rose-coral)
  final outerRadius = center - safePadding;
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: outerRadius,
    color: img.ColorRgb8(0xFF, 0x44, 0x58),
  );

  // Inner white circle (represents the GoMeet "G" / logo nucleus)
  // Size: 45 % of outer radius keeps proportions clean at all sizes
  final innerRadius = (outerRadius * 0.45).round();
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: innerRadius,
    color: img.ColorRgb8(0xFF, 0xFF, 0xFF),
  );

  // Small navy circle at centre (creates a ring effect that mimics the logo mark)
  final dotRadius = (outerRadius * 0.18).round();
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: dotRadius,
    color: img.ColorRgb8(0x0F, 0x0F, 0x1A),
  );

  final file = File(path);
  file.writeAsBytesSync(img.encodePng(image));
  print('  Created: $path  (${size}x$size, padding=$safePadding)');
}
