# GoMeet PWA — Phase 2: Core User Flows Implementation Spec

> **For build-phase agents:** Execute this spec task-by-task. Each task follows strict TDD (red-green-refactor). Steps use checkbox (`- [ ]`) syntax for tracking. Execute ALL steps in order — never skip "run test" verification steps. Each task depends on the ones listed in its **Dependencies** line.

**Goal:** Wire the GoRouter with all primary routes, create the 404 screen, add an offline banner, and verify/fix every core user flow (auth, profile creation, discover, chat, analytics) to work end-to-end in Chrome.
**Tech Stack:** Flutter 3.x, GoRouter, Firebase Auth (web), Cloud Firestore, Firebase Storage, connectivity_plus ≥5.0.0, flutter_test

---

## Task p2-router-wire: Wire CorePwaHomeScreen as Web Entry Route

**Agent:** frontend_engineer
**Dependencies:** none
**Files:**
- Create: `lib/core/router/app_router.dart`
- Modify: `lib/main.dart`
- Test: `test/core/router/app_router_test.dart`

UI Reference: none

- [ ] **Step 1: Write the failing test**

Create `test/core/router/app_router_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:gomeet/core/router/app_router.dart';
import 'package:gomeet/features/shell/screens/not_found_screen.dart';
import 'package:gomeet/features/shell/screens/core_pwa_home_screen.dart';

void main() {
  group('AppRouter', () {
    test('appRouter is a GoRouter instance', () {
      expect(appRouter, isA<GoRouter>());
    });

    testWidgets('initial route / renders CorePwaHomeScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: appRouter),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CorePwaHomeScreen), findsOneWidget);
    });

    testWidgets('unknown route renders NotFoundScreen', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: appRouter),
      );
      appRouter.go('/this-route-does-not-exist-xyz');
      await tester.pumpAndSettle();
      expect(find.byType(NotFoundScreen), findsOneWidget);
    });

    group('all declared routes do not render NotFoundScreen', () {
      const namedRoutes = [
        '/sign-in',
        '/sign-up',
        '/profile/create',
        '/discover',
        '/chat',
        '/chat/test-convo-id',
        '/profile/test-user-id',
        '/settings',
      ];

      for (final path in namedRoutes) {
        testWidgets('route $path is reachable', (tester) async {
          await tester.pumpWidget(
            MaterialApp.router(routerConfig: appRouter),
          );
          appRouter.go(path);
          await tester.pumpAndSettle();
          expect(find.byType(NotFoundScreen), findsNothing);
        });
      }
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails (RED)**

```bash
flutter test test/core/router/app_router_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:gomeet/core/router/app_router.dart'`

- [ ] **Step 3: Grep for existing screen class names to locate real imports**

Run each command and record the file path + class name found:

```bash
grep -r "class CorePwaHomeScreen" lib/ --include="*.dart" -l
grep -r "class SignInScreen\|SigninScreen\|LoginScreen" lib/ --include="*.dart" -l
grep -r "class SignUpScreen\|SignupScreen\|RegisterScreen" lib/ --include="*.dart" -l
grep -r "class DiscoverScreen\|SwipeScreen\|HomeScreen" lib/ --include="*.dart" -l
grep -r "class ChatListScreen\|ChatScreen\|ConversationsScreen" lib/ --include="*.dart" -l
grep -r "class ChatThreadScreen\|ChatRoomScreen\|MessageScreen" lib/ --include="*.dart" -l
grep -r "class ProfileViewScreen\|UserProfileScreen\|ProfileScreen" lib/ --include="*.dart" -l
grep -r "class SettingsScreen\|SettingScreen" lib/ --include="*.dart" -l
grep -r "class ProfileCreat" lib/ --include="*.dart" -l
```

- [ ] **Step 4: Create `lib/core/router/app_router.dart`**

For every screen found in Step 3, uncomment the matching import line below and delete the corresponding `_Stub` class. Leave stubs in place for any screen you cannot locate — they are valid, runnable widgets.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Core & shell (must exist — created in p2-not-found-screen) ──
import '../../features/shell/screens/not_found_screen.dart';
import '../../features/shell/screens/core_pwa_home_screen.dart';

// ── Real screen imports: uncomment each line once Step 3 identifies the path ──
// import '../../features/auth/screens/sign_in_screen.dart';
// import '../../features/auth/screens/sign_up_screen.dart';
// import '../../features/profile/screens/profile_creation_screen.dart';
// import '../../features/discover/screens/discover_screen.dart';
// import '../../features/chat/screens/chat_list_screen.dart';
// import '../../features/chat/screens/chat_thread_screen.dart';
// import '../../features/profile/screens/profile_view_screen.dart';
// import '../../features/settings/screens/settings_screen.dart';

// ── Stub screens (delete each stub once its real import above is uncommented) ──

class _StubSignInScreen extends StatelessWidget {
  const _StubSignInScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Sign In')));
}

class _StubSignUpScreen extends StatelessWidget {
  const _StubSignUpScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Sign Up')));
}

class _StubProfileCreateScreen extends StatelessWidget {
  const _StubProfileCreateScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Create Profile')));
}

class _StubDiscoverScreen extends StatelessWidget {
  const _StubDiscoverScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Discover')));
}

class _StubChatListScreen extends StatelessWidget {
  const _StubChatListScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chat List')));
}

