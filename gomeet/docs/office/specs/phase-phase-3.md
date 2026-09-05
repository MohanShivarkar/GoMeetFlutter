# GoMeet PWA — Phase 3: PWA Shell & Installability Implementation Spec

> **For build-phase agents:** Execute this spec task-by-task. Each task follows TDD (red-green-refactor). Steps use checkbox (`- [ ]`) syntax for tracking. Complete every step in order — later tasks depend on earlier ones.

**Goal:** Make the GoMeet Flutter web build a fully installable, offline-capable PWA with a Lighthouse PWA score >= 90.
**Tech Stack:** Flutter 3.x, Dart, `image` package (v4), Firebase Hosting, `firebase serve`, Chrome DevTools, Lighthouse.

---

## Dependency Map

```
p3-icons
    └── p3-manifest
            └── p3-index-html
                    └── p3-service-worker-verify
                            ├── p3-offline-shell-test
                            └── p3-lighthouse-audit
                                        └── p3-install-test
```

---

## Task p3-icons: Generate GoMeet Brand Icons

**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html

**Files:**
- Create: `tool/generate_icons.dart`
- Create: `test/pwa/icons_test.dart`
- Create (output): `web/icons/Icon-192.png`
- Create (output): `web/icons/Icon-512.png`
- Create (output): `web/icons/Icon-maskable-192.png`
- Create (output): `web/icons/Icon-maskable-512.png`
- Modify: `pubspec.yaml` (add `image` dev dependency)

---

- [ ] **Step 1: Add the `image` package as a dev dependency**

Open `pubspec.yaml` and add the `image` package under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  image: ^4.1.0          # ← add this line
```

- [ ] **Step 2: Fetch the dependency**

```bash
flutter pub get
```

Expected: `image 4.x.x` appears in `.dart_tool/package_config.json`. No errors.

---

- [ ] **Step 3: Write the failing test**

Create `test/pwa/icons_test.dart`:

```dart
import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:test/test.dart';

void main() {
  group('PWA Icons — existence and dimensions', () {
    const iconSpecs = [
      {'path': 'web/icons/Icon-192.png', 'size': 192},
      {'path': 'web/icons/Icon-512.png', 'size': 512},
      {'path': 'web/icons/Icon-maskable-192.png', 'size': 192},
      {'path': 'web/icons/Icon-maskable-512.png', 'size': 512},
    ];

    for (final spec in iconSpecs) {
      final path = spec['path'] as String;
      final size = spec['size'] as int;

      test('$path exists', () {
        final file = File(path);
        expect(
          file.existsSync(),
          isTrue,
          reason: '$path must be present in the repository',
        );
      });

      test('$path is a valid PNG with ${size}x$size dimensions', () {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'File must exist before checking dimensions');

        final bytes = file.readAsBytesSync();
        expect(bytes.isNotEmpty, isTrue, reason: '$path must not be empty');

        final decoded = img.decodePng(bytes);
        expect(decoded, isNotNull, reason: '$path must be a valid PNG');
        expect(decoded!.width, equals(size), reason: 'Width must be $size px');
        expect(decoded.height, equals(size), reason: 'Height must be $size px');
      });
    }
  });
}
```

- [ ] **Step 4: Run the test to confirm it fails (RED)**

```bash
flutter test test/pwa/icons_test.dart
```

Expected output:
```
FAIL — web/icons/Icon-192.png must be present in the repository
FAIL — web/icons/Icon-512.png must be present in the repository
FAIL — web/icons/Icon-maskable-192.png must be present in the repository
FAIL — web/icons/Icon-maskable-512.png must be present in the repository
```

All 8 tests fail. This is correct — the icons do not exist yet.

---

- [ ] **Step 5: Create the `web/icons/` directory**

```bash
mkdir -p web/icons
```

---

- [ ] **Step 6: Write the icon generation script**

Create `tool/generate_icons.dart`:

```dart
/// Generates GoMeet brand placeholder icons for the PWA manifest.
///
/// Produces four PNG files in web/icons/ using the GoMeet brand palette:
///   Background: #0F0F1A (dark navy)
///   Brand accent: #FF4458 (rose-coral)
///
/// Standard icons (no padding): Icon-192.png, Icon-512.png
/// Maskable icons (~10 % safe-zone padding): Icon-maskable-192.png, Icon-maskable-512.png
///
/// Run with: dart run tool/generate_icons.dart
library;

import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  Directory('web/icons').createSync(recursive: true);

  // Standard icons — no safe-zone padding, icon fills the full canvas
  _generateIcon('web/icons/Icon-192.png', 192, safePadding: 0);
  _generateIcon('web/icons/Icon-512.png', 512, safePadding: 0);

  // Maskable icons — ~10 % safe-zone padding on all sides
  // 10% of 192 = 19.2  → 19 px
  // 10% of 512 = 51.2  → 51 px
  _generateIcon('web/icons/Icon-maskable-192.png', 192, safePadding: 19);
  _generateIcon('web/icons/Icon-maskable-512.png', 512, safePadding: 51);

  print('✓ All icons generated in web/icons/');
}

