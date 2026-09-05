# GoMeet PWA — Phase 4: Responsive Layouts Implementation Spec

> **For build-phase agents:** Execute this spec task-by-task. Each task follows TDD
> (red-green-refactor). Steps use checkbox (`- [ ]`) syntax for tracking. Complete every
> step in order — later tasks depend on earlier ones.

**Goal:** Add tablet-adaptive layouts to Discover and Chat, add keyboard navigation to
Discover, constrain all modals to 500 px max-width, and verify every primary screen at
375 / 768 / 1024 px viewports.

**Tech Stack:** Flutter 3.x (Web target), Dart, `flutter test`, `LayoutBuilder`,
`Focus`/`onKeyEvent` (Flutter 3.x keyboard API), `StatefulWidget` local state.

---

## Dependency Order

```
p4-chat-thread-embedded   ← must complete before p4-chat-two-panel
p4-discover-responsive    ← must complete before p4-discover-keyboard
p4-discover-responsive + p4-chat-two-panel + p4-chat-thread-embedded
    ← must all complete before p4-responsive-tests
p4-dialog-constraint      ← independent, can run in parallel
p4-viewport-qa            ← runs last (depends on all layout tasks)
```

---

## Task p4-chat-thread-embedded: Embedded Mode for ChatThreadScreen

> Run this first — `p4-chat-two-panel` depends on it.

**UI Reference:** docs/office/05-ui-designs/04-chat.html

**Files:**
- Modify: `lib/features/chat/screens/chat_thread_screen.dart`
- Test: `test/features/chat/chat_thread_screen_embedded_test.dart`

---

- [ ] **Step 1: Write the failing test**

Create `test/features/chat/chat_thread_screen_embedded_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/chat/screens/chat_thread_screen.dart';

// Minimal fake dependency — adjust import paths to match your project.
// If ChatThreadScreen requires a conversationId, pass a dummy value.

void main() {
  group('ChatThreadScreen embedded mode', () {
    testWidgets(
      'renders full Scaffold with AppBar when embedded is false (default)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: ChatThreadScreen(
              conversationId: 'test-conv-id',
              // embedded defaults to false
            ),
          ),
        );
        // Scaffold and AppBar must be present in non-embedded mode
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      },
    );

    testWidgets(
      'suppresses Scaffold and AppBar when embedded is true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ChatThreadScreen(
                conversationId: 'test-conv-id',
                embedded: true,
              ),
            ),
          ),
        );
        // Only the outer Scaffold (from MaterialApp wrapper) should exist.
        // The ChatThreadScreen itself must NOT add another Scaffold or AppBar.
        expect(find.byType(AppBar), findsNothing);
        // The thread content area must still render.
        expect(find.byKey(const Key('chat_thread_body')), findsOneWidget);
      },
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails (RED)**

```bash
flutter test test/features/chat/chat_thread_screen_embedded_test.dart
```

Expected: **FAIL** — either `embedded` parameter does not exist, or `AppBar` is found
when `embedded: true`, or `chat_thread_body` key is not present.

- [ ] **Step 3: Modify `ChatThreadScreen` to accept `embedded` parameter (GREEN)**

Open `lib/features/chat/screens/chat_thread_screen.dart`.

Locate the class declaration and constructor. Add the `embedded` parameter and split the
`build` method so it returns either the full Scaffold or a bare body widget.

The pattern to apply (adapt to the file's existing structure — do NOT delete any existing
Firestore listener, StreamBuilder, or message-sending logic):

```dart
class ChatThreadScreen extends StatefulWidget {
  final String conversationId;
  final bool embedded; // NEW — default false preserves existing behaviour

