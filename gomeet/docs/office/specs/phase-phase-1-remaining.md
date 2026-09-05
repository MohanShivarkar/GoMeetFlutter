# GoMeet PWA — Phase 1 Remaining: Build Unblocked

> **For build-phase agents:** Execute this spec task-by-task. Each task follows TDD (red-green-refactor). Steps use checkbox (`- [ ]`) syntax for tracking. Complete every checkbox before moving to the next task.

**Goal:** Replace all placeholder Firebase/reCAPTCHA config values, achieve a zero-error `flutter build web` output, and confirm the app shell loads cleanly in Chrome DevTools.
**Tech Stack:** Flutter 3.x (web target), Firebase (Auth, Firestore, App Check), Dart, Chrome DevTools

---

## Dependency Map

```
p1-finalize-firebase-config
        │
        ▼
p1-build-verify
        │
        ▼
p1-chrome-verify
```

Each task must be fully complete before the next begins.

---

### Task p1-finalize-firebase-config: Replace Placeholder Firebase & reCAPTCHA Config Values

**Files:**
- Modify: `lib/firebase_options.dart`
- Modify: `lib/main.dart`
- Create: `test/firebase_config_placeholder_test.dart`

> **Pre-requisite — gather real values before writing a single line of code:**
> 1. Go to [Firebase Console](https://console.firebase.google.com) → Select the GoMeet project → Project Settings → General → Your Apps → Web App.
> 2. Note down every field: `apiKey`, `authDomain`, `projectId`, `storageBucket`, `messagingSenderId`, `appId`, `measurementId`.
> 3. Go to [Google reCAPTCHA Admin Console](https://www.google.com/recaptcha/admin) → your GoMeet site → Copy the **v3 Site Key** (starts with `6L`).
> 4. Verify the GoMeet hosting domain is registered for this reCAPTCHA key.
>
> Do **not** proceed to Step 1 until you have all values in hand.

---

- [ ] **Step 1: Write the failing placeholder-detection test**

Create `test/firebase_config_placeholder_test.dart`:

```dart
// test/firebase_config_placeholder_test.dart
//
// Purpose: Fail loudly if any Firebase web config value is still a placeholder.
// These tests run on every platform; they inspect the Dart source values directly.
// Run with: flutter test test/firebase_config_placeholder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/firebase_options.dart'; // adjust package name if different

void main() {
  group('FirebaseOptions — no placeholder values', () {
    // Pull the web-specific options object directly (not via currentPlatform,
    // which throws on non-web platforms). The `web` static getter is always
    // compiled into the class regardless of the running platform.
    final opts = DefaultFirebaseOptions.web;

    test('measurementId is not the G-PENDING placeholder', () {
      expect(
        opts.measurementId,
        isNotNull,
        reason: 'measurementId must be set',
      );
      expect(
        opts.measurementId,
        isNot(equals('G-PENDING')),
        reason: 'Replace G-PENDING with the real Measurement ID from Firebase Console',
      );
      expect(
        opts.measurementId!.startsWith('G-'),
        isTrue,
        reason: 'measurementId must follow the G-XXXXXXXXXX format',
      );
    });

    test('appId does not contain TODO', () {
      expect(
        opts.appId.contains('TODO'),
        isFalse,
        reason: 'Replace the TODO appId comment with the real web App ID from Firebase Console',
      );
      expect(
        opts.appId,
        isNotEmpty,
        reason: 'appId must not be empty',
      );
      // Firebase web App IDs follow the format: 1:NNNNNNN:web:XXXXXXXXXXXXXXXX
      expect(
        RegExp(r'^\d+:\d+:web:[a-f0-9]+$').hasMatch(opts.appId),
        isTrue,
        reason: 'appId must match the Firebase web App ID format',
      );
    });

    test('apiKey is not empty and not a placeholder', () {
      expect(opts.apiKey, isNotEmpty);
      expect(opts.apiKey, isNot(equals('YOUR_API_KEY')));
      expect(opts.apiKey, isNot(equals('PLACEHOLDER')));
    });

    test('authDomain is not empty', () {
      expect(opts.authDomain, isNotEmpty);
    });

    test('projectId is not empty', () {
      expect(opts.projectId, isNotEmpty);
    });

    test('storageBucket is not empty', () {
      expect(opts.storageBucket, isNotEmpty);
    });

    test('messagingSenderId is not empty', () {
      expect(opts.messagingSenderId, isNotEmpty);
    });
  });

  group('main.dart — reCAPTCHA key is not the placeholder', () {
    // We cannot import main.dart directly (it calls runApp), so we test the
    // constant extracted into its own file. See Step 3 for how to extract it.
    test('reCAPTCHA v3 site key is not the XXXX placeholder', () {
      // Import the constant from the extracted file created in Step 3.
      // This import is added after Step 3 is complete.
      // For now this test documents the expectation.
      expect(
        kReCaptchaV3SiteKey,
        isNot(equals('6LcXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')),
        reason: 'Replace with real reCAPTCHA v3 site key from Google reCAPTCHA Admin Console',
      );
      expect(
        kReCaptchaV3SiteKey.startsWith('6L'),
        isTrue,
        reason: 'reCAPTCHA v3 site keys always start with 6L',
      );
      expect(kReCaptchaV3SiteKey.length, greaterThanOrEqualTo(40));
    });
  });
}
```

> **Note:** The test references `kReCaptchaV3SiteKey` and `DefaultFirebaseOptions.web`. Both will cause compile errors until Steps 2–4 are complete. That is expected — this is the RED phase.

---

- [ ] **Step 2: Run the test to confirm it fails (RED)**

```bash
flutter test test/firebase_config_placeholder_test.dart
```

Expected output (any of the following — exact message depends on current state):
```
FAILED: FirebaseOptions — no placeholder values measurementId is not the G-PENDING placeholder
  Expected: not 'G-PENDING'
  Actual: 'G-PENDING'

FAILED: FirebaseOptions — no placeholder values appId does not contain TODO
  Expected: <false>
  Actual: <true>

ERROR: Could not resolve 'package:gomeet/web_constants.dart'
```

All failures are expected. Proceed to Step 3.

---

- [ ] **Step 3: Extract the reCAPTCHA key into a standalone constants file**

Create `lib/web_constants.dart`:

```dart
// lib/web_constants.dart
//
// Web-platform constants extracted here so they can be tested without
// importing main.dart (which calls runApp and cannot be unit-tested).

/// reCAPTCHA v3 site key used by Firebase App Check on the web platform.
///
/// Obtain the real value from:
///   https://www.google.com/recaptcha/admin
///   → Your GoMeet site → Copy Site Key
///
/// IMPORTANT: The domain registered for this key must match the GoMeet
/// hosting domain (e.g. gomeet.web.app or your custom domain).
const String kReCaptchaV3SiteKey =
    '6LcXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'; // ← REPLACE THIS
```

Add the import to `test/firebase_config_placeholder_test.dart` at the top:

```dart
import 'package:gomeet/web_constants.dart';
```

---

- [ ] **Step 4: Replace all placeholder values**

Open `lib/firebase_options.dart`. Locate the `web` static getter. It will look similar to:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSy...',           // already filled — verify it is real
  authDomain: '....firebaseapp.com',
  projectId: 'gomeet-...',
  storageBucket: 'gomeet-....appspot.com',
  messagingSenderId: '...',
  appId: '1:...:web:TODO',       // ← contains TODO
  measurementId: 'G-PENDING',    // ← placeholder
);
```

Replace **only** the two placeholder fields with the real values you gathered in the Pre-requisite step. The final result must look like:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',  // real key
  authDomain: 'your-project-id.firebaseapp.com',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
  messagingSenderId: '123456789012',
  appId: '1:123456789012:web:abcdef1234567890abcdef',   // real App ID
  measurementId: 'G-ABCDEFGHIJ',                        // real Measurement ID
);
```

> Replace every `XXXX`/`your-project-id`/`123...` above with the actual values from Firebase Console. Do not invent values.

---

- [ ] **Step 5: Replace the reCAPTCHA placeholder in web_constants.dart**

Open `lib/web_constants.dart`. Replace the placeholder site key:

```dart
// lib/web_constants.dart
const String kReCaptchaV3SiteKey =
    '6LcABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890ab'; // ← your real v3 site key
```

> The real key comes from Google reCAPTCHA Admin Console. It is ~40 characters, starts with `6L`, and is NOT the secret key.

---

- [ ] **Step 6: Update main.dart to import from web_constants.dart**

Open `lib/main.dart`. Find the line that uses the hardcoded reCAPTCHA string:

```dart
// BEFORE — inline placeholder string
await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider('6LcXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'),
);
```

Add the import at the top of `lib/main.dart` (after existing imports):

```dart
import 'package:gomeet/web_constants.dart';
```

Then replace the inline string with the constant:

```dart
// AFTER — uses the named constant
await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider(kReCaptchaV3SiteKey),
);
```

---

- [ ] **Step 7: Run the test to confirm it passes (GREEN)**

```bash
flutter test test/firebase_config_placeholder_test.dart
```

Expected output:
```
00:XX +8: All tests passed!
```

If any test still fails, re-check the value you entered against the Firebase Console — do not proceed until all 8 tests pass.

---

- [ ] **Step 8: Refactor — verify no other placeholder strings remain**

Run a grep to confirm no other placeholder strings exist in the codebase:

```bash
grep -rn "G-PENDING\|6LcXXX\|YOUR_API_KEY\|appId.*TODO" lib/
```

Expected output: no matches (empty). If any matches appear, fix them before proceeding.

---

- [ ] **Step 9: Commit**

```bash
git add lib/firebase_options.dart lib/main.dart lib/web_constants.dart test/firebase_config_placeholder_test.dart
git commit -m "feat: replace firebase web config and recaptcha placeholder values"
```

---

### Task p1-build-verify: Achieve Zero-Error flutter build web

**Files:**
- Modify: any file flagged by the compiler (document each below)
- Create stubs as needed (paths determined by compiler output)
- Verify: `build/web/` directory exists after build

> **This task is iterative.** The RED phase is the first failing build. Each fix is one GREEN micro-cycle. Document every error → fix pair in the "Error Log" section at the bottom of this task.

---

- [ ] **Step 1: Run the build — establish the RED baseline**

```bash
flutter build web --pwa-strategy=offline-first 2>&1 | tee /tmp/build_errors.txt
echo "Exit code: $?"
```

Expected: non-zero exit code with one or more compilation errors. Record all errors in the Error Log table at the end of this task.

If the build **already passes** (exit code 0) on the first run, skip to Step 10 (verify artifact).

---

- [ ] **Step 2: Fix Pattern A — dart:io import in a web-compiled file**

**Symptom:**
```
Error: Dart library 'dart:io' is not available on this platform.
 - 'dart:io' is from 'dart:io'
lib/services/some_service.dart:3:8: Error: Not found: 'dart:io'
import 'dart:io';
```

**Fix:** For each affected file, replace the unconditional `dart:io` import with a conditional import pattern.

If the file only uses `dart:io` for `File`, `Directory`, or `Platform`:

```dart
// BEFORE
import 'dart:io';
```

```dart
// AFTER — conditional import
import 'package:gomeet/utils/platform_file_stub.dart'
    if (dart.library.io) 'dart:io';
```

If the file uses `Platform.isAndroid` / `Platform.isIOS`, replace with `kIsWeb` guard:

```dart
// BEFORE
import 'dart:io';
// ...
if (Platform.isAndroid) { ... }
```

```dart
// AFTER
import 'package:flutter/foundation.dart'; // provides kIsWeb
// ...
if (!kIsWeb) { ... } // treats non-web as mobile
```

Create `lib/utils/platform_file_stub.dart` if it does not yet exist:

```dart
// lib/utils/platform_file_stub.dart
// Stub for dart:io File/Directory types on web.
// Only used as the conditional-import fallback when dart:io is unavailable.

class File {
  final String path;
  const File(this.path);
  Future<List<int>> readAsBytes() async => [];
  Future<String> readAsString() async => '';
  bool existsSync() => false;
}

class Directory {
  final String path;
  const Directory(this.path);
  bool existsSync() => false;
}
```

Apply this fix to every file listed in the build error output. Re-run the build after fixing ALL `dart:io` errors before moving to Step 3.

---

- [ ] **Step 3: Fix Pattern B — permission_handler not web-compatible**

**Symptom:**
```
Error: The argument type 'Future<PermissionStatus>' can't be assigned ...
  or
Error: Target of URI doesn't exist: 'package:permission_handler/...'
```

**Fix:** The conditional import stub for `permission_handler` must exist. Create it if missing:

```dart
// lib/stubs/permission_handler_web_stub.dart
// No-op stub — the web platform handles permissions natively via browser prompts.
// This file is selected by conditional imports when dart.library.html is available.

enum Permission { camera, microphone, location, storage, photos }

enum PermissionStatus { granted, denied, restricted, limited, permanentlyDenied }

extension PermissionActions on Permission {
  Future<PermissionStatus> request() async => PermissionStatus.granted;
  Future<PermissionStatus> get status async => PermissionStatus.granted;
}

class PermissionWithService extends Permission {
  const PermissionWithService._();
}
```

In every file that imports `permission_handler`, replace:

```dart
// BEFORE
import 'package:permission_handler/permission_handler.dart';
```

```dart
// AFTER
import 'package:permission_handler/permission_handler.dart'
    if (dart.library.html) 'package:gomeet/stubs/permission_handler_web_stub.dart';
```

---

- [ ] **Step 4: Fix Pattern C — flutter_local_notifications not web-compatible**

**Symptom:**
```
Error: Not found: 'package:flutter_local_notifications/...'
  or runtime: MissingPluginException (No implementation found for method initialize)
```

**Fix:** Create the no-op stub:

```dart
// lib/stubs/notifications_web_stub.dart
// No-op stub for flutter_local_notifications on web.
// Web push notifications are deferred to v2 (FCM VAPID).

class FlutterLocalNotificationsPlugin {
  Future<bool?> initialize(
    dynamic initializationSettings, {
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  Future<void> show(
    int id,
    String? title,
    String? body,
    dynamic notificationDetails, {
    String? payload,
  }) async {}

  Future<void> cancel(int id, {String? tag}) async {}
  Future<void> cancelAll() async {}
}

class InitializationSettings {
  final dynamic android;
  final dynamic iOS;
  final dynamic macOS;
  const InitializationSettings({this.android, this.iOS, this.macOS});
}

class AndroidInitializationSettings {
  const AndroidInitializationSettings(String defaultIcon);
}

class DarwinInitializationSettings {
  const DarwinInitializationSettings();
}

class NotificationDetails {
  final dynamic android;
  final dynamic iOS;
  const NotificationDetails({this.android, this.iOS});
}
```

Replace imports in every affected file:

```dart
// BEFORE
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
```

```dart
// AFTER
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    if (dart.library.html) 'package:gomeet/stubs/notifications_web_stub.dart';
```

---

- [ ] **Step 5: Fix Pattern D — agora_rtc_engine not web-compatible**

**Symptom:**
```
Error: The name 'RtcEngine' is defined in the library 'package:agora_rtc_engine/...'
  which is not available on the web platform.
```

**Fix:** The video call screen must already guard against web. If it does not, add the guard:

Open the file containing the Agora usage (e.g. `lib/screens/video_call_screen.dart`). Wrap the entire Agora-dependent widget body:

```dart
// lib/screens/video_call_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatelessWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off, color: Color(0xFFFF4458), size: 64),
              const SizedBox(height: 16),
              Text(
                'Video calls are coming soon to the web.\nDownload the app for video calls now.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Original Agora widget tree — only reached on non-web platforms.
    return _VideoCallNative();
  }
}

class _VideoCallNative extends StatefulWidget {
  @override
  State<_VideoCallNative> createState() => _VideoCallNativeState();
}

class _VideoCallNativeState extends State<_VideoCallNative> {
  @override
  Widget build(BuildContext context) {
    // Existing Agora implementation stays here, unchanged.
    // The Agora import is ONLY in this file and ONLY reached on non-web.
    return const SizedBox.shrink(); // replace with existing implementation
  }
}
```

Move the `import 'package:agora_rtc_engine/...'` line so it is ONLY inside `_VideoCallNativeState`'s file, or use a deferred import. The simplest safe approach — split into two files:

```dart
// lib/screens/video_call_native.dart  (new file — only imported on non-web)
import 'package:agora_rtc_engine/rtc_engine.dart';
// ... existing agora code ...
```

Then in `video_call_screen.dart`, import conditionally:

```dart
import 'package:gomeet/screens/video_call_native.dart'
    if (dart.library.html) 'package:gomeet/stubs/video_call_stub.dart';
```

Create `lib/stubs/video_call_stub.dart`:

```dart
// lib/stubs/video_call_stub.dart
import 'package:flutter/material.dart';

class VideoCallNative extends StatelessWidget {
  const VideoCallNative({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

---

- [ ] **Step 6: Fix Pattern E — razorpay_flutter not web-compatible**

**Symptom:**
```
Error: The library 'package:razorpay_flutter/razorpay_flutter.dart' is only
  available on Android and iOS.
```

**Fix:** Guard the premium/payment screen with `kIsWeb`:

In the file that uses Razorpay (e.g. `lib/screens/premium_screen.dart`):

```dart
// lib/screens/premium_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        appBar: AppBar(
          title: const Text('GoMeet Premium'),
          backgroundColor: const Color(0xFF0F0F1A),
        ),
        body: Center(
          child: Text(
            'Premium upgrades are available on the GoMeet mobile app.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ),
      );
    }
    return const _PremiumNative();
  }
}

