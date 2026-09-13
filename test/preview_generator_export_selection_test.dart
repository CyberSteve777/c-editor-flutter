import 'dart:ui' as ui;
import 'dart:io';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as gif;

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => fallback ?? key;
}

PreviewCanvas _canvas(WidgetTester tester) =>
    tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));

RenderRepaintBoundary _boundary(WidgetTester tester) =>
    _canvas(tester).boundaryKey!.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;

Uint8List _bytes(ByteData data) => Uint8List.fromList(
  data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
);

String _pixelDifference(Uint8List actual, Uint8List expected) {
  if (actual.length != expected.length) {
    return 'Byte lengths: ${actual.length} / ${expected.length}';
  }
  final width = (kPreviewCanvasSize.width * 2).round();
  var changed = 0;
  var minX = width;
  var maxX = -1;
  var minY = expected.length;
  var maxY = -1;
  String? first;
  for (var i = 0; i < actual.length; i += 4) {
    if (actual[i] == expected[i] &&
        actual[i + 1] == expected[i + 1] &&
        actual[i + 2] == expected[i + 2] &&
        actual[i + 3] == expected[i + 3]) {
      continue;
    }
    final x = (i ~/ 4) % width;
    final y = (i ~/ 4) ~/ width;
    changed++;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
    first ??=
        '($x,$y) ${actual.sublist(i, i + 4)} / ${expected.sublist(i, i + 4)}';
  }
  return '$changed pixels differ in ($minX,$minY)–($maxX,$maxY); first $first';
}

Future<Uint8List> _pixels(WidgetTester tester) async {
  final image = await tester.runAsync(
    () => _boundary(tester).toImage(pixelRatio: 2),
  );
  try {
    final data = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    return _bytes(data!);
  } finally {
    image!.dispose();
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 200 && finder.evaluate().isEmpty; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(finder, findsOneWidget);
  await tester.pumpAndSettle();
}

Future<void> _open(
  WidgetTester tester,
  Future<PreviewExportResult> Function(ui.Image image, String name) exporter,
) async {
  SharedPreferences.setMockInitialValues({});
  rootBundle.clear();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1400, 1100);
  addTearDown(tester.view.reset);
  final bank = PvzObject(
    aliases: const ['SeedBank'],
    objClass: 'SeedBankProperties',
    objData: {
      'PresetPlantList': ['peashooter'],
    },
  );
  await tester.pumpWidget(
    MaterialApp(
      home: PreviewGeneratorScreen(
        host: _Host(),
        levelFile: PvzLevelFile(objects: [bank]),
        parsed: ParsedLevelData(objectMap: {'SeedBank': bank}),
        fileName: 'selected-stroke.json',
        initialStyle: PreviewAutoStyle.normal,
        imageExporter: exporter,
      ),
    ),
  );
  await _waitFor(tester, find.byType(PreviewCanvas));
  await _waitForCanvasImages(tester);
}

Future<void> _waitForCanvasImages(WidgetTester tester) async {
  // A baseline taken before asset decoding finishes can differ from a later
  // export even when selection painting is correctly omitted.
  final doc = _canvas(tester).document;
  final assets = <String>{
    ?doc.banner.assetPath,
    for (final layer in doc.layers) ...[
      ?layer.imageAsset,
      for (final item in layer.items) item.assetPath,
      for (final section in layer.sections)
        for (final item in section.items) item.assetPath,
    ],
  };
  final context = _canvas(tester).boundaryKey!.currentContext!;
  await tester.runAsync(
    () => Future.wait([
      for (final asset in assets)
        precacheImage(AssetImage(asset), context, onError: (_, _) {}),
    ]),
  );
  await tester.pumpAndSettle();
  final boundaryFinder = find.byKey(_canvas(tester).boundaryKey!);
  bool imagesReady() {
    final rawImages = tester.widgetList<RawImage>(
      find.descendant(of: boundaryFinder, matching: find.byType(RawImage)),
    );
    final unresolvedGif = find.descendant(
      of: boundaryFinder,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is AssetImageWidget &&
            widget.assetPath.toLowerCase().endsWith('.gif'),
      ),
    );
    return rawImages.isNotEmpty &&
        rawImages.every((image) => image.image != null) &&
        unresolvedGif.evaluate().isEmpty &&
        find
            .descendant(
              of: boundaryFinder,
              matching: find.byType(CircularProgressIndicator),
            )
            .evaluate()
            .isEmpty;
  }

  for (var attempt = 0; attempt < 200 && !imagesReady(); attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(
    imagesReady(),
    isTrue,
    reason: 'All canvas image frames must be ready.',
  );
  expect(tester.takeException(), isNull);
}

