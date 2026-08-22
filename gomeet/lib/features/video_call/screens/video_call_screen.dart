import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gomeet/features/video_call/widgets/video_call_coming_soon_banner.dart';

// The agora_rtc_engine package is mobile-only and must not be imported on web.
// The kIsWeb guard in build() ensures this code path is never reached on web,
// but Dart still compiles all imports regardless of runtime guards.
// If the build fails due to this import on web, move the Agora engine
// initialisation to a separate file and use a conditional import:
//   lib/features/video_call/engine/agora_engine.dart  (shim)
//   lib/features/video_call/engine/agora_engine_mobile.dart
//   lib/features/video_call/engine/agora_engine_web.dart  (no-op stub)
//
// For v1, if the package has a web stub registered in pubspec.yaml, no
// additional action is needed here.

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  @override
  Widget build(BuildContext context) {
    // Web does not support Agora RTC in v1. Show a coming-soon banner.
    if (kIsWeb) {
      return const Scaffold(
        body: VideoCallComingSoonBanner(),
      );
    }

    // --- Existing mobile build logic follows (to be implemented) ---
    // For now, return a placeholder
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: const Center(
        child: Text('Video Call Screen (Mobile)'),
      ),
    );
  }
}