class _PremiumNative extends StatefulWidget {
  const _PremiumNative();

  @override
  State<_PremiumNative> createState() => _PremiumNativeState();
}

class _PremiumNativeState extends State<_PremiumNative> {
  @override
  Widget build(BuildContext context) {
    // Existing Razorpay implementation stays here.
    return const SizedBox.shrink();
  }
}
```

Keep the `import 'package:razorpay_flutter/razorpay_flutter.dart'` line ONLY inside `_PremiumNativeState` (not at the top of `premium_screen.dart`). Add it as a local import:

```dart
class _PremiumNativeState extends State<_PremiumNative> {
  // ignore: unused_import
  // The import is here to prevent it from appearing in web compilation paths.
  void _initRazorpay() {
    // ignore: depend_on_referenced_packages
    // import is conditional — only reached on non-web
  }
  // ... rest of implementation
}
```

**Safest approach** — same conditional import pattern as Agora:

```dart
// lib/screens/premium_screen.dart (top)
import 'package:gomeet/screens/premium_native.dart'
    if (dart.library.html) 'package:gomeet/stubs/premium_stub.dart';
```

Create `lib/stubs/premium_stub.dart`:

```dart
// lib/stubs/premium_stub.dart
import 'package:flutter/material.dart';

class PremiumNative extends StatelessWidget {
  const PremiumNative({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
```

---

- [ ] **Step 7: Fix Pattern F — camera package not web-compatible**

**Symptom:**
```
Error: The plugin 'camera' doesn't support the current platform (Chrome)
  or compile error referencing CameraController on web.
```

**Fix:** The camera package is replaced with `image_picker_for_web` on web. Verify `pubspec.yaml` includes both:

```yaml
# pubspec.yaml (confirm these entries exist — do not add duplicates)
dependencies:
  camera: ^0.10.0          # for mobile
  image_picker: ^1.0.0     # cross-platform, has web support via image_picker_for_web
  image_picker_for_web: ^3.0.0  # web implementation registered automatically
```

Run `flutter pub get` after editing pubspec.

In any file that directly uses `CameraController` (e.g. `lib/screens/photo_capture_screen.dart`), add a web guard:

```dart
// lib/screens/photo_capture_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final void Function(String filePath) onPhotoSelected;

  const PhotoCaptureScreen({super.key, required this.onPhotoSelected});

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    // On web, ImageSource.camera opens the device camera via getUserMedia.
    // On mobile, it opens the native camera.
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null) {
      widget.onPhotoSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () => _pickImage(ImageSource.gallery),
          icon: const Icon(Icons.photo_library),
          label: const Text('Choose from Gallery'),
        ),
        if (!kIsWeb) // camera source via native SDK only on mobile
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take a Photo'),
          ),
        if (kIsWeb)
          ElevatedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Use Camera'),
          ),
      ],
    );
  }
}
```

---

- [ ] **Step 8: Fix Pattern G — geolocator / location package not web-compatible**

**Symptom:**
```
Error: The plugin 'geolocator' doesn't support the current platform (Chrome)
```

**Fix:** Create a web geolocation stub using `dart:html`:

```dart
// lib/stubs/web_geolocation.dart
// Uses the browser's native Geolocation API.
// Selected by conditional import when dart.library.html is available.

