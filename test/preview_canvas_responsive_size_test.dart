import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Rect _visibleRect(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
}

PreviewDocument _document({bool withEdgeLayer = false}) => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    assetPath: 'assets/meta/icon.png',
  ),
  layers: [
    if (withEdgeLayer)
      PreviewLayer(
        id: 'edge',
        kind: PreviewLayerKind.shape,
        bounds: const Rect.fromLTWH(0, 0, 1, 1),
        shapeKind: PreviewShapeKind.rect,
      ),
  ],
);

void main() {
  for (final scenario in [
    (size: const Size(2000, 800), axis: Axis.vertical, minimumFraction: 0.75),
    (size: const Size(1200, 300), axis: Axis.vertical, minimumFraction: 0.75),
    (size: const Size(900, 1000), axis: Axis.horizontal, minimumFraction: 0.85),
  ]) {
    testWidgets('canvas fills available ${scenario.size} editing area', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = scenario.size;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreviewCanvas(
              document: _document(),
              interactive: true,
              boundaryKey: boundaryKey,
            ),
          ),
        ),
      );
      final imageRect = _visibleRect(tester, find.byKey(boundaryKey));
      final visibleLength = scenario.axis == Axis.vertical
          ? imageRect.height
          : imageRect.width;
      final availableLength = scenario.axis == Axis.vertical
          ? scenario.size.height
          : scenario.size.width;
      expect(
        visibleLength,
        greaterThanOrEqualTo(availableLength * scenario.minimumFraction),
      );
      expect(
        imageRect.width / imageRect.height,
        closeTo(kPreviewCanvasSize.aspectRatio, 0.001),
      );
      expect(imageRect.left, greaterThanOrEqualTo(0));
      expect(imageRect.top, greaterThanOrEqualTo(0));
      expect(imageRect.right, lessThanOrEqualTo(scenario.size.width));
      expect(imageRect.bottom, lessThanOrEqualTo(scenario.size.height));
      expect(tester.getSize(find.byKey(boundaryKey)), kPreviewCanvasSize);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('resizing the window automatically enlarges the same canvas', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreviewCanvas(
            document: _document(),
            interactive: true,
            boundaryKey: boundaryKey,
          ),
        ),
      ),
    );
    final originalRect = _visibleRect(tester, find.byKey(boundaryKey));
    tester.view.physicalSize = const Size(1600, 600);
    await tester.pump();
    final enlargedRect = _visibleRect(tester, find.byKey(boundaryKey));
    expect(enlargedRect.width, greaterThan(originalRect.width));
    expect(enlargedRect.height, greaterThan(originalRect.height));
    expect(tester.getSize(find.byKey(boundaryKey)), kPreviewCanvasSize);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rotation handle stays hittable above a full-canvas layer', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    double? rotation;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PreviewCanvas(
            document: _document(withEdgeLayer: true),
            interactive: true,
            selectedLayerId: 'edge',
            onLayerRotated: (_, value) => rotation = value,
          ),
        ),
      ),
    );
    final handle = find.byIcon(Icons.rotate_right);
    final handleRect = _visibleRect(tester, handle);
    expect(handleRect.top, greaterThanOrEqualTo(0));
    await tester.drag(handle, const Offset(30, 12));
    expect(rotation, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'non-editable canvas uses the full viewport without handle margins',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1144, 439);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PreviewCanvas(
              document: _document(),
              boundaryKey: boundaryKey,
            ),
          ),
        ),
      );
      expect(
        _visibleRect(tester, find.byKey(boundaryKey)).size,
        kPreviewCanvasSize,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
