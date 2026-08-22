import 'package:flutter_test/flutter_test.dart';
import 'package:dating/platform/notifications/notification_service_web.dart';

void main() {
  group('NotificationServiceWeb', () {
    late NotificationService sut;

    setUp(() {
      sut = NotificationService();
    });

    test('initialize completes without error', () async {
      await expectLater(sut.initialize(), completes);
    });

    test('showNotification completes without error', () async {
      await expectLater(
        sut.showNotification(
          id: 1,
          title: 'Test Title',
          body: 'Test Body',
        ),
        completes,
      );
    });

    test('cancelNotification completes without error', () async {
      await expectLater(sut.cancelNotification(1), completes);
    });

    test('cancelAllNotifications completes without error', () async {
      await expectLater(sut.cancelAllNotifications(), completes);
    });
  });
}
