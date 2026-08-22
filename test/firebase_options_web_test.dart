import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions.web', () {
    test('apiKey is non-empty', () {
      final opts = DefaultFirebaseOptions.web;
      expect(opts.apiKey, isNotEmpty);
    });

    test('projectId is non-empty', () {
      final opts = DefaultFirebaseOptions.web;
      expect(opts.projectId, isNotEmpty);
    });

    test('appId is non-empty', () {
      final opts = DefaultFirebaseOptions.web;
      expect(opts.appId, isNotEmpty);
    });

    test('messagingSenderId is non-empty', () {
      final opts = DefaultFirebaseOptions.web;
      expect(opts.messagingSenderId, isNotEmpty);
    });
  });
}
