import 'dart:ui' as ui;

import 'package:c_editor/widgets/app_ui_scale.dart';
import 'package:c_editor/widgets/app_ui_scaler.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('scaled MediaQuery keeps fold geometry in one coordinate space', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late MediaQueryData scaledMedia;
    const hinge = ui.DisplayFeature(
      bounds: Rect.fromLTWH(490, 0, 20, 800),
      type: ui.DisplayFeatureType.hinge,
      state: ui.DisplayFeatureState.postureFlat,
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1000, 800),
          devicePixelRatio: 2,
          padding: EdgeInsets.fromLTRB(20, 40, 30, 50),
          viewPadding: EdgeInsets.fromLTRB(20, 40, 30, 50),
          viewInsets: EdgeInsets.only(bottom: 200),
          systemGestureInsets: EdgeInsets.fromLTRB(10, 0, 10, 20),
          displayFeatures: [hinge],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppUiScaler(
            scale: 2,
            wrapMessenger: false,
            child: Builder(
              builder: (context) {
                scaledMedia = MediaQuery.of(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );

    expect(scaledMedia.size, const Size(500, 400));
    expect(scaledMedia.devicePixelRatio, 4);
    expect(scaledMedia.padding, const EdgeInsets.fromLTRB(10, 20, 15, 25));
    expect(scaledMedia.viewInsets, const EdgeInsets.only(bottom: 100));
    expect(
      scaledMedia.systemGestureInsets,
      const EdgeInsets.fromLTRB(5, 0, 5, 10),
    );
    expect(
      scaledMedia.displayFeatures.single.bounds,
      const Rect.fromLTWH(245, 0, 10, 400),
    );
    expect(find.byKey(const ValueKey('appUiScalerClip')), findsOneWidget);
    expect(find.byType(Transform), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('current layout constraints win over stale window metrics', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    late Size scaledSize;
    late double appliedScale;

    await tester.pumpWidget(
      MediaQuery(
        // Simulate the brief frame where window metrics still report the old
        // size but the render tree has already received its new constraints.
        data: const MediaQueryData(size: Size(1200, 900)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 800,
              height: 500,
              child: AppUiScaler(
                scale: 2,
                applyCompactViewportScale: true,
                wrapMessenger: false,
                child: Builder(
                  builder: (context) {
                    scaledSize = MediaQuery.sizeOf(context);
                    appliedScale = AppUiScale.of(context);
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(appliedScale, 1.7);
    expect(scaledSize.width, closeTo(800 / 1.7, .0001));
    expect(scaledSize.height, closeTo(500 / 1.7, .0001));
    expect(tester.takeException(), isNull);
  });

  testWidgets('root UI survives abrupt viewport changes without losing state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final probeKey = GlobalKey<_ResizeProbeState>();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return AppUiScaler(
            scale: 1.15,
            applyCompactViewportScale: true,
            wrapMessenger: false,
            child: child!,
          );
        },
        home: _ResizeProbe(key: probeKey),
      ),
    );
    await tester.tap(find.text('Increment'));
    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    final originalState = probeKey.currentState;
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: const Offset(20, 20));
    addTearDown(pointer.removePointer);

    for (final size in [
      const Size(360, 780),
      const Size(780, 360),
      const Size(80, 48),
      Size.zero,
      const Size(900, 700),
      const Size(320, 680),
      const Size(1280, 720),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pump();
      await pointer.moveTo(Offset(size.width * .5, size.height * .5));
      await tester.pump();
      expect(
        tester.takeException(),
        isNull,
        reason: 'layout exception after changing directly to $size',
      );
      expect(probeKey.currentState, same(originalState));
      expect(find.text('Count: 1'), findsOneWidget);
      expect(find.text('Resize-safe dialog'), findsOneWidget);
    }
  });
}

class _ResizeProbe extends StatefulWidget {
  const _ResizeProbe({super.key});

  @override
  State<_ResizeProbe> createState() => _ResizeProbeState();
}

class _ResizeProbeState extends State<_ResizeProbe> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Count: $count'),
          FilledButton(
            onPressed: () => setState(() => count++),
            child: const Text('Increment'),
          ),
          FilledButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const AlertDialog(
                title: Text('Resize-safe dialog'),
                content: Text('The open overlay must survive window changes.'),
              ),
            ),
            child: const Text('Open dialog'),
          ),
        ],
      ),
    );
  }
}
