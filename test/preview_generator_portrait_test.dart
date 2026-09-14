import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_toolbar_action.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_toolbar_prefs.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => fallback ?? key;
}

const _toolbarViewportKey = ValueKey('previewToolbarViewport');
const _canvasViewportKey = ValueKey('previewCanvasViewport');
const _zoomSliderKey = ValueKey('previewCanvasZoomSlider');
const _textFieldKey = ValueKey('previewTextContentField');

PreviewCanvas _canvas(WidgetTester tester) =>
    tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));

Future<void> _open(
  WidgetTester tester, {
  required double width,
  required PreviewToolbarStyle style,
  TargetPlatform platform = TargetPlatform.android,
  Future<PreviewExportResult> Function(ui.Image, String)? exporter,
}) async {
  SharedPreferences.setMockInitialValues({
    kPreviewToolbarStylePrefsKey: style.name,
  });
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: PreviewGeneratorScreen(
        host: _Host(),
        levelFile: PvzLevelFile(objects: []),
        parsed: ParsedLevelData(objectMap: {}),
        fileName: 'portrait.json',
        imageExporter: exporter,
      ),
    ),
  );
  for (
    var attempt = 0;
    attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
    attempt++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(find.byType(PreviewCanvas), findsOneWidget);
  await tester.pumpAndSettle();
  expect(find.text('previewGenDisplayTooNarrowTitle'), findsNothing);
  expect(tester.takeException(), isNull);
}

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void _expectWorkspaceFits(WidgetTester tester, double width, double height) {
  final toolbar = tester.getRect(find.byKey(_toolbarViewportKey));
  final canvas = tester.getRect(find.byKey(_canvasViewportKey));
  for (final rect in [toolbar, canvas]) {
    expect(rect.width, greaterThan(0));
    expect(rect.height, greaterThan(0));
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(width));
    expect(rect.top, greaterThanOrEqualTo(0));
    expect(rect.bottom, lessThanOrEqualTo(height));
  }
  expect(canvas.top, greaterThanOrEqualTo(toolbar.bottom));
  expect(
    tester.getSize(find.byKey(_canvas(tester).boundaryKey!)),
    kPreviewCanvasSize,
  );
  expect(tester.takeException(), isNull);
}

