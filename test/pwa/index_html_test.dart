import 'dart:io';

import 'package:test/test.dart';

void main() {
  late String html;

  setUpAll(() {
    final file = File('web/index.html');
    expect(file.existsSync(), isTrue, reason: 'web/index.html must exist');
    html = file.readAsStringSync();
  });

  group('web/index.html — PWA meta tags', () {
    test('has theme-color meta tag set to #FF4458', () {
      expect(
        html,
        contains('<meta name="theme-color" content="#FF4458">'),
        reason: 'theme-color meta tag must be present with value #FF4458',
      );
    });

    test('has apple-touch-icon link for 192x192', () {
      expect(
        html,
        contains(
          '<link rel="apple-touch-icon" sizes="192x192" href="icons/Icon-192.png">',
        ),
        reason: 'apple-touch-icon 192x192 must be declared for iOS Safari',
      );
    });

    test('has apple-touch-icon link for 512x512', () {
      expect(
        html,
        contains(
          '<link rel="apple-touch-icon" sizes="512x512" href="icons/Icon-512.png">',
        ),
        reason: 'apple-touch-icon 512x512 must be declared for iOS Safari',
      );
    });

    test('manifest link points to manifest.json', () {
      expect(
        html,
        contains('rel="manifest"'),
        reason: 'A manifest link tag must be present',
      );
      expect(
        html,
        contains('manifest.json'),
        reason: 'The manifest link href must point to manifest.json',
      );
    });

    test('Flutter bootstrap script is referenced', () {
      // Flutter 3.x emits either flutter.js or flutter_bootstrap.js
      final hasFlutterJs = html.contains('flutter.js') ||
          html.contains('flutter_bootstrap.js');
      expect(
        hasFlutterJs,
        isTrue,
        reason: 'web/index.html must reference flutter.js or flutter_bootstrap.js',
      );
    });
  });
}
