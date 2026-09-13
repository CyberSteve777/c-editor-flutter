import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_editor_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _toolbarViewportKey = ValueKey('previewToolbarViewport');
const _canvasViewportKey = ValueKey('previewCanvasViewport');
const _zoomSliderKey = ValueKey('previewCanvasZoomSlider');

PreviewDocument _document() => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    stem: 'Unknown',
  ),
  layers: [
    PreviewLayer(
      id: 'edge',
      kind: PreviewLayerKind.shape,
      bounds: const Rect.fromLTWH(0.90, 0.88, 0.08, 0.10),
      shapeKind: PreviewShapeKind.rect,
      shapeFilled: true,
      fillColor: Colors.green,
    ),
  ],
);

Widget _workspace({
  required Widget toolbar,
  required PreviewDocument document,
  required GlobalKey boundaryKey,
  String? selectedLayerId,
  ValueChanged<String?>? onSelectLayer,
  void Function(String id, Rect bounds)? onLayerMoved,
  void Function(String id, double scale)? onLayerScaled,
  VoidCallback? onToolbarResizeStarted,
}) => PreviewEditorWorkspace(
  toolbar: toolbar,
  canvas: PreviewCanvas(
    document: document,
    interactive: true,
    boundaryKey: boundaryKey,
    selectedLayerId: selectedLayerId,
    onSelectLayer: onSelectLayer,
    onLayerMoved: onLayerMoved,
    onLayerScaled: onLayerScaled,
  ),
  canvasZoomLabel: 'Canvas zoom',
  fitCanvasLabel: 'Fit canvas',
  resizeToolbarLabel: 'Resize toolbar',
  zoomInLabel: 'Zoom in',
  zoomOutLabel: 'Zoom out',
  onToolbarResizeStarted: onToolbarResizeStarted,
);

Rect _paintedCanvasRect(GlobalKey boundaryKey) {
  final box = boundaryKey.currentContext!.findRenderObject()! as RenderBox;
  return Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
}

