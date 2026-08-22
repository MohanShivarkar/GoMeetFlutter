import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/premium/widgets/premium_web_notice_widget.dart';

void main() {
  group('PremiumWebNoticeWidget', () {
    testWidgets('renders the subscribe message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumWebNoticeWidget(),
          ),
        ),
      );

      expect(
        find.text('Subscribe via the GoMeet mobile app'),
        findsOneWidget,
      );
    });

    testWidgets('renders a crown/premium icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumWebNoticeWidget(),
          ),
        ),
      );

      expect(find.byIcon(Icons.workspace_premium_outlined), findsOneWidget);
    });

    testWidgets('renders a body explanation text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumWebNoticeWidget(),
          ),
        ),
      );

      expect(
        find.text(
          'GoMeet Premium subscriptions are available on the iOS and Android apps.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders a download app button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PremiumWebNoticeWidget(),
          ),
        ),
      );

      expect(find.text('Download the App'), findsOneWidget);
    });
  });
}
