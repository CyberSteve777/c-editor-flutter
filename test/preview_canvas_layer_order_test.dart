import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

PreviewDocument _document() => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    assetPath: 'missing-preview-test-background.png',
  ),
  layers: [
    for (final entry in [('red', Colors.red, 1), ('blue', Colors.blue, 2)])
      PreviewLayer(
        id: entry.$1,
        kind: PreviewLayerKind.shape,
        bounds: const Rect.fromLTWH(0.1, 0.1, 0.7, 0.7),
        shapeKind: PreviewShapeKind.rect,
        shapeFilled: true,
        fillColor: entry.$2,
        strokeWidth: 0,
        zIndex: entry.$3,
      ),
  ],
);

Future<Color> _centerPixel(WidgetTester tester, GlobalKey boundaryKey) async {
  final boundary =
      boundaryKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
  try {
    final bytes = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final offset = ((image!.height ~/ 2) * image.width + image.width ~/ 2) * 4;
    return Color.fromARGB(
      bytes!.getUint8(offset + 3),
      bytes.getUint8(offset),
      bytes.getUint8(offset + 1),
      bytes.getUint8(offset + 2),
    );
  } finally {
    image!.dispose();
  }
}

void main() {
  for (final interactive in [false, true]) {
    testWidgets(
      'editing=$interactive and the export boundary share the complete render order',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1400, 900);
        addTearDown(tester.view.reset);
        final doc = _document();
        final boundaryKey = GlobalKey();
        late StateSetter rebuild;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return PreviewCanvas(
                    document: doc,
                    interactive: interactive,
                    boundaryKey: boundaryKey,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          (await _centerPixel(tester, boundaryKey)).toARGB32(),
          Colors.blue.toARGB32(),
        );
        rebuild(() => doc.moveLayer('red', PreviewLayerOrderAction.toFront));
        await tester.pumpAndSettle();
        expect(
          (await _centerPixel(tester, boundaryKey)).toARGB32(),
          Colors.red.toARGB32(),
        );
        rebuild(
          () => doc.moveLayer(
            kPreviewBackgroundLayerId,
            PreviewLayerOrderAction.toFront,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          await _centerPixel(tester, boundaryKey),
          const Color(0xFF0B2A33),
        );
        rebuild(
          () => doc.moveLayer(
            kPreviewBackgroundLayerId,
            PreviewLayerOrderAction.toBack,
          ),
        );
        await tester.pumpAndSettle();
        expect(
          (await _centerPixel(tester, boundaryKey)).toARGB32(),
          Colors.red.toARGB32(),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'hit testing follows the top layer and preserves blank-area deselection',
    (tester) async {
      final doc = _document();
      final boundaryKey = GlobalKey();
      late StateSetter rebuild;
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return PreviewCanvas(
                  document: doc,
                  interactive: true,
                  boundaryKey: boundaryKey,
                  onSelectLayer: (id) => selected = id,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderBox>(find.byKey(boundaryKey));
      final center = boundary.localToGlobal(boundary.size.center(Offset.zero));
      await tester.tapAt(center);
      expect(selected, 'blue');
      rebuild(() => doc.moveLayer('red', PreviewLayerOrderAction.toFront));
      await tester.pumpAndSettle();
      await tester.tapAt(center);
      expect(selected, 'red');
      await tester.tapAt(
        boundary.localToGlobal(
          Offset(boundary.size.width * .97, boundary.size.height * .97),
        ),
      );
      expect(selected, isNull);
      rebuild(
        () => doc.moveLayer(
          kPreviewBackgroundLayerId,
          PreviewLayerOrderAction.toFront,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(center);
      expect(
        selected,
        isNull,
        reason: 'An opaque front background must not select obscured layers.',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