import 'dart:html' as html;

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;

  const Position({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    this.altitude = 0,
    this.speed = 0,
    this.heading = 0,
  });
}

Future<Position> getCurrentPosition() async {
  final geo = html.window.navigator.geolocation;
  final pos = await geo.getCurrentPosition();
  return Position(
    latitude: pos.coords!.latitude!.toDouble(),
    longitude: pos.coords!.longitude!.toDouble(),
    accuracy: pos.coords!.accuracy?.toDouble() ?? 0.0,
  );
}

Stream<Position> getPositionStream() async* {
  final position = await getCurrentPosition();
  yield position;
}
```

Create the mobile stub (used on non-web when geolocator IS available):

```dart
// lib/stubs/mobile_geolocation.dart
// Thin wrapper around the geolocator package for non-web platforms.

import 'package:geolocator/geolocator.dart' as geo;

class Position {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;

  const Position({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
    this.altitude = 0,
    this.speed = 0,
    this.heading = 0,
  });
}

Future<Position> getCurrentPosition() async {
  final p = await geo.Geolocator.getCurrentPosition();
  return Position(
    latitude: p.latitude,
    longitude: p.longitude,
    accuracy: p.accuracy,
    altitude: p.altitude,
    speed: p.speed,
    heading: p.heading,
  );
}
```

Create the unified geolocation service that switches via conditional import:

```dart
// lib/services/geolocation_service.dart