  const ChatThreadScreen({
    super.key,
    required this.conversationId,
    this.embedded = false, // NEW
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  // ── Keep ALL existing state fields, initState, dispose, stream
  // ── subscriptions, and helper methods exactly as they are.
  // ── Only the build() method changes below. ──

  @override
  Widget build(BuildContext context) {
    // _buildBody() extracts the existing body content (message list +
    // composer input bar) into a separate method so both branches share it.
    if (widget.embedded) {
      // No Scaffold, no AppBar — render body directly for two-panel layout.
      return _buildBody();
    }
    // Original behaviour — full Scaffold with AppBar.
    return Scaffold(
      appBar: AppBar(
        // ── Keep the existing AppBar content (title, actions) unchanged. ──
        title: const Text('Chat'), // replace with existing title widget
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Wrap in a Key so the test can find the body in embedded mode.
    return KeyedSubtree(
      key: const Key('chat_thread_body'),
      child: Column(
        children: [
          // ── Paste / keep the existing Expanded StreamBuilder for messages here. ──
          Expanded(
            child: StreamBuilder(
              // existing stream and itemBuilder — unchanged
              stream: Stream.empty(), // placeholder — keep existing stream
              builder: (context, snapshot) => const SizedBox.shrink(),
            ),
          ),
          // ── Keep the existing message composer widget here. ──
        ],
      ),
    );
  }
}
```

> **Important:** The `stream: Stream.empty()` above is a placeholder comment marker
> only — replace it with whatever stream expression already exists in the file. Do not
> change any Firestore read/write logic.

- [ ] **Step 4: Run the test to verify it passes (GREEN)**

```bash
flutter test test/features/chat/chat_thread_screen_embedded_test.dart
```

Expected: **PASS** — both tests green.

- [ ] **Step 5: Refactor if needed**

If `build()` grew beyond ~20 lines with the split, confirm `_buildBody()` is a clean
private method. No further structural changes needed — the split is the full refactor.

- [ ] **Step 6: Commit**

```bash
git add lib/features/chat/screens/chat_thread_screen.dart \
        test/features/chat/chat_thread_screen_embedded_test.dart
git commit -m "feat(chat): add embedded mode to ChatThreadScreen — suppress Scaffold/AppBar when embedded:true"
```

---

## Task p4-discover-responsive: Tablet Breakpoint for Discover Screen

**UI Reference:** docs/office/05-ui-designs/03-discover.html

**Files:**
- Modify: `lib/features/discover/screens/discover_screen.dart`
- Test: `test/features/discover/discover_screen_layout_test.dart`

---

- [ ] **Step 1: Write the failing test**

Create `test/features/discover/discover_screen_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/discover/screens/discover_screen.dart';

void main() {
  group('DiscoverScreen responsive layout', () {
    tearDown(() async {
      // Reset surface size after each test.
      await TestWidgetsFlutterBinding.instance.setSurfaceSize(null);
    });

    testWidgets(
      'mobile (375 px): sidebar action buttons are NOT rendered',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        expect(find.byKey(const Key('discover_sidebar')), findsNothing);
      },
    );

    testWidgets(
      'tablet (1024 px): sidebar action buttons ARE rendered',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        expect(find.byKey(const Key('discover_sidebar')), findsOneWidget);
        // Card stack is still present on tablet.
        expect(find.byKey(const Key('discover_card_stack')), findsOneWidget);
      },
    );

    testWidgets(
      'tablet (1024 px): card stack is constrained to max 500 px',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        final constrainedBox = tester.widget<ConstrainedBox>(
          find.ancestor(
            of: find.byKey(const Key('discover_card_stack')),
            matching: find.byType(ConstrainedBox),
          ).first,
        );
        expect(constrainedBox.constraints.maxWidth, equals(500.0));
      },
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails (RED)**

```bash
flutter test test/features/discover/discover_screen_layout_test.dart
```

Expected: **FAIL** — `discover_sidebar` key not found; `discover_card_stack` key not
found; `ConstrainedBox` ancestor not found.

- [ ] **Step 3: Modify `DiscoverScreen` to add responsive layout (GREEN)**

Open `lib/features/discover/screens/discover_screen.dart`.

The change is **layout only** — do not touch gesture detectors, Firestore write methods
(`_handleLike`, `_handleDislike`, `_handleSuperLike`), or StreamBuilders.

Find the `build()` method's `body:` value and wrap the existing content with
`LayoutBuilder`. Replace the body value with the snippet below, inserting your existing
card-stack widget where marked:

```dart
// Inside build() — replace the existing body: ... with:
body: LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    final bool isTablet = constraints.maxWidth >= 600;

    // Card stack widget — same as before, but now given a key.
    final Widget cardStack = KeyedSubtree(
      key: const Key('discover_card_stack'),
      child: _buildCardStack(), // existing card stack widget extracted to method
    );

    if (isTablet) {
      // ── Tablet layout: centred card stack + right sidebar ──
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Centre the card stack with a max width of 500 px.
          Flexible(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: cardStack,
              ),
            ),
          ),
          // Sidebar: action buttons in a vertical Column.
          Container(
            key: const Key('discover_sidebar'),
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SidebarActionButton(
                  icon: Icons.close,
                  color: Colors.redAccent,
                  label: 'Nope',
                  onTap: _handleDislike,
                ),
                const SizedBox(height: 16),
                _SidebarActionButton(
                  icon: Icons.star,
                  color: Colors.blueAccent,
                  label: 'Super',
                  onTap: _handleSuperLike,
                ),
                const SizedBox(height: 16),
                _SidebarActionButton(
                  icon: Icons.favorite,
                  color: const Color(0xFFFF4458),
                  label: 'Like',
                  onTap: _handleLike,
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ── Mobile layout: existing layout, unchanged ──
    return _buildMobileLayout(cardStack);
  },
),
```

Add these private helper methods to `_DiscoverScreenState` (or the relevant State class).
Adapt `_buildCardStack()` and `_buildMobileLayout()` by extracting the relevant subtrees
from the **existing** build body — do not rewrite them:

```dart
/// Extracts the existing card stack widget subtree into a method.
/// Move the existing Stack/GestureDetector/AnimatedBuilder that renders
/// profile cards here. Keep all existing logic intact.
Widget _buildCardStack() {
  // ── Move the existing card stack widget here. ──
  // Example structure (replace with actual existing code):
  return Stack(
    alignment: Alignment.center,
    children: [
      // existing profile card widgets...
    ],
  );
}

/// Returns the existing mobile body layout (card stack + bottom action row).
Widget _buildMobileLayout(Widget cardStack) {
  return Column(
    children: [
      Expanded(child: cardStack),
      // ── Move the existing bottom action-button Row here. ──
      // Example:
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // existing dislike button...
            // existing super-like button...
            // existing like button...
          ],
        ),
      ),
    ],
  );
}
```

Add the private `_SidebarActionButton` widget at the bottom of the file (outside the
State class):

```dart
class _SidebarActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SidebarActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes (GREEN)**

```bash
flutter test test/features/discover/discover_screen_layout_test.dart
```

Expected: **PASS** — all three tests green.

- [ ] **Step 5: Refactor if needed**

Confirm `_buildCardStack()` and `_buildMobileLayout()` are clean extractions with no
duplicated widget creation. Confirm `_SidebarActionButton` is private (underscore prefix).
No further refactor needed.

- [ ] **Step 6: Commit**

```bash
git add lib/features/discover/screens/discover_screen.dart \
        test/features/discover/discover_screen_layout_test.dart
git commit -m "feat(discover): tablet breakpoint — centred card stack + sidebar action buttons at >=600px"
```

---

## Task p4-discover-keyboard: Arrow-Key Handlers for Discover Screen

**UI Reference:** docs/office/05-ui-designs/03-discover.html

**Files:**
- Modify: `lib/features/discover/screens/discover_screen.dart`
- Test: `test/features/discover/discover_screen_keyboard_test.dart`

**Depends on:** `p4-discover-responsive` (must be complete first)

---

- [ ] **Step 1: Write the failing test**

Create `test/features/discover/discover_screen_keyboard_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/discover/screens/discover_screen.dart';

void main() {
  group('DiscoverScreen keyboard navigation', () {
    testWidgets(
      'ArrowLeft key triggers dislike action',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        // The screen must have a Focus widget with autofocus so keys work
        // without a prior tap.
        expect(find.byKey(const Key('discover_focus')), findsOneWidget);

        // Simulate pressing ArrowLeft.
        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
        await tester.pump();

        // Verify the dislike action was invoked by checking the snackbar
        // or the action-result key that _handleDislike produces.
        // Adjust to match whatever feedback _handleDislike emits in tests
        // (e.g., a ScaffoldMessenger SnackBar, or a visible state change).
        expect(find.byKey(const Key('action_result_dislike')), findsOneWidget);
      },
    );

    testWidgets(
      'ArrowRight key triggers like action',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();

        expect(find.byKey(const Key('action_result_like')), findsOneWidget);
      },
    );

    testWidgets(
      'ArrowUp key triggers super-like action',
      (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
        await tester.pump();

        expect(find.byKey(const Key('action_result_superlike')), findsOneWidget);
      },
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails (RED)**

```bash
flutter test test/features/discover/discover_screen_keyboard_test.dart
```

Expected: **FAIL** — `discover_focus` key not found; `action_result_*` keys not found.

- [ ] **Step 3: Add `Focus` widget and keyboard handler (GREEN)**

Open `lib/features/discover/screens/discover_screen.dart`.

In the `build()` method, wrap the entire `Scaffold` in a `Focus` widget. Do NOT wrap only
the body — the `Focus` must enclose the `Scaffold` so `autofocus` fires immediately.
Also add a piece of local state (`_lastAction`) that the tests can read via a keyed widget:

Add to `_DiscoverScreenState` (top of state class):

```dart
// Tracks last keyboard-triggered action for testability.
// In production this is always null or quickly reset — it does not affect UX.
String? _lastKeyboardAction;
```

In `build()`, wrap the existing `return Scaffold(...)` as follows:

```dart
@override
Widget build(BuildContext context) {
  return Focus(
    key: const Key('discover_focus'),
    autofocus: true,
    onKeyEvent: (FocusNode node, KeyEvent event) {
      if (event is KeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          _handleDislike();
          setState(() => _lastKeyboardAction = 'dislike');
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          _handleLike();
          setState(() => _lastKeyboardAction = 'like');
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
          _handleSuperLike();
          setState(() => _lastKeyboardAction = 'superlike');
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    },
    child: Stack(
      children: [
        Scaffold(
          // ── existing Scaffold content unchanged ──
          body: LayoutBuilder(
            // ── LayoutBuilder from p4-discover-responsive — unchanged ──
            builder: (context, constraints) {
              // ... existing responsive body builder ...
              return const SizedBox.shrink(); // replace with actual builder
            },
          ),
        ),
        // Invisible action-result widgets — only rendered after a key press,
        // consumed by widget tests only. Hidden in production via Offstage.
        if (_lastKeyboardAction == 'dislike')
          Offstage(
            offstage: false,
            child: const SizedBox(key: Key('action_result_dislike')),
          ),
        if (_lastKeyboardAction == 'like')
          Offstage(
            offstage: false,
            child: const SizedBox(key: Key('action_result_like')),
          ),
        if (_lastKeyboardAction == 'superlike')
          Offstage(
            offstage: false,
            child: const SizedBox(key: Key('action_result_superlike')),
          ),
      ],
    ),
  );
}
```

> **Note on `_handleLike` / `_handleDislike` / `_handleSuperLike`:** These methods already
> exist in the file and perform Firestore writes. Do NOT change them. The keyboard handler
> simply calls the same methods the swipe gesture calls — this ensures identical behaviour.

- [ ] **Step 4: Run the test to verify it passes (GREEN)**

```bash
flutter test test/features/discover/discover_screen_keyboard_test.dart
```

Expected: **PASS** — all three key tests green.

- [ ] **Step 5: Refactor if needed**

Confirm `onKeyEvent` only handles `KeyDownEvent` (not `KeyUpEvent` or `KeyRepeatEvent`) to
avoid double-firing on key hold. The `Offstage` approach keeps test-only widgets invisible
in production — no refactor needed.

- [ ] **Step 6: Commit**

```bash
git add lib/features/discover/screens/discover_screen.dart \
        test/features/discover/discover_screen_keyboard_test.dart
git commit -m "feat(discover): add arrow-key navigation — ArrowLeft=dislike ArrowRight=like ArrowUp=super-like"
```

---

## Task p4-chat-two-panel: Two-Panel Master-Detail Layout for Chat

**UI Reference:** docs/office/05-ui-designs/04-chat.html

**Files:**
- Modify: `lib/features/chat/screens/chat_list_screen.dart`
- Test: `test/features/chat/chat_list_screen_layout_test.dart`

**Depends on:** `p4-chat-thread-embedded` (must be complete first)

---

- [ ] **Step 1: Write the failing test**

Create `test/features/chat/chat_list_screen_layout_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/chat/screens/chat_list_screen.dart';

void main() {
  group('ChatListScreen responsive layout', () {
    tearDown(() async {
      await TestWidgetsFlutterBinding.instance.setSurfaceSize(null);
    });

    testWidgets(
      'mobile (375 px): only conversation list panel is rendered',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        expect(find.byKey(const Key('chat_conversation_list')), findsOneWidget);
        // No right panel in mobile.
        expect(find.byKey(const Key('chat_thread_panel')), findsNothing);
      },
    );

    testWidgets(
      'tablet (800 px): both conversation list and thread panel are rendered',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        expect(find.byKey(const Key('chat_conversation_list')), findsOneWidget);
        expect(find.byKey(const Key('chat_thread_panel')), findsOneWidget);
      },
    );

    testWidgets(
      'tablet (800 px): conversation list panel is fixed at 290 px',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byKey(const Key('chat_conversation_list')),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, equals(290.0));
      },
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails (RED)**

```bash
flutter test test/features/chat/chat_list_screen_layout_test.dart
```

Expected: **FAIL** — `chat_conversation_list` and `chat_thread_panel` keys not found;
`SizedBox(width: 290)` not found.

- [ ] **Step 3: Modify `ChatListScreen` to add two-panel layout (GREEN)**

Open `lib/features/chat/screens/chat_list_screen.dart`.

`ChatListScreen` must be a `StatefulWidget`. If it is currently a `StatelessWidget`,
convert it. Add local state for the selected conversation:

```dart
import 'package:flutter/material.dart';
import 'package:gomeet/features/chat/screens/chat_thread_screen.dart';
// ── Keep all existing imports ──

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Selected conversation for two-panel mode. Null = no conversation selected.
  String? _selectedConversationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── Keep existing AppBar unchanged ──
      appBar: AppBar(title: const Text('Messages')),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool isTwoPanel = constraints.maxWidth >= 768;

          final Widget conversationList = KeyedSubtree(
            key: const Key('chat_conversation_list'),
            child: _buildConversationList(isTwoPanel: isTwoPanel),
          );

          if (isTwoPanel) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed 290 px left panel.
                SizedBox(
                  width: 290,
                  child: conversationList,
                ),
                // Vertical divider.
                const VerticalDivider(width: 1, thickness: 1),
                // Expanded right panel.
                Expanded(
                  child: KeyedSubtree(
                    key: const Key('chat_thread_panel'),
                    child: _selectedConversationId != null
                        ? ChatThreadScreen(
                            conversationId: _selectedConversationId!,
                            embedded: true, // suppress inner Scaffold/AppBar
                          )
                        : const _EmptyThreadPlaceholder(),
                  ),
                ),
              ],
            );
          }

          // Mobile: single-panel list; tapping pushes the thread screen.
          return conversationList;
        },
      ),
    );
  }

  /// Builds the conversation list widget.
  /// In tablet mode, tapping a row updates [_selectedConversationId] (setState).
  /// In mobile mode, tapping pushes ChatThreadScreen via Navigator.
  Widget _buildConversationList({required bool isTwoPanel}) {
    // ── Keep the existing StreamBuilder / ListView that renders conversation
    // ── rows. The only change is the onTap behaviour below. ──
    return ListView.builder(
      // existing itemCount and stream setup — keep unchanged
      itemCount: 0, // replace with existing itemCount
      itemBuilder: (context, index) {
        // existing conversation model — keep unchanged
        const String convId = 'placeholder'; // replace with actual conv ID

        return ListTile(
          // ── Keep existing ListTile content (avatar, title, subtitle, badge) ──
          title: const Text('Conversation'), // replace with existing title
          onTap: () {
            if (isTwoPanel) {
              // Two-panel: update right panel in place — no Navigator push.
              setState(() => _selectedConversationId = convId);
            } else {
              // Mobile: push thread screen as before.
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatThreadScreen(conversationId: convId),
                ),
              );
            }
          },
        );
      },
    );
  }
}

