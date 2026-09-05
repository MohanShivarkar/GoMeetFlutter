# GoMeet PWA Implementation Spec — Phase 5: Polish, Install CTA & Deploy

> **For build-phase agents:** Execute this spec task-by-task. Each task follows TDD (red-green-refactor). Steps use checkbox (`- [ ]`) syntax for tracking. Read every step before touching any file — later steps sometimes constrain earlier ones.

**Goal:** Wire the PWA install CTA, finalize Firebase Hosting configuration, validate bundle size and Lighthouse scores, run cross-browser QA, and execute the production deployment.
**Tech Stack:** Flutter Web, dart:js interop, Firebase Analytics, SharedPreferences, Firebase Hosting, Lighthouse CLI

---

## Dependency Map

```
p5-install-manager  ──┐
                       ├──► p5-install-banner ──► p5-cross-browser-qa ──► p5-deploy
p5-firebase-json   ──┤                                                         ▲
p5-app-check-enforce─┤                                                         │
p5-bundle-size-check─┤                                                         │
p5-lighthouse-final──┘ ─────────────────────────────────────────────────────────┘
```

All tasks in this phase are independent of each other except where noted above.

---

## Task p5-install-manager: WebInstallManager — dart:js Interop

**Assigned agent:** backend_engineer
**UI Reference:** none

**Files:**
- Create: `lib/features/pwa/web_install_manager.dart`
- Create: `lib/features/pwa/web_install_manager_stub.dart`
- Create: `lib/features/pwa/install_manager.dart`
- Create: `test/features/pwa/web_install_manager_test.dart`

---

- [ ] **Step 1: Write the failing tests**

```dart
// test/features/pwa/web_install_manager_test.dart
// Run with: flutter test test/features/pwa/web_install_manager_test.dart --platform chrome
//
// These tests run in Chrome because the implementation uses dart:js.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/pwa/install_manager.dart';

void main() {
  group('WebInstallManager', () {
    late WebInstallManager manager;

    setUp(() {
      manager = WebInstallManager.forTesting();
    });

    tearDown(() {
      manager.isInstallAvailable.dispose();
    });

    test('isInstallAvailable starts as false', () {
      expect(manager.isInstallAvailable.value, isFalse);
    });

    test('showInstallPrompt completes without error when no deferred prompt is stored', () async {
      // _deferredPrompt is null at construction; must return early cleanly.
      await expectLater(manager.showInstallPrompt(), completes);
    });

    test('isInstallAvailable remains false after showInstallPrompt with no stored prompt', () async {
      await manager.showInstallPrompt();
      expect(manager.isInstallAvailable.value, isFalse);
    });

    test('init() registers event listeners without throwing', () {
      expect(() => manager.init(), returnsNormally);
    });

    test('isInstallAvailable is a ValueNotifier<bool>', () {
      expect(manager.isInstallAvailable, isA<ValueNotifier<bool>>());
    });
  });
}
```

- [ ] **Step 2: Run tests — verify RED**

```bash
flutter test test/features/pwa/web_install_manager_test.dart --platform chrome
```

Expected: FAIL — `Error: The library 'package:gomeet/features/pwa/install_manager.dart' not found`

---

- [ ] **Step 3: Create the non-web stub**

```dart
// lib/features/pwa/web_install_manager_stub.dart
//
// Non-web stub. All methods are no-ops. Imported on Android / iOS / desktop.
// Never import this file directly — import install_manager.dart instead.

import 'package:flutter/foundation.dart';

class WebInstallManager {
  // Singleton for production use.
  static final WebInstallManager instance = WebInstallManager._internal();
  WebInstallManager._internal();

  // Testing constructor — allows direct instantiation in unit tests.
  @visibleForTesting
  WebInstallManager.forTesting();

  final ValueNotifier<bool> isInstallAvailable = ValueNotifier<bool>(false);

  /// No-op on non-web platforms.
  void init() {}

  /// No-op on non-web platforms.
  Future<void> showInstallPrompt() async {}
}
```

- [ ] **Step 4: Create the conditional-export barrel**

```dart
// lib/features/pwa/install_manager.dart
//
// Platform-agnostic import surface for WebInstallManager.
// On web (dart.library.js available):  uses web_install_manager.dart
// On all other platforms:              uses web_install_manager_stub.dart
//
// All application code imports THIS file, never the platform-specific one.

export 'web_install_manager_stub.dart'
    if (dart.library.js) 'web_install_manager.dart';
```

- [ ] **Step 5: Run tests — verify they now hit the stub and pass**

```bash
flutter test test/features/pwa/web_install_manager_test.dart --platform chrome
```

Expected: PASS — stub satisfies every assertion (isInstallAvailable is false, showInstallPrompt completes, init does not throw).

> **Note:** The Chrome platform is required so the conditional export resolves to the web implementation in the next step. When the real implementation is absent, the stub is exported on all platforms; tests still pass.

---

- [ ] **Step 6: Write the real web implementation (GREEN for the web platform)**