Future<String> _drawStroke(WidgetTester tester) async {
  await _tap(tester, find.byKey(const ValueKey('previewToolbarTool-pen')));
  final boundary = _boundary(tester);
  final start = boundary.localToGlobal(
    Offset(boundary.size.width * 0.4, boundary.size.height * 0.4),
  );
  final finish = boundary.localToGlobal(
    Offset(boundary.size.width * 0.7, boundary.size.height * 0.6),
  );
  final gesture = await tester.startGesture(start);
  await tester.pump();
  await gesture.moveTo(Offset.lerp(start, finish, 0.5)!);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.moveTo(finish);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.up();
  await tester.pumpAndSettle();
  final stroke = _canvas(tester).document.layers.singleWhere(
    (layer) => layer.kind == PreviewLayerKind.stroke,
  );
  expect(stroke.points.length, greaterThanOrEqualTo(2));

  await _tap(tester, find.byKey(const ValueKey('previewToolbarTool-select')));
  await tester.tapAt(
    boundary.localToGlobal(
      Offset(boundary.size.width * 0.97, boundary.size.height * 0.97),
    ),
  );
  await tester.pumpAndSettle();
  expect(_canvas(tester).selectedLayerId, isNull);
  // Switching back from drawing rebuilds the editable icon wrappers.
  await _waitForCanvasImages(tester);
  return stroke.id;
}

Future<void> _selectStrokeInLayers(WidgetTester tester, String id) async {
  await _tap(
    tester,
    find.byKey(const ValueKey('previewToolbarAction-previewTool_layers')),
  );
  final dialog = find.byKey(const ValueKey('previewLayersDialog'));
  await _waitFor(tester, dialog);
  await _tap(tester, find.byKey(ValueKey('previewLayerOption-$id')));
  await _tap(
    tester,
    find.descendant(of: dialog, matching: find.byType(TextButton)).last,
  );
  expect(_canvas(tester).selectedLayerId, id);
  expect(_canvas(tester).interactive, isTrue);
  await _waitForCanvasImages(tester);
}