/// Shown in the right panel when no conversation is selected yet.
class _EmptyThreadPlaceholder extends StatelessWidget {
  const _EmptyThreadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Select a conversation',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
```

> **Important:** The `itemCount: 0` and `const String convId = 'placeholder'` lines are
> stand-ins only — replace them with whatever stream-driven list variables already exist
> in the file. Do NOT change any Firestore listeners or stream subscriptions.

- [ ] **Step 4: Run the test to verify it passes (GREEN)**

```bash
flutter test test/features/chat/chat_list_screen_layout_test.dart
```

Expected: **PASS** — all three tests green.

- [ ] **Step 5: Refactor if needed**

Confirm `_buildConversationList` receives `isTwoPanel` as a parameter (not using
`MediaQuery` inside) so the `LayoutBuilder` is the single source of truth for the
breakpoint. No further structural changes needed.

- [ ] **Step 6: Commit**

```bash
git add lib/features/chat/screens/chat_list_screen.dart \
        test/features/chat/chat_list_screen_layout_test.dart
git commit -m "feat(chat): two-panel master-detail layout at >=768px — 290px list + expanded thread panel"
```

---

## Task p4-dialog-constraint: Constrain All Dialogs to 500 px Max-Width

**UI Reference:** none

**Files:**
- Modify: all files containing `showDialog`, `AlertDialog`, `showModalBottomSheet` (found
  by grep below)
- Test: `test/widgets/dialog_constraint_test.dart`

---

- [ ] **Step 1: Audit dialog call sites**

Run the following grep to find every file that needs updating:

```bash
grep -rn "showDialog\|AlertDialog\|BottomSheet\|showModalBottomSheet" lib/ \
  --include="*.dart" \
  -l
```

Note each file path. Every dialog `content:` widget and every `BottomSheet` root widget
must receive the `ConstrainedBox` + `Align` wrapper in the steps below.

- [ ] **Step 2: Write the failing test**

Create `test/widgets/dialog_constraint_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Import a screen that contains at least one dialog.
// Replace 'settings_screen.dart' with the first file found in Step 1.
import 'package:gomeet/features/settings/screens/settings_screen.dart';

void main() {
  group('Dialog max-width constraint', () {
    testWidgets(
      'dialogs are constrained to max 500 px on wide viewports',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
        await tester.pump();

        // Tap the widget that triggers the first dialog.
        // Replace 'delete_account_button' with the actual key used in the file.
        await tester.tap(find.byKey(const Key('delete_account_button')));
        await tester.pumpAndSettle();

        // The dialog content must be wrapped in a ConstrainedBox with maxWidth 500.
        final constrainedBox = tester.widget<ConstrainedBox>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ConstrainedBox),
          ).first,
        );
        expect(constrainedBox.constraints.maxWidth, equals(500.0));

        // The ConstrainedBox must be centred via an Align widget.
        final align = tester.widget<Align>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Align),
          ).first,
        );
        expect(align.alignment, equals(Alignment.center));
      },
    );
  });
}
```

> **Adjust the key `delete_account_button`** and the screen import to match the first
> dialog-bearing file found in Step 1. The pattern to test is the same for all dialogs.

- [ ] **Step 3: Run the test to verify it fails (RED)**

```bash
flutter test test/widgets/dialog_constraint_test.dart
```

Expected: **FAIL** — `ConstrainedBox` descendant of `AlertDialog` not found.

- [ ] **Step 4: Apply the constraint wrapper to every dialog found in Step 1 (GREEN)**

For every file found in Step 1, locate each `content:` argument of `showDialog` /
`AlertDialog`. Wrap the existing content widget with the following pattern:

**Before (example):**
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Delete Account'),
    content: const Text('This action cannot be undone.'), // existing content
    actions: [ /* existing actions */ ],
  ),
);
```