/// Creates a single square PNG icon.
///
/// [path]        – Output file path.
/// [size]        – Canvas size in pixels (width == height).
/// [safePadding] – Pixels of safe-zone to leave clear on each edge (maskable icons).
void _generateIcon(String path, int size, {required int safePadding}) {
  final image = img.Image(width: size, height: size);

  // Fill entire canvas with brand background #0F0F1A
  img.fill(image, color: img.ColorRgb8(0x0F, 0x0F, 0x1A));

  final center = size ~/ 2;

  // Outer brand circle — #FF4458 (rose-coral)
  final outerRadius = center - safePadding;
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: outerRadius,
    color: img.ColorRgb8(0xFF, 0x44, 0x58),
  );

  // Inner white circle (represents the GoMeet "G" / logo nucleus)
  // Size: 45 % of outer radius keeps proportions clean at all sizes
  final innerRadius = (outerRadius * 0.45).round();
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: innerRadius,
    color: img.ColorRgb8(0xFF, 0xFF, 0xFF),
  );

  // Small navy circle at centre (creates a ring effect that mimics the logo mark)
  final dotRadius = (outerRadius * 0.18).round();
  img.fillCircle(
    image,
    x: center,
    y: center,
    radius: dotRadius,
    color: img.ColorRgb8(0x0F, 0x0F, 0x1A),
  );

  final file = File(path);
  file.writeAsBytesSync(img.encodePng(image));
  print('  Created: $path  (${size}x$size, padding=$safePadding)');
}
```

- [ ] **Step 7: Run the icon generation script**

```bash
dart run tool/generate_icons.dart
```

Expected output:
```
  Created: web/icons/Icon-192.png  (192x192, padding=0)
  Created: web/icons/Icon-512.png  (512x512, padding=0)
  Created: web/icons/Icon-maskable-192.png  (192x192, padding=19)
  Created: web/icons/Icon-maskable-512.png  (512x512, padding=51)
