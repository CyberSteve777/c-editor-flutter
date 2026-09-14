import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PreviewDocument _document({List<Offset>? points, double strokeWidth = 3}) =>
    PreviewDocument(
      banner: PreviewBannerRef(
        kind: PreviewBannerSourceKind.assetStem,
        assetPath: 'missing-stroke-test-background.png',
      ),
      layers: [
        PreviewLayer(
          id: 'shape',
          kind: PreviewLayerKind.shape,
          bounds: const Rect.fromLTWH(0.1, 0.1, 0.8, 0.8),
          shapeKind: PreviewShapeKind.rect,
          shapeFilled: true,
          fillColor: Colors.blue,
          strokeWidth: 0,
          zIndex: 1,
        ),
        PreviewLayer(
          id: 'text',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0.2, 0.5, 0.4, 0.15),
          text: 'Text below the stroke',
          textStyle: PreviewTextStyleData(
            fontFamily: null,
            fontSize: 20,
            outline: false,
          ),
          zIndex: 2,
        ),
        PreviewLayer(
          id: 'stroke',
          kind: PreviewLayerKind.stroke,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          points:
              points ??
              const [Offset(0.15, 0.2), Offset(0.85, 0.2), Offset(0.85, 0.8)],
          strokeColor: Colors.red,
          strokeWidth: strokeWidth,
          zIndex: 3,
        ),
      ],
    );

class _Harness {
  _Harness(this.document);

  final PreviewDocument document;
  final boundaryKey = GlobalKey();
  final penPoints = <Offset>[];
  final eraserPoints = <Offset>[];
  String? selected;
  late StateSetter rebuild;