Future<void> _setZoom(WidgetTester tester, double zoom) async {
  tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(zoom);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('additional controls scroll without shrinking the fitted image', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final document = _document();
    final boundaryKey = GlobalKey();
    late StateSetter rebuild;
    var controlCount = 3;
    var lastControlUsed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return _workspace(
                document: document,
                boundaryKey: boundaryKey,
                toolbar: Column(
                  children: [
                    for (var i = 0; i < controlCount; i++)
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            if (i == 29) lastControlUsed = true;
                          },
                          child: Text('Control $i'),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final initialImageRect = _paintedCanvasRect(boundaryKey);
    final initialToolbarSize = tester.getSize(find.byKey(_toolbarViewportKey));

    rebuild(() => controlCount = 30);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(_toolbarViewportKey)), initialToolbarSize);
    expect(_paintedCanvasRect(boundaryKey), initialImageRect);
    expect(
      tester
          .widget<Scrollbar>(
            find.byKey(const ValueKey('previewToolbarScrollbar')),
          )
          .thumbVisibility,
      isTrue,
    );

    await tester.scrollUntilVisible(
      find.text('Control 29'),
      160,
      scrollable: find.descendant(
        of: find.byKey(_toolbarViewportKey),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Control 29'));
    expect(lastControlUsed, isTrue);
    expect(_paintedCanvasRect(boundaryKey), initialImageRect);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'dragging the divider shrinks the toolbar and enlarges the image',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      var resizeStarted = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _workspace(
              toolbar: const SizedBox(height: 800, child: Text('Controls')),
              document: _document(),
              boundaryKey: boundaryKey,
              onToolbarResizeStarted: () => resizeStarted++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final initialToolbarHeight = tester
          .getSize(find.byKey(_toolbarViewportKey))
          .height;
      final initialImageWidth = _paintedCanvasRect(boundaryKey).width;

      await tester.drag(
        find.byKey(const ValueKey('previewToolbarResizeHandle')),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      expect(resizeStarted, 1);
      expect(
        tester.getSize(find.byKey(_toolbarViewportKey)).height,
        lessThan(initialToolbarHeight),
      );
      expect(
        _paintedCanvasRect(boundaryKey).width,
        greaterThan(initialImageWidth),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('canvas zoom is view-only and fit restores the original view', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final document = _document();
    final originalLayer = document.layers.single.copy();
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _workspace(
            toolbar: const Text('Controls'),
            document: document,
            boundaryKey: boundaryKey,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final originalRect = _paintedCanvasRect(boundaryKey);

    await _setZoom(tester, 2);
    expect(
      _paintedCanvasRect(boundaryKey).width,
      closeTo(originalRect.width * 2, 0.01),
    );
    expect(
      _paintedCanvasRect(boundaryKey).height,
      closeTo(originalRect.height * 2, 0.01),
    );
    expect(tester.getSize(find.byKey(boundaryKey)), kPreviewCanvasSize);
    expect(document.layers.single.bounds, originalLayer.bounds);
    expect(document.layers.single.scale, originalLayer.scale);

    await tester.tap(find.byKey(const ValueKey('previewCanvasFitButton')));
    await tester.pumpAndSettle();
    expect(tester.widget<Slider>(find.byKey(_zoomSliderKey)).value, 1);
    expect(_paintedCanvasRect(boundaryKey), originalRect);

    await tester.tap(find.byKey(const ValueKey('previewCanvasZoomInButton')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Slider>(find.byKey(_zoomSliderKey)).value,
      closeTo(1.1, 0.001),
    );
    await tester.tap(find.byKey(const ValueKey('previewCanvasZoomOutButton')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Slider>(find.byKey(_zoomSliderKey)).value,
      closeTo(1, 0.001),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('scrollbar panning keeps zoomed edge layers selectable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundaryKey = GlobalKey();
    String? selectedLayer;
    Rect? movedBounds;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _workspace(
            toolbar: const Text('Controls'),
            document: _document(),
            boundaryKey: boundaryKey,
            onSelectLayer: (id) => selectedLayer = id,
            onLayerMoved: (id, bounds) {
              expect(id, 'edge');
              movedBounds = bounds;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _setZoom(tester, 3);
    final viewport = tester.getRect(find.byKey(_canvasViewportKey));
    final canvasScrollbars = tester.widgetList<Scrollbar>(
      find.descendant(
        of: find.byKey(_canvasViewportKey),
        matching: find.byType(Scrollbar),
      ),
    );
    final horizontal = canvasScrollbars.singleWhere(
      (bar) => bar.scrollbarOrientation == ScrollbarOrientation.bottom,
    );
    final vertical = canvasScrollbars.singleWhere(
      (bar) => bar.scrollbarOrientation == ScrollbarOrientation.right,
    );
    expect(horizontal.thumbVisibility, isTrue);
    expect(vertical.thumbVisibility, isTrue);
    final originalHorizontalOffset = horizontal.controller!.offset;
    final originalVerticalOffset = vertical.controller!.offset;

    await tester.dragFrom(
      Offset(viewport.center.dx, viewport.bottom - 3),
      Offset(viewport.width * 0.4, 0),
    );
    await tester.pumpAndSettle();
    await tester.dragFrom(
      Offset(viewport.right - 3, viewport.center.dy),
      Offset(0, viewport.height * 0.4),
    );
    await tester.pumpAndSettle();
    expect(
      horizontal.controller!.offset,
      greaterThan(originalHorizontalOffset),
    );
    expect(vertical.controller!.offset, greaterThan(originalVerticalOffset));

    final boundary =
        boundaryKey.currentContext!.findRenderObject()! as RenderBox;
    final edgeCenter = boundary.localToGlobal(
      Offset(kPreviewCanvasSize.width * 0.94, kPreviewCanvasSize.height * 0.93),
    );
    expect(
      viewport.contains(edgeCenter),
      isTrue,
      reason: 'Scrolled edge layer $edgeCenter must be within $viewport',
    );
    await tester.tapAt(edgeCenter);
    await tester.pumpAndSettle();
    expect(selectedLayer, 'edge');
    final horizontalAfterPanning = horizontal.controller!.offset;
    final verticalAfterPanning = vertical.controller!.offset;
    await tester.dragFrom(edgeCenter, const Offset(-90, -50));
    await tester.pumpAndSettle();
    expect(movedBounds, isNotNull);
    expect(horizontal.controller!.offset, horizontalAfterPanning);
    expect(vertical.controller!.offset, verticalAfterPanning);
    expect(tester.takeException(), isNull);
  });

  testWidgets('window resizing and short viewports do not overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _workspace(
            toolbar: const SizedBox(height: 1200, child: Text('Controls')),
            document: _document(),
            boundaryKey: boundaryKey,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _setZoom(tester, 2);
    for (final size in [
      const Size(600, 300),
      const Size(600, 160),
      const Size(300, 100),
      const Size(1200, 900),
    ]) {
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final canvasRect = _paintedCanvasRect(boundaryKey);
      expect(canvasRect.width, greaterThan(0));
      expect(canvasRect.height, greaterThan(0));
      expect(canvasRect.width.isFinite && canvasRect.height.isFinite, isTrue);
      expect(tester.getSize(find.byKey(boundaryKey)), kPreviewCanvasSize);
    }
  });

  testWidgets(
    'Ctrl and Command wheel scale elements without panning the view',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final scaledElements = <double>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _workspace(
              toolbar: const Text('Controls'),
              document: _document(),
              boundaryKey: GlobalKey(),
              selectedLayerId: 'edge',
              onLayerScaled: (id, scale) {
                expect(id, 'edge');
                scaledElements.add(scale);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _setZoom(tester, 2);
      final scrollbars = tester.widgetList<Scrollbar>(
        find.descendant(
          of: find.byKey(_canvasViewportKey),
          matching: find.byType(Scrollbar),
        ),
      );
      final controllers = [for (final bar in scrollbars) bar.controller!];
      final originalOffsets = [
        for (final controller in controllers) controller.offset,
      ];
      final position = tester.getCenter(find.byKey(_canvasViewportKey));

      for (final modifier in [
        LogicalKeyboardKey.controlLeft,
        LogicalKeyboardKey.metaLeft,
      ]) {
        await tester.sendKeyDownEvent(modifier);
        try {
          await tester.sendEventToBinding(
            PointerScrollEvent(
              position: position,
              scrollDelta: const Offset(0, -40),
            ),
          );
          await tester.pumpAndSettle();
          expect([
            for (final controller in controllers) controller.offset,
          ], originalOffsets);
        } finally {
          await tester.sendKeyUpEvent(modifier);
        }
      }
      expect(scaledElements, hasLength(2));
      expect(scaledElements, everyElement(closeTo(1.08, 0.001)));
      final vertical = scrollbars
          .singleWhere(
            (bar) => bar.scrollbarOrientation == ScrollbarOrientation.right,
          )
          .controller!;
      final previousOffset = vertical.offset;
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: position,
          scrollDelta: const Offset(0, 40),
        ),
      );
      await tester.pumpAndSettle();
      expect(vertical.offset, greaterThan(previousOffset));
      expect(scaledElements, hasLength(2));
      expect(tester.takeException(), isNull);
    },
  );
}