import 'package:gomeet/stubs/mobile_geolocation.dart'
    if (dart.library.html) 'package:gomeet/stubs/web_geolocation.dart';

export 'package:gomeet/stubs/mobile_geolocation.dart'
    if (dart.library.html) 'package:gomeet/stubs/web_geolocation.dart'
    show Position, getCurrentPosition;

class GeolocationService {
  Future<Position> fetchCurrentPosition() => getCurrentPosition();
}
```

Replace all direct `geolocator` imports in your codebase with:

```dart
import 'package:gomeet/services/geolocation_service.dart';
```

---

- [ ] **Step 9: Re-run the build after ALL fixes (GREEN)**

```bash
flutter build web --pwa-strategy=offline-first 2>&1 | tee /tmp/build_output.txt
echo "Exit code: $?"
```

Expected:
```
✓  Built build/web
Exit code: 0
```

If additional errors appear that do not match Patterns A–G, apply the same diagnostic approach:
- Identify the offending package/import
- Determine if it is a `dart:io` issue (use conditional import) or a plugin issue (use `kIsWeb` guard or stub)
- Apply the minimal fix; re-run

**Do not proceed to Step 10 until exit code is 0.**

---

- [ ] **Step 10: Verify the build artifact exists**

```bash
ls -lh build/web/index.html
ls -lh build/web/main.dart.js
ls -lh build/web/flutter_service_worker.js
ls -lh build/web/manifest.json
```

Expected: all four files exist with non-zero sizes.

```bash
# Check service worker references the pwa-strategy cache
grep -c "offline" build/web/flutter_service_worker.js
```

Expected: at least 1 match.

---

- [ ] **Step 11: Fill in the Error Log**

Document every error found and fix applied during this task. Copy this table into your commit message or a `docs/office/build-error-log.md` file:

| # | Error Message (first line) | File | Fix Applied | Pattern |
|---|---------------------------|------|-------------|---------|
| 1 | _paste error here_ | _file_ | _fix_ | A/B/C/D/E/F/G/other |

---

- [ ] **Step 12: Commit**

```bash
git add lib/ test/ pubspec.yaml pubspec.lock
git commit -m "fix: resolve all web compilation errors — flutter build web exits 0

