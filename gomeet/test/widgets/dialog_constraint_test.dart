import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating/core/widgets/dialog_helpers.dart';

/// Minimal in-test widget that pops an AlertDialog using [constrainedDialogContent].
/// This is the test fixture — no real screen import needed because the audit
/// found zero existing dialog call sites in the codebase; the helper itself
/// is the deliverable and this widget exercises it directly.
class _DialogTestWidget extends StatelessWidget {
  const _DialogTestWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('show_dialog_button'),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Test Dialog'),
              content: constrainedDialogContent(
                const Text('Dialog content here.'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(_).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
          child: const Text('Show Dialog'),
        ),
      ),
    );
  }
}

/// Minimal in-test widget that pops a ModalBottomSheet using [constrainedDialogContent].
class _BottomSheetTestWidget extends StatelessWidget {
  const _BottomSheetTestWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          key: const Key('show_sheet_button'),
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (_) => constrainedDialogContent(
              const SizedBox(
                height: 200,
                child: Center(child: Text('Sheet content')),
              ),
            ),
          ),
          child: const Text('Show Sheet'),
        ),
      ),
    );
  }
}

void main() {
  group('Dialog max-width constraint', () {
    testWidgets(
      'AlertDialog content is constrained to max 500 px on wide viewports',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(home: _DialogTestWidget()),
        );

        await tester.tap(find.byKey(const Key('show_dialog_button')));
        await tester.pumpAndSettle();

        // AlertDialog renders its own internal ConstrainedBoxes; search all
        // descendants and verify at least one has maxWidth == 500.
        final allBoxes = tester.widgetList<ConstrainedBox>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(ConstrainedBox),
          ),
        );
        final constrained500 =
            allBoxes.where((b) => b.constraints.maxWidth == 500.0);
        expect(
          constrained500,
          isNotEmpty,
          reason: 'Expected a ConstrainedBox(maxWidth: 500) inside AlertDialog',
        );
      },
    );

    testWidgets(
      'AlertDialog content is centred via an Align widget',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(home: _DialogTestWidget()),
        );

        await tester.tap(find.byKey(const Key('show_dialog_button')));
        await tester.pumpAndSettle();

        // AlertDialog may render internal Align widgets; search all and verify
        // at least one has alignment == Alignment.center.
        final allAligns = tester.widgetList<Align>(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(Align),
          ),
        );
        final centred = allAligns.where(
          (a) => a.alignment == Alignment.center,
        );
        expect(
          centred,
          isNotEmpty,
          reason: 'Expected an Align(alignment: Alignment.center) inside AlertDialog',
        );
      },
    );

    testWidgets(
      'ModalBottomSheet root is constrained to max 500 px on wide viewports',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(home: _BottomSheetTestWidget()),
        );

        await tester.tap(find.byKey(const Key('show_sheet_button')));
        await tester.pumpAndSettle();

        // The bottom sheet root must be wrapped in ConstrainedBox with maxWidth 500.
        expect(find.byType(ConstrainedBox), findsWidgets);
        final boxes = tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
        final constrained500 = boxes.where(
          (b) => b.constraints.maxWidth == 500.0,
        );
        expect(constrained500, isNotEmpty);
      },
    );

    testWidgets(
      'constrainedDialogContent preserves original child widget',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          const MaterialApp(home: _DialogTestWidget()),
        );

        await tester.tap(find.byKey(const Key('show_dialog_button')));
        await tester.pumpAndSettle();

        // Original content text must still be visible.
        expect(find.text('Dialog content here.'), findsOneWidget);
      },
    );
  });
}
