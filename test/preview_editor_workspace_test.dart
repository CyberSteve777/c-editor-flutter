import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_editor_workspace.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
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
  PreferredSizeWidget? toolbarHeader,
  required PreviewDocument document,
  required GlobalKey boundaryKey,
  PreviewEditTool tool = PreviewEditTool.select,
  String? selectedLayerId,
  ValueChanged<String?>? onSelectLayer,
  void Function(String id, Rect bounds)? onLayerMoved,
  void Function(String id, double scale)? onLayerScaled,
  VoidCallback? onToolbarResizeStarted,
  VoidCallback? onCanvasPaint,
  ValueChanged<Offset>? onStrokeStarted,
}) => PreviewEditorWorkspace(
  toolbar: toolbar,
  toolbarHeader: toolbarHeader,
  canvas: _CanvasPaintProbe(
    onPaint: onCanvasPaint,
    child: PreviewCanvas(
      document: document,
      interactive: true,
      tool: tool,
      boundaryKey: boundaryKey,
      selectedLayerId: selectedLayerId,
      onSelectLayer: onSelectLayer,
      onLayerMoved: onLayerMoved,
      onLayerScaled: onLayerScaled,
      onStrokeStarted: onStrokeStarted,
    ),
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

Finder _scrollbarPaint(
  Finder viewport,
  ScrollbarOrientation orientation,
) => find.descendant(
  of: viewport,
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.foregroundPainter is ScrollbarPainter &&
        ((widget.foregroundPainter! as ScrollbarPainter).scrollbarOrientation ==
                orientation ||
            (orientation == ScrollbarOrientation.right &&
                (widget.foregroundPainter! as ScrollbarPainter)
                        .scrollbarOrientation ==
                    null)),
  ),
);

Offset _thumbCenter(
  WidgetTester tester,
  Finder paint,
  ScrollbarOrientation orientation,
  PointerDeviceKind kind,
) {
  final painter =
      tester.widget<CustomPaint>(paint).foregroundPainter! as ScrollbarPainter;
  final box = tester.renderObject<RenderBox>(paint);
  final vertical = orientation == ScrollbarOrientation.right;
  final extent = vertical ? box.size.height : box.size.width;
  final points = <Offset>[];
  for (var position = 0.0; position < extent; position++) {
    final point = vertical
        ? Offset(box.size.width - 2, position)
        : Offset(position, box.size.height - 2);
    if (painter.hitTestOnlyThumbInteractive(point, kind)) points.add(point);
  }
  expect(points, isNotEmpty, reason: 'The painted thumb must accept $kind');
  return box.localToGlobal(points[points.length ~/ 2]);
}

Rect _renderedRect(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
}

Widget _scaledApp(Widget home, double scale) => MaterialApp(
  builder: (context, child) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size / scale;
    return MediaQuery(
      data: mediaQuery.copyWith(size: size),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    );
  },
  home: Scaffold(body: home),
);

void _setDeviceViewport(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

class _CanvasPaintProbe extends SingleChildRenderObjectWidget {
  const _CanvasPaintProbe({required this.onPaint, required super.child});

  final VoidCallback? onPaint;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _CanvasPaintProbeRenderObject(onPaint);

  @override
  void updateRenderObject(
    BuildContext context,
    _CanvasPaintProbeRenderObject renderObject,
  ) => renderObject.onPaint = onPaint;
}

class _CanvasPaintProbeRenderObject extends RenderProxyBox {
  _CanvasPaintProbeRenderObject(this.onPaint);

  VoidCallback? onPaint;

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset);
    onPaint?.call();
  }
}