```dart
// lib/features/pwa/web_install_manager.dart
//
// Web-only implementation of WebInstallManager.
// Uses dart:js interop to listen for the beforeinstallprompt and appinstalled
// DOM events on window.
//
// DO NOT import this file directly — use install_manager.dart.

// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js' as js;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class WebInstallManager {
  // -------------------------------------------------------------------------
  // Construction
  // -------------------------------------------------------------------------

  /// Singleton used by production code.
  static final WebInstallManager instance = WebInstallManager._internal(
    analytics: FirebaseAnalytics.instance,
  );

  WebInstallManager._internal({required FirebaseAnalytics analytics})
      : _analytics = analytics;

  /// Injectable constructor for unit tests.
  @visibleForTesting
  WebInstallManager.forTesting({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? _NoOpAnalytics();

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  /// True when a deferred install prompt is available (beforeinstallprompt
  /// has fired and the user has not yet accepted or dismissed the prompt).
  final ValueNotifier<bool> isInstallAvailable = ValueNotifier<bool>(false);

  /// Register window event listeners. Call once from main() after Firebase
  /// is initialised (on web only, guarded by kIsWeb at the call site).
  void init() {
    // Listen for the browser's installability signal.
    js.context.callMethod('addEventListener', [
      'beforeinstallprompt',
      js.allowInterop((js.JsObject event) {
        // Prevent the browser from showing its default mini-infobar.
        event.callMethod('preventDefault');
        _deferredPrompt = event;
        isInstallAvailable.value = true;
        _analytics.logEvent(name: 'pwa_install_prompt_shown');
      }),
    ]);

    // The appinstalled event fires after the OS/browser completes
    // the installation — regardless of which UI triggered it.
    js.context.callMethod('addEventListener', [
      'appinstalled',
      js.allowInterop((dynamic _) {
        _deferredPrompt = null;
        isInstallAvailable.value = false;
        _analytics.logEvent(name: 'pwa_installed');
      }),
    ]);
  }

  /// Show the browser's native install prompt.
  ///
  /// Resolves immediately if no deferred prompt is stored (e.g. Firefox,
  /// Safari, or Chrome before the event fires). Sets [isInstallAvailable]
  /// to false after the user interacts with the prompt (accepted or dismissed).
  Future<void> showInstallPrompt() async {
    final prompt = _deferredPrompt;
    if (prompt == null) return; // Safe no-op for unsupported browsers.

    // Trigger the browser's install sheet.
    prompt.callMethod('prompt');

    // Wait for the user's choice before clearing state.
    final completer = Completer<void>();
    final userChoicePromise = prompt['userChoice'] as js.JsObject;
    userChoicePromise.callMethod('then', [
      js.allowInterop((dynamic _) {
        // outcome is either 'accepted' or 'dismissed' — in both cases we
        // clear the stored prompt and mark install as unavailable.
        _deferredPrompt = null;
        isInstallAvailable.value = false;
        completer.complete();
      }),
    ]);

    return completer.future;
  }

  // -------------------------------------------------------------------------
  // Private state
  // -------------------------------------------------------------------------

  final FirebaseAnalytics _analytics;
  js.JsObject? _deferredPrompt;
}

// ---------------------------------------------------------------------------
// Internal helper — no-op analytics used by forTesting() constructor so tests
// do not require a real Firebase project.
// ---------------------------------------------------------------------------

class _NoOpAnalytics implements FirebaseAnalytics {
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) async {}

  // All other FirebaseAnalytics members are unimplemented; they are never
  // called during WebInstallManager tests.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
```

- [ ] **Step 7: Run tests on Chrome — verify GREEN**

```bash
flutter test test/features/pwa/web_install_manager_test.dart --platform chrome
```

Expected: PASS — all 5 tests pass.

- [ ] **Step 8: Verify web compilation**

```bash
flutter build web --pwa-strategy=offline-first --release 2>&1 | grep -E "error:|Error"
```

Expected: no output (zero compilation errors).

- [ ] **Step 9: Refactor — no refactor needed**

The implementation is minimal and follows the single-responsibility principle. No refactor required.

- [ ] **Step 10: Wire init() into main.dart**

Open `lib/main.dart`. After `Firebase.initializeApp()` and the `FirebaseAppCheck` activation block, add the `WebInstallManager.init()` call:

```dart
// In lib/main.dart — inside the main() async function,
// AFTER the existing Firebase.initializeApp() and App Check activation block.

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gomeet/features/pwa/install_manager.dart';

// ... existing Firebase init code ...

if (kIsWeb) {
  WebInstallManager.instance.init();
}
```

- [ ] **Step 11: Commit**

```bash
git add lib/features/pwa/web_install_manager.dart \
        lib/features/pwa/web_install_manager_stub.dart \
        lib/features/pwa/install_manager.dart \
        lib/main.dart \
        test/features/pwa/web_install_manager_test.dart
git commit -m "feat(pwa): add WebInstallManager with beforeinstallprompt and appinstalled interop"
```

---

## Task p5-install-banner: Dismissable Install Banner Widget

**Assigned agent:** frontend_engineer
**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html (Panel A — custom install CTA overlay) and docs/office/05-ui-designs/03-discover.html (banner placement in the Discover screen)

**Files:**
- Create: `lib/features/pwa/widgets/install_banner.dart`
- Modify: `lib/features/discover/discover_screen.dart`
- Create: `test/features/pwa/widgets/install_banner_test.dart`

**Depends on:** p5-install-manager (install_manager.dart must exist)

---

- [ ] **Step 1: Write failing widget tests**

```dart
// test/features/pwa/widgets/install_banner_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gomeet/features/pwa/widgets/install_banner.dart';

void main() {
  setUp(() async {
    // Reset SharedPreferences before every test.
    SharedPreferences.setMockInitialValues({});
  });

  group('InstallBanner', () {
    testWidgets('renders the home-screen copy text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Add GoMeet to your home screen for faster access'),
        findsOneWidget,
      );
    });

    testWidgets('renders an Install button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Install'), findsOneWidget);
    });

    testWidgets('renders a dismiss (X) icon button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('Install button invokes onInstallTapped callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async { tapped = true; }),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Install'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('tapping X hides the banner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(
        find.text('Add GoMeet to your home screen for faster access'),
        findsNothing,
      );
    });

    testWidgets('tapping X persists dismissed flag in SharedPreferences', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('install_banner_dismissed'), isTrue);
    });

    testWidgets('banner is invisible when already dismissed in SharedPreferences', (tester) async {
      SharedPreferences.setMockInitialValues({'install_banner_dismissed': true});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InstallBanner(onInstallTapped: () async {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Add GoMeet to your home screen for faster access'),
        findsNothing,
      );
    });
  });
}
```

- [ ] **Step 2: Run tests — verify RED**

```bash
flutter test test/features/pwa/widgets/install_banner_test.dart
```

Expected: FAIL — `Error: 'package:gomeet/features/pwa/widgets/install_banner.dart' not found`

---

- [ ] **Step 3: Implement InstallBanner widget**