Errors fixed:
- [list each Pattern letter and file here, e.g. Pattern A: lib/services/storage_service.dart]
- Pattern B: lib/services/notification_service.dart
- ...

Build artifact verified: build/web/index.html, main.dart.js, flutter_service_worker.js"
```

---

### Task p1-chrome-verify: Confirm App Shell Loads Cleanly in Chrome

**Files:**
- Modify: any file flagged by Chrome DevTools console errors
- No new files created unless a console error requires a fix

> This task is manual verification with targeted fixes. The RED phase is the initial Chrome run with console errors. GREEN is a clean console. There is no automated test file — the "test" is Chrome DevTools.

---

- [ ] **Step 1: Start the development server (RED)**

```bash
flutter run -d chrome --web-port 5000
```

Wait for the message:
```
Launching lib/main.dart on Chrome in debug mode...
...
Running with unsound null safety
Debug service listening on ws://127.0.0.1:...
```

The browser will open automatically. If it does not, navigate to `http://localhost:5000`.

---

- [ ] **Step 2: Open Chrome DevTools and capture the baseline console**

1. In Chrome: press `F12` (or right-click → Inspect).
2. Go to the **Console** tab.
3. Clear the console (click the 🚫 icon or press `Ctrl+L`).
4. Reload the page (`Ctrl+Shift+R` for hard reload).
5. Wait 10 seconds for Firebase to initialise.
6. Screenshot or copy-paste every message in the console.