void main() {
  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('toolbar header scrolls away without resizing canvas ($kind)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1000, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      var backPressed = 0;
      var exportPressed = 0;
      const headerKey = ValueKey('workspaceTestTitleBar');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _workspace(
              toolbarHeader: AppBar(
                key: headerKey,
                primary: false,
                leading: BackButton(onPressed: () => backPressed++),
                title: const Text('Preview Image Generator'),
                actions: [
                  IconButton(
                    tooltip: 'Export preview',
                    onPressed: () => exportPressed++,
                    icon: const Icon(Icons.save_alt),
                  ),
                ],
              ),
              toolbar: const SizedBox(height: 1200, child: Text('Controls')),
              document: _document(),
              boundaryKey: boundaryKey,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final viewport = find.byKey(_toolbarViewportKey);
      final originalCanvasRect = _paintedCanvasRect(boundaryKey);
      final originalToolbarRect = tester.getRect(viewport);
      expect(find.byType(BackButton).hitTestable(), findsOneWidget);
      if (kind == PointerDeviceKind.touch) {
        await tester.dragFrom(
          tester.getCenter(viewport),
          const Offset(0, -180),
        );
      } else {
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(viewport),
            scrollDelta: const Offset(0, 180),
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(headerKey)).bottom,
        lessThanOrEqualTo(originalToolbarRect.top),
      );
      expect(find.byType(BackButton).hitTestable(), findsNothing);
      expect(tester.getRect(viewport), originalToolbarRect);
      expect(_paintedCanvasRect(boundaryKey), originalCanvasRect);

      await tester.scrollUntilVisible(
        find.byType(BackButton),
        -160,
        scrollable: find.descendant(
          of: viewport,
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.tap(find.byTooltip('Export preview'));
      expect(backPressed, 1);
      expect(exportPressed, 1);
      expect(_paintedCanvasRect(boundaryKey), originalCanvasRect);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('divider can collapse shared toolbar to exactly one title row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundaryKey = GlobalKey();
    final header = AppBar(
      primary: false,
      toolbarHeight: 64,
      title: const Text('Preview Image Generator'),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _workspace(
            toolbarHeader: header,
            toolbar: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('Controls'), SizedBox(height: 1200)],
            ),
            document: _document(),
            boundaryKey: boundaryKey,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final oldCanvasRect = tester.getRect(find.byKey(_canvasViewportKey));
    final handle = find.byKey(const ValueKey('previewToolbarResizeHandle'));
    await tester.drag(handle, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(_toolbarViewportKey)).height,
      header.preferredSize.height,
    );
    expect(
      tester.getRect(find.byType(AppBar)),
      tester.getRect(find.byKey(_toolbarViewportKey)),
    );
    expect(
      tester.getSize(find.byKey(_canvasViewportKey)).height,
      greaterThan(oldCanvasRect.height),
    );
    expect(find.text('Preview Image Generator').hitTestable(), findsOneWidget);

    await tester.drag(handle, const Offset(0, 180));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(_toolbarViewportKey)).height,
      greaterThan(header.preferredSize.height),
    );
    expect(find.text('Controls').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared title respects safe areas and short keyboard viewports', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundaryKey = GlobalKey();
    var keyboardHeight = 0.0;
    late StateSetter updateInsets;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            updateInsets = setState;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.fromLTRB(16, 24, 20, 0),
                viewPadding: const EdgeInsets.fromLTRB(16, 24, 20, 0),
                viewInsets: EdgeInsets.only(bottom: keyboardHeight),
                textScaler: const TextScaler.linear(1.6),
              ),
              child: Scaffold(
                body: SafeArea(
                  bottom: false,
                  child: _workspace(
                    toolbarHeader: AppBar(
                      primary: false,
                      title: const Text('Preview Image Generator'),
                    ),
                    toolbar: const SizedBox(height: 1200, child: TextField()),
                    document: _document(),
                    boundaryKey: boundaryKey,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final initialToolbar = tester.getRect(find.byKey(_toolbarViewportKey));
    expect(initialToolbar.top, 24);
    expect(initialToolbar.left, 16);
    expect(initialToolbar.right, 980);

    for (final (size, inset) in [
      (const Size(1000, 700), 320.0),
      (const Size(600, 240), 100.0),
      (const Size(300, 100), 0.0),
      (const Size(1000, 700), 0.0),
    ]) {
      updateInsets(() => keyboardHeight = inset);
      await tester.binding.setSurfaceSize(size);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final viewport = tester.getRect(find.byKey(_canvasViewportKey));
      expect(viewport.height, greaterThan(0));
      expect(viewport.bottom, lessThanOrEqualTo(size.height - inset));
      expect(tester.getSize(find.byKey(boundaryKey)), kPreviewCanvasSize);
    }
  });

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    testWidgets('thumb dragging in pen mode does not draw ($kind)', (
      tester,
    ) async {
      _setDeviceViewport(tester, const Size(1200, 800));
      var strokes = 0;
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        _scaledApp(
          _workspace(
            toolbar: const Text('Controls'),
            document: _document(),
            boundaryKey: boundaryKey,
            tool: PreviewEditTool.pen,
            onStrokeStarted: (_) => strokes++,
          ),
          1.4,
        ),
      );
      await tester.pumpAndSettle();
      await _setZoom(tester, 3);
      final viewport = find.byKey(_canvasViewportKey);
      for (final orientation in [
        ScrollbarOrientation.bottom,
        ScrollbarOrientation.right,
      ]) {
        final paint = _scrollbarPaint(viewport, orientation);
        final horizontal = orientation == ScrollbarOrientation.bottom;
        var thumb = _thumbCenter(tester, paint, orientation, kind);
        if (kind == PointerDeviceKind.touch) {
          // A finger may hit the larger thumb target just inside the painted
          // track. It is still a scrollbar interaction, not a drawing gesture.
          thumb -= horizontal ? const Offset(0, 12) : const Offset(12, 0);
          final painter =
              tester.widget<CustomPaint>(paint).foregroundPainter!
                  as ScrollbarPainter;
          final box = tester.renderObject<RenderBox>(paint);
          expect(
            painter.hitTestOnlyThumbInteractive(box.globalToLocal(thumb), kind),
            isTrue,
          );
        }
        final oldRect = _paintedCanvasRect(boundaryKey);
        final gesture = await tester.startGesture(thumb, kind: kind);
        await gesture.moveBy(
          horizontal ? const Offset(60, 0) : const Offset(0, 60),
        );
        await tester.pump();
        final newRect = _paintedCanvasRect(boundaryKey);
        expect(
          horizontal ? newRect.left : newRect.top,
          lessThan(horizontal ? oldRect.left : oldRect.top),
          reason: 'Pen mode must not steal thumb panning',
        );
        expect(
          strokes,
          0,
          reason: 'Scrollbar dragging must not start a stroke',
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
    for (final orientation in [
      ScrollbarOrientation.bottom,
      ScrollbarOrientation.right,
    ]) {
      testWidgets(
        'thumb input wins over pending zoom layout ($orientation, $kind)',
        (tester) async {
          _setDeviceViewport(tester, const Size(1200, 800));
          final boundaryKey = GlobalKey();
          await tester.pumpWidget(
            _scaledApp(
              _workspace(
                toolbar: const Text('Controls'),
                document: _document(),
                boundaryKey: boundaryKey,
              ),
              1.4,
            ),
          );
          await tester.pumpAndSettle();
          await _setZoom(tester, 2);
          final viewport = find.byKey(_canvasViewportKey);
          final bars = tester.widgetList<Scrollbar>(
            find.descendant(of: viewport, matching: find.byType(Scrollbar)),
          );
          final scrollbar = bars.singleWhere(
            (bar) => bar.scrollbarOrientation == orientation,
          );
          final horizontal = orientation == ScrollbarOrientation.bottom;
          final otherBar = bars.singleWhere(
            (bar) => bar.scrollbarOrientation != orientation,
          );
          final otherOffset = otherBar.controller!.offset;
          final otherDimension =
              otherBar.controller!.position.viewportDimension;
          final thumb = _thumbCenter(
            tester,
            _scrollbarPaint(viewport, orientation),
            orientation,
            kind,
          );
          final gesture = await tester.startGesture(thumb, kind: kind);
          await gesture.moveBy(
            horizontal ? const Offset(5, 0) : const Offset(0, 5),
          );
          await tester.pump();
          tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.1);
          // The second interaction occurs before the queued zoom layout: its pan
          // must not be overwritten by the older focal-point correction.
          await gesture.moveBy(
            horizontal ? const Offset(60, 0) : const Offset(0, 60),
          );
          final requestedOffset = scrollbar.controller!.offset;
          await tester.pump();
          expect(scrollbar.controller!.offset, closeTo(requestedOffset, 0.01));
          expect(
            otherBar.controller!.offset,
            closeTo(
              (otherOffset + otherDimension / 2) / 2 * 2.1 - otherDimension / 2,
              0.01,
            ),
            reason: 'Panning one axis must not cancel the other zoom anchor',
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('visible thumb accepts dragging after rapid fit and zoom', (
    tester,
  ) async {
    _setDeviceViewport(tester, const Size(1200, 800));
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      _scaledApp(
        _workspace(
          toolbar: const Text('Controls'),
          document: _document(),
          boundaryKey: boundaryKey,
        ),
        1.4,
      ),
    );
    await tester.pumpAndSettle();
    await _setZoom(tester, 2);
    tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(1);
    await tester.pump();
    tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2);
    await tester.pump();
    // Let the standard scrollbar rebuild its recognizer after the fit frame
    // reported a zero scroll extent; the thumb must then remain draggable.
    await tester.pump();
    final viewport = find.byKey(_canvasViewportKey);
    final scrollbar = tester
        .widgetList<Scrollbar>(
          find.descendant(of: viewport, matching: find.byType(Scrollbar)),
        )
        .singleWhere(
          (bar) => bar.scrollbarOrientation == ScrollbarOrientation.right,
        );
    final oldOffset = scrollbar.controller!.offset;
    final oldCanvasRect = _paintedCanvasRect(boundaryKey);
    final thumb = _thumbCenter(
      tester,
      _scrollbarPaint(viewport, ScrollbarOrientation.right),
      ScrollbarOrientation.right,
      PointerDeviceKind.touch,
    );
    final gesture = await tester.startGesture(thumb);
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump();
    expect(scrollbar.controller!.offset, greaterThan(oldOffset));
    expect(_paintedCanvasRect(boundaryKey).top, lessThan(oldCanvasRect.top));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final uiScale in [0.85, 1.4, 2.0]) {
    for (final kind in [PointerDeviceKind.touch, PointerDeviceKind.mouse]) {
      testWidgets(
        'thumb panning paints both axes at UI scale $uiScale ($kind)',
        (tester) async {
          _setDeviceViewport(tester, const Size(1200, 800));
          final boundaryKey = GlobalKey();
          var selected = 0;
          await tester.pumpWidget(
            _scaledApp(
              _workspace(
                toolbar: const Text('Controls'),
                document: _document(),
                boundaryKey: boundaryKey,
                onSelectLayer: (_) => selected++,
              ),
              uiScale,
            ),
          );
          await tester.pumpAndSettle();
          await _setZoom(tester, 2.5);
          final viewport = find.byKey(_canvasViewportKey);
          final viewportRect = _renderedRect(tester, viewport);
          final bars = tester.widgetList<Scrollbar>(
            find.descendant(of: viewport, matching: find.byType(Scrollbar)),
          );
          for (final orientation in [
            ScrollbarOrientation.bottom,
            ScrollbarOrientation.right,
          ]) {
            final bar = bars.singleWhere(
              (bar) => bar.scrollbarOrientation == orientation,
            );
            final oldOffset = bar.controller!.offset;
            final oldImageRect = _paintedCanvasRect(boundaryKey);
            final thumb = _thumbCenter(
              tester,
              _scrollbarPaint(viewport, orientation),
              orientation,
              kind,
            );
            final horizontal = orientation == ScrollbarOrientation.bottom;
            final gesture = await tester.startGesture(thumb, kind: kind);
            await gesture.moveBy(
              horizontal
                  ? Offset(viewportRect.width * 0.18, 0)
                  : Offset(0, viewportRect.height * 0.18),
            );
            await tester.pump();
            final newOffset = bar.controller!.offset;
            final newImageRect = _paintedCanvasRect(boundaryKey);
            expect(newOffset, greaterThan(oldOffset));
            final expectedShift = -(newOffset - oldOffset) * uiScale;
            expect(
              horizontal
                  ? newImageRect.left - oldImageRect.left
                  : newImageRect.top - oldImageRect.top,
              closeTo(expectedShift, 0.01),
              reason:
                  'Thumb movement must repaint the actual canvas this frame',
            );
            expect(
              horizontal
                  ? newImageRect.top - oldImageRect.top
                  : newImageRect.left - oldImageRect.left,
              closeTo(0, 0.01),
            );
            await gesture.up();
            await tester.pumpAndSettle();
          }
          expect(selected, 0, reason: 'Thumb dragging must not select a layer');
          final center = viewportRect.center;
          final boundary =
              boundaryKey.currentContext!.findRenderObject()! as RenderBox;
          final visiblePoint = boundary.globalToLocal(center);
          tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.8);
          await tester.pump();
          expect(
            (boundary.localToGlobal(visiblePoint) - center).distance,
            lessThan(0.01),
          );
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('toolbar thumb pans content at UI scale $uiScale ($kind)', (
        tester,
      ) async {
        _setDeviceViewport(tester, const Size(1200, 800));
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          _scaledApp(
            _workspace(
              toolbar: Column(
                children: [
                  for (var i = 0; i < 30; i++)
                    SizedBox(height: 48, child: Text('Control $i')),
                ],
              ),
              document: _document(),
              boundaryKey: boundaryKey,
            ),
            uiScale,
          ),
        );
        await tester.pumpAndSettle();
        final viewport = find.byKey(_toolbarViewportKey);
        final rect = _renderedRect(tester, viewport);
        final scrollbar = tester.widget<Scrollbar>(
          find.byKey(const ValueKey('previewToolbarScrollbar')),
        );
        final oldOffset = scrollbar.controller!.offset;
        final oldControlRect = _renderedRect(tester, find.text('Control 0'));
        final oldCanvasRect = _paintedCanvasRect(boundaryKey);
        final thumb = _thumbCenter(
          tester,
          _scrollbarPaint(viewport, ScrollbarOrientation.right),
          ScrollbarOrientation.right,
          kind,
        );
        final gesture = await tester.startGesture(thumb, kind: kind);
        await gesture.moveBy(Offset(0, rect.height * 0.35));
        await tester.pump();
        final newOffset = scrollbar.controller!.offset;
        expect(newOffset, greaterThan(oldOffset));
        expect(
          _renderedRect(tester, find.text('Control 0')).top -
              oldControlRect.top,
          closeTo(-(newOffset - oldOffset) * uiScale, 0.01),
        );
        expect(_paintedCanvasRect(boundaryKey), oldCanvasRect);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('padded touch thumb dragging does not move underlying text', (
    tester,
  ) async {
    _setDeviceViewport(tester, const Size(1200, 800));
    final document = _document();
    document.layers.add(
      PreviewLayer(
        id: 'text',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0, 0, 1, 1),
        text: 'Canvas text',
      ),
    );
    var selected = 0;
    var moved = 0;
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      _scaledApp(
        _workspace(
          toolbar: const Text('Controls'),
          document: document,
          boundaryKey: boundaryKey,
          selectedLayerId: 'text',
          onSelectLayer: (_) => selected++,
          onLayerMoved: (_, _) => moved++,
        ),
        1.4,
      ),
    );
    await tester.pumpAndSettle();
    await _setZoom(tester, 3);
    final viewport = find.byKey(_canvasViewportKey);
    for (final orientation in [
      ScrollbarOrientation.bottom,
      ScrollbarOrientation.right,
    ]) {
      var thumb = _thumbCenter(
        tester,
        _scrollbarPaint(viewport, orientation),
        orientation,
        PointerDeviceKind.touch,
      );
      thumb -= orientation == ScrollbarOrientation.bottom
          ? const Offset(0, 12)
          : const Offset(12, 0);
      final oldRect = _paintedCanvasRect(boundaryKey);
      final gesture = await tester.startGesture(thumb);
      await gesture.moveBy(
        orientation == ScrollbarOrientation.bottom
            ? const Offset(60, 0)
            : const Offset(0, 60),
      );
      await tester.pump();
      final newRect = _paintedCanvasRect(boundaryKey);
      expect(
        orientation == ScrollbarOrientation.bottom ? newRect.left : newRect.top,
        lessThan(
          orientation == ScrollbarOrientation.bottom
              ? oldRect.left
              : oldRect.top,
        ),
      );
      await gesture.up();
      await tester.pumpAndSettle();
    }
    expect(
      selected,
      0,
      reason: 'A scrollbar drag must not select underlying text',
    );
    expect(moved, 0, reason: 'A scrollbar drag must not move underlying text');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'thumbs remain usable after selection, toolbar growth and resize',
    (tester) async {
      _setDeviceViewport(tester, const Size(1200, 800));
      final boundaryKey = GlobalKey();
      final document = _document();
      late StateSetter rebuild;
      var controlCount = 3;
      String? selected;
      await tester.pumpWidget(
        _scaledApp(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return _workspace(
                toolbar: Column(
                  children: [
                    for (var i = 0; i < controlCount; i++)
                      SizedBox(height: 48, child: Text('Control $i')),
                  ],
                ),
                document: document,
                boundaryKey: boundaryKey,
                selectedLayerId: selected,
              );
            },
          ),
          1.4,
        ),
      );
      await tester.pumpAndSettle();
      await _setZoom(tester, 2);
      final initialImageRect = _paintedCanvasRect(boundaryKey);
      rebuild(() {
        controlCount = 30;
        selected = 'edge';
      });
      await tester.pumpAndSettle();
      expect(_paintedCanvasRect(boundaryKey), initialImageRect);
      await tester.drag(
        find.byKey(const ValueKey('previewToolbarResizeHandle')),
        const Offset(0, -60),
      );
      await tester.pumpAndSettle();
      final viewport = find.byKey(_canvasViewportKey);
      for (final orientation in [
        ScrollbarOrientation.bottom,
        ScrollbarOrientation.right,
      ]) {
        final scrollbar = tester
            .widgetList<Scrollbar>(
              find.descendant(of: viewport, matching: find.byType(Scrollbar)),
            )
            .singleWhere((bar) => bar.scrollbarOrientation == orientation);
        final oldOffset = scrollbar.controller!.offset;
        final oldRect = _paintedCanvasRect(boundaryKey);
        final thumb = _thumbCenter(
          tester,
          _scrollbarPaint(viewport, orientation),
          orientation,
          PointerDeviceKind.touch,
        );
        final horizontal = orientation == ScrollbarOrientation.bottom;
        final gesture = await tester.startGesture(thumb);
        await gesture.moveBy(
          horizontal ? const Offset(60, 0) : const Offset(0, 60),
        );
        await tester.pump();
        final newRect = _paintedCanvasRect(boundaryKey);
        expect(scrollbar.controller!.offset, greaterThan(oldOffset));
        expect(
          horizontal ? newRect.left : newRect.top,
          lessThan(horizontal ? oldRect.left : oldRect.top),
        );
        await gesture.up();
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every zoom frame paints with its center already anchored', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final boundaryKey = GlobalKey();
    final paintedCenters = <Offset>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _workspace(
            toolbar: const Text('Controls'),
            document: _document(),
            boundaryKey: boundaryKey,
            onCanvasPaint: () {
              paintedCenters.add(_paintedCanvasRect(boundaryKey).center);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final center = tester.getCenter(find.byKey(_canvasViewportKey));
    for (final zoom in [1.1, 1.4, 2.4, 1.8, 0.8, 0.5, 1.0, 3.0]) {
      paintedCenters.clear();
      tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(zoom);
      await tester.pump();
      expect(paintedCenters, isNotEmpty, reason: 'Zoom $zoom must paint');
      for (final paintedCenter in paintedCenters) {
        expect(
          (paintedCenter - center).distance,
          lessThan(0.01),
          reason: 'Zoom $zoom must anchor before its first paint',
        );
      }
      await tester.pump();
      expect(
        (_paintedCanvasRect(boundaryKey).center - center).distance,
        lessThan(0.01),
      );
      expect(tester.takeException(), isNull);
    }
    // Multiple input updates before one frame must use the same view anchor.
    final slider = tester.widget<Slider>(find.byKey(_zoomSliderKey));
    paintedCenters.clear();
    for (final zoom in [2.7, 2.2, 1.6]) {
      slider.onChanged!(zoom);
    }
    await tester.pump();
    expect(paintedCenters, isNotEmpty);
    expect(
      paintedCenters.every((point) => (point - center).distance < 0.01),
      isTrue,
    );
    paintedCenters.clear();
    await tester.tap(find.byKey(const ValueKey('previewCanvasFitButton')));
    await tester.pump();
    expect(paintedCenters, isNotEmpty);
    expect(
      paintedCenters.every((point) => (point - center).distance < 0.01),
      isTrue,
    );
    expect(tester.takeException(), isNull);

    paintedCenters.clear();
    await tester.binding.setSurfaceSize(const Size(1000, 650));
    tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.2);
    await tester.pump();
    final resizedCenter = tester.getCenter(find.byKey(_canvasViewportKey));
    expect(paintedCenters, isNotEmpty);
    expect(
      paintedCenters.every((point) => (point - resizedCenter).distance < 0.01),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'zooming a panned view preserves its visible point on first paint',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      Offset? documentPoint;
      final paintedPoints = <Offset>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _workspace(
              toolbar: const Text('Controls'),
              document: _document(),
              boundaryKey: boundaryKey,
              onCanvasPaint: () {
                if (documentPoint == null) return;
                final box =
                    boundaryKey.currentContext!.findRenderObject()!
                        as RenderBox;
                paintedPoints.add(box.localToGlobal(documentPoint));
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
      for (final scrollbar in scrollbars) {
        final controller = scrollbar.controller!;
        controller.jumpTo(controller.position.maxScrollExtent * 0.6);
      }
      await tester.pumpAndSettle();
      final center = tester.getCenter(find.byKey(_canvasViewportKey));
      final box = boundaryKey.currentContext!.findRenderObject()! as RenderBox;
      documentPoint = box.globalToLocal(center);
      for (final zoom in [2.3, 2.7, 2.4, 1.8]) {
        paintedPoints.clear();
        tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(zoom);
        await tester.pump();
        expect(paintedPoints, isNotEmpty);
        for (final point in paintedPoints) {
          expect((point - center).distance, lessThan(0.01));
        }
        await tester.pump();
        expect(
          (box.localToGlobal(documentPoint) - center).distance,
          lessThan(0.01),
        );
        expect(tester.takeException(), isNull);
      }

      // Fit followed by another zoom in one frame must discard the panned anchor.
      documentPoint = kPreviewCanvasSize.center(Offset.zero);
      paintedPoints.clear();
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('previewCanvasFitButton')),
          )
          .onPressed!();
      tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.5);
      await tester.pump();
      expect(paintedPoints, isNotEmpty);
      expect(
        paintedPoints.every((point) => (point - center).distance < 0.01),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

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

    final horizontalPainter = find.descendant(
      of: find.byKey(_canvasViewportKey),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint &&
            widget.foregroundPainter is ScrollbarPainter &&
            (widget.foregroundPainter! as ScrollbarPainter)
                    .scrollbarOrientation ==
                ScrollbarOrientation.bottom,
      ),
    );
    final thumbPainter =
        tester.widget<CustomPaint>(horizontalPainter).foregroundPainter!
            as ScrollbarPainter;
    final thumbBox = tester.renderObject<RenderBox>(horizontalPainter);
    expect(
      thumbPainter.hitTestOnlyThumbInteractive(
        thumbBox.globalToLocal(Offset(viewport.center.dx, viewport.bottom - 3)),
        PointerDeviceKind.touch,
      ),
      isTrue,
      reason:
          'The centered zoom must update the draggable thumb before panning',
    );

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