```dart
// lib/features/pwa/widgets/install_banner.dart
//
// A dismissable bottom banner that prompts the user to install GoMeet as a PWA.
// The banner is self-contained: it reads and writes the dismiss flag to
// SharedPreferences using the key 'install_banner_dismissed'.
//
// Usage (caller is responsible for the kIsWeb guard and swipe-count gate):
//   InstallBanner(onInstallTapped: () async {
//     if (kIsWeb) await WebInstallManager.instance.showInstallPrompt();
//   })

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstallBanner extends StatefulWidget {
  const InstallBanner({
    super.key,
    required this.onInstallTapped,
  });

  /// Called when the user taps the "Install" button.
  /// The caller is responsible for invoking the platform-specific prompt.
  final Future<void> Function() onInstallTapped;

  @override
  State<InstallBanner> createState() => _InstallBannerState();
}

class _InstallBannerState extends State<InstallBanner> {
  static const _prefKey = 'install_banner_dismissed';

  bool _dismissed = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadDismissedState();
  }

  Future<void> _loadDismissedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _dismissed = prefs.getBool(_prefKey) ?? false;
        _loadingPrefs = false;
      });
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    if (mounted) {
      setState(() => _dismissed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show nothing while loading prefs or after dismissal.
    if (_loadingPrefs || _dismissed) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFFF4458).withOpacity(0.4),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // GoMeet app icon (uses the PWA icon from web/icons/).
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'icons/Icon-192.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite,
                    color: Color(0xFFFF4458),
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Banner copy.
              const Expanded(
                child: Text(
                  'Add GoMeet to your home screen for faster access',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Install CTA.
              TextButton(
                onPressed: widget.onInstallTapped,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Install',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Dismiss button.
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                color: Colors.white54,
                onPressed: _dismiss,
                tooltip: 'Dismiss',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run tests — verify GREEN**

```bash
flutter test test/features/pwa/widgets/install_banner_test.dart
```

Expected: PASS — all 7 tests pass.

---

- [ ] **Step 5: Write failing test for Discover screen swipe counter**

```dart
// Append to test/features/pwa/widgets/install_banner_test.dart

// NOTE: This group tests the Discover screen's integration behavior via a
// thin acceptance test. Replace 'DiscoverScreen' with the exact class name
// used in your codebase if it differs.

// (No test for the Discover screen integration here — the Discover screen
//  depends on the full Riverpod / BLoC / routing setup which is outside the
//  scope of this unit test. The integration is verified in p5-cross-browser-qa.
//  Refer to Step 6 for the exact code changes to make in discover_screen.dart.)
```

- [ ] **Step 6: Wire install banner into Discover screen**

Open `lib/features/discover/discover_screen.dart`.

Make the following targeted additions. **Do not touch any existing swipe or card logic.**

**6a. Add imports at the top of the file (after existing imports):**

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gomeet/features/pwa/install_manager.dart';
import 'package:gomeet/features/pwa/widgets/install_banner.dart';
```

**6b. Inside the `State` class, add a swipe counter field:**

```dart
// Add this field alongside existing state fields in _DiscoverScreenState
// (adjust class name to match the actual state class name in the file).
int _swipeCount = 0;
```

**6c. In the existing swipe-completion handler** (the callback or method that fires after a card is swiped left or right — look for calls to `likeProfile`, `dislikeProfile`, or the card swipe gesture completion), increment the counter:

```dart
// Inside the swipe handler, after the existing swipe logic:
setState(() => _swipeCount += 1);
```

**6d. In the `build` method's return widget tree**, wrap the existing `Scaffold` body inside a `Stack` (or add to an existing `Stack` if one already exists) and append the conditional banner. The banner must be the **last** child of the `Stack` so it overlays the card stack:

```dart
// Example: if your build currently returns a Scaffold with body: someWidget,
// change it so the body is a Stack:

// BEFORE (simplified):
// body: CardStack(...)

// AFTER:
// body: Stack(
//   children: [
//     CardStack(...),          // existing widget, unchanged
//     if (kIsWeb && _swipeCount >= 1)
//       Align(
//         alignment: Alignment.bottomCenter,
//         child: ValueListenableBuilder<bool>(
//           valueListenable: WebInstallManager.instance.isInstallAvailable,
//           builder: (context, isAvailable, _) {
//             if (!isAvailable) return const SizedBox.shrink();
//             return InstallBanner(
//               onInstallTapped: () async {
//                 if (kIsWeb) {
//                   await WebInstallManager.instance.showInstallPrompt();
//                 }
//               },
//             );
//           },
//         ),
//       ),
//   ],
// ),
```

The full, self-contained addition to paste into `discover_screen.dart` (showing the banner section only):

```dart
// Paste this inside the Stack children list, AFTER the existing card stack child:
if (kIsWeb && _swipeCount >= 1)
  Align(
    alignment: Alignment.bottomCenter,
    child: ValueListenableBuilder<bool>(
      valueListenable: WebInstallManager.instance.isInstallAvailable,
      builder: (_, isAvailable, __) {
        if (!isAvailable) return const SizedBox.shrink();
        return InstallBanner(
          onInstallTapped: () async {
            if (kIsWeb) {
              await WebInstallManager.instance.showInstallPrompt();
            }
          },
        );
      },
    ),
  ),
```

- [ ] **Step 7: Run the widget tests to confirm nothing is broken**

```bash
flutter test test/features/pwa/widgets/install_banner_test.dart
```

Expected: PASS — all 7 tests still pass.

- [ ] **Step 8: Verify web compilation with the new changes**

```bash
flutter build web --pwa-strategy=offline-first --release 2>&1 | grep -E "error:|Error"
```

Expected: no output.

- [ ] **Step 9: Refactor — no refactor needed**

The banner is self-contained. The Discover screen additions are minimal. No cleanup required.

- [ ] **Step 10: Commit**

```bash
git add lib/features/pwa/widgets/install_banner.dart \
        lib/features/discover/discover_screen.dart \
        test/features/pwa/widgets/install_banner_test.dart
git commit -m "feat(pwa): add dismissable install banner; wire into Discover screen after first swipe"
```