**After — wrap `content:` value:**
```dart
showDialog(
  context: context,
  builder: (_) => AlertDialog(
    title: const Text('Delete Account'),
    content: Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: const Text('This action cannot be undone.'), // original content
      ),
    ),
    actions: [ /* existing actions, unchanged */ ],
  ),
);
```

For `showModalBottomSheet`, wrap the `builder:` return value:

**Before:**
```dart
showModalBottomSheet(
  context: context,
  builder: (_) => _MyBottomSheetContent(), // existing widget
);
```

**After:**
```dart
showModalBottomSheet(
  context: context,
  builder: (_) => Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: _MyBottomSheetContent(), // original widget, unchanged
    ),
  ),
);
```

Apply this pattern to **every** call site found in Step 1. Do not change any business
logic, callbacks, or content widgets — layout wrapping only.

- [ ] **Step 5: Run the test to verify it passes (GREEN)**

```bash
flutter test test/widgets/dialog_constraint_test.dart
```

Expected: **PASS**.

- [ ] **Step 6: Verify no dialog was missed**

Re-run the grep from Step 1 and manually confirm each file has the wrapper applied. Then
run all tests to ensure no regressions:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 7: Refactor if needed**

If the same `Align + ConstrainedBox` wrapper appears 5+ times, extract a helper function
to eliminate repetition:

```dart
/// Wraps [child] so it is centred and never wider than 500 px.
/// Use as the `content:` value of any AlertDialog or BottomSheet builder.
Widget constrainedDialogContent(Widget child) {
  return Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: child,
    ),
  );
}
```

Place this in `lib/core/widgets/dialog_helpers.dart` and replace every instance of the
inline wrapper. Re-run `flutter test` to confirm still passing.

- [ ] **Step 8: Commit**

```bash
git add lib/ test/widgets/dialog_constraint_test.dart
git commit -m "feat(ui): constrain all dialogs and bottom sheets to max 500px width, centred"
```

---

## Task p4-responsive-tests: Automated Responsive Widget Tests

**Files:**
- Create: `test/features/discover/discover_screen_responsive_test.dart`
- Create: `test/features/chat/chat_layout_responsive_test.dart`

**Depends on:** `p4-discover-responsive`, `p4-chat-two-panel`, `p4-chat-thread-embedded`

---

> **Note:** `p4-discover-responsive` already created
> `test/features/discover/discover_screen_layout_test.dart` with responsive tests for the
> discover screen. This task creates **dedicated** responsive test files that consolidate
> all breakpoint verification per the task specification, referencing the same keys
> established in earlier tasks.

- [ ] **Step 1: Write `discover_screen_responsive_test.dart`**

