// test/firebase_json_test.dart
//
// Validates that firebase.json contains the required hosting configuration
// before any deployment attempt.

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Map<String, dynamic> config;

  setUpAll(() {
    final file = File('firebase.json');
    expect(file.existsSync(), isTrue,
        reason: 'firebase.json must exist at the project root');
    final raw = file.readAsStringSync();
    config = jsonDecode(raw) as Map<String, dynamic>;
  });

  group('firebase.json hosting config', () {
    late Map<String, dynamic> hosting;

    setUp(() {
      hosting = config['hosting'] as Map<String, dynamic>;
    });

    test('hosting.public is "build/web"', () {
      expect(hosting['public'], equals('build/web'));
    });

    test('ignore array exists and contains "firebase.json"', () {
      final ignore = hosting['ignore'] as List;
      expect(ignore, contains('firebase.json'));
    });

    test('ignore array contains hidden-file glob', () {
      final ignore = hosting['ignore'] as List;
      expect(ignore.any((e) => (e as String).contains('**\/.**')), isTrue,
          reason: 'ignore must include a glob for hidden files such as **\/.**');
    });

    test('headers list is non-empty', () {
      final headers = hosting['headers'] as List;
      expect(headers, isNotEmpty);
    });

    test('/index.html gets Cache-Control: no-cache', () {
      final headers = hosting['headers'] as List;
      final entry = headers.firstWhere(
        (h) => h['source'] == '/index.html',
        orElse: () => throw TestFailure(
            'No header entry found for source "/index.html"'),
      ) as Map<String, dynamic>;
      final headerList = entry['headers'] as List;
      expect(
        headerList.any((h) =>
            h['key'] == 'Cache-Control' && h['value'] == 'no-cache'),
        isTrue,
      );
    });

    test('JS/CSS/WASM assets get Cache-Control: public, max-age=31536000, immutable', () {
      final headers = hosting['headers'] as List;
      const expectedValue = 'public, max-age=31536000, immutable';
      // The glob source must cover .js, .css, and .wasm extensions.
      final assetEntry = headers.firstWhere(
        (h) {
          final source = h['source'] as String;
          return source.contains('.js') ||
              source.contains('.css') ||
              source.contains('.wasm');
        },
        orElse: () => throw TestFailure(
            'No header entry found for JS/CSS/WASM assets'),
      ) as Map<String, dynamic>;
      final headerList = assetEntry['headers'] as List;
      expect(
        headerList.any((h) =>
            h['key'] == 'Cache-Control' && h['value'] == expectedValue),
        isTrue,
      );
    });

    test('catch-all rewrite maps "**" to "/index.html"', () {
      final rewrites = hosting['rewrites'] as List;
      expect(
        rewrites.any((r) =>
            r['source'] == '**' && r['destination'] == '/index.html'),
        isTrue,
      );
    });
  });
}
