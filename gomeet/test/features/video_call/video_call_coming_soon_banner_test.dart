import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/video_call/widgets/video_call_coming_soon_banner.dart';

void main() {
  group('VideoCallComingSoonBanner', () {
    testWidgets('renders the coming soon message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoCallComingSoonBanner(),
          ),
        ),
      );

      expect(find.text('Video calls coming soon on web'), findsOneWidget);
    });

    testWidgets('renders an icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoCallComingSoonBanner(),
          ),
        ),
      );

      expect(find.byIcon(Icons.videocam_off_outlined), findsOneWidget);
    });

    testWidgets('renders a subtitle with context', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VideoCallComingSoonBanner(),
          ),
        ),
      );

      expect(
        find.text('Use the GoMeet mobile app for video calls.'),
        findsOneWidget,
      );
    });
  });
}
