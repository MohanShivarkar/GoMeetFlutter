import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dating/features/shell/widgets/offline_banner.dart';

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