Future<void> _waitForExports(
  WidgetTester tester,
  bool Function() complete,
) async {
  await tester.pump(const Duration(milliseconds: 100));
  for (var attempt = 0; attempt < 200 && !complete(); attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(complete(), isTrue);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // Asset Futures from a previous FakeAsync zone must not be reused.
    rootBundle.clear();
  });

  for (final width in [360.0, 390.0, 430.0]) {
    for (final style in PreviewToolbarStyle.values) {
      testWidgets(
        '$width dp portrait keeps $style controls and keyboard editing usable',
        (tester) async {
          await _open(
            tester,
            width: width,
            style: style,
            platform: width == 390
                ? TargetPlatform.iOS
                : TargetPlatform.android,
          );
          final initialLayers = _canvas(tester).document.layers.length;
          final select = find.byKey(
            const ValueKey('previewToolbarTool-select'),
          );
          expect(
            tester.widget<PreviewToolbarAction>(select).compact,
            style == PreviewToolbarStyle.compact,
          );
          _expectWorkspaceFits(tester, width, 844);

          // Exercise both wrapped controls and the compact horizontal rows.
          for (final key in [
            'previewToolbarTool-select',
            'previewToolbarTool-pen',
            'previewToolbarTool-eraser',
            'previewToolbarAction-previewGenAddImage',
            'previewToolbarAction-previewTool_figures',
            'previewToolbarAction-previewGenChooseBanner',
            'previewToolbarAction-previewGenModuleInfo',
            'previewToolbarAction-previewGenRecreate',
          ]) {
            await _reveal(tester, find.byKey(ValueKey(key)));
          }
          await _tap(
            tester,
            find.byKey(
              const ValueKey('previewToolbarAction-previewGenAddText'),
            ),
          );
          expect(_canvas(tester).document.layers.length, initialLayers + 1);
          final textId = _canvas(tester).selectedLayerId!;
          final field = find.byKey(_textFieldKey);
          await _reveal(tester, field);
          expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
          expect(_canvas(tester).editingTextLayerId, isNull);

          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await tester.pumpAndSettle();
          const text = 'Portrait text editing';
          tester.testTextInput.updateEditingValue(
            const TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: 21),
              composing: TextRange(start: 14, end: 21),
            ),
          );
          await tester.pumpAndSettle();
          expect(field.hitTestable(), findsOneWidget);
          expect(tester.getRect(field).bottom, lessThanOrEqualTo(544));
          expect(_canvas(tester).document.layerById(textId)!.plainText, text);
          _expectWorkspaceFits(tester, width, 544);
          await _reveal(
            tester,
            find.byKey(const ValueKey('previewTextFontPicker')),
          );
          _expectWorkspaceFits(tester, width, 544);

          tester.view.viewInsets = const FakeViewPadding();
          await tester.pumpAndSettle();
          await _tap(tester, select);
          await _tap(
            tester,
            find.byKey(
              const ValueKey('previewToolbarAction-previewTool_layers'),
            ),
          );
          final layers = find.byKey(const ValueKey('previewLayersDialog'));
          expect(layers, findsOneWidget);
          expect(tester.getRect(layers).width, lessThanOrEqualTo(width));
          expect(
            find.byKey(ValueKey('previewLayerOption-$textId')),
            findsOneWidget,
          );
          await _tap(tester, find.byKey(const ValueKey('previewLayersClose')));
          expect(layers, findsNothing);
          await _reveal(tester, find.byTooltip('Export image'));
          await _reveal(
            tester,
            find.byKey(const ValueKey('previewGeneratorBackButton')),
          );
          _expectWorkspaceFits(tester, width, 844);
        },
      );
    }
  }

  testWidgets(
    '390 dp iOS portrait allows touch dragging and resizing a zoomed layer',
    (tester) async {
      await _open(
        tester,
        width: 390,
        style: PreviewToolbarStyle.compact,
        platform: TargetPlatform.iOS,
      );
      final document = _canvas(tester).document;
      final shape = PreviewLayer(
        id: 'portrait-touch-shape',
        kind: PreviewLayerKind.shape,
        bounds: const Rect.fromLTWH(.41, .32, .18, .36),
        shapeKind: PreviewShapeKind.rect,
        shapeFilled: true,
        fillColor: Colors.orange,
      );
      document.addLayer(shape);
      _canvas(tester).onSelectLayer!(shape.id);
      await tester.pumpAndSettle();
      tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.5);
      await tester.pumpAndSettle();
      final scrollControllers = tester
          .widgetList<Scrollbar>(
            find.descendant(
              of: find.byKey(_canvasViewportKey),
              matching: find.byType(Scrollbar),
            ),
          )
          .map((bar) => bar.controller!)
          .toList();
      final scrollOffsets = [
        for (final controller in scrollControllers) controller.offset,
      ];
      final viewport = tester.getRect(find.byKey(_canvasViewportKey));
      final body = find.byKey(
        const ValueKey('preview-layer-gesture-portrait-touch-shape'),
      );
      final start = tester.getCenter(body);
      expect(body.hitTestable(), findsOneWidget);
      expect(viewport.contains(start), isTrue);
      final originalBounds = shape.bounds;
      final move = await tester.startGesture(
        start,
        kind: ui.PointerDeviceKind.touch,
      );
      await move.moveBy(const Offset(20, 10));
      await tester.pump(const Duration(milliseconds: 16));
      await move.moveBy(const Offset(20, 10));
      await tester.pump(const Duration(milliseconds: 16));
      await move.up();
      await tester.pumpAndSettle();
      expect(shape.bounds.left, greaterThan(originalBounds.left));
      expect(shape.bounds.top, greaterThan(originalBounds.top));
      expect(shape.bounds.width, closeTo(originalBounds.width, 1e-9));
      expect(shape.bounds.height, closeTo(originalBounds.height, 1e-9));
      expect(_canvas(tester).selectedLayerId, shape.id);

      // The resize handle is centered on the design-space bottom-right corner.
      // Convert that corner through the real fit and zoom transforms, then
      // exercise its touch hit area rather than invoking an editing callback.
      final boundary = tester.renderObject<RenderBox>(
        find.byKey(_canvas(tester).boundaryKey!),
      );
      final handle = boundary.localToGlobal(
        Offset(
          shape.bounds.right * kPreviewCanvasSize.width,
          shape.bounds.bottom * kPreviewCanvasSize.height,
        ),
      );
      expect(viewport.contains(handle), isTrue);
      final movedBounds = shape.bounds;
      final resize = await tester.startGesture(
        handle,
        kind: ui.PointerDeviceKind.touch,
      );
      await resize.moveBy(const Offset(16, 12));
      await tester.pump(const Duration(milliseconds: 16));
      await resize.moveBy(const Offset(16, 12));
      await tester.pump(const Duration(milliseconds: 16));
      await resize.up();
      await tester.pumpAndSettle();
      expect(shape.bounds.width, greaterThan(movedBounds.width));
      expect(shape.bounds.height, greaterThan(movedBounds.height));
      expect(shape.bounds.topLeft, movedBounds.topLeft);
      expect(shape.scale, 1);
      expect(
        [for (final controller in scrollControllers) controller.offset],
        scrollOffsets,
        reason: 'Layer gestures must not pan the surrounding zoomed view',
      );
      expect(tester.widget<Slider>(find.byKey(_zoomSliderKey)).value, 2.5);
      _expectWorkspaceFits(tester, 390, 844);
    },
  );

  testWidgets(
    'iOS portrait edits survive rotation and zoomed panned export stays identical',
    (tester) async {
      final exports = <Uint8List>[];
      await _open(
        tester,
        width: 390,
        style: PreviewToolbarStyle.compact,
        platform: TargetPlatform.iOS,
        exporter: (image, name) async {
          expect(name, 'portrait.json');
          expect(image.width, (kPreviewCanvasSize.width * 2).round());
          expect(image.height, (kPreviewCanvasSize.height * 2).round());
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          exports.add(
            Uint8List.fromList(
              bytes.buffer.asUint8List(
                bytes.offsetInBytes,
                bytes.lengthInBytes,
              ),
            ),
          );
          return PreviewExportResult(
            path: 'previews/portrait.png',
            bytes: Uint8List(0),
          );
        },
      );
      final state = tester.state(find.byType(PreviewGeneratorScreen));
      final document = _canvas(tester).document;
      await _tap(
        tester,
        find.byKey(const ValueKey('previewToolbarAction-previewGenAddText')),
      );
      final textId = _canvas(tester).selectedLayerId!;
      await _reveal(tester, find.byKey(_textFieldKey));
      await tester.enterText(find.byKey(_textFieldKey), 'Rotate and retain');
      await tester.pumpAndSettle();
      await _tap(
        tester,
        find.byKey(const ValueKey('previewToolbarTool-select')),
      );
      final editedLayer = document.layerById(textId)!;
      final editedBounds = editedLayer.bounds;
      final editedScale = editedLayer.scale;
      // An edge layer makes accidental capture of only the visible area evident.
      document.addLayer(
        PreviewLayer(
          id: 'portrait-export-edge',
          kind: PreviewLayerKind.shape,
          bounds: const Rect.fromLTWH(.82, .72, .15, .20),
          shapeKind: PreviewShapeKind.rect,
          shapeFilled: true,
          fillColor: Colors.orange,
          strokeWidth: 0,
        ),
      );
      _canvas(tester).onSelectLayer!(null);
      await tester.pumpAndSettle();
      // Decode the banner before either reference capture so timing cannot
      // change the exported content between the two views.
      final asset =
          document.banner.assetPath ??
          'lib/bundled_plugins/preview_img_cplugin/assets/banners/Unknown.png';
      await tester.runAsync(
        () => precacheImage(
          AssetImage(asset),
          tester.element(find.byType(PreviewCanvas)),
        ),
      );
      await tester.pumpAndSettle();
      await _reveal(tester, find.byTooltip('Export image'));
      await tester.tap(find.byTooltip('Export image'));
      await _waitForExports(tester, () => exports.length == 1);

      tester.widget<Slider>(find.byKey(_zoomSliderKey)).onChanged!(2.5);
      await tester.pumpAndSettle();
      for (final bar in tester.widgetList<Scrollbar>(
        find.descendant(
          of: find.byKey(_canvasViewportKey),
          matching: find.byType(Scrollbar),
        ),
      )) {
        final controller = bar.controller!;
        controller.jumpTo(controller.position.maxScrollExtent * .75);
      }
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(844, 390);
      await tester.pumpAndSettle();
      _expectWorkspaceFits(tester, 844, 390);
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(PreviewGeneratorScreen)), same(state));
      expect(_canvas(tester).document, same(document));
      expect(document.layerById(textId), same(editedLayer));
      expect(editedLayer.plainText, 'Rotate and retain');
      expect(editedLayer.bounds, editedBounds);
      expect(editedLayer.scale, editedScale);
      expect(tester.widget<Slider>(find.byKey(_zoomSliderKey)).value, 2.5);
      _expectWorkspaceFits(tester, 390, 844);

      await _reveal(tester, find.byTooltip('Export image'));
      await tester.tap(find.byTooltip('Export image'));
      await _waitForExports(tester, () => exports.length == 2);
      expect(
        listEquals(exports[0], exports[1]),
        isTrue,
        reason:
            'View zoom, panning and rotation must preserve every export pixel',
      );
      expect(editedLayer.bounds, editedBounds);
      expect(editedLayer.scale, editedScale);
      expect(tester.takeException(), isNull);
    },
  );
}