**Record all messages here before fixing anything.** This is your RED state baseline.

---

- [ ] **Step 3: Verify the app shell renders (no red screen)**

Check: The browser should show either:
- The GoMeet loading splash / splash screen, **OR**
- The sign-in screen

If a **red error screen** (Flutter error widget) is shown instead, read the error text. The most common causes and fixes:

**Cause A — Firebase not initialised before runApp:**

Error text: `FirebaseException: No Firebase App '[DEFAULT]' has been created`

Fix: Ensure `main.dart` has `WidgetsFlutterBinding.ensureInitialized()` and `await Firebase.initializeApp()` BEFORE `runApp()`:

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gomeet/firebase_options.dart';
import 'package:gomeet/web_constants.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider(kReCaptchaV3SiteKey),
    );
  }

  runApp(const GoMeetApp());
}
```

**Cause B — Router failure on web (path-based URL issues):**

Error text: `RouteNotFoundException: Could not find a route for /`

Fix: Ensure your router has a route registered for `/`. In GoRouter:

```dart
GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(), // or HomeScreen
    ),
    // ... other routes
  ],
);
```

**Cause C — Null check on a non-web-initialised service:**

Error text: `Null check operator used on a null value` with a stack trace pointing to a service initialised only on mobile.

Fix: Wrap the service initialisation with `if (!kIsWeb)`:

```dart
if (!kIsWeb) {
  await SomeMobileOnlyService.instance.initialize();
}
```

---

- [ ] **Step 4: Check Firebase Auth reachability**

In Chrome DevTools → **Network** tab:
1. Filter by `identitytoolkit` or `firestore.googleapis.com`.
2. Reload the app.
3. Confirm requests return HTTP 200 (not 401, 403, or CORS errors).

**If you see a CORS error:**

```
Access to fetch at 'https://identitytoolkit.googleapis.com/...' from origin
'http://localhost:5000' has been blocked by CORS policy
```

Fix: This should not occur — Firebase Auth handles CORS automatically. Confirm:
- `authDomain` in `firebase_options.dart` is exactly `your-project-id.firebaseapp.com` (not modified)
- `localhost` is in the Firebase Console → Authentication → Settings → Authorized domains list

To add localhost:
1. Firebase Console → Authentication → Settings → Authorized domains → Add domain → `localhost`

**If you see an App Check error:**

```
FirebaseError: AppCheck: Requests throttled due to 5XX errors
  or