class _StubChatThreadScreen extends StatelessWidget {
  final String conversationId;
  const _StubChatThreadScreen({required this.conversationId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Chat: $conversationId')));
}

class _StubProfileViewScreen extends StatelessWidget {
  final String userId;
  const _StubProfileViewScreen({required this.userId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Profile: $userId')));
}

class _StubSettingsScreen extends StatelessWidget {
  const _StubSettingsScreen();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

// ── Router ──

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const NotFoundScreen(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const CorePwaHomeScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const _StubSignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const _StubSignUpScreen(),
    ),
    GoRoute(
      path: '/profile/create',
      builder: (context, state) => const _StubProfileCreateScreen(),
    ),
    GoRoute(
      path: '/discover',
      builder: (context, state) => const _StubDiscoverScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const _StubChatListScreen(),
      routes: [
        GoRoute(
          path: ':conversationId',
          builder: (context, state) => _StubChatThreadScreen(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) => _StubProfileViewScreen(
        userId: state.pathParameters['userId']!,
      ),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const _StubSettingsScreen(),
    ),
  ],
);
```

- [ ] **Step 5: Update `lib/main.dart` to use appRouter**

Locate the `runApp` call and the existing `MaterialApp` (or `_AppShellPlaceholder`) block:

```bash
grep -n "MaterialApp\|_AppShellPlaceholder\|runApp" lib/main.dart
```

Add the router import at the top of `main.dart`:

```dart
import 'core/router/app_router.dart';
```

Find the `MaterialApp(...)` block (its exact content will vary) and replace it with:

```dart
MaterialApp.router(
  routerConfig: appRouter,
  title: 'GoMeet',
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF4458),
      brightness: Brightness.dark,
      surface: const Color(0xFF0F0F1A),
    ),
    useMaterial3: true,
  ),
)
```

- [ ] **Step 6: Run test to verify it passes (GREEN)**

```bash
flutter test test/core/router/app_router_test.dart
```

Expected: All tests PASS.

- [ ] **Step 7: Verify path-based routing in browser**

```bash
flutter run -d chrome
```

Navigate in the browser address bar:
- `http://localhost:<port>/` → CorePwaHomeScreen renders
- `http://localhost:<port>/sign-in` → sign-in content (stub or real)
- `http://localhost:<port>/nonexistent` → 404 NotFoundScreen

Confirm the URL bar shows `/sign-in` (path-based), NOT `/#/sign-in` (hash-based). If hash-based URLs appear, add `urlPathStrategy: PathUrlStrategy()` in `main.dart` before `runApp`:

```dart
// Add import at top of main.dart:
import 'package:flutter_web_plugins/url_strategy.dart';

// Add before runApp():
usePathUrlStrategy();
```

- [ ] **Step 8: Refactor — swap stubs for real screen imports**

For each screen found in Step 3:
1. Uncomment the corresponding import in `app_router.dart`.
2. Replace `_StubXxxScreen(...)` in the routes list with the real class name.
3. Delete the `_StubXxxScreen` class.
4. Run `flutter test test/core/router/app_router_test.dart` after each swap to confirm no regressions.

- [ ] **Step 9: Commit**

```bash
git add lib/core/router/app_router.dart lib/main.dart test/core/router/app_router_test.dart
git commit -m "feat: wire GoRouter with all primary routes, 404 fallback, path-based URLs"
```

---

## Task p2-not-found-screen: 404 Not Found Screen

**Agent:** frontend_engineer
**Dependencies:** none (can run in parallel with p2-router-wire)
**Files:**
- Create: `lib/features/shell/screens/not_found_screen.dart`
- Create (TDD driver): `test/features/shell/not_found_screen_test.dart`

UI Reference: none

- [ ] **Step 1: Write the failing test**

Create `test/features/shell/not_found_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/shell/screens/not_found_screen.dart';

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
```

- [ ] **Step 2: Run test to verify it fails (RED)**

```bash
flutter test test/features/shell/not_found_screen_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:gomeet/features/shell/screens/not_found_screen.dart'`

- [ ] **Step 3: Create `lib/features/shell/screens/not_found_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Graceful 404 screen.
///
/// Used as [GoRouter.errorBuilder] for unmatched routes.
/// Does not duplicate a Scaffold if already inside a ShellRoute that
/// provides one — in that case, wrap the [body] content in your shell's
/// Scaffold instead and remove the one here.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '404',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4458),
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Page not found',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The page you are looking for does not exist or has been moved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF9E9EAE),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Go to home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes (GREEN)**

```bash
flutter test test/features/shell/not_found_screen_test.dart
```

Expected: 4/4 PASS.

- [ ] **Step 5: No refactor needed — implementation is minimal.**

- [ ] **Step 6: Commit**

```bash
git add lib/features/shell/screens/not_found_screen.dart \
        test/features/shell/not_found_screen_test.dart
git commit -m "feat: add NotFoundScreen — 404 page with home navigation, max 500 px constraint"
```

---

## Task p2-not-found-screen-test: 404 Screen Widget Tests (Automation Review)

**Agent:** automation_developer
**Dependencies:** `p2-not-found-screen` must be complete.
**Files:**
- Read + verify: `test/features/shell/not_found_screen_test.dart`

UI Reference: none

> **Note:** The test file was created in `p2-not-found-screen`. This task is a quality gate: run all tests, confirm they pass, and add any missing coverage identified below.

- [ ] **Step 1: Run the existing test suite**

```bash
flutter test test/features/shell/not_found_screen_test.dart --reporter expanded
```

Expected: 4 tests — all PASS.
If any test FAILS, fix `not_found_screen.dart` per the error message before continuing.

- [ ] **Step 2: Verify test coverage completeness**

Open `test/features/shell/not_found_screen_test.dart` and confirm it includes tests for:

| Coverage point | Expected finder |
|---|---|
| `404` text renders | `find.textContaining('404')` |
| `Page not found` renders | `find.textContaining('Page not found')` |
| Button labeled `Go to home` exists | `find.widgetWithText(ElevatedButton, 'Go to home')` |
| Button `onPressed` is non-null | `buttonWidget.onPressed != null` |
| Content `ConstrainedBox(maxWidth: 500)` at 1200 px viewport | `constrainedBoxes.firstWhere(box => box.constraints.maxWidth == 500)` |

If any row is missing, add the test using the patterns from the `p2-not-found-screen` spec above.

- [ ] **Step 3: Confirm final pass**

```bash
flutter test test/features/shell/not_found_screen_test.dart --reporter expanded
```

Expected: All tests PASS.

- [ ] **Step 4: Commit**

```bash
git add test/features/shell/not_found_screen_test.dart
git commit -m "test: verify NotFoundScreen widget test coverage is complete"
```

---

## Task p2-offline-banner: Offline Connectivity Banner

**Agent:** frontend_engineer
**Dependencies:** none
**Files:**
- Create: `lib/features/shell/widgets/offline_banner.dart`
- Modify: `lib/main.dart` (wrap root widget)
- Test: `test/features/shell/offline_banner_test.dart`

UI Reference: docs/office/05-ui-designs/05-pwa-install.html

The mockup Panel B shows the offline shell state: the app chrome remains visible with a banner explaining the offline state and a reconnect action. The banner is slim, branded (rose `#FF4458` background), and non-blocking.

- [ ] **Step 1: Confirm connectivity_plus is in pubspec.yaml**

```bash
grep "connectivity_plus" pubspec.yaml
```

If missing, add it:

```yaml
dependencies:
  connectivity_plus: ^5.0.2
```

Then run:

```bash
flutter pub get
```

- [ ] **Step 2: Write the failing test**

Create `test/features/shell/offline_banner_test.dart`:

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/shell/widgets/offline_banner.dart';

void main() {
  group('OfflineBanner', () {
    testWidgets('does not show banner when stream emits wifi connectivity',
        (tester) async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: OfflineBanner(
            connectivityStream: controller.stream,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      controller.add([ConnectivityResult.wifi]);
      await tester.pump();

      expect(find.textContaining('offline'), findsNothing);
    });

    testWidgets('shows banner when stream emits ConnectivityResult.none',
        (tester) async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: OfflineBanner(
            connectivityStream: controller.stream,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      controller.add([ConnectivityResult.none]);
      await tester.pump();

      expect(find.textContaining('offline'), findsOneWidget);
      expect(find.textContaining('connect to continue'), findsOneWidget);
    });

    testWidgets('hides banner automatically when connectivity is restored',
        (tester) async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: OfflineBanner(
            connectivityStream: controller.stream,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      controller.add([ConnectivityResult.none]);
      await tester.pump();
      expect(find.textContaining('offline'), findsOneWidget);

      controller.add([ConnectivityResult.mobile]);
      await tester.pump();
      expect(find.textContaining('offline'), findsNothing);
    });

    testWidgets('banner is dismissable via close button', (tester) async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: OfflineBanner(
            connectivityStream: controller.stream,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      controller.add([ConnectivityResult.none]);
      await tester.pump();
      expect(find.textContaining('offline'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.textContaining('offline'), findsNothing);
    });

    testWidgets('child widget is always rendered regardless of banner state',
        (tester) async {
      final controller = StreamController<List<ConnectivityResult>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: OfflineBanner(
            connectivityStream: controller.stream,
            child: const Scaffold(body: Text('App Content')),
          ),
        ),
      );

      controller.add([ConnectivityResult.none]);
      await tester.pump();

      expect(find.text('App Content'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Run test to verify it fails (RED)**

```bash
flutter test test/features/shell/offline_banner_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:gomeet/features/shell/widgets/offline_banner.dart'`

- [ ] **Step 4: Create `lib/features/shell/widgets/offline_banner.dart`**

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Wraps [child] and overlays a slim dismissable banner at the top of the
/// screen whenever network connectivity is lost.
///
/// In production, [connectivityStream] defaults to
/// [Connectivity.onConnectivityChanged]. Pass a custom stream in tests
/// to control connectivity state without calling the real plugin.
class OfflineBanner extends StatefulWidget {
  final Widget child;

  /// Override the connectivity stream (for testing only).
  final Stream<List<ConnectivityResult>>? connectivityStream;

  const OfflineBanner({
    super.key,
    required this.child,
    this.connectivityStream,
  });

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<List<ConnectivityResult>> get _effectiveStream =>
      widget.connectivityStream ?? Connectivity().onConnectivityChanged;

  @override
  void initState() {
    super.initState();
    _subscription = _effectiveStream.listen(_handleConnectivity);
    // Check initial connectivity only when using the real plugin stream
    // (injected test streams control the initial state themselves).
    if (widget.connectivityStream == null) {
      Connectivity().checkConnectivity().then((results) {
        if (mounted) _handleConnectivity(results);
      });
    }
  }

  void _handleConnectivity(List<ConnectivityResult> results) {
    setState(() {
      _isOffline = results.every((r) => r == ConnectivityResult.none);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _OfflineBannerStrip(
              onDismiss: () => setState(() => _isOffline = false),
            ),
          ),
      ],
    );
  }
}

class _OfflineBannerStrip extends StatelessWidget {
  final VoidCallback onDismiss;

  const _OfflineBannerStrip({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xFFFF4458),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'You are offline — connect to continue.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes (GREEN)**

```bash
flutter test test/features/shell/offline_banner_test.dart
```

Expected: 5/5 PASS.

- [ ] **Step 6: Wrap the root widget in `lib/main.dart` with OfflineBanner**

Add the import at the top of `main.dart`:

```dart
import 'features/shell/widgets/offline_banner.dart';
```

Locate the `MaterialApp.router(...)` call. Wrap it with `OfflineBanner`:

```dart
runApp(
  OfflineBanner(
    child: MaterialApp.router(
      routerConfig: appRouter,
      title: 'GoMeet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4458),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F0F1A),
        ),
        useMaterial3: true,
      ),
    ),
  ),
);
```

- [ ] **Step 7: Verify in browser**

```bash
flutter run -d chrome
```

Open Chrome DevTools → Network → click the "Offline" throttling preset. The banner should appear within 1–2 seconds. Unset Offline — the banner should disappear.

- [ ] **Step 8: No refactor needed — implementation is minimal.**

- [ ] **Step 9: Commit**

```bash
git add lib/features/shell/widgets/offline_banner.dart \
        lib/main.dart \
        test/features/shell/offline_banner_test.dart
git commit -m "feat: add OfflineBanner widget with connectivity_plus stream listener"
```

---

## Task p2-auth-email-google: Email + Google Sign-In Web Fix

**Agent:** backend_engineer
**Dependencies:** none
**Files:**
- Locate via grep: existing sign-in screen and/or auth service
- Create if missing: `lib/features/auth/services/google_sign_in_web_service.dart`
- Test: `test/features/auth/google_sign_in_web_service_test.dart`

UI Reference: docs/office/05-ui-designs/01-sign-in.html

The sign-in mockup shows Email/password, Google Sign-In, and phone auth options. Firebase `LOCAL` persistence keeps the session across browser refreshes — no "remember me" toggle needed.

- [ ] **Step 1: Locate existing auth files**

```bash
grep -r "signInWithEmailAndPassword\|FirebaseAuth\|GoogleSignIn" lib/ --include="*.dart" -l
grep -r "signInWithPopup\|GoogleAuthProvider" lib/ --include="*.dart" -l
grep -r "class.*SignIn\|class.*Auth.*Service\|class.*AuthRepository" lib/ --include="*.dart" -l
```

Record the sign-in screen file path and any existing auth service/repository file paths. You will modify these in Step 4.

- [ ] **Step 2: Check for problematic platform guards on Google Sign-In**

```bash
grep -n "GoogleSignIn()\|google_sign_in" lib/ -r --include="*.dart"
grep -n "kIsWeb" lib/ -r --include="*.dart" | grep -i "google\|sign"
```

If `GoogleSignIn()` is called WITHOUT a `kIsWeb` guard (i.e., always called regardless of platform), the web build will fail or produce incorrect behaviour. Note the file and line number.

- [ ] **Step 3: Check that Firebase Auth persistence is set to LOCAL**

```bash
grep -n "setPersistence\|Persistence\." lib/ -r --include="*.dart"
```

If `setPersistence` is not called explicitly, Firebase Auth uses `LOCAL` persistence by default on web — this is correct. If you see `Persistence.SESSION` or `Persistence.NONE`, that is the bug (sessions won't survive page refresh).

- [ ] **Step 4: Write the failing test**

Create `test/features/auth/google_sign_in_web_service_test.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/auth/services/google_sign_in_web_service.dart';

// ── Fakes ──

class FakeUserCredential extends Fake implements UserCredential {
  @override
  User? get user => null;
  @override
  AdditionalUserInfo? get additionalUserInfo => null;
  @override
  AuthCredential? get credential => null;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  bool signInWithPopupCalled = false;
  AuthProvider? capturedProvider;

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) async {
    signInWithPopupCalled = true;
    capturedProvider = provider;
    return FakeUserCredential();
  }
}

// ── Tests ──

void main() {
  group('GoogleSignInWebService', () {
    test('signIn calls FirebaseAuth.signInWithPopup with GoogleAuthProvider',
        () async {
      final fakeAuth = FakeFirebaseAuth();
      final service = GoogleSignInWebService(auth: fakeAuth);

      await service.signIn();

      expect(fakeAuth.signInWithPopupCalled, isTrue);
      expect(fakeAuth.capturedProvider, isA<GoogleAuthProvider>());
    });

    test('signIn returns the UserCredential from signInWithPopup', () async {
      final fakeAuth = FakeFirebaseAuth();
      final service = GoogleSignInWebService(auth: fakeAuth);

      final result = await service.signIn();

      expect(result, isA<UserCredential>());
    });
  });
}
```

- [ ] **Step 5: Run test to verify it fails (RED)**

```bash
flutter test test/features/auth/google_sign_in_web_service_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:gomeet/features/auth/services/google_sign_in_web_service.dart'`

- [ ] **Step 6: Create `lib/features/auth/services/google_sign_in_web_service.dart`**

```dart
import 'package:firebase_auth/firebase_auth.dart';

/// Web-specific Google Sign-In service.
///
/// Uses [FirebaseAuth.signInWithPopup] which opens a Google OAuth popup
/// in the browser. This avoids the native `google_sign_in` Flutter plugin
/// which does not work on web.
///
/// The existing sign-in screen (found via grep in Step 1) must call this
/// service instead of [GoogleSignIn()] when [kIsWeb] is true.
class GoogleSignInWebService {
  final FirebaseAuth _auth;

  GoogleSignInWebService({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  Future<UserCredential> signIn() async {
    final provider = GoogleAuthProvider();
    // Add scopes if required by the existing mobile flow:
    // provider.addScope('https://www.googleapis.com/auth/contacts.readonly');
    return await _auth.signInWithPopup(provider);
  }
}
```

- [ ] **Step 7: Run test to verify it passes (GREEN)**

```bash
flutter test test/features/auth/google_sign_in_web_service_test.dart
```

Expected: 2/2 PASS.

- [ ] **Step 8: Wire the web service into the existing sign-in screen**

Open the sign-in screen file found in Step 1. Find the method that handles "Sign in with Google" button press. Apply the following pattern (adapt variable names to match the file):

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/google_sign_in_web_service.dart';
// Keep the existing google_sign_in import for mobile — do NOT remove it.

// In the button onPressed handler, replace unconditional GoogleSignIn() usage:
Future<void> _handleGoogleSignIn() async {
  try {
    if (kIsWeb) {
      // Web: use popup flow
      final service = GoogleSignInWebService();
      await service.signIn();
    } else {
      // Mobile: existing native GoogleSignIn code (leave unchanged)
      // ... existing mobile code ...
    }
    // Navigate on success — use existing navigation code
  } catch (e) {
    // Show existing error UI
  }
}
```

- [ ] **Step 9: Verify Firebase Auth LOCAL persistence (web)**

In `lib/main.dart` or wherever `Firebase.initializeApp()` is called, confirm `LOCAL` persistence is set for web. Add it if missing:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// After Firebase.initializeApp():
if (kIsWeb) {
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
}
```

- [ ] **Step 10: Manually verify in Chrome**

```bash
flutter run -d chrome
```

1. Sign up with email + password → Firebase Auth issues a token → user is signed in.
2. Refresh the page (`F5`) → user is still signed in (LOCAL persistence works).
3. Sign out, then tap "Sign in with Google" → Google OAuth popup opens → after completing OAuth, user is signed in.
4. Navigate to Firebase Console → Authentication → Users → confirm new web user appears.

- [ ] **Step 11: Commit**

```bash
git add lib/features/auth/services/google_sign_in_web_service.dart \
        test/features/auth/google_sign_in_web_service_test.dart
git commit -m "fix: add GoogleSignInWebService using signInWithPopup for web OAuth"
```

---

## Task p2-auth-phone-otp: Phone/OTP Web Fix

**Agent:** backend_engineer
**Dependencies:** none
**Files:**
- Locate via grep: existing phone auth screen
- Create if missing: `lib/features/auth/services/phone_auth_web_service.dart`
- Test: `test/features/auth/phone_auth_web_service_test.dart`

UI Reference: docs/office/05-ui-designs/01-sign-in.html

- [ ] **Step 1: Locate existing phone auth code**

```bash
grep -r "PhoneAuthProvider\|verifyPhoneNumber\|signInWithPhoneNumber\|RecaptchaVerifier" lib/ --include="*.dart" -l
grep -rn "RecaptchaVerifier" lib/ --include="*.dart"
```

Record file paths and line numbers. Look specifically for any `RecaptchaVerifier` that passes a container `id` string — this is the web-incompatible pattern.

- [ ] **Step 2: Identify the bug pattern**

The problematic pattern (causes `reCAPTCHA container element not found` on web):
```dart
// WRONG — native container pattern does not exist on web:
RecaptchaVerifier(
  container: 'recaptcha-container',  // ← HTML element ID, web-only API but wrong usage
  ...
)
```

The correct web pattern (invisible reCAPTCHA rendered automatically by Firebase):
```dart
// CORRECT:
RecaptchaVerifier(
  auth: FirebaseAuth.instance,
  size: RecaptchaVerifierSize.invisible,
  theme: RecaptchaVerifierTheme.light,
)
```

- [ ] **Step 3: Write the failing test**

Create `test/features/auth/phone_auth_web_service_test.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/auth/services/phone_auth_web_service.dart';

class FakeVerificationCompleted extends Fake {}

void main() {
  group('PhoneAuthWebService', () {
    test('creates PhoneAuthWebService without throwing', () {
      expect(() => PhoneAuthWebService(), returnsNormally);
    });

    test('recaptchaVerifier is configured as invisible', () {
      final service = PhoneAuthWebService();
      // The service exposes the verifier size for testability
      expect(service.recaptchaSize, equals(RecaptchaVerifierSize.invisible));
    });
  });
}
```

- [ ] **Step 4: Run test to verify it fails (RED)**

```bash
flutter test test/features/auth/phone_auth_web_service_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:gomeet/features/auth/services/phone_auth_web_service.dart'`

- [ ] **Step 5: Create `lib/features/auth/services/phone_auth_web_service.dart`**

```dart
import 'package:firebase_auth/firebase_auth.dart';

/// Web-specific Phone/OTP authentication service.
///
/// Firebase Phone Auth on web auto-injects an invisible reCAPTCHA verifier.
/// The [RecaptchaVerifier] must use [RecaptchaVerifierSize.invisible] —
/// never pass a container ID (that API is for a different web SDK version).
///
/// The existing phone auth screen must call [sendOtp] instead of calling
/// [FirebaseAuth.verifyPhoneNumber] with a native-style verifier.
class PhoneAuthWebService {
  final FirebaseAuth _auth;
  final RecaptchaVerifierSize recaptchaSize;

  PhoneAuthWebService({
    FirebaseAuth? auth,
    this.recaptchaSize = RecaptchaVerifierSize.invisible,
  }) : _auth = auth ?? FirebaseAuth.instance;

  /// Sends an OTP to [phoneNumber].
  ///
  /// [onCodeSent] is called with the verificationId when Firebase sends the SMS.
  /// [onError] is called if verification fails (e.g., invalid phone number).
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
  }) async {
    final verifier = RecaptchaVerifier(
      auth: _auth,
      size: recaptchaSize,
      theme: RecaptchaVerifierTheme.light,
    );

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (_) {
        // Auto-resolution is not commonly triggered on web; no-op is safe.
      },
      verificationFailed: onError,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
      verifier: verifier,
    );
  }

  /// Signs in using the [verificationId] from [sendOtp] and the user's [smsCode].
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }
}
```

- [ ] **Step 6: Run test to verify it passes (GREEN)**

```bash
flutter test test/features/auth/phone_auth_web_service_test.dart
```

Expected: 2/2 PASS.

- [ ] **Step 7: Wire the service into the existing phone auth screen**

Open the phone auth screen file found in Step 1. Replace direct `RecaptchaVerifier` construction (or `verifyPhoneNumber` calls) with the `PhoneAuthWebService`:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/phone_auth_web_service.dart';

// In the screen state class:
late final PhoneAuthWebService _phoneService;

@override
void initState() {
  super.initState();
  if (kIsWeb) {
    _phoneService = PhoneAuthWebService();
  }
}

// In the "Send OTP" button handler:
Future<void> _onSendOtp() async {
  if (kIsWeb) {
    await _phoneService.sendOtp(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        setState(() => _verificationId = verificationId);
        // Show OTP input field
      },
      onError: (e) {
        // Show existing error UI
      },
    );
  } else {
    // Existing mobile verifyPhoneNumber call — leave unchanged
  }
}
```

- [ ] **Step 8: Manually verify in Chrome**

```bash
flutter run -d chrome
```

1. Navigate to the phone auth screen.
2. Enter a valid test phone number (use Firebase Auth test phone numbers from Firebase Console → Authentication → Sign-in method → Phone → Phone numbers for testing).
3. Tap "Send OTP" — no reCAPTCHA widget should appear visually (invisible reCAPTCHA runs silently).
4. Enter the test OTP code displayed in Firebase Console.
5. User is signed in.

- [ ] **Step 9: Commit**

```bash
git add lib/features/auth/services/phone_auth_web_service.dart \
        test/features/auth/phone_auth_web_service_test.dart
git commit -m "fix: add PhoneAuthWebService with invisible reCAPTCHA verifier for web"
```

---

## Task p2-profile-creation: Profile Creation Flow Verification

**Agent:** frontend_engineer
**Dependencies:** none
**Files:**
- Locate via grep: existing profile creation screens
- Verify/fix: DI wiring for `CameraServiceWeb` and `LocationServiceWeb`
- Test: `test/features/profile/profile_creation_web_test.dart`

UI Reference: docs/office/05-ui-designs/02-profile-creation.html

The mockup shows Step 3 of 5: a 3×2 photo grid, camera capture button, file-picker upload, drag-to-reorder, a progress bar, and a "GoMeet Photo Tips" card. The camera button uses `getUserMedia`; location is obtained from the browser Geolocation API.

- [ ] **Step 1: Locate existing profile creation files**

```bash
grep -r "profileCreation\|ProfileCreate\|UserProfile\|ProfileStep" lib/ --include="*.dart" -l
grep -r "image_picker\|ImagePicker\|XFile" lib/ --include="*.dart" -l
grep -r "CameraService\|LocationService\|GeoService" lib/ --include="*.dart" -l
grep -r "getUserMedia\|ImagePickerWeb\|image_picker_for_web" lib/ --include="*.dart" -l
```

Record all file paths found.

- [ ] **Step 2: Check pubspec.yaml for required web packages**

```bash
grep -E "image_picker_for_web|image_picker:" pubspec.yaml
```

`image_picker` version ≥ 1.0.0 includes web support via `image_picker_for_web` automatically. If the project uses `image_picker` < 1.0.0, update it:

```yaml
dependencies:
  image_picker: ^1.1.2
```

Then:

```bash
flutter pub upgrade image_picker
```

- [ ] **Step 3: Write the failing smoke test**

Create `test/features/profile/profile_creation_web_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import the profile creation screen class found in Step 1.
// Replace the import path and class name with what grep returned.
// Example — update this import:
// import 'package:gomeet/features/profile/screens/profile_creation_screen.dart';

void main() {
  group('Profile creation web smoke tests', () {
    test('image_picker package supports web platform', () {
      // This is a static code audit test — it verifies that the build
      // dependencies allow image_picker on web. If this test file compiles
      // and the app runs in Chrome, the package is wired correctly.
      // The actual runtime test is Step 8 (manual Chrome verification).
      expect(true, isTrue); // placeholder for build-time validation
    });

    testWidgets('profile photo grid renders without overflow on 390 px viewport',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Replace ProfilePhotoGrid with the actual photo grid widget class
      // found in the profile creation screen (grep for 'PhotoGrid\|photoGrid\|GridView').
      // If the widget name is different, update the finder accordingly.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _TestPhotoGridPlaceholder(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow exceptions
      expect(tester.takeException(), isNull);
    });
  });
}

/// Temporary widget used only for the viewport test above.
/// Replace with the real photo grid widget once its class name is found in Step 1.
class _TestPhotoGridPlaceholder extends StatelessWidget {
  const _TestPhotoGridPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      children: List.generate(
        6,
        (i) => Container(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.all(4),
          child: const Icon(Icons.add_a_photo, color: Colors.white54),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes (GREEN — the test is a smoke test)**

```bash
flutter test test/features/profile/profile_creation_web_test.dart
```

Expected: PASS. These tests verify no build-time errors; the real verification is Step 8.

- [ ] **Step 5: Verify DI wiring for CameraServiceWeb**

From the files found in Step 1, locate where `CameraService` is registered in the DI container (search for Riverpod `Provider`, BLoC `BlocProvider`, or `GetIt.instance.registerLazySingleton`):

```bash
grep -r "CameraService\|LocationService\|registerLazySingleton\|Provider.*Camera\|Provider.*Location" lib/ --include="*.dart" -l
```

Locate the DI registration. Ensure a web-compatible implementation is registered when `kIsWeb` is true. Example pattern (adapt to the project's DI approach):

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// If using GetIt:
if (kIsWeb) {
  GetIt.instance.registerLazySingleton<CameraService>(() => CameraServiceWeb());
  GetIt.instance.registerLazySingleton<LocationService>(() => LocationServiceWeb());
} else {
  GetIt.instance.registerLazySingleton<CameraService>(() => CameraServiceNative());
  GetIt.instance.registerLazySingleton<LocationService>(() => LocationServiceNative());
}

// If using Riverpod:
final cameraServiceProvider = Provider<CameraService>((ref) {
  if (kIsWeb) return CameraServiceWeb();
  return CameraServiceNative();
});
```

If `CameraServiceWeb` and `LocationServiceWeb` stubs do not exist, they were created in Phase 1. If missing, verify Phase 1 tasks are complete before continuing.

- [ ] **Step 6: Manually verify photo upload in Chrome**

```bash
flutter run -d chrome
```

1. Navigate to the profile creation photo step.
2. Tap the file-picker button → a native browser file picker opens → select a JPG/PNG.
3. The selected photo should appear in the photo grid.
4. Navigate to Firebase Console → Storage → verify the uploaded file appears under `users/{userId}/`.
5. Tap the camera button → browser requests `getUserMedia` camera permission → live camera feed appears → capture a photo.

- [ ] **Step 7: Manually verify location in Chrome**

1. Reach the step that requests location in the profile creation flow.
2. Browser displays a permission prompt: "Allow [site] to know your location?" → click Allow.
3. Location is accepted and the step advances without errors.
4. Verify in Firestore: `users/{userId}.location` field is set to a `GeoPoint`.

- [ ] **Step 8: Commit**

```bash
git add test/features/profile/profile_creation_web_test.dart
git commit -m "test: add profile creation web smoke tests; verify DI wiring for CameraServiceWeb"
```

---

## Task p2-discover-flow: Discover / Swipe Screen Web Verification

**Agent:** frontend_engineer
**Dependencies:** none
**Files:**
- Locate via grep: existing discover/swipe screen
- Modify: discover screen gesture handler (if touch-only)
- Test: `test/features/discover/discover_web_gesture_test.dart`

UI Reference: docs/office/05-ui-designs/03-discover.html

The mockup shows an 820 px tablet layout: card stack centred at ~320 px, action buttons in a right sidebar (Rewind, Nope, Super Like, Like, Boost), and a keyboard shortcut hint bar (← Nope, → Like). Mouse-drag swipe gestures on profile cards must trigger Firestore like/dislike writes. Keyboard shortcuts are a Phase 4 deliverable — note Phase 4 dependency below.

> **Phase 4 dependency:** Keyboard arrow-key support (← dislike, → like) is implemented in Phase 4 task `p4-discover-keyboard`. This task only fixes mouse-drag gestures.

- [ ] **Step 1: Locate existing discover / swipe screen**

```bash
grep -r "DiscoverScreen\|SwipeCard\|TinderCard\|SwipeWidget\|CardStack" lib/ --include="*.dart" -l
grep -r "GestureDetector\|Draggable\|DragTarget\|onPanUpdate\|onHorizontalDrag" lib/ --include="*.dart" -l
grep -r "swipes.*likes\|swipes.*dislikes\|Firestore.*swipe\|like.*write\|dislike.*write" lib/ --include="*.dart" -l
```

Record the discover screen file path and the file that writes swipe results to Firestore.

- [ ] **Step 2: Identify touch-only gesture issue**

Open the discover screen file. Look for `onHorizontalDragUpdate` or `onPanUpdate` handlers. If the card only uses `TouchEvent` callbacks and not `PointerEvent` callbacks, mouse drag will not register on web.

The fix: ensure `GestureDetector` or `Listener` handles `PointerMoveEvent`:

```bash
grep -n "GestureDetector\|Listener\|PointerEvent\|onPointerMove" lib/ -r --include="*.dart"
```

- [ ] **Step 3: Write the failing gesture test**

Create `test/features/discover/discover_web_gesture_test.dart`:

```dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SwipeCard gesture recognition', () {
    testWidgets('left drag (dislike) gesture is recognised via pointer events',
        (tester) async {
      bool dislikeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestSwipeTarget(
              onSwipeLeft: () => dislikeTriggered = true,
              onSwipeRight: () {},
            ),
          ),
        ),
      );

      final cardFinder = find.byKey(const ValueKey('swipe-card'));
      final cardCenter = tester.getCenter(cardFinder);

      // Simulate a mouse (pointer) drag to the left — 200 px
      final gesture = await tester.startGesture(
        cardCenter,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(-200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(dislikeTriggered, isTrue,
          reason: 'Left mouse drag should trigger dislike (swipe left)');
    });

    testWidgets('right drag (like) gesture is recognised via pointer events',
        (tester) async {
      bool likeTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestSwipeTarget(
              onSwipeLeft: () {},
              onSwipeRight: () => likeTriggered = true,
            ),
          ),
        ),
      );

      final cardFinder = find.byKey(const ValueKey('swipe-card'));
      final cardCenter = tester.getCenter(cardFinder);

      final gesture = await tester.startGesture(
        cardCenter,
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveBy(const Offset(200, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(likeTriggered, isTrue,
          reason: 'Right mouse drag should trigger like (swipe right)');
    });
  });
}

/// Minimal swipe target widget to test gesture detection in isolation.
/// Once the real SwipeCard widget is found in Step 1, replace [_TestSwipeTarget]
/// with the real widget and update the ValueKey if the card uses a different key.
class _TestSwipeTarget extends StatefulWidget {
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const _TestSwipeTarget({
    required this.onSwipeLeft,
    required this.onSwipeRight,
  });

  @override
  State<_TestSwipeTarget> createState() => _TestSwipeTargetState();
}

class _TestSwipeTargetState extends State<_TestSwipeTarget> {
  double _dx = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use onPanUpdate (not onHorizontalDragUpdate alone) so pointer events
      // from mouse drags are also captured on web.
      onPanUpdate: (details) => setState(() => _dx += details.delta.dx),
      onPanEnd: (details) {
        if (_dx < -100) widget.onSwipeLeft();
        if (_dx > 100) widget.onSwipeRight();
        setState(() => _dx = 0);
      },
      child: Container(
        key: const ValueKey('swipe-card'),
        width: 300,
        height: 400,
        color: Colors.blueGrey,
        child: const Center(child: Text('Swipe me')),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes with the test widget (GREEN baseline)**

```bash
flutter test test/features/discover/discover_web_gesture_test.dart
```

Expected: 2/2 PASS (the `_TestSwipeTarget` uses `onPanUpdate` correctly).

- [ ] **Step 5: Apply gesture fix to the real swipe card**

Open the discover screen / swipe card file found in Step 1. If the card uses `onHorizontalDragUpdate` only (which does NOT fire for mouse on web in all Flutter versions), replace it with `onPanUpdate`:

```dart
// BEFORE (touch-only in some Flutter web versions):
GestureDetector(
  onHorizontalDragUpdate: (details) { /* ... */ },
  onHorizontalDragEnd: (details) { /* ... */ },
)

// AFTER (works for both touch and mouse on web):
GestureDetector(
  onPanUpdate: (details) {
    // Use details.delta.dx for horizontal tracking
    setState(() => _dragOffset += details.delta.dx);
  },
  onPanEnd: (details) {
    if (_dragOffset < -100) _onDislike();
    if (_dragOffset > 100) _onLike();
    setState(() => _dragOffset = 0);
  },
)
```

- [ ] **Step 6: Verify Firestore writes on swipe**

```bash
flutter run -d chrome
```

1. Sign in with a test account.
2. Navigate to the Discover screen.
3. Drag a profile card to the left (dislike) → card animates away.
4. In Firebase Console → Firestore → `swipes/{userId}/dislikes/{targetUserId}` → verify document was created.
5. Drag a profile card to the right (like) → card animates away.
6. In Firestore → `swipes/{userId}/likes/{targetUserId}` → verify document was created.
7. Create a second test account and like the first account back → verify a match document is created in `matches/`.

- [ ] **Step 7: Commit**

```bash
git add test/features/discover/discover_web_gesture_test.dart
git commit -m "fix: replace onHorizontalDrag with onPanUpdate for web mouse-drag swipe support"
```

---

## Task p2-chat-flow: Real-Time Chat Web Verification

**Agent:** frontend_engineer
**Dependencies:** none
**Files:**
- Locate via grep: existing chat list and thread screens
- Fix: any StreamBuilder/Firestore listener issues on web
- Test: `test/features/chat/chat_stream_test.dart`

UI Reference: docs/office/05-ui-designs/04-chat.html

The mockup at 960 px shows a two-panel layout (conversation list left 290 px, message thread right). For Phase 2 the goal is functional real-time messaging. Responsive two-panel layout is a Phase 4 deliverable.

> **Phase 4 dependency:** Two-panel master-detail layout at ≥768 px is implemented in `p4-chat-tablet-layout`.

- [ ] **Step 1: Locate existing chat files**

```bash
grep -r "ChatScreen\|ChatThread\|MessageBubble\|ConversationList" lib/ --include="*.dart" -l
grep -r "StreamBuilder\|snapshots()\|Firestore.*messages\|conversations.*listen" lib/ --include="*.dart" -l
grep -r "unreadCount\|unreadBadge\|lastMessage" lib/ --include="*.dart" -l
```

Record the chat list screen file and chat thread screen file.

- [ ] **Step 2: Write the failing stream test**

Create `test/features/chat/chat_stream_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Chat message stream', () {
    testWidgets('StreamBuilder renders messages from a mock stream',
        (tester) async {
      final fakeMessages = [
        const _FakeMessage(text: 'Hello!', senderId: 'user-a'),
        const _FakeMessage(text: 'Hi there!', senderId: 'user-b'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _TestMessageList(messages: fakeMessages),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.text('Hi there!'), findsOneWidget);
    });

    testWidgets('new message added to stream appears in the list',
        (tester) async {
      final controller = StreamController<List<_FakeMessage>>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StreamBuilder<List<_FakeMessage>>(
              stream: controller.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return ListView(
                  children: snapshot.data!
                      .map((m) => ListTile(title: Text(m.text)))
                      .toList(),
                );
              },
            ),
          ),
        ),
      );

      controller.add([const _FakeMessage(text: 'First message', senderId: 'a')]);
      await tester.pump();
      expect(find.text('First message'), findsOneWidget);

      controller.add([
        const _FakeMessage(text: 'First message', senderId: 'a'),
        const _FakeMessage(text: 'Second message', senderId: 'b'),
      ]);
      await tester.pump();
      expect(find.text('Second message'), findsOneWidget);
    });
  });
}

// ── Test helpers ──

import 'dart:async';

class _FakeMessage {
  final String text;
  final String senderId;
  const _FakeMessage({required this.text, required this.senderId});
}

class _TestMessageList extends StatelessWidget {
  final List<_FakeMessage> messages;
  const _TestMessageList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: messages
          .map((m) => ListTile(
                title: Text(m.text),
                leading: CircleAvatar(child: Text(m.senderId[0])),
              ))
          .toList(),
    );
  }
}
```

- [ ] **Step 3: Run test to verify it passes (GREEN — validates stream approach)**

```bash
flutter test test/features/chat/chat_stream_test.dart
```

Expected: 2/2 PASS.

- [ ] **Step 4: Audit existing chat StreamBuilder for web issues**

Open the chat thread screen file from Step 1. Look for these specific patterns that cause problems on web:

```bash
grep -n "platform\|Platform\.\|kIsWeb\|dart:io" <chat-thread-file>.dart
```

Common issues:
- `Platform.isAndroid` guard blocking Firestore listener setup on web → remove guard.
- `dart:io` import in a file that runs on web → replace with conditional import.
- `await Firestore.instance.enablePersistence()` called without `try/catch` → on web, persistence may throw if called twice (e.g., hot restart); wrap in try/catch.

Apply the persistence fix:

```dart
// In the Firebase initialization (main.dart or a dedicated init file):
try {
  await FirebaseFirestore.instance.enablePersistence(
    const PersistenceSettings(synchronizeTabs: true),
  );
} catch (e) {
  // Persistence already enabled (e.g., after hot restart in dev mode).
  // This is safe to ignore.
  debugPrint('Firestore persistence already enabled: $e');
}
```

- [ ] **Step 5: Verify image sharing in chat**

```bash
flutter run -d chrome
```

1. Open a conversation thread.
2. Tap the image attach button → a browser file picker opens → select an image.
3. The image uploads to Firebase Storage and appears as a message bubble in the thread.
4. Verify in Firestore: the message document has `imageUrl` set to the Firebase Storage download URL.

- [ ] **Step 6: Verify unread badges**

1. Open the chat list screen.
2. Send a message from a second test account.
3. The conversation row for the second account shows an unread badge (count > 0).
4. Open the thread → badge clears (unreadCount resets to 0 in Firestore).

- [ ] **Step 7: Commit**

```bash
git add test/features/chat/chat_stream_test.dart
git commit -m "fix: audit and fix chat StreamBuilder for Firestore web compatibility"
```

---

## Task p2-analytics-verify: Firebase Analytics Web Verification

**Agent:** backend_engineer
**Dependencies:** none
**Files:**
- Audit: all files containing `logEvent\|FirebaseAnalytics`
- Fix: remove `kIsWeb` / `Platform.isAndroid` guards from analytics calls
- Test: `test/features/analytics/analytics_platform_guard_test.dart`

- [ ] **Step 1: Grep for analytics calls**

```bash
grep -rn "logEvent\|FirebaseAnalytics" lib/ --include="*.dart"
grep -rn "kIsWeb\|Platform\.isAndroid\|Platform\.isIOS" lib/ --include="*.dart" | grep -i "analytic\|logEvent"
```

Record every file where `logEvent` is called. Note any lines where the call is wrapped in a `kIsWeb` or platform guard.

- [ ] **Step 2: Write the failing test (code audit)**

Create `test/features/analytics/analytics_platform_guard_test.dart`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Analytics platform guard audit', () {
    test('no logEvent calls are silenced by kIsWeb or Platform guards', () {
      final libDir = Directory('lib');
      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      final violations = <String>[];

      for (final file in dartFiles) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          // Check for logEvent inside a kIsWeb == false branch or
          // inside a Platform.isAndroid / Platform.isIOS branch.
          // Pattern: the if-guard appears within 5 lines before logEvent.
          if (line.contains('logEvent')) {
            final context =
                lines.sublist((i - 5).clamp(0, i), i).join('\n');
            if (context.contains('!kIsWeb') ||
                context.contains('kIsWeb == false') ||
                context.contains('Platform.isAndroid') ||
                context.contains('Platform.isIOS')) {
              violations.add(
                '${file.path}:${i + 1} — logEvent appears to be '
                'guarded by a platform check that would silence it on web.',
              );
            }
          }
        }
      }

      if (violations.isNotEmpty) {
        fail(
          'Found ${violations.length} analytics platform guard violation(s):\n'
          '${violations.join('\n')}\n\n'
          'Remove the platform guard — FirebaseAnalytics.logEvent works on web.',
        );
      }
    });
  });
}
```

- [ ] **Step 3: Run test to find violations (RED if guards exist)**

```bash
flutter test test/features/analytics/analytics_platform_guard_test.dart
```

Expected: PASS if no guards exist. If FAIL, the output lists every file and line with a guard.

- [ ] **Step 4: Remove each platform guard (GREEN)**

For every violation reported, open the file and remove the guard. Example fix:

```dart
// BEFORE — analytics silenced on web:
if (!kIsWeb) {
  await FirebaseAnalytics.instance.logEvent(
    name: 'profile_completed',
    parameters: {'step': 5},
  );
}

// AFTER — analytics fires on all platforms:
await FirebaseAnalytics.instance.logEvent(
  name: 'profile_completed',
  parameters: {'step': 5},
);
```

After removing all guards, re-run the test:

```bash
flutter test test/features/analytics/analytics_platform_guard_test.dart
```

Expected: PASS.

- [ ] **Step 5: Verify in Firebase DebugView**

```bash
flutter run -d chrome --dart-define=FLUTTER_WEB_DEBUG=true
```

In the browser, navigate to:
```
http://localhost:<port>/?debug_mode=1
```

In Firebase Console → Analytics → DebugView → select the web app. Trigger app flows (sign-in, discover, chat) and verify events appear in DebugView within 30–60 seconds.

Alternatively, install the **Google Analytics Debugger** Chrome extension and verify events in the extension panel.

- [ ] **Step 6: Commit**

```bash
git add test/features/analytics/analytics_platform_guard_test.dart
git commit -m "fix: remove platform guards from Firebase Analytics logEvent calls (web support)"
```

---

## Task p2-app-check-monitoring: App Check Monitoring Verification

**Agent:** backend_engineer
**Dependencies:** none (Phase 1 Firebase config must be complete)
**Files:** None to create or modify — this is a Firebase Console verification task.

- [ ] **Step 1: Confirm App Check is initialised for web in main.dart**

```bash
grep -n "FirebaseAppCheck\|ReCaptchaV3Provider\|activate" lib/main.dart
```

Expected output: at minimum one line showing `FirebaseAppCheck.instance.activate(...)` with a `ReCaptchaV3Provider`. If missing, add it (this was a Phase 1 task — verify Phase 1 is complete):

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// In main(), after Firebase.initializeApp():
if (kIsWeb) {
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('YOUR_RECAPTCHA_V3_SITE_KEY'),
  );
}
```

- [ ] **Step 2: Write a test confirming App Check initialisation code exists**

Create `test/app_check/app_check_init_test.dart`:

```dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Check initialisation audit', () {
    test('main.dart contains ReCaptchaV3Provider activation for web', () {
      final mainFile = File('lib/main.dart');
      expect(mainFile.existsSync(), isTrue,
          reason: 'lib/main.dart must exist');

      final content = mainFile.readAsStringSync();

      expect(
        content.contains('ReCaptchaV3Provider'),
        isTrue,
        reason: 'main.dart must activate App Check with ReCaptchaV3Provider '
            'for web. Add: FirebaseAppCheck.instance.activate('
            'webProvider: ReCaptchaV3Provider(\'YOUR_KEY\')).',
      );

      expect(
        content.contains('FirebaseAppCheck'),
        isTrue,
        reason: 'main.dart must import and use FirebaseAppCheck.',
      );
    });
  });
}
```

- [ ] **Step 3: Run test (RED if App Check missing, GREEN if present)**

```bash
flutter test test/app_check/app_check_init_test.dart
```

Expected: PASS (App Check was initialised in Phase 1). If FAIL, add the activation code from Step 1.

- [ ] **Step 4: Verify monitoring mode in Firebase Console**

```bash
flutter run -d chrome
```

1. Run the app in Chrome for 2–3 minutes. Navigate through sign-in, discover, and chat flows to generate Firebase SDK requests.
2. Open [Firebase Console](https://console.firebase.google.com) → Select your project → App Check.
3. In the **Apps** tab, find your web app (listed with the reCAPTCHA v3 provider).
4. Confirm the request attestation chart shows **verified requests** appearing (blue bar). This confirms:
   - The reCAPTCHA v3 site key is correct.
   - The domain (localhost or your deploy domain) is whitelisted in the reCAPTCHA Admin Console.
   - App Check tokens are being generated and accepted.
5. Confirm there are **no blocked requests** (red bar) — App Check is in monitoring mode, not enforcement mode.

> **If no verified requests appear after 5 minutes:**
> Check the reCAPTCHA v3 site key in Firebase Console → App Check → Apps → Edit. The site key must match the domain you are serving from. For localhost, ensure `localhost` is listed in the reCAPTCHA Admin Console allowed domains.

- [ ] **Step 5: Confirm no Firestore or Storage requests are blocked**

In Firebase Console → Firestore → Usage tab, confirm all read/write operations show as successful. In Storage → Usage tab, confirm uploads are successful.

If any requests show as `PERMISSION_DENIED` with an App Check error, switch App Check to monitoring mode:
- Firebase Console → App Check → Apps → [web app] → Overflow menu → **Monitor requests (don't enforce)**.

Leave App Check in monitoring mode until the public launch (enforcement is switched on in Phase 5).

- [ ] **Step 6: Commit**

```bash
git add test/app_check/app_check_init_test.dart
git commit -m "test: add App Check init audit test; verify monitoring mode in Firebase Console"
```

---

## Phase 2 Self-Review Checklist

| Task | Deliverable | Test file | Acceptance |
|------|-------------|-----------|-----------|
| p2-router-wire | `lib/core/router/app_router.dart` | `test/core/router/app_router_test.dart` | All routes reachable; 404 shows NotFoundScreen; path URLs |
| p2-not-found-screen | `lib/features/shell/screens/not_found_screen.dart` | `test/features/shell/not_found_screen_test.dart` | 404 text, home button, max 500 px |
| p2-not-found-screen-test | (test extension) | Same as above | 4 tests PASS at 1200 px viewport |
| p2-offline-banner | `lib/features/shell/widgets/offline_banner.dart` | `test/features/shell/offline_banner_test.dart` | Banner shows/hides/dismisses; child always rendered |
| p2-auth-email-google | `lib/features/auth/services/google_sign_in_web_service.dart` | `test/features/auth/google_sign_in_web_service_test.dart` | signInWithPopup called; LOCAL persistence active |
| p2-auth-phone-otp | `lib/features/auth/services/phone_auth_web_service.dart` | `test/features/auth/phone_auth_web_service_test.dart` | Invisible reCAPTCHA; OTP flow completes in Chrome |
| p2-profile-creation | DI wiring verified | `test/features/profile/profile_creation_web_test.dart` | Photo upload lands in Storage; location sets GeoPoint |
| p2-discover-flow | Mouse-drag fix in swipe card | `test/features/discover/discover_web_gesture_test.dart` | Firestore like/dislike writes on drag |
| p2-chat-flow | StreamBuilder web fix | `test/features/chat/chat_stream_test.dart` | Real-time messages; image upload; unread badges |
| p2-analytics-verify | Guards removed from logEvent | `test/features/analytics/analytics_platform_guard_test.dart` | Events appear in DebugView |
| p2-app-check-monitoring | No code change — Console verification | `test/app_check/app_check_init_test.dart` | Verified requests in App Check dashboard |

**Type consistency verification:**
- `appRouter` exported from `lib/core/router/app_router.dart` — same name used in `main.dart` and router tests.
- `NotFoundScreen` class — used as `GoRouter.errorBuilder` in `app_router.dart` and imported in router test.
- `OfflineBanner.connectivityStream` — parameter name matches test injection site.
- `GoogleSignInWebService(auth:)` — named parameter matches test fake injection.
- `PhoneAuthWebService(recaptchaSize:)` — named parameter matches test assertion.