✓ All icons generated in web/icons/
```

---

- [ ] **Step 8: Run the test to confirm it passes (GREEN)**

```bash
flutter test test/pwa/icons_test.dart
```

Expected output:
```
00:02 +8: All tests passed!
```

All 8 tests (4 existence + 4 dimension checks) pass.

- [ ] **Step 9: Refactor**

No refactor needed — the generator is minimal and self-contained. The test is declarative and data-driven.

- [ ] **Step 10: Commit**

```bash
git add pubspec.yaml pubspec.lock tool/generate_icons.dart test/pwa/icons_test.dart web/icons/
git commit -m "feat(pwa): generate brand icons for PWA manifest (192, 512, maskable)"
```

---

## Task p3-manifest: Create PWA Manifest

**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html

**Files:**
- Create: `web/manifest.json`
- Create: `test/pwa/manifest_test.dart`

---

- [ ] **Step 1: Write the failing test**

Create `test/pwa/manifest_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Map<String, dynamic> manifest;

  setUpAll(() {
    final file = File('web/manifest.json');
    expect(file.existsSync(), isTrue, reason: 'web/manifest.json must exist');
    final raw = file.readAsStringSync();
    manifest = jsonDecode(raw) as Map<String, dynamic>;
  });

  group('PWA Manifest — required scalar fields', () {
    test('name is "GoMeet"', () {
      expect(manifest['name'], equals('GoMeet'));
    });

    test('short_name is "GoMeet"', () {
      expect(manifest['short_name'], equals('GoMeet'));
    });

    test('description is correct', () {
      expect(
        manifest['description'],
        equals('Swipe, match, and chat — no app install needed.'),
      );
    });

    test('start_url is "/"', () {
      expect(manifest['start_url'], equals('/'));
    });

    test('display is "standalone"', () {
      expect(manifest['display'], equals('standalone'));
    });

    test('background_color is "#0F0F1A"', () {
      expect(manifest['background_color'], equals('#0F0F1A'));
    });

    test('theme_color is "#FF4458"', () {
      expect(manifest['theme_color'], equals('#FF4458'));
    });

    test('orientation is "portrait-primary"', () {
      expect(manifest['orientation'], equals('portrait-primary'));
    });
  });

  group('PWA Manifest — icons array', () {
    late List<dynamic> icons;

    setUp(() {
      icons = manifest['icons'] as List<dynamic>;
    });

    test('icons array has exactly 4 entries', () {
      expect(icons.length, equals(4));
    });

    test('contains Icon-192.png (any purpose)', () {
      final entry = icons.firstWhere(
        (i) => (i as Map)['src'] == 'icons/Icon-192.png',
        orElse: () => null,
      );
      expect(entry, isNotNull, reason: 'icons/Icon-192.png must appear in icons array');
      expect((entry as Map)['sizes'], equals('192x192'));
      expect(entry['type'], equals('image/png'));
    });

    test('contains Icon-512.png (any purpose)', () {
      final entry = icons.firstWhere(
        (i) => (i as Map)['src'] == 'icons/Icon-512.png',
        orElse: () => null,
      );
      expect(entry, isNotNull, reason: 'icons/Icon-512.png must appear in icons array');
      expect((entry as Map)['sizes'], equals('512x512'));
      expect(entry['type'], equals('image/png'));
    });

    test('contains Icon-maskable-192.png with purpose "maskable"', () {
      final entry = icons.firstWhere(
        (i) => (i as Map)['src'] == 'icons/Icon-maskable-192.png',
        orElse: () => null,
      );
      expect(entry, isNotNull, reason: 'icons/Icon-maskable-192.png must appear in icons array');
      expect((entry as Map)['sizes'], equals('192x192'));
      expect(entry['type'], equals('image/png'));
      expect(entry['purpose'], equals('maskable'));
    });

    test('contains Icon-maskable-512.png with purpose "maskable"', () {
      final entry = icons.firstWhere(
        (i) => (i as Map)['src'] == 'icons/Icon-maskable-512.png',
        orElse: () => null,
      );
      expect(entry, isNotNull, reason: 'icons/Icon-maskable-512.png must appear in icons array');
      expect((entry as Map)['sizes'], equals('512x512'));
      expect(entry['type'], equals('image/png'));
      expect(entry['purpose'], equals('maskable'));
    });
  });
}
```

- [ ] **Step 2: Run the test to confirm it fails (RED)**

```bash
flutter test test/pwa/manifest_test.dart
```

Expected output:
```
FAIL — web/manifest.json must exist
```

All tests fail because the file does not yet exist.

---

- [ ] **Step 3: Create `web/manifest.json`**

Create `web/manifest.json` with the following exact content:

```json
{
  "name": "GoMeet",
  "short_name": "GoMeet",
  "description": "Swipe, match, and chat — no app install needed.",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#0F0F1A",
  "theme_color": "#FF4458",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

- [ ] **Step 4: Run the test to confirm it passes (GREEN)**

```bash
flutter test test/pwa/manifest_test.dart
```

Expected output:
```
00:01 +12: All tests passed!
```

All 12 tests pass (8 scalar field checks + 4 icon entry checks).

- [ ] **Step 5: Refactor**

No refactor needed — manifest.json is pure data, the test is exhaustive.

- [ ] **Step 6: Commit**

```bash
git add web/manifest.json test/pwa/manifest_test.dart
git commit -m "feat(pwa): add web/manifest.json with GoMeet brand config and icons"
```

---

## Task p3-index-html: Add iOS PWA Meta Tags to web/index.html

**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html

**Files:**
- Modify: `web/index.html`
- Create: `test/pwa/index_html_test.dart`

---

- [ ] **Step 1: Write the failing test**

Create `test/pwa/index_html_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to confirm it fails (RED)**

```bash
flutter test test/pwa/index_html_test.dart
```

Expected output (some or all of the following, depending on the current state of web/index.html):
```
FAIL — theme-color meta tag must be present with value #FF4458
FAIL — apple-touch-icon 192x192 must be declared for iOS Safari
FAIL — apple-touch-icon 512x512 must be declared for iOS Safari
```

The manifest and bootstrap script tests may already pass if Flutter generated a default index.html. The three PWA-specific tags will fail.

---

- [ ] **Step 3: Update `web/index.html`**

Open `web/index.html`. Locate the `<head>` section. Add the three new tags **inside `<head>`**, directly after any existing `<meta charset>` or `<meta name="viewport">` tag. Also ensure `<link rel="manifest" href="manifest.json">` is present (add it if missing).

The resulting `<head>` section must contain — in this order — the following lines (existing tags are preserved; only new lines are added):

```html
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base URL you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    For more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base
  -->
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Swipe, match, and chat — no app install needed.">

  <!-- PWA: theme color for browser chrome -->
  <meta name="theme-color" content="#FF4458">

  <!-- iOS Safari PWA icons -->
  <link rel="apple-touch-icon" sizes="192x192" href="icons/Icon-192.png">
  <link rel="apple-touch-icon" sizes="512x512" href="icons/Icon-512.png">

  <!-- PWA manifest -->
  <link rel="manifest" href="manifest.json">

  <title>GoMeet</title>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

> **Note:** Do not delete any existing tags in `web/index.html` that were generated by Flutter (e.g. `<meta name="apple-mobile-web-app-capable">`, `<meta name="apple-mobile-web-app-status-bar-style">`, existing `<link rel="manifest">`). If an existing `<link rel="manifest">` already points to `manifest.json`, do not add a second one — the test only checks that `rel="manifest"` and `manifest.json` both appear anywhere in the file. If `flutter_bootstrap.js` does not exist and the file references `flutter.js`, leave it as `flutter.js` — either passes the test.

- [ ] **Step 4: Run the test to confirm it passes (GREEN)**

```bash
flutter test test/pwa/index_html_test.dart
```

Expected output:
```
00:01 +5: All tests passed!
```

All 5 tests pass.

- [ ] **Step 5: Refactor**

No refactor needed — this is a configuration file update.

- [ ] **Step 6: Commit**

```bash
git add web/index.html test/pwa/index_html_test.dart
git commit -m "feat(pwa): add iOS Safari meta tags and theme-color to web/index.html"
```

---

## Task p3-service-worker-verify: Build and Verify Service Worker

> **Agent:** backend_engineer
> **No UI Reference** — this is a build and infrastructure verification task.

**Files:**
- Create or verify: `firebase.json`
- Create: `docs/office/pwa-sw-verification.md` (result log)

---

- [ ] **Step 1: Write the verification shell script (RED baseline)**

Create `tool/verify_sw.sh`:

```bash
#!/usr/bin/env bash
# Verifies that the Flutter web build contains a valid service worker.
# Run AFTER 'flutter build web --pwa-strategy=offline-first'.
# Exit code 0 = pass, 1 = fail.

set -euo pipefail

BUILD_DIR="build/web"
SW_FILE="$BUILD_DIR/flutter_service_worker.js"
MANIFEST_FILE="$BUILD_DIR/manifest.json"
INDEX_FILE="$BUILD_DIR/index.html"

echo "=== GoMeet PWA Service Worker Verification ==="

FAIL=0

check() {
  local label="$1"
  local condition="$2"
  if eval "$condition"; then
    echo "  PASS  $label"
  else
    echo "  FAIL  $label"
    FAIL=1
  fi
}

check "build/web/ directory exists"          "[ -d '$BUILD_DIR' ]"
check "flutter_service_worker.js emitted"    "[ -f '$SW_FILE' ]"
check "manifest.json in build output"        "[ -f '$MANIFEST_FILE' ]"
check "index.html in build output"           "[ -f '$INDEX_FILE' ]"
check "service worker references RESOURCES"  "grep -q 'RESOURCES' '$SW_FILE'"
check "service worker references index.html" "grep -q 'index.html' '$SW_FILE'"
check "Icon-192.png in build output"         "[ -f '$BUILD_DIR/icons/Icon-192.png' ]"
check "Icon-512.png in build output"         "[ -f '$BUILD_DIR/icons/Icon-512.png' ]"
check "Icon-maskable-192.png in build output" "[ -f '$BUILD_DIR/icons/Icon-maskable-192.png' ]"
check "Icon-maskable-512.png in build output" "[ -f '$BUILD_DIR/icons/Icon-maskable-512.png' ]"

if [ "$FAIL" -eq 1 ]; then
  echo ""
  echo "RESULT: FAIL — one or more checks did not pass."
  exit 1
else
  echo ""
  echo "RESULT: PASS — service worker and all assets are present."
  exit 0
fi
```

Make it executable:

```bash
chmod +x tool/verify_sw.sh
```

- [ ] **Step 2: Run the verification script before building (confirms RED)**

```bash
bash tool/verify_sw.sh
```

Expected output:
```
  FAIL  build/web/ directory exists
  FAIL  flutter_service_worker.js emitted
  ...
RESULT: FAIL — one or more checks did not pass.
```

This is expected — the build has not been run yet.

---

- [ ] **Step 3: Verify or create `firebase.json`**

If `firebase.json` does not exist at the project root, create it now. If it already exists, ensure the `hosting.public` field is `"build/web"` and the rewrites catch-all is present.

Write (or update) `firebase.json`:

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
        "source": "/flutter_service_worker.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "no-cache"
          }
        ]
      },
      {
        "source": "**/*.@(js|css|wasm|png|jpg|svg|ttf|woff|woff2)",
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

- [ ] **Step 4: Run the Flutter web build with offline-first PWA strategy**

```bash
flutter build web --pwa-strategy=offline-first --release
```

Expected: build completes with `✓ Built build/web` and exit code 0.
If compilation errors occur, they must be resolved before proceeding (these are pre-existing issues from Phase 1/2 — they are out of scope for this task; escalate to the Phase 1 agent).

- [ ] **Step 5: Run the verification script (GREEN)**

```bash
bash tool/verify_sw.sh
```

Expected output:
```
=== GoMeet PWA Service Worker Verification ===
  PASS  build/web/ directory exists
  PASS  flutter_service_worker.js emitted
  PASS  manifest.json in build output
  PASS  index.html in build output
  PASS  service worker references RESOURCES
  PASS  service worker references index.html
  PASS  Icon-192.png in build output
  PASS  Icon-512.png in build output
  PASS  Icon-maskable-192.png in build output
  PASS  Icon-maskable-512.png in build output

RESULT: PASS — service worker and all assets are present.
```

All 10 checks pass.

---

- [ ] **Step 6: Serve locally with Firebase and verify in Chrome DevTools**

```bash
firebase serve --only hosting
```

Expected: `✔  hosting: Local server: http://localhost:5000`

Open Chrome and navigate to `http://localhost:5000`.

Open Chrome DevTools (`F12` or `Cmd+Option+I`) → **Application** tab → **Service Workers** (left sidebar).

Verify:
- Source: `flutter_service_worker.js`
- Status: **activated and running** (green dot)
- No errors in the console

Then click **Cache Storage** (left sidebar) and expand the cache named `flutter-app-manifest` or similar.

Verify:
- `index.html` appears in the cached file list
- `main.dart.js` (or `main.dart.js.gz`) appears in the cached file list
- Icon files appear in the cached file list

- [ ] **Step 7: Document the verification result**

Create `docs/office/pwa-sw-verification.md`:

```markdown
# PWA Service Worker Verification Log

**Date:** <!-- fill in today's date -->
**Build command:** `flutter build web --pwa-strategy=offline-first --release`
**Served via:** `firebase serve --only hosting` → http://localhost:5000
**Flutter version:** <!-- output of `flutter --version` -->

## Script Result

```
<!-- paste the full output of `bash tool/verify_sw.sh` here -->
```

## Chrome DevTools — Service Workers

- [ ] flutter_service_worker.js listed as source
- [ ] Status: activated and running
- [ ] No errors shown in the Service Worker panel

## Chrome DevTools — Cache Storage

- [ ] Cache entry exists (e.g. `flutter-app-manifest-...`)
- [ ] index.html present in cache
- [ ] main.dart.js present in cache
- [ ] Icon-192.png present in cache
- [ ] Icon-512.png present in cache

## Result

[ ] PASS / [ ] FAIL
```

Fill in the log with actual results after running the steps above.

- [ ] **Step 8: Refactor**

No refactor needed.

- [ ] **Step 9: Commit**

```bash
git add firebase.json tool/verify_sw.sh docs/office/pwa-sw-verification.md
git commit -m "feat(pwa): add firebase.json hosting config and service worker verification script"
```

---

## Task p3-offline-shell-test: Smoke-Test Offline Shell Behaviour

**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html

> **Agent:** automation_developer
> **Prerequisite:** `p3-service-worker-verify` complete — `firebase serve` must be running on port 5000 with an activated service worker and populated cache.

**Files:**
- Create: `test/pwa/offline_shell_test_procedure.md`
- Create: `docs/office/pwa-offline-shell-result.md`

---

- [ ] **Step 1: Write the test procedure document (RED — defines what "pass" means)**

Create `test/pwa/offline_shell_test_procedure.md`:

```markdown
# Offline Shell Smoke Test Procedure

## Purpose

Verify that the GoMeet PWA app shell loads correctly from the service worker cache
when the device is offline. A "pass" means the GoMeet UI renders — not a Chrome
dinosaur error page.

## Prerequisites

1. `firebase serve --only hosting` is running (http://localhost:5000).
2. The service worker is activated and running (verified in p3-service-worker-verify).
3. Chrome browser (version 100+) is open.

## Steps

### Phase A — Seed the cache (Online)

1. Open Chrome and navigate to `http://localhost:5000`.
2. Wait for the Flutter app to fully load (splash screen disappears, main UI is visible).
3. Open Chrome DevTools (`F12`) → **Application** → **Service Workers**.
4. Confirm status is **activated and running**.
5. Open **Cache Storage** → confirm app shell assets are listed.

### Phase B — Go Offline

6. In Chrome DevTools, switch to the **Network** tab.
7. In the **Throttling** dropdown (next to the "Disable cache" checkbox), select **Offline**.
8. The Network tab should show a yellow warning: "You are offline".

### Phase C — Reload and Verify

9. Press `Ctrl+R` (or `Cmd+R`) to reload the page.
10. Observe the page behaviour.

### Pass Criteria

- [ ] The GoMeet app shell renders (navigation bar, background colour #0F0F1A visible).
- [ ] NO Chrome dinosaur error page ("No internet" / ERR_INTERNET_DISCONNECTED) is shown.
- [ ] If OfflineBanner widget is wired (from Phase 2 p2-offline-banner):
      the banner reading "You're offline" (or equivalent) is visible.
- [ ] If OfflineBanner is NOT yet wired:
      document this as a known gap — the shell still loads, which is the minimum pass bar.

### Fail Criteria

- [ ] Chrome shows a dinosaur error page (service worker not serving cached assets).
- [ ] A blank white screen with no GoMeet UI elements.

### Phase D — Restore Connectivity

11. In Chrome DevTools → Network → change throttling back to **No throttling**.
12. Reload the page — app should return to normal operation.

## Pass / Fail

Record the result in `docs/office/pwa-offline-shell-result.md`.
```

- [ ] **Step 2: Confirm the test procedure will fail without a running build (RED checkpoint)**

Attempt the following without `firebase serve` running:

```bash
curl -s http://localhost:5000 | head -5
```

Expected: `curl: (7) Failed to connect to localhost port 5000` or similar connection refused.

This confirms we cannot execute the test yet without the server. The procedure is correctly blocked on prerequisites.

---

- [ ] **Step 3: Execute the offline shell test**

Follow every step in `test/pwa/offline_shell_test_procedure.md` exactly.

Ensure `firebase serve` is running:

```bash
firebase serve --only hosting
```

Open Chrome to `http://localhost:5000` and follow Steps 1–12 of the procedure.

- [ ] **Step 4: Document the result (GREEN = shell loads offline)**

Create `docs/office/pwa-offline-shell-result.md`:

```markdown
# Offline Shell Smoke Test — Result

**Date:** <!-- fill in -->
**Tester:** <!-- fill in -->
**Flutter version:** <!-- output of `flutter --version` -->
**Chrome version:** <!-- from chrome://version/ -->

## Test Execution

### Phase A — Cache seeded
- Navigated to http://localhost:5000
- App loaded successfully
- Service worker status: activated and running
- Cache Storage: [list key assets visible, e.g. "index.html, main.dart.js, icons/Icon-192.png"]

### Phase B — Went Offline
- Network throttling set to: Offline
- DevTools shows offline warning: Yes / No

### Phase C — Reload Result

**What was rendered after reload:**
<!-- Describe what appeared — app shell? Dinosaur? Blank? -->

**Screenshot description / evidence:**
<!-- Describe or attach screenshot -->

## Pass Criteria Evaluation

- [ ] GoMeet app shell rendered (background #0F0F1A visible): PASS / FAIL
- [ ] No Chrome dinosaur error: PASS / FAIL
- [ ] OfflineBanner visible: PASS / FAIL / NOT YET WIRED (known gap)

## Overall Result

[ ] PASS — offline shell loads correctly
[ ] FAIL — see notes below

## Notes / Gaps

<!-- Any known gaps, e.g. "OfflineBanner not yet wired — p2-offline-banner pending" -->
```

Fill in all sections with actual observed results.

- [ ] **Step 5: Refactor**

No refactor needed — this is a documented manual test.

- [ ] **Step 6: Commit**

```bash
git add test/pwa/offline_shell_test_procedure.md docs/office/pwa-offline-shell-result.md
git commit -m "test(pwa): offline shell smoke test procedure and result log"
```

---

## Task p3-lighthouse-audit: Lighthouse PWA Audit (Score >= 90)

> **Agent:** automation_developer
> **No UI Reference** — this is an automated audit task.
> **Prerequisite:** `p3-service-worker-verify` complete. Build available at `build/web/`.

**Files:**
- Create: `docs/office/pwa-lighthouse-result.md`
- Modify (if score < 90): any of `web/manifest.json`, `web/index.html`, `firebase.json`

---

- [ ] **Step 1: Write the acceptance criteria (RED — defines what "pass" means)**

Create `docs/office/pwa-lighthouse-result.md` with the criteria template:

```markdown
# Lighthouse PWA Audit Result

**Target:** PWA score >= 90
**Status:** PENDING

## Audit Configuration

- **Tool:** Chrome DevTools Lighthouse (or `npx lighthouse`)
- **Category:** Progressive Web App
- **URL:** <!-- http://localhost:5000 OR Firebase preview channel URL -->
- **Mode:** Navigation
- **Device:** Mobile (emulated)

## Run History

| Run # | Date | URL | PWA Score | Notes |
|-------|------|-----|-----------|-------|
| 1     |      |     |           |       |

## Final Result

[ ] PASS (score >= 90)
[ ] FAIL (score < 90 — see remediation log below)

## Remediation Log

<!-- Document each fix applied between runs -->
```

- [ ] **Step 2: Deploy to a Firebase preview channel for HTTPS (required for full PWA audit)**

```bash
firebase hosting:channel:deploy pwa-audit-preview --expires 2h
```

Expected output:
```
✔  hosting:pwa-audit-preview: Channel URL (expires ...): https://gomeet--pwa-audit-preview-<hash>.web.app
```

Copy the preview URL. Lighthouse requires HTTPS for a complete PWA audit — `localhost` only partially satisfies service worker checks.

If `firebase hosting:channel:deploy` fails (not authenticated or project not configured), fall back to local `firebase serve` for the audit and note that HTTPS checks will be marked as warnings rather than failures.

---

- [ ] **Step 3: Run the Lighthouse audit**

**Option A — Chrome DevTools (recommended):**

1. Open Chrome and navigate to the preview channel URL (or `http://localhost:5000`).
2. Open DevTools → **Lighthouse** tab.
3. Under "Categories", check only **Progressive Web App**.
4. Under "Device", select **Mobile**.
5. Click **Analyze page load**.
6. Wait for the audit to complete (~30 seconds).
7. Note the PWA score.

**Option B — CLI (if DevTools unavailable):**

```bash
npx lighthouse <PREVIEW_URL> \
  --only-categories=pwa \
  --output=json \
  --output-path=docs/office/lighthouse-report.json \
  --chrome-flags="--headless"
```

Then extract the score:

```bash
node -e "
  const r = require('./docs/office/lighthouse-report.json');
  const score = r.categories.pwa.score * 100;
  console.log('PWA Score:', score);
  process.exit(score >= 90 ? 0 : 1);
"
```

---

- [ ] **Step 4: If score >= 90 — document and proceed (GREEN)**

Update `docs/office/pwa-lighthouse-result.md` with the score and mark PASS. Skip to Step 7.

- [ ] **Step 5: If score < 90 — apply remediation**

The following are the most common Lighthouse PWA failures and their fixes:

**Failure: "No maskable icon found"**
- Cause: `purpose: "maskable"` missing from manifest icons array.
- Fix: Already addressed in p3-manifest. Verify `web/manifest.json` has both `Icon-maskable-192.png` and `Icon-maskable-512.png` with `"purpose": "maskable"`.

**Failure: "Manifest `start_url` is not cached by a service worker"**
- Cause: The service worker does not cache `/`. This is automatic with `--pwa-strategy=offline-first` — if it fails, the build was not run with that flag.
- Fix:
  ```bash
  flutter build web --pwa-strategy=offline-first --release
  firebase hosting:channel:deploy pwa-audit-preview --expires 2h
  ```

**Failure: "Does not redirect HTTP traffic to HTTPS"**
- Cause: Running against `http://localhost:5000`. Firebase Hosting enforces HTTPS automatically on deployed URLs.
- Fix: Use the preview channel HTTPS URL, not localhost.

**Failure: "apple-touch-icon is not defined"**
- Cause: Missing `<link rel="apple-touch-icon">` in `web/index.html`.
- Fix: Already addressed in p3-index-html. Verify both apple-touch-icon tags are present.

**Failure: "`theme-color` meta tag not found"**
- Cause: Missing or incorrect `<meta name="theme-color">` in `web/index.html`.
- Fix: Already addressed in p3-index-html. Verify `content="#FF4458"` is present.

**Failure: "Service worker does not successfully serve the page offline"**
- Cause: Service worker is registered but not intercepting fetch. Verify:
  1. DevTools → Application → Service Workers shows "activated and running" (not "waiting to activate").
  2. Try clicking "skipWaiting" in DevTools to force activation.
  3. Hard reload (`Ctrl+Shift+R`) and re-audit.

After applying any fix, rebuild and redeploy:

```bash
flutter build web --pwa-strategy=offline-first --release
firebase hosting:channel:deploy pwa-audit-preview --expires 2h
```

Then re-run the Lighthouse audit (go back to Step 3).

- [ ] **Step 6: Repeat until score >= 90**

Add each run to the "Run History" table in `docs/office/pwa-lighthouse-result.md`. Document every fix applied in the "Remediation Log" section.

- [ ] **Step 7: Update the result document with final passing score**

Update `docs/office/pwa-lighthouse-result.md`:

```markdown
## Final Result

[x] PASS (score >= 90) — Final score: [SCORE]
```

Include a screenshot description or the JSON report path.

- [ ] **Step 8: Commit**

```bash
git add docs/office/pwa-lighthouse-result.md
# Include any web/ fixes that were applied during remediation:
git add web/manifest.json web/index.html firebase.json
git commit -m "test(pwa): Lighthouse PWA audit passing — score [SCORE]/100"
```

---

## Task p3-install-test: Manual PWA Installation Test

**UI Reference:** docs/office/05-ui-designs/05-pwa-install.html

> **Agent:** automation_developer
> **Prerequisite:** `p3-lighthouse-audit` complete. The Firebase preview channel URL is available and the PWA score is >= 90.

**Files:**
- Create: `docs/office/pwa-install-test-result.md`

---

- [ ] **Step 1: Write the acceptance criteria (RED — defines "pass")**

Create `docs/office/pwa-install-test-result.md` with the checklist template:

```markdown
# PWA Manual Installation Test — Result

**Date:** <!-- fill in -->
**Tester:** <!-- fill in -->
**Test URL:** <!-- Firebase preview channel HTTPS URL -->
**Status:** PENDING

---

## Platform A: Android Chrome

**Device / OS:** <!-- e.g. Pixel 7, Android 14 -->
**Chrome version:** <!-- from chrome://version -->

### Steps

1. Navigate to the test URL in Chrome on Android.
2. Wait for the page to fully load.
3. Tap the browser ⋮ (three-dot) menu.
4. Check for "Add to Home Screen" or "Install app" option.

### Results

- [ ] "Add to Home Screen" / "Install app" option visible in Chrome menu
- [ ] Completed installation (tapped "Add" or "Install")
- [ ] GoMeet icon appears on the home screen with label "GoMeet"
- [ ] Tapping the home screen icon opens the app in standalone mode (no browser address bar)
- [ ] Background colour is #0F0F1A (dark navy), not white

**Notes:**
<!-- Describe any unexpected behaviour -->

**Pass / Fail:** PASS / FAIL

---

## Platform B: Desktop Chrome (Windows / macOS / Linux)

**OS / Chrome version:** <!-- e.g. macOS 14.5, Chrome 126 -->

### Steps

1. Navigate to the test URL in Chrome on desktop.
2. Look for the install icon (monitor with down-arrow) in the address bar.
3. Click the install icon.
4. Click "Install" in the dialog.

### Results

- [ ] Install icon (⊕ or monitor+arrow) visible in Chrome address bar
- [ ] Install dialog appears with GoMeet icon and name "GoMeet"
- [ ] Completed installation
- [ ] App opens in a standalone window (no browser tabs/address bar)
- [ ] Window title shows "GoMeet"
- [ ] Background colour is #0F0F1A, not white

**Notes:**
<!-- Describe any unexpected behaviour -->

**Pass / Fail:** PASS / FAIL

---

## Platform C: iOS Safari

**Device / iOS version:** <!-- e.g. iPhone 15 Pro, iOS 17.5 -->
**Safari version:** <!-- from Settings → Safari -->

### Steps

1. Navigate to the test URL in Safari on iOS.
2. Wait for the page to fully load.
3. Tap the Share button (box with up-arrow) in the Safari toolbar.
4. Scroll the share sheet and tap "Add to Home Screen".
5. Verify the icon preview shows the GoMeet brand icon.
6. Verify the name field shows "GoMeet".
7. Tap "Add".

### Results

- [ ] "Add to Home Screen" option visible in Safari share sheet
- [ ] Icon preview in the "Add to Home Screen" dialog shows GoMeet brand icon (rose-coral circle, not a website screenshot)
- [ ] Name field pre-filled as "GoMeet"
- [ ] GoMeet icon appears on the iOS home screen
- [ ] Tapping the home screen icon opens the app in standalone mode (no Safari address bar / nav chrome)
- [ ] Background colour is #0F0F1A, not white

**Notes:**
<!-- Describe any unexpected behaviour -->

**Pass / Fail:** PASS / FAIL

---

## Overall Result

All three platforms must pass for the task to be complete.

- [ ] Android Chrome: PASS
- [ ] Desktop Chrome: PASS
- [ ] iOS Safari: PASS

**Overall:** PASS / FAIL

## Known Gaps / Deferred Items

<!-- e.g. "beforeinstallprompt in-app CTA not yet wired (deferred to p5-install-cta)" -->
<!-- e.g. "iOS PWA does not support push notifications — known platform limitation" -->
```

- [ ] **Step 2: Execute the test on Android Chrome (GREEN check)**

Follow the steps in the "Platform A: Android Chrome" section above.

Access the Firebase preview channel HTTPS URL from your Android device. If you do not have a physical Android device, use the Chrome DevTools "Mobile simulation" for basic validation, but note that the install prompt may behave differently in simulation — document this.

After completing installation, fill in the "Results" section for Platform A.

- [ ] **Step 3: Execute the test on Desktop Chrome (GREEN check)**

Follow the steps in the "Platform B: Desktop Chrome" section above.

Navigate to the preview URL in Chrome on your desktop. The install icon appears in the address bar once Chrome determines the PWA criteria are met (this may take a few seconds after the page loads).

After completing installation, fill in the "Results" section for Platform B.

- [ ] **Step 4: Execute the test on iOS Safari (GREEN check)**

Follow the steps in the "Platform C: iOS Safari" section above.

Access the Firebase preview channel HTTPS URL in Safari on an iOS device. If no physical iOS device is available, use the macOS Safari with "Develop → Enter Responsive Design Mode" for partial simulation, and note the limitation.

After completing installation, fill in the "Results" section for Platform C.

- [ ] **Step 5: Evaluate overall result**

Check the "Overall Result" section:

- If all three platforms pass → mark **PASS**.
- If any platform fails → identify the root cause:
  - **Android Chrome — no install prompt:** The Lighthouse score may not be >= 90, or `start_url` may not be cached. Recheck `p3-lighthouse-audit`.
  - **Desktop Chrome — no install icon:** Same as above. Also check that the manifest `display` is `"standalone"` (not `"browser"`).
  - **iOS Safari — wrong icon shown:** `<link rel="apple-touch-icon">` may be missing or pointing to the wrong path. Recheck `p3-index-html`.
  - **App opens with browser chrome:** The manifest `display: standalone` is not being respected. Verify the served manifest.json content matches `web/manifest.json` exactly.

Apply any fixes identified, rebuild, redeploy, and re-run the affected platform test.

- [ ] **Step 6: Refactor**

No refactor needed — this is a documented manual test.

- [ ] **Step 7: Commit**

```bash
git add docs/office/pwa-install-test-result.md
git commit -m "test(pwa): manual PWA installation test — all platforms pass"
```

---

## Phase 3 Complete — Acceptance Checklist

Before marking Phase 3 done, verify all of the following:

```
[ ] p3-icons:    flutter test test/pwa/icons_test.dart → 8/8 PASS
[ ] p3-manifest: flutter test test/pwa/manifest_test.dart → 12/12 PASS
[ ] p3-index-html: flutter test test/pwa/index_html_test.dart → 5/5 PASS
[ ] p3-service-worker-verify: bash tool/verify_sw.sh → 10/10 PASS
[ ] p3-service-worker-verify: Chrome DevTools confirms SW "activated and running"
[ ] p3-offline-shell-test: App shell loads offline (no dinosaur error)
[ ] p3-lighthouse-audit: PWA score >= 90 on HTTPS preview URL
[ ] p3-install-test: Installation verified on Android Chrome + Desktop Chrome + iOS Safari
```

All tasks committed. Phase 3 is ready for Phase 5 (Polish, Install CTA & Deploy).