AppCheck: App attestation failed
```

Fix: Confirm App Check is in **monitoring mode** (not enforced) during development:
1. Firebase Console → App Check → Apps → your web app → Set to "Monitoring".
2. Add `localhost` to the reCAPTCHA allowed domains in Google reCAPTCHA Admin Console.

---

- [ ] **Step 5: Check Firestore connection**

In Chrome DevTools → **Console**, look for:

```
[firebase/firestore] WebChannelConnection RPC ... failed with error: ...
```

If Firestore fails to connect:

1. Confirm Security Rules allow the test user (or allow unauthenticated reads in development):
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
2. Confirm the `projectId` in `firebase_options.dart` matches the actual Firebase project.
3. In Network tab, confirm `firestore.googleapis.com` requests return 200 after sign-in.

---

- [ ] **Step 6: Confirm the GoMeet loading placeholder renders without a crash**

Manual checklist — verify each item in the browser:

- [ ] Page loads without a full red Flutter error screen
- [ ] GoMeet logo or app name is visible (loading splash or auth screen)
- [ ] No `dart:io` runtime errors in console (these indicate a missed conditional import)
- [ ] No `MissingPluginException` errors in console (these indicate an unguarded plugin)
- [ ] Firebase Auth SDK loads (check Network tab: `identitytoolkit.googleapis.com` request present)
- [ ] Firestore SDK initialises (check Network tab: `firestore.googleapis.com` request present, or no Firestore error in console)
- [ ] No unhandled exceptions visible in Console tab

---

- [ ] **Step 7: Fix any MissingPluginException found in Step 6**

**Symptom:**
```
MissingPluginException (No implementation found for method X on channel Y)
```

This means a plugin is being called at runtime on web despite compile-time guards. The plugin's `MethodChannel` call is reached.

For each such error, identify the calling code and add a runtime `kIsWeb` guard:

```dart
// Example: flutter_local_notifications MissingPluginException
import 'package:flutter/foundation.dart';