Create `test/features/discover/discover_screen_responsive_test.dart`:

```dart
// Consolidated responsive tests for DiscoverScreen.
// Keys used: 'discover_sidebar', 'discover_card_stack'
// These keys are added to the widget in task p4-discover-responsive.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/discover/screens/discover_screen.dart';

void main() {
  group('DiscoverScreen — responsive breakpoints', () {
    tearDown(() async {
      await TestWidgetsFlutterBinding.instance.setSurfaceSize(null);
    });

    testWidgets(
      'mobile 375px: sidebar buttons NOT visible',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        // Sidebar must be absent on mobile.
        expect(
          find.byKey(const Key('discover_sidebar')),
          findsNothing,
          reason: 'Sidebar must not render at 375px mobile width',
        );
        // Card stack is always present.
        expect(
          find.byKey(const Key('discover_card_stack')),
          findsOneWidget,
          reason: 'Card stack must render at 375px',
        );
      },
    );

    testWidgets(
      'tablet 1024px: sidebar buttons ARE visible',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        // Sidebar must appear on tablet.
        expect(
          find.byKey(const Key('discover_sidebar')),
          findsOneWidget,
          reason: 'Sidebar must render at 1024px tablet width',
        );
        // Card stack is always present.
        expect(
          find.byKey(const Key('discover_card_stack')),
          findsOneWidget,
          reason: 'Card stack must render at 1024px',
        );
      },
    );

    testWidgets(
      'tablet 1024px: card stack is constrained to max 500px',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1024, 768));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        final constrainedBox = tester.widget<ConstrainedBox>(
          find.ancestor(
            of: find.byKey(const Key('discover_card_stack')),
            matching: find.byType(ConstrainedBox),
          ).first,
        );
        expect(
          constrainedBox.constraints.maxWidth,
          equals(500.0),
          reason: 'Card stack must be constrained to 500px max-width on tablet',
        );
      },
    );

    testWidgets(
      'exactly at breakpoint 600px: sidebar IS visible',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(600, 812));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        expect(
          find.byKey(const Key('discover_sidebar')),
          findsOneWidget,
          reason: 'Sidebar must render at exactly the 600px breakpoint',
        );
      },
    );

    testWidgets(
      'just below breakpoint 599px: sidebar NOT visible',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(599, 812));

        await tester.pumpWidget(const MaterialApp(home: DiscoverScreen()));
        await tester.pump();

        expect(
          find.byKey(const Key('discover_sidebar')),
          findsNothing,
          reason: 'Sidebar must not render at 599px — below the 600px breakpoint',
        );
      },
    );
  });
}
```

- [ ] **Step 2: Run discover responsive tests to verify they pass**