Future<void> _finishExport(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  for (var attempt = 0; attempt < 200; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
    if (find.byType(SnackBar).evaluate().isNotEmpty) break;
  }
  await tester.pumpAndSettle();
  expect(find.byType(SnackBar), findsOneWidget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'GIF notice can be cancelled and confirmed PNG contains only the first frame',
    (tester) async {
      var pngExports = 0;
      var sawFrameOverride = false;
      await _open(tester, (image, name) async {
        pngExports++;
        final canvas = _canvas(tester);
        sawFrameOverride = canvas.imageFrameOverrides.isNotEmpty;
        expect(canvas.selectedLayerId, isNull);
        expect(
          tester
              .widget<AbsorbPointer>(
                find.byKey(const ValueKey('previewExportInputBarrier')),
              )
              .absorbing,
          isTrue,
        );
        return PreviewPngExporter.export(image: image, levelFileName: name);
      });
      final temp = await tester.runAsync(
        () => Directory.systemTemp.createTemp('preview_gif_generator_'),
      );
      addTearDown(() async => temp!.delete(recursive: true));
      final file = File('${temp!.path}/sticker.gif');
      final encoder = gif.GifEncoder();
      for (final color in [
        gif.ColorRgb8(255, 0, 0),
        gif.ColorRgb8(0, 0, 255),
      ]) {
        final frame = gif.Image(width: 8, height: 8);
        gif.fill(frame, color: color);
        encoder.addFrame(frame, duration: color.r == 255 ? 7 : 11);
      }
      await tester.runAsync(() async {
        await file.writeAsBytes(encoder.finish()!);
        await LevelRepository.setSavedFolderPath(temp.path);
      });
      final strokeId = await _drawStroke(tester);
      _canvas(tester).document.addLayer(
        PreviewLayer(
          id: 'animated-sticker',
          kind: PreviewLayerKind.image,
          bounds: const Rect.fromLTWH(.25, .25, .1, .1),
          imagePath: file.path,
        ),
      );
      await _selectStrokeInLayers(tester, strokeId);
      final export = find
          .descendant(
            of: find.byType(AppBar),
            matching: find.byType(IconButton),
          )
          .last;
      await tester.tap(export);
      await tester.pumpAndSettle();
      final dialog = find.byKey(const ValueKey('previewGifPngNoticeDialog'));
      expect(dialog, findsOneWidget);
      expect(pngExports, 0);
      await tester.tap(find.byKey(const ValueKey('previewGifPngNoticeCancel')));
      await tester.pumpAndSettle();
      expect(dialog, findsNothing);
      expect(pngExports, 0);
      expect(_canvas(tester).selectedLayerId, strokeId);
      expect(_canvas(tester).imageFrameOverrides, isEmpty);
      expect(
        tester
            .widget<AbsorbPointer>(
              find.byKey(const ValueKey('previewExportInputBarrier')),
            )
            .absorbing,
        isFalse,
      );
      final outputDirectory = Directory('${temp.path}/previews');
      expect(await tester.runAsync(outputDirectory.exists), isFalse);

      await tester.tap(export);
      await tester.pumpAndSettle();
      expect(dialog, findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('previewGifPngNoticeExport')));
      await _finishExport(tester);
      final output = File('${outputDirectory.path}/selected-stroke.png');
      final bytes = await tester.runAsync(output.readAsBytes);
      final preview = gif.decodePng(bytes!);
      expect(preview, isNotNull);
      expect(preview!.numFrames, 1);
      expect(preview.width, (kPreviewCanvasSize.width * 2).round());
      expect(preview.height, (kPreviewCanvasSize.height * 2).round());
      final x = (preview.width * .3).round();
      final y = (preview.height * .3).round();
      final first = preview.getPixel(x, y);
      expect(first.r, greaterThan(220));
      expect(first.b, lessThan(35));
      final exportedFiles = await tester.runAsync(
        () => outputDirectory
            .list()
            .map((entry) => entry.uri.pathSegments.last)
            .toList(),
      );
      expect(exportedFiles, ['selected-stroke.png']);
      expect(sawFrameOverride, isTrue);
      expect(pngExports, 1);
      expect(_canvas(tester).imageFrameOverrides, isEmpty);
      expect(_canvas(tester).selectedLayerId, strokeId);
      expect(
        tester
            .widget<AbsorbPointer>(
              find.byKey(const ValueKey('previewExportInputBarrier')),
            )
            .absorbing,
        isFalse,
      );
      expect(tester.takeException(), isNull);
      // Remove the custom file GIF before deleting its test-only directory.
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final succeeds in [true, false]) {
    testWidgets(
      '${succeeds ? 'successful' : 'failed'} export omits selected stroke paint and restores selection',
      (tester) async {
        late Uint8List cleanPixels;
        late String strokeId;
        PreviewCanvas? exportingCanvas;
        bool? canvasInputBlocked;
        Uint8List? exportedPixels;
        String? exportedName;
        var exports = 0;
        await _open(tester, (image, name) async {
          exports++;
          exportedName = name;
          exportingCanvas = _canvas(tester);
          canvasInputBlocked = tester
              .widget<AbsorbPointer>(
                find.byKey(const ValueKey('previewExportInputBarrier')),
              )
              .absorbing;
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (data != null) exportedPixels = _bytes(data);
          if (!succeeds) throw StateError('Injected export failure');
          return PreviewExportResult(
            path: 'previews/selected-stroke.png',
            bytes: Uint8List(0),
          );
        });
        strokeId = await _drawStroke(tester);
        cleanPixels = await _pixels(tester);
        expect(
          listEquals(await _pixels(tester), cleanPixels),
          isTrue,
          reason: 'The unselected reference canvas must be stable.',
        );
        await _selectStrokeInLayers(tester, strokeId);
        final selectedPixels = await _pixels(tester);
        expect(
          listEquals(selectedPixels, cleanPixels),
          isFalse,
          reason:
              'The selected stroke must visibly differ so the export comparison exercises its highlight.',
        );

        final exportButton = find
            .descendant(
              of: find.byType(AppBar),
              matching: find.byType(IconButton),
            )
            .last;
        await tester.ensureVisible(exportButton);
        await tester.pumpAndSettle();
        await tester.tap(exportButton);
        await _finishExport(tester);
        expect(exports, 1);
        expect(exportedName, 'selected-stroke.json');
        expect(exportingCanvas, isNotNull);
        expect(canvasInputBlocked, isTrue);
        expect(exportingCanvas!.selectedLayerId, isNull);
        expect(exportingCanvas!.document.layerById(strokeId), isNotNull);
        expect(exportedPixels, isNotNull);
        expect(
          listEquals(exportedPixels, cleanPixels),
          isTrue,
          reason:
              'Export must match the unselected canvas, without amber stroke highlighting. '
              '${_pixelDifference(exportedPixels!, cleanPixels)}',
        );
        expect(find.byType(PreviewGeneratorScreen), findsOneWidget);
        expect(_canvas(tester).selectedLayerId, strokeId);
        expect(_canvas(tester).interactive, isTrue);
        expect(
          tester
              .widget<AbsorbPointer>(
                find.byKey(const ValueKey('previewExportInputBarrier')),
              )
              .absorbing,
          isFalse,
        );
        expect(_canvas(tester).document.layerById(strokeId), isNotNull);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