---

## Task p5-firebase-json: Firebase Hosting Configuration

**Assigned agent:** devops
**UI Reference:** none

**Files:**
- Create/Overwrite: `firebase.json`
- Create: `test/firebase_json_test.dart`

---

- [ ] **Step 1: Write the failing validation test**

```dart
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
```

- [ ] **Step 2: Run test — verify RED**

```bash
flutter test test/firebase_json_test.dart
```

Expected: FAIL — `firebase.json must exist at the project root`

---

- [ ] **Step 3: Create firebase.json**

Create `firebase.json` at the project root with this exact content:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "headers": [
      {
        "source": "/index.html",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      },
      {
        "source": "**/*.@(js|css|wasm)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000, immutable"
          }
        ]
      }
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

- [ ] **Step 4: Run test — verify GREEN**

```bash
flutter test test/firebase_json_test.dart
```

Expected: PASS — all 7 tests pass.

- [ ] **Step 5: Validate JSON syntax independently**

```bash
python3 -c "import json, sys; json.load(open('firebase.json')); print('JSON valid')"
```

Expected: `JSON valid`

- [ ] **Step 6: Refactor — no refactor needed**

Configuration is minimal and complete. No changes required.

- [ ] **Step 7: Commit**

```bash
git add firebase.json test/firebase_json_test.dart
git commit -m "feat(hosting): add firebase.json with cache headers and SPA rewrite rule"
```

---

## Task p5-app-check-enforce: Switch Firebase App Check to Enforced Mode

**Assigned agent:** devops
**UI Reference:** none

> This task has no automatable code changes — it is a Firebase Console operation. Follow every checkbox in order. If any step reveals a problem, stop and follow the rollback instruction before proceeding.

**Prerequisite:** App Check monitoring dashboard shows >= 99% verified requests over at least 48 hours of QA traffic (confirmed from the p2-app-check-monitoring task and subsequent QA sessions).

---

- [ ] **Step 1: Confirm attestation rate in Firebase Console**

