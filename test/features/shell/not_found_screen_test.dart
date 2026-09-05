import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating/features/shell/screens/not_found_screen.dart';

void main() {
  group('NotFoundScreen', () {
    testWidgets('renders 404 heading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotFoundScreen()),
      );
      expect(find.textContaining('404'), findsOneWidget);
    });

    testWidgets('renders Page not found message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotFoundScreen()),
      );
      expect(find.textContaining('Page not found'), findsOneWidget);
    });

    testWidgets('renders a tappable Go to home button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: NotFoundScreen()),
      );
      final button = find.widgetWithText(ElevatedButton, 'Go to home');
      expect(button, findsOneWidget);
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget.onPressed, isNotNull);
    });

    testWidgets('content is constrained to max 500 px at 1200 px viewport',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(home: NotFoundScreen()),
      );
      await tester.pumpAndSettle();

      final constrainedBoxes =
          tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final contentBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == 500,
        orElse: () => throw TestFailure(
          'No ConstrainedBox with maxWidth == 500 found. '
          'NotFoundScreen must constrain content to 500 px.',
        ),
      );
      expect(contentBox.constraints.maxWidth, equals(500));
      expect(tester.takeException(), isNull);
    });
  });
}