  Future<void> pump(
    WidgetTester tester, {
    PreviewEditTool tool = PreviewEditTool.select,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return PreviewCanvas(
                document: document,
                interactive: true,
                tool: tool,
                selectedLayerId: selected,
                boundaryKey: boundaryKey,
                onSelectLayer: (id) => setState(() => selected = id),
                onStrokeStarted: penPoints.add,
                onStrokeUpdated: penPoints.add,
                onEraseAt: eraserPoints.add,
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Offset global(Offset designPoint) {
    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderBox;
    return boundary.localToGlobal(designPoint);
  }

  Future<void> tap(WidgetTester tester, Offset designPoint) async {
    await tester.tapAt(global(designPoint));
    await tester.pumpAndSettle();
  }

  CustomPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(
        find.descendant(
          of: find.byKey(const ValueKey('stroke')),
          matching: find.byType(CustomPaint),
        ),
      )
      .painter!;
}

Offset _design(double x, double y) =>
    Offset(x * kPreviewCanvasSize.width, y * kPreviewCanvasSize.height);

void main() {
  testWidgets('thin strokes select near each segment but not blank canvas', (
    tester,
  ) async {
    final harness = _Harness(_document());
    await harness.pump(tester);
    await harness.tap(tester, _design(0.5, 0.2) + const Offset(0, 11));
    expect(harness.selected, 'stroke');
    await harness.tap(tester, _design(0.85, 0.4) + const Offset(-11, 0));
    expect(harness.selected, 'stroke');
    await harness.tap(tester, _design(0.97, 0.97));
    expect(harness.selected, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('non-stroke areas pass through to underlying shape and text', (
    tester,
  ) async {
    final harness = _Harness(_document());
    await harness.pump(tester);
    await harness.tap(tester, _design(0.5, 0.2) + const Offset(0, 13));
    expect(harness.selected, 'shape');
    await harness.tap(tester, _design(0.4, 0.57));
    expect(harness.selected, 'text');
    await harness.tap(tester, _design(0.5, 0.2));
    expect(harness.selected, 'stroke');
    expect(tester.takeException(), isNull);
  });

  testWidgets('thick stroke hit tolerance scales with rendered stroke width', (
    tester,
  ) async {
    final harness = _Harness(_document(strokeWidth: 80));
    await harness.pump(tester);
    await harness.tap(tester, _design(0.5, 0.2) + const Offset(0, 45));
    expect(harness.selected, 'stroke');
    await harness.tap(tester, _design(0.5, 0.2) + const Offset(0, 47));
    expect(harness.selected, 'shape');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'segment projection clamps at endpoints rather than infinite lines',
    (tester) async {
      final harness = _Harness(_document());
      await harness.pump(tester);
      final painter = harness.painter(tester);
      expect(
        painter.hitTest(_design(0.15, 0.2) + const Offset(-11, 0)),
        isTrue,
      );
      expect(
        painter.hitTest(_design(0.15, 0.2) + const Offset(-13, 0)),
        isFalse,
      );
      expect(
        painter.hitTest(_design(0.5, 0.2) + const Offset(0, 11.9)),
        isTrue,
      );
      expect(
        painter.hitTest(_design(0.5, 0.2) + const Offset(0, 12.1)),
        isFalse,
      );
      expect(painter.hitTest(_design(0.4, 0.4)), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  for (final points in <List<Offset>>[
    [],
    [const Offset(0.5, 0.2)],
  ]) {
    testWidgets(
      '${points.length}-point drafts do not intercept any selection',
      (tester) async {
        final harness = _Harness(_document(points: points));
        await harness.pump(tester);
        expect(harness.painter(tester).hitTest(_design(0.5, 0.2)), isFalse);
        await harness.tap(tester, _design(0.5, 0.2));
        expect(harness.selected, 'shape');
        await harness.tap(tester, _design(0.97, 0.97));
        expect(harness.selected, isNull);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('repeated endpoints have finite point-distance selection', (
    tester,
  ) async {
    final harness = _Harness(
      _document(points: const [Offset(0.5, 0.2), Offset(0.5, 0.2)]),
    );
    await harness.pump(tester);
    expect(
      harness.painter(tester).hitTest(_design(0.5, 0.2) + const Offset(0, 11)),
      isTrue,
    );
    expect(
      harness.painter(tester).hitTest(_design(0.5, 0.2) + const Offset(0, 13)),
      isFalse,
    );
    await harness.tap(tester, _design(0.5, 0.2));
    expect(harness.selected, 'stroke');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a front background blocks even a precise stroke hit', (
    tester,
  ) async {
    final harness = _Harness(_document());
    await harness.pump(tester);
    await harness.tap(tester, _design(0.5, 0.2));
    expect(harness.selected, 'stroke');
    harness.rebuild(
      () => harness.document.moveLayer(
        kPreviewBackgroundLayerId,
        PreviewLayerOrderAction.toFront,
      ),
    );
    await tester.pumpAndSettle();
    await harness.tap(tester, _design(0.5, 0.2));
    expect(harness.selected, isNull);
    await harness.tap(tester, _design(0.4, 0.57));
    expect(harness.selected, isNull);
    expect(tester.takeException(), isNull);
  });

  for (final tool in [PreviewEditTool.pen, PreviewEditTool.eraser]) {
    testWidgets('$tool outer pans work on and away from existing stroke', (
      tester,
    ) async {
      final harness = _Harness(_document());
      await harness.pump(tester, tool: tool);
      for (final start in [_design(0.5, 0.2), _design(0.4, 0.4)]) {
        final before = tool == PreviewEditTool.pen
            ? harness.penPoints.length
            : harness.eraserPoints.length;
        final gesture = await tester.startGesture(harness.global(start));
        await tester.pump();
        await gesture.moveTo(harness.global(start + const Offset(50, 30)));
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.moveTo(harness.global(start + const Offset(90, 50)));
        await tester.pump(const Duration(milliseconds: 16));
        await gesture.up();
        await tester.pumpAndSettle();
        final after = tool == PreviewEditTool.pen
            ? harness.penPoints.length
            : harness.eraserPoints.length;
        expect(after, greaterThan(before));
        expect(harness.selected, isNull);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