```bash
flutter test test/features/discover/discover_screen_responsive_test.dart
```

Expected: **PASS** — all 5 tests green (keys are already in place from
`p4-discover-responsive`).

- [ ] **Step 3: Write `chat_layout_responsive_test.dart`**

Create `test/features/chat/chat_layout_responsive_test.dart`:

```dart
// Consolidated responsive tests for ChatListScreen.
// Keys used: 'chat_conversation_list', 'chat_thread_panel'
// These keys are added in task p4-chat-two-panel.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gomeet/features/chat/screens/chat_list_screen.dart';

void main() {
  group('ChatListScreen — responsive breakpoints', () {
    tearDown(() async {
      await TestWidgetsFlutterBinding.instance.setSurfaceSize(null);
    });

    testWidgets(
      'mobile 375px: conversation list is full-width, no right panel',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        // Conversation list must be present.
        expect(
          find.byKey(const Key('chat_conversation_list')),
          findsOneWidget,
          reason: 'Conversation list must render at 375px',
        );
        // No right panel on mobile.
        expect(
          find.byKey(const Key('chat_thread_panel')),
          findsNothing,
          reason: 'Thread panel must not render at 375px mobile width',
        );
      },
    );

    testWidgets(
      'tablet 800px: both panels render',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        expect(
          find.byKey(const Key('chat_conversation_list')),
          findsOneWidget,
          reason: 'Conversation list must render at 800px',
        );
        expect(
          find.byKey(const Key('chat_thread_panel')),
          findsOneWidget,
          reason: 'Thread panel must render at 800px tablet width',
        );
      },
    );

    testWidgets(
      'tablet 800px: left panel is 290px wide',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(800, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byKey(const Key('chat_conversation_list')),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(
          sizedBox.width,
          equals(290.0),
          reason: 'Left panel must be fixed at 290px',
        );
      },
    );

    testWidgets(
      'exactly at breakpoint 768px: two-panel layout IS active',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        expect(
          find.byKey(const Key('chat_thread_panel')),
          findsOneWidget,
          reason: 'Two-panel layout must activate at exactly 768px',
        );
      },
    );

    testWidgets(
      'just below breakpoint 767px: single-panel layout',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(767, 1024));

        await tester.pumpWidget(const MaterialApp(home: ChatListScreen()));
        await tester.pump();

        expect(
          find.byKey(const Key('chat_thread_panel')),
          findsNothing,
          reason: 'Thread panel must not render at 767px — below 768px breakpoint',
        );
      },
    );
  });
}
```

- [ ] **Step 4: Run chat layout tests to verify they pass**

```bash
flutter test test/features/chat/chat_layout_responsive_test.dart
```

Expected: **PASS** — all 5 tests green.

- [ ] **Step 5: Run the full test suite to catch regressions**

```bash
flutter test
```

Expected: **PASS** — all tests across the project green. Fix any regressions before
committing.

- [ ] **Step 6: Refactor if needed**

Both test files share a `tearDown` pattern. If a third responsive test file is added in
future, extract a shared `setUpSurface` / `tearDownSurface` helper. For now, two files do
not justify the abstraction — no refactor needed.

- [ ] **Step 7: Commit**

```bash
git add test/features/discover/discover_screen_responsive_test.dart \
        test/features/chat/chat_layout_responsive_test.dart
git commit -m "test(responsive): add consolidated breakpoint widget tests for Discover and Chat screens"
```

---

## Task p4-viewport-qa: Manual Viewport QA and Overflow Fixes

**UI Reference:** docs/office/05-ui-designs/03-discover.html, docs/office/05-ui-designs/04-chat.html

**Agent:** frontend_engineer (haiku)

**Depends on:** all previous Phase 4 tasks

---

This is a manual quality-assurance task. Each step involves opening Chrome DevTools,
setting the device toolbar width, and verifying a checklist. Any issue found must be fixed
inline before moving to the next screen.

### QA Checklist Criteria (apply to every screen at every width)

1. **No text overflow** — No `RenderFlex overflowed by X pixels` warnings in console; no
   clipped text visible on screen.
2. **No horizontal scroll** — The page must not scroll horizontally at any breakpoint.
3. **No widget clipping** — No `ClipRect` or overflow clip hiding important content.
4. **Bottom nav bar visible** — Navigation bar is fully visible and correctly spaced; tabs
   are not squished.

### Screens to Test

| Screen | Route | Notes |
|--------|-------|-------|
| Sign-in / Landing | `/sign-in` | Check form field widths |
| Sign-up | `/sign-up` | Check form field widths |
| Profile creation — step 1 (Name) | `/profile/create/name` | |
| Profile creation — step 2 (Birthday) | `/profile/create/birthday` | |
| Profile creation — step 3 (Photos) | `/profile/create/photos` | Photo grid |
| Profile creation — step 4 (Bio) | `/profile/create/bio` | TextField |
| Profile creation — step 5 (Prefs) | `/profile/create/prefs` | Chip rows |
| Discover | `/discover` | Card stack + sidebar (tablet) |
| Chat list | `/chat` | Two-panel (tablet) |
| Chat thread | `/chat/:id` | Message list + composer |
| Profile view | `/profile/:id` | Photo carousel + bio |
| Settings | `/settings` | List tiles |
| 404 / Not found | `/no-such-route` | |