Future<void> initNotifications() async {
  if (kIsWeb) return; // notifications deferred to v2 on web
  await FlutterLocalNotificationsPlugin().initialize(...);
}
```

Apply this pattern to every plugin listed in the console errors.

---

- [ ] **Step 8: Capture the GREEN console state**

After fixing all errors:

1. Hard-reload the page (`Ctrl+Shift+R`).
2. Wait 10 seconds.
3. Screenshot the Console tab — it should show zero red errors.

Acceptable console messages (not errors, can be ignored):
- `[firebase/app-check] App Check debug token: ...` (debug mode only)
- `Flutter Web` renderer info messages
- Service worker registration success messages

**Do not proceed to Step 9 until the Console shows zero red errors.**

---

- [ ] **Step 9: Document all findings**

Create `docs/office/chrome-verify-log.md`:

```markdown
# Chrome Verification Log — Phase 1

**Date:** YYYY-MM-DD
**Flutter version:** (output of `flutter --version`)
**Chrome version:** (from Chrome → Help → About)

## Baseline Errors (RED state)

| # | Console Message | Severity | Root Cause |
|---|----------------|----------|------------|
| 1 | _paste_ | Error/Warning | _cause_ |

## Fixes Applied

| # | Error | Fix Applied | File Modified |
|---|-------|-------------|---------------|
| 1 | _error_ | _fix_ | _file_ |

## Final State (GREEN)

- App shell renders: YES / NO
- Firebase Auth reachable: YES / NO
- Firestore connected: YES / NO
- Console red errors: 0
- Screenshot: [attach or describe]
```

---

- [ ] **Step 10: Commit**

```bash
git add lib/ docs/office/chrome-verify-log.md
git commit -m "fix: resolve chrome runtime errors — app shell loads cleanly

Verified:
- Flutter app shell renders without red screen
- Firebase Auth reachable (HTTP 200 on identitytoolkit)
- Firestore connection established
- Zero console errors after fixes

Fixes applied:
- [list each fix: e.g. 'add kIsWeb guard to NotificationService.init()']"
```

---

## Error Pattern Quick Reference

| Symptom | Pattern | Fix Location |
|---------|---------|-------------|
| `dart:io not available` | A | Conditional import in offending file |
| `permission_handler` compile error | B | `lib/stubs/permission_handler_web_stub.dart` |
| `flutter_local_notifications` compile error | C | `lib/stubs/notifications_web_stub.dart` |
| `agora_rtc_engine` compile error | D | `kIsWeb` guard in video call screen |
| `razorpay_flutter` compile error | E | `kIsWeb` guard in premium screen |
| `camera` plugin error | F | Replace with `image_picker_for_web` |
| `geolocator` plugin error | G | `lib/services/geolocation_service.dart` |
| `MissingPluginException` at runtime | — | Add `if (kIsWeb) return;` guard at call site |
| Firebase CORS error | — | Add `localhost` to Firebase Auth authorized domains |
| App Check attestation error | — | Set App Check to monitoring mode; add localhost to reCAPTCHA domains |
| Red screen: `RouteNotFoundException` | — | Add `/` route to router |
| Red screen: Firebase not initialised | — | Move `Firebase.initializeApp()` before `runApp()` |

---

## Phase 1 Completion Checklist

Before marking Phase 1 complete, verify every item:

- [ ] `flutter test test/firebase_config_placeholder_test.dart` → 8 tests pass
- [ ] `firebase_options.dart` — no `G-PENDING`, no `TODO` in any field
- [ ] `lib/web_constants.dart` — `kReCaptchaV3SiteKey` starts with `6L`, length >= 40
- [ ] `flutter build web --pwa-strategy=offline-first` → exit code 0
- [ ] `build/web/index.html` exists
- [ ] `build/web/main.dart.js` exists
- [ ] `build/web/flutter_service_worker.js` exists
- [ ] `flutter run -d chrome` → app shell visible, no red screen
- [ ] Chrome DevTools Console → zero red errors after hard reload
- [ ] Firebase Auth requests → HTTP 200 in Network tab
- [ ] Firestore requests → connected (no error in Console)
- [ ] `docs/office/chrome-verify-log.md` created and filled in
- [ ] All commits are atomic (one per task)