1. Open [Firebase Console](https://console.firebase.google.com) → select **GoMeet** project.
2. Navigate to **App Check** → **Apps** → **GoMeet Web**.
3. Check the **Verified requests** percentage over the last 7 days.
4. **Gate:** if the rate is below 99%, **stop here**. Do not enforce. Investigate unattested traffic sources before re-evaluating.

- [ ] **Step 2: Switch to enforced mode**

1. In **App Check → Apps → GoMeet Web**, click **Enforce**.
2. Confirm the modal dialog.
3. Note the timestamp of enforcement.

- [ ] **Step 3: Immediate smoke test in Chrome**

Within 60 seconds of enforcement:

1. Open Chrome → navigate to the GoMeet Firebase Hosting URL.
2. Open DevTools → **Network** tab → clear the log.
3. Sign in with email/password credentials.
4. Navigate to the Discover screen and confirm profile cards load (Firestore read succeeds).
5. Confirm the Network tab shows no `403` or `401` responses on Firestore or Storage requests.

- [ ] **Step 4: Rollback procedure (execute only if requests are blocked)**

If step 3 reveals blocked requests (403 on Firestore):

1. Firebase Console → **App Check → Apps → GoMeet Web** → click **Unenforce** (revert to monitoring mode).
2. Wait 5 minutes.
3. Re-run the smoke test to confirm traffic is unblocked.
4. Open App Check monitoring → examine the **Unverified requests** table to identify the client/path generating unattested traffic.
5. Fix the root cause (missing `FirebaseAppCheck.instance.activate()` call, reCAPTCHA domain not allow-listed, etc.) before re-attempting enforcement.

- [ ] **Step 5: Document outcome**

Create the file `docs/office/app-check-enforcement.md` with the following content (fill in actuals):

```markdown
# App Check Enforcement Log

- **Enforced at:** YYYY-MM-DD HH:MM UTC
- **Attestation rate at time of enforcement:** XX.X%
- **Smoke test result:** PASS / FAIL
- **Rollback required:** No / Yes (reason: ...)
- **Notes:** ...
```

- [ ] **Step 6: Commit the log**

```bash
git add docs/office/app-check-enforcement.md
git commit -m "ops: document Firebase App Check enforcement event"
```

---

## Task p5-bundle-size-check: Bundle Size Audit & Optimisation

**Assigned agent:** backend_engineer
**UI Reference:** none

---

- [ ] **Step 1: Write the deferred-import smoke test (preemptive)**

This test verifies that deferred-import wrappers compile and resolve correctly. Write it now so it is ready if step 4 triggers the optimisation path.

```dart
// test/bundle/deferred_import_test.dart
//
// Verifies that screens intended for deferred loading expose the expected
// widget type after loadLibrary() completes. Run with:
//   flutter test test/bundle/deferred_import_test.dart --platform chrome

import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/settings/settings_screen.dart' deferred as settings;

void main() {
  group('Deferred import: SettingsScreen', () {
    test('loadLibrary completes without error', () async {
      await expectLater(settings.loadLibrary(), completes);
    });

    test('SettingsScreen type is accessible after loadLibrary', () async {
      await settings.loadLibrary();
      // Constructing the widget would require full widget-test scaffolding;
      // here we only verify the type is resolvable (compile-time check).
      expect(settings.SettingsScreen, isNotNull);
    });
  });
}
```

- [ ] **Step 2: Run the deferred-import test — verify it compiles**

```bash
flutter test test/bundle/deferred_import_test.dart --platform chrome
```

Expected: PASS if `settings_screen.dart` already exists with a class named `SettingsScreen`. If the class name differs, update the import path and class reference accordingly.

---

- [ ] **Step 3: Build the release web bundle**

```bash
flutter build web --pwa-strategy=offline-first --release
```

Expected: Build completes with no errors. Output is in `build/web/`.

- [ ] **Step 4: Measure initial transfer size**

Open Chrome → navigate to `localhost:5000` (serve the build locally):

```bash
cd build/web && python3 -m http.server 5000
```

Then in Chrome:

1. Open DevTools → **Network** tab.
2. Check **Disable cache**.
3. Set throttling to **Fast 3G** (to surface compressed transfer sizes).
4. Hard-reload: Cmd+Shift+R (macOS) or Ctrl+Shift+R (Windows/Linux).
5. Once loaded, click **Network** tab → look at the **Transferred** total at the bottom status bar.

**Budget gates:**
| Scenario | Budget |
|---|---|
| Mobile (HTML renderer, `main.dart.js` only) | <= 3.5 MB transferred (gzipped) |
| Desktop (CanvasKit, `main.dart.js` + `canvaskit.wasm`) | <= 5.0 MB transferred (gzipped) |

- [ ] **Step 5a: If within budget — document and skip to step 7**

Record the measured sizes:

```bash
# Log sizes of key artifacts (uncompressed):
ls -lh build/web/main.dart.js build/web/flutter.js 2>/dev/null || true
du -sh build/web/
```

Write `docs/office/bundle-size-report.md`:

```markdown
# Bundle Size Report

- **Build date:** YYYY-MM-DD
- **Flutter version:** (output of `flutter --version`)
- **main.dart.js (uncompressed):** X MB
- **Total transferred — mobile (Fast 3G, Chrome DevTools):** X.X MB
- **Total transferred — desktop (Fast 3G, Chrome DevTools):** X.X MB
- **Status:** WITHIN BUDGET — no deferred loading required
```

Skip to step 7.

- [ ] **Step 5b: If over budget — apply deferred imports for non-critical screens**

Open `lib/app_router.dart` (or wherever routes for Settings, Premium, and Video Call are defined). Apply `deferred as` imports for each non-critical screen.

**Before (existing imports, example):**

```dart
import 'package:gomeet/features/settings/settings_screen.dart';
import 'package:gomeet/features/premium/premium_stub_screen.dart';
import 'package:gomeet/features/video/video_call_stub_screen.dart';
```

**After (deferred):**

```dart
import 'package:gomeet/features/settings/settings_screen.dart'
    deferred as settings;
import 'package:gomeet/features/premium/premium_stub_screen.dart'
    deferred as premium;
import 'package:gomeet/features/video/video_call_stub_screen.dart'
    deferred as video;
```

**Update each route's `builder` or `pageBuilder` to load the library before building:**

```dart
// Example for GoRouter / auto_route / Navigator.push — adapt to the actual
// router implementation in the codebase.

// GoRouter example:
GoRoute(
  path: '/settings',
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: FutureBuilder<void>(
        future: settings.loadLibrary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return settings.SettingsScreen();
        },
      ),
    );
  },
),

GoRoute(
  path: '/premium',
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: FutureBuilder<void>(
        future: premium.loadLibrary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return premium.PremiumStubScreen();
        },
      ),
    );
  },
),

GoRoute(
  path: '/video',
  pageBuilder: (context, state) {
    return NoTransitionPage(
      child: FutureBuilder<void>(
        future: video.loadLibrary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return video.VideoCallStubScreen();
        },
      ),
    );
  },
),
```

- [ ] **Step 6: Re-build and re-measure after deferred imports**

```bash
flutter build web --pwa-strategy=offline-first --release
cd build/web && python3 -m http.server 5000
```

Repeat the Chrome DevTools measurement from step 4. Both budgets must be met before proceeding.

- [ ] **Step 7: Run the deferred-import test to confirm no regression**

```bash
flutter test test/bundle/deferred_import_test.dart --platform chrome
```

Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add docs/office/bundle-size-report.md \
        lib/app_router.dart \
        test/bundle/deferred_import_test.dart
git commit -m "perf(web): apply deferred loading for non-critical screens; bundle within size budget"
```

---

## Task p5-lighthouse-final: Final Lighthouse Audit on Preview Channel

**Assigned agent:** automation_developer
**UI Reference:** none

---

- [ ] **Step 1: Install Lighthouse CLI**

```bash
npm install -g lighthouse
lighthouse --version
```

Expected: prints Lighthouse version (e.g., `11.x.x`).

- [ ] **Step 2: Build and deploy to a Firebase Hosting preview channel**

```bash
flutter build web --pwa-strategy=offline-first --release
firebase hosting:channel:deploy staging --expires 1d
```

Expected: Firebase CLI prints the preview channel URL, e.g.:
`https://gomeet--staging-abc123.web.app`

Copy this URL — it is the `PREVIEW_URL` used in subsequent steps. HTTPS is required for the full PWA audit.

- [ ] **Step 3: Run the PWA category audit**

```bash
lighthouse <PREVIEW_URL> \
  --only-categories=pwa \
  --chrome-flags="--headless" \
  --output=json \
  --output-path=docs/office/lighthouse-pwa.json
```

Expected: command completes. Open `docs/office/lighthouse-pwa.json` and find `categories.pwa.score` — multiply by 100 to get the 0–100 score.

**Target:** PWA score >= 90.

- [ ] **Step 4: Run the Performance category audit**

```bash
lighthouse <PREVIEW_URL> \
  --only-categories=performance \
  --chrome-flags="--headless" \
  --emulated-form-factor=mobile \
  --output=json \
  --output-path=docs/office/lighthouse-performance.json
```

Expected: command completes. Find `categories.performance.score` × 100.

**Target:** Performance score >= 80.

- [ ] **Step 5: Assert scores pass the targets**

```bash
node -e "
const pwa = require('./docs/office/lighthouse-pwa.json');
const perf = require('./docs/office/lighthouse-performance.json');
const pwaScore = Math.round(pwa.categories.pwa.score * 100);
const perfScore = Math.round(perf.categories.performance.score * 100);
console.log('PWA score:', pwaScore, pwaScore >= 90 ? 'PASS' : 'FAIL');
console.log('Performance score:', perfScore, perfScore >= 80 ? 'PASS' : 'FAIL');
if (pwaScore < 90 || perfScore < 80) process.exit(1);
"
```

Expected: both lines print `PASS`. If either prints `FAIL`, follow step 6.

- [ ] **Step 6 (conditional): Apply performance levers if score < 80**

Run only if the Performance audit fails. Check `lighthouse-performance.json` for the failing audits. Apply the relevant fix from the table below, rebuild, redeploy the preview channel, and re-run steps 3–5.

| Failing audit | Fix |
|---|---|
| "Avoid enormous network payloads" | Apply deferred imports (p5-bundle-size-check step 5b) if not already done |
| "Eliminate render-blocking resources" | Add `<link rel="preconnect" href="https://firestore.googleapis.com">` and `<link rel="preconnect" href="https://identitytoolkit.googleapis.com">` to `web/index.html` |
| "Reduce unused JavaScript" | Increase deferred screens list in app_router.dart |
| "Largest Contentful Paint element" — CanvasKit load | Force HTML renderer on mobile: add `--web-renderer html` flag for the mobile preview build |

**Preconnect hints addition to `web/index.html` (if needed):**

```html
<!-- Add inside <head>, before the existing <script> tags -->
<link rel="preconnect" href="https://firestore.googleapis.com" crossorigin>
<link rel="preconnect" href="https://identitytoolkit.googleapis.com" crossorigin>
<link rel="preconnect" href="https://firebase.googleapis.com" crossorigin>
<link rel="preconnect" href="https://storage.googleapis.com" crossorigin>
```

- [ ] **Step 7: Write a score-assertion test**

```dart
// test/lighthouse/lighthouse_score_test.dart
//
// Asserts that the persisted Lighthouse JSON reports meet score targets.
// Run after the Lighthouse CLI steps above have produced the JSON files.

import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

void main() {
  group('Lighthouse score targets', () {
    test('PWA score is >= 90', () {
      final raw = File('docs/office/lighthouse-pwa.json').readAsStringSync();
      final report = jsonDecode(raw) as Map<String, dynamic>;
      final categories = report['categories'] as Map<String, dynamic>;
      final pwa = categories['pwa'] as Map<String, dynamic>;
      final score = ((pwa['score'] as num) * 100).round();
      expect(score, greaterThanOrEqualTo(90),
          reason: 'PWA Lighthouse score was $score, expected >= 90');
    });

    test('Performance score is >= 80', () {
      final raw =
          File('docs/office/lighthouse-performance.json').readAsStringSync();
      final report = jsonDecode(raw) as Map<String, dynamic>;
      final categories = report['categories'] as Map<String, dynamic>;
      final performance = categories['performance'] as Map<String, dynamic>;
      final score = ((performance['score'] as num) * 100).round();
      expect(score, greaterThanOrEqualTo(80),
          reason: 'Performance Lighthouse score was $score, expected >= 80');
    });
  });
}
```

- [ ] **Step 8: Run the Dart assertion test**

```bash
flutter test test/lighthouse/lighthouse_score_test.dart
```

Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add docs/office/lighthouse-pwa.json \
        docs/office/lighthouse-performance.json \
        test/lighthouse/lighthouse_score_test.dart \
        web/index.html
git commit -m "ops: final Lighthouse audit — PWA and Performance targets met"
```

---

## Task p5-cross-browser-qa: Cross-Browser End-to-End QA

**Assigned agent:** automation_developer
**UI Reference:** none

---

### Part A: Automated regression — install banner safety in non-Chrome browsers

This is the only automatable sub-task: verify that `WebInstallManager` and `InstallBanner` do not crash when `beforeinstallprompt` never fires (Firefox, Safari, all non-Chrome browsers).

- [ ] **Step 1: Verify the existing null-guard test covers the Firefox/Safari scenario**

```bash
flutter test test/features/pwa/web_install_manager_test.dart --platform chrome
```

Expected: PASS — in particular the test `'showInstallPrompt completes without error when no deferred prompt is stored'` confirms the null-guard works. Firefox and Safari never fire `beforeinstallprompt`, so `_deferredPrompt` stays null and `showInstallPrompt()` returns early without calling any JS.

- [ ] **Step 2: Write a widget-level safety test for the banner in the no-prompt state**

```dart
// Append to test/features/pwa/widgets/install_banner_test.dart

group('InstallBanner — no install prompt available (Firefox / Safari scenario)', () {
  testWidgets('banner with onInstallTapped no-op does not throw', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // Simulate what happens in Firefox/Safari: onInstallTapped is a no-op.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InstallBanner(
            onInstallTapped: () async {
              // In Firefox/Safari, WebInstallManager.instance.isInstallAvailable
              // is false so the banner won't be shown via ValueListenableBuilder.
              // This callback path is exercised only in Chrome. We test the
              // widget itself stays stable when the callback is a no-op.
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tapping Install must not throw even if no prompt is available.
    await tester.tap(find.text('Install'));
    await tester.pumpAndSettle();
    // No exception = pass.
  });
});
```

- [ ] **Step 3: Run the updated banner tests**

```bash
flutter test test/features/pwa/widgets/install_banner_test.dart
```

Expected: PASS — all 8 tests pass (7 original + 1 new).

---

### Part B: Manual P0 flow checklist

Execute the following checklist for each browser. Record results in `docs/office/cross-browser-qa-report.md`.

**P0 flow:** sign-up → profile creation → discover (swipe) → match popup → chat (send + receive message)

- [ ] **Step 4: Create the QA report file**

```bash
cat > docs/office/cross-browser-qa-report.md << 'EOF'
# Cross-Browser QA Report

**Date:** YYYY-MM-DD
**Build:** (git commit hash)
**Live URL:** https://...

## Browsers Tested

| Browser | Version | Platform | P0 Flow | Console Errors | Notes |
|---|---|---|---|---|---|
| Chrome | 1xx | macOS | PASS/FAIL | None/List | |
| Firefox | 1xx | macOS | PASS/FAIL | None/List | |
| Safari | 1x | macOS | PASS/FAIL | None/List | |
| Chrome (Android) | 1xx | Android 14 | PASS/FAIL | None/List | |
| Safari (iOS) | 17.x | iOS 17 | PASS/FAIL | None/List | Manual only |

## Install Banner Behaviour

| Browser | isInstallAvailable | Banner shown? | Expected? |
|---|---|---|---|
| Chrome | true (after eligibility) | Yes | Yes |
| Firefox | false (event never fires) | No | Yes |
| Safari (macOS) | false (event never fires) | No | Yes |
| Safari (iOS) | false (event never fires) | No | Yes |
| Android Chrome | true (after eligibility) | Yes | Yes |

## Bugs Found

| ID | Browser | Severity | Description | Fix Commit |
|---|---|---|---|---|
| | | | | |

## Sign-off

- [ ] All P0 flows pass in Chrome
- [ ] All P0 flows pass in Firefox
- [ ] All P0 flows pass in Safari (macOS)
- [ ] Android Chrome P0 flow passes
- [ ] iOS Safari P0 flow passes (manual)
- [ ] No crash related to install banner in Firefox or Safari
EOF
```

- [ ] **Step 5: Chrome desktop — run the P0 flow**

1. Navigate to the Firebase Hosting preview URL (from p5-lighthouse-final step 2).
2. Open DevTools → **Console** tab.
3. Sign up with a new email address.
4. Complete the 5-step profile creation (upload at least one photo).
5. On Discover: swipe right on 3 profiles using the mouse drag gesture.
6. Confirm the match popup appears after a mutual like.
7. Navigate to Chat → send a text message → verify the other user (or a test account in another tab) receives it in real time.
8. Confirm no red console errors appear at any step.
9. Verify the install banner appears after the first swipe and shows the CTA text.
10. Verify the Chrome address bar shows the install icon (PWA installability).

Record result in the QA report.

- [ ] **Step 6: Firefox desktop — run the P0 flow**

Repeat the P0 flow in Firefox. Additionally:

- Open DevTools → **Console** → confirm no JavaScript errors related to `beforeinstallprompt`.
- Confirm the install banner is **not** shown (because `isInstallAvailable` is false in Firefox).

Record result in the QA report.

- [ ] **Step 7: Safari desktop — run the P0 flow**

Repeat the P0 flow in Safari. Additionally:

- Confirm the install banner is **not** shown.
- Confirm Google Sign-In popup works (Safari may block popups — user must allow if prompted).

Record result in the QA report.

- [ ] **Step 8: Android Chrome — run the P0 flow**

Using a physical Android device or BrowserStack:

1. Open the preview URL in Chrome for Android.
2. Complete the P0 flow using touch gestures for card swipes.
3. Confirm the app is responsive at the device's viewport.
4. Confirm the install banner appears after the first swipe.
5. Confirm Chrome for Android shows the "Add to Home Screen" prompt when the Install button is tapped.

Record result in the QA report.

- [ ] **Step 9: iOS Safari — manual P0 flow**

On a physical iPhone running iOS 17+ (no remote WebDriver available):

1. Open the preview URL in Safari.
2. Complete the P0 flow using touch gestures.
3. Confirm the install banner is **not** shown (iOS Safari does not support `beforeinstallprompt`).
4. Confirm no JavaScript errors in Safari → Develop → device console.

Record result in the QA report.

- [ ] **Step 10: Fix any blocking bugs found**

For each FAIL in the QA report:
- Open the relevant source file.
- Write a failing test that reproduces the bug.
- Fix the bug.
- Verify the test passes.
- Add the fix commit hash to the QA report.

- [ ] **Step 11: Commit QA report and any bug fixes**

```bash
git add docs/office/cross-browser-qa-report.md \
        test/features/pwa/widgets/install_banner_test.dart
git commit -m "qa: cross-browser QA complete; all P0 flows pass in Chrome, Firefox, Safari, Android Chrome, iOS Safari"
```

---

## Task p5-deploy: Production Deployment

**Assigned agent:** devops
**UI Reference:** none

**Depends on:** All preceding Phase 5 tasks must be complete and committed.

---

- [ ] **Step 1: Confirm pre-flight checklist**

Before running any build or deploy command, verify every item:

```
[ ] firebase.json is committed and passes flutter test test/firebase_json_test.dart
[ ] Lighthouse PWA score >= 90 (docs/office/lighthouse-pwa.json)
[ ] Lighthouse Performance score >= 80 (docs/office/lighthouse-performance.json)
[ ] Cross-browser QA report shows all P0 flows PASS (docs/office/cross-browser-qa-report.md)
[ ] App Check is in enforced mode (docs/office/app-check-enforcement.md)
[ ] Bundle size is within budget (docs/office/bundle-size-report.md)
[ ] All tests pass: flutter test
```

Run the full test suite one final time:

```bash
flutter test
```

Expected: all tests PASS, zero failures.

- [ ] **Step 2: Build the production release**

```bash
flutter build web --pwa-strategy=offline-first --release
```

Expected: `✓ Built build/web` with no warnings about undefined symbols or missing files.

- [ ] **Step 3: Deploy to Firebase Hosting production**

```bash
firebase deploy --only hosting
```

Expected output (abbreviated):

```
=== Deploying to 'gomeet'...
i  deploying hosting
✔  hosting[gomeet]: file upload complete
✔  Deploy complete!

Project Console: https://console.firebase.google.com/project/gomeet/overview
Hosting URL: https://gomeet.web.app
```

Record the **Hosting URL** and current timestamp.

- [ ] **Step 4: Verify live URL**

Open the Hosting URL in Chrome. Verify each of the following:

```
[ ] The GoMeet sign-in screen loads within 5 seconds on a 4G connection
[ ] No blank screen or "ERR_FAILED" error
[ ] Firebase Auth: sign in with an existing account succeeds
[ ] Firestore: profile cards load on the Discover screen
[ ] Service worker: open DevTools → Application → Service Workers → confirm flutter_service_worker.js is registered and active
```

- [ ] **Step 5: Verify PWA install prompt in Chrome**

1. In Chrome, navigate to the live Hosting URL.
2. Wait for the `beforeinstallprompt` event (up to 30 seconds — Chrome checks installability criteria including HTTPS, manifest, service worker).
3. Confirm the install icon appears in the Chrome address bar (right side).
4. Click the install icon → Chrome install dialog appears.
5. Click **Install** → GoMeet opens in a standalone window (no browser chrome).
6. Verify the standalone window shows the correct GoMeet UI.

```
[ ] Install icon appears in Chrome address bar
[ ] Install dialog shows GoMeet name and icon
[ ] Standalone mode opens after install
[ ] Standalone window URL is the live Hosting URL
```

- [ ] **Step 6: Verify offline shell**

1. In Chrome DevTools (the standalone PWA window) → **Network** tab → set to **Offline**.
2. Hard-reload (Cmd+Shift+R / Ctrl+Shift+R).
3. Confirm the GoMeet app shell loads (not a browser error page).
4. Confirm an offline indicator or message is shown (the service worker serves cached assets).
5. Re-enable network → confirm the app recovers without a manual refresh.

```
[ ] App shell loads while offline
[ ] Browser error page is NOT shown
[ ] App recovers automatically when network is restored
```

- [ ] **Step 7: Record deployment details**

Create `docs/office/production-deployment.md`:

```markdown
# Production Deployment Record

- **Deployed at:** YYYY-MM-DD HH:MM UTC
- **Live URL:** https://gomeet.web.app  (update if custom domain)
- **Git commit:** (output of `git rev-parse HEAD`)
- **Flutter version:** (output of `flutter --version | head -1`)
- **Firebase project:** gomeet
- **Hosting channel:** live (production)

## Post-Deploy Verification

- [x] Live URL loads GoMeet sign-in screen
- [x] Firebase Auth and Firestore operational
- [x] PWA install prompt appears in Chrome address bar
- [x] Standalone mode opens correctly after install
- [x] Offline shell serves cached assets when network is disabled

## Rollback Procedure

If a critical issue is found after deployment:

1. Identify the last known-good deploy in Firebase Console → Hosting → Release history.
2. Click "Rollback" on that release.
3. Verify the live URL serves the previous build.
4. Open a hot-fix branch, apply the fix, re-run the full test suite and Lighthouse audit, then redeploy.
```

- [ ] **Step 8: Commit**

```bash
git add docs/office/production-deployment.md
git commit -m "ops: production deployment complete — GoMeet PWA live"
```

---

## Self-Review

### Plan Coverage

| Phase 5 requirement | Covered by |
|---|---|
| WebInstallManager with dart:js interop | p5-install-manager |
| beforeinstallprompt event listener | p5-install-manager Step 6 |
| isInstallAvailable ValueNotifier | p5-install-manager Step 6 |
| Analytics: pwa_install_prompt_shown | p5-install-manager Step 6 |
| Analytics: pwa_installed via appinstalled | p5-install-manager Step 6 |
| Dismissable install banner | p5-install-banner |
| SharedPreferences persistence for dismiss | p5-install-banner Step 3 |
| Discover screen wiring after first swipe | p5-install-banner Step 6 |
| kIsWeb guards at call sites | p5-install-banner Steps 3, 6 |
| firebase.json with correct cache headers | p5-firebase-json |
| SPA catch-all rewrite rule | p5-firebase-json Step 3 |
| App Check enforced mode | p5-app-check-enforce |
| Bundle size <= 3.5 MB / 5 MB | p5-bundle-size-check |
| Deferred imports for non-critical screens | p5-bundle-size-check Step 5b |
| Lighthouse PWA >= 90 | p5-lighthouse-final |
| Lighthouse Performance >= 80 | p5-lighthouse-final |
| Cross-browser QA: Chrome, Firefox, Safari, Android, iOS | p5-cross-browser-qa |
| No crash from install banner in Firefox/Safari | p5-cross-browser-qa Parts A + B |
| Production deploy with verification | p5-deploy |
| Offline shell verification | p5-deploy Step 6 |
| Standalone mode verification | p5-deploy Step 5 |

### Type Consistency Check

- `WebInstallManager.instance` — singleton, same type in both `web_install_manager.dart` and stub.
- `WebInstallManager.isInstallAvailable` — `ValueNotifier<bool>` in both web and stub. Used with `ValueListenableBuilder<bool>` in `discover_screen.dart` — types match.
- `WebInstallManager.showInstallPrompt()` — `Future<void>` in both. Called as `await WebInstallManager.instance.showInstallPrompt()` and as `onInstallTapped` callback of type `Future<void> Function()` in `InstallBanner` — types match.
- `InstallBanner.onInstallTapped` — `Future<void> Function()` — matches the `TextButton.onPressed` which accepts `VoidCallback`. **Correction needed:** `TextButton.onPressed` accepts `VoidCallback?` (sync), not `Future<void> Function()`. Fix: wrap in an async callback in the widget:

In `lib/features/pwa/widgets/install_banner.dart`, change the `Install` button's `onPressed`:

```dart
// In _InstallBannerState.build(), change the TextButton onPressed:
onPressed: () => widget.onInstallTapped(),
// This drops the Future<void> return value which is fine — fire-and-forget.
// The widget doesn't need to await the prompt result.
```

This is already the correct pattern since `TextButton.onPressed` is `VoidCallback?`. The `() => widget.onInstallTapped()` syntax calls the async function and discards the future intentionally.

### Test Command Accuracy

| Test file | Command | Platform |
|---|---|---|
| `test/features/pwa/web_install_manager_test.dart` | `flutter test ... --platform chrome` | Chrome (dart:js required) |
| `test/features/pwa/widgets/install_banner_test.dart` | `flutter test ...` | Dart VM |
| `test/firebase_json_test.dart` | `flutter test ...` | Dart VM |
| `test/bundle/deferred_import_test.dart` | `flutter test ... --platform chrome` | Chrome (deferred lib resolution) |
| `test/lighthouse/lighthouse_score_test.dart` | `flutter test ...` | Dart VM (reads JSON files) |