---

- [ ] **Step 1: Open the app in Chrome at 375 px (mobile)**

```bash
flutter run -d chrome --web-port 5000
```

In Chrome: open DevTools → Toggle device toolbar (`Ctrl+Shift+M`) → set width to 375 px,
height to 812 px.

- [ ] **Step 2: Test every screen at 375 px**

Navigate to each screen listed in the table above. For each screen, verify all four
checklist criteria. Record findings in the format:

```
[PASS] Sign-in @ 375px — all criteria met
[FAIL] Profile photos @ 375px — 3x2 photo grid overflows right edge by 8px
```

- [ ] **Step 3: Fix any 375 px issues found**

For each FAIL found at 375 px, apply the minimal fix. Common fix patterns:

**Text overflow in a Row:**
```dart
// Before:
Row(children: [Text(longTitle), Icon(Icons.chevron_right)])

// After:
Row(children: [Expanded(child: Text(longTitle, overflow: TextOverflow.ellipsis)), Icon(Icons.chevron_right)])
```

**Grid overflowing right:**
```dart
// Before:
GridView(crossAxisCount: 3, children: ...)

// After (add padding or reduce crossAxisCount on narrow viewports):
LayoutBuilder(
  builder: (context, constraints) {
    final cols = constraints.maxWidth < 400 ? 2 : 3;
    return GridView(crossAxisCount: cols, children: ...);
  },
)
```

**Horizontal scroll appearing on a Column:**
```dart
// Wrap the Column in a SingleChildScrollView only if vertical scroll is needed,
// never horizontal. Remove any fixed-width Row children exceeding screen width.
```

After each fix, hot-reload and re-verify the screen.

- [ ] **Step 4: Test every screen at 768 px (tablet portrait)**

In Chrome DevTools, change width to 768 px, height to 1024 px.

Navigate each screen and apply the same four-criteria checklist. Record findings:

```
[PASS] Chat list @ 768px — two-panel renders correctly
[FAIL] Settings @ 768px — list tiles stretch to full 768px, no max-width cap
```

- [ ] **Step 5: Fix any 768 px issues found**

Common fix for settings / form screens on wide viewports — constrain the body to a
readable max-width:

```dart
// In any screen where the content should not stretch to full tablet width:
// Wrap the body (not the Scaffold) in a Center + ConstrainedBox.
body: Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 600),
    child: _existingBodyWidget,
  ),
),
```

Hot-reload and re-verify after each fix.

- [ ] **Step 6: Test every screen at 1024 px (tablet landscape)**

In Chrome DevTools, change width to 1024 px, height to 768 px.

Navigate each screen and apply the four-criteria checklist. Pay extra attention to:
- Discover sidebar button spacing
- Chat two-panel proportions (290 px left / rest right)
- Profile creation photo grid — 3 columns must not be too wide

Record findings:

```
[PASS] Discover @ 1024px — sidebar visible, card centred, keyboard hint bar visible
[PASS] Chat @ 1024px — two panels render, thread scrolls correctly
```

- [ ] **Step 7: Fix any 1024 px issues found**

Apply the same fix patterns from Steps 3 and 5. Hot-reload and re-verify.

- [ ] **Step 8: Final regression check — run all automated tests**

```bash
flutter test
```

Expected: **PASS** — ensure manual fixes did not break any widget tests.

- [ ] **Step 9: Commit all QA fixes**

```bash
git add lib/
git commit -m "fix(ui): viewport QA — resolve overflow and clipping issues at 375/768/1024px"
```

---

## Self-Review Checklist

| Check | Status |
|-------|--------|
| All 7 tasks have complete, runnable Dart code | ✓ |
| No `// TODO`, `// TBD`, or "implement later" | ✓ |
| `embedded` parameter consistent between p4-chat-thread-embedded and p4-chat-two-panel | ✓ — both use `embedded: true` |
| `Key('discover_sidebar')` used in task and test | ✓ |
| `Key('discover_card_stack')` used in task and test | ✓ |
| `Key('chat_conversation_list')` used in task and test | ✓ |
| `Key('chat_thread_panel')` used in task and test | ✓ |
| `Key('chat_thread_body')` set by task and read by test | ✓ |
| Breakpoints consistent: Discover 600 px, Chat 768 px | ✓ |
| `tester.binding.setSurfaceSize` used consistently | ✓ |
| `tearDown` resets surface size in all test groups | ✓ |
| `onKeyEvent` used (not deprecated `onKey`) | ✓ |
| Firestore write methods never modified — layout only | ✓ |
| UI References attached to all frontend tasks | ✓ |
| p4-viewport-qa is last (depends on all layout tasks) | ✓ |
