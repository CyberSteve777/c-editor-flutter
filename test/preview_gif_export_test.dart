import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_format_dialog.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_gif_animation.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:shared_preferences/shared_preferences.dart';

Uint8List _gif(List<int> durations) {
  final encoder = image.GifEncoder(repeat: 0);
  final palette = image.PaletteUint8(256, 3);
  palette.setRgb(1, 255, 0, 0);
  palette.setRgb(2, 0, 0, 255);
  for (var i = 0; i < durations.length; i++) {
    final frame = image.Image(
      width: 2,
      height: 2,
      numChannels: 1,
      palette: palette,
    );
    for (final pixel in frame) {
      frame.setPixelIndex(pixel.x, pixel.y, i.isEven ? 1 : 2);
    }
    encoder.addFrame(frame, duration: durations[i]);
  }
  return encoder.finish()!;
}

PreviewLayer _sticker(String id, String path, {bool visible = true}) =>
    PreviewLayer(
      id: id,
      kind: PreviewLayerKind.image,
      bounds: const Rect.fromLTWH(.1, .1, .3, .3),
      imageAsset: path,
      visible: visible,
    );

PreviewDocument _document(List<PreviewLayer> layers, {String? banner}) =>
    PreviewDocument(
      banner: PreviewBannerRef(
        kind: PreviewBannerSourceKind.assetStem,
        assetPath: banner ?? 'background.png',
      ),
      layers: layers,
    );

Future<List<int>> _pixel(ui.Image frame) async {
  final pixels = await frame.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  return pixels!.buffer.asUint8List(pixels.offsetInBytes, 4).toList();
}

Matcher _failure(PreviewPngExportFailure failure) =>
    isA<PreviewPngExportException>().having(
      (error) => error.failure,
      'failure',
      failure,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('only rendered GIF resources trigger animation export', () {
    final hidden = _sticker('hidden', 'hidden.gif', visible: false);
    final file = _sticker('file', 'unused.gif')..imagePath = '/chosen.png';
    final icon = PreviewItem(id: 'icon', assetPath: 'icon.gif');
    final row = PreviewItem(id: 'row', assetPath: 'row.GIF');
    final grid = PreviewLayer(
      id: 'grid',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(.1, .1, .3, .3),
      items: [PreviewItem(id: 'legacy', assetPath: 'unused_legacy.gif')],
      sections: [
        PreviewIconSection(
          items: [icon],
          rows: [
            PreviewIconRow(items: [row], iconSize: 36),
          ],
        ),
      ],
    );
    final doc = _document([
      hidden,
      file,
      grid,
      _sticker('duplicate', 'row.GIF'),
    ]);
    expect(previewDocumentGifSources(doc).map((source) => source.path), [
      'row.GIF',
    ]);
    grid.lawnRows = 5;
    grid.lawnCols = 9;
    grid.sections.single.items.add(
      PreviewItem(id: 'cell', assetPath: 'cell.gif', gridX: 0, gridY: 0),
    );
    expect(previewDocumentGifSources(doc).map((source) => source.path), [
      'icon.gif',
      'cell.gif',
      'row.GIF',
    ]);
  });

  test('asset and custom background GIF sources are retained', () {
    final doc = _document([
      _sticker('asset', 'sticker.gif'),
    ], banner: 'banner.gif');
    expect(previewDocumentGifSources(doc).map((source) => source.path), [
      'banner.gif',
      'sticker.gif',
    ]);
    doc.banner = PreviewBannerRef(
      kind: PreviewBannerSourceKind.userFile,
      userFilePath: '/custom.GIF',
    );
    final source = previewDocumentGifSources(doc).first;
    expect(source.path, '/custom.GIF');
    expect(source.isAsset, isFalse);
  });

  test(
    'GIF timeline preserves source timing and independent complete cycles',
    () async {
      final doc = _document([
        _sticker('a', 'a.gif'),
        _sticker('b', 'b.gif'),
        _sticker('a2', 'a.gif'),
      ]);
      final loaded = <String>[];
      final animation = await PreviewGifAnimation.load(
        doc,
        bytesLoader: (source) async {
          loaded.add(source.path);
          return _gif(source.path == 'a.gif' ? [10, 20] : [15, 5]);
        },
      );
      try {
        expect(loaded, ['a.gif', 'b.gif']);
        expect(animation.frameTimes, [0, 10, 15, 20, 30, 35, 40, 55, 60]);
        expect(await _pixel(animation.imagesAt(0)['a.gif']!), [255, 0, 0, 255]);
        expect(await _pixel(animation.imagesAt(10)['a.gif']!), [
          0,
          0,
          255,
          255,
        ]);
        expect(await _pixel(animation.imagesAt(30)['a.gif']!), [
          255,
          0,
          0,
          255,
        ]);
        expect(await _pixel(animation.imagesAt(35)['b.gif']!), [
          0,
          0,
          255,
          255,
        ]);
      } finally {
        animation.dispose();
      }
    },
  );

  test('oversized timelines and too many source frames fail safely', () async {
    final doc = _document([_sticker('a', 'a.gif')]);
    for (final durations in [
      <int>[3001, 3001],
      List<int>.filled(301, 10),
    ]) {
      await expectLater(
        PreviewGifAnimation.load(
          doc,
          bytesLoader: (_) async => _gif(durations),
        ),
        throwsA(_failure(PreviewPngExportFailure.animationTooLarge)),
      );
    }
    final valid = await PreviewGifAnimation.load(
      doc,
      bytesLoader: (_) async => _gif([10, 20]),
    );
    valid.dispose();
  });

  test(
    'encoded GIF uses configured folder and collision-safe gif suffix',
    () async {
      final temp = await Directory.systemTemp.createTemp('preview_gif_export_');
      addTearDown(() async => temp.delete(recursive: true));
      await LevelRepository.setSavedFolderPath(temp.path);
      final bytes = _gif([10, 20]);
      final first = await PreviewPngExporter.exportEncoded(
        bytes: bytes,
        levelFileName: 'level.json',
        extension: 'gif',
      );
      final second = await PreviewPngExporter.exportEncoded(
        bytes: bytes,
        levelFileName: 'level.gif',
        extension: 'gif',
      );
      expect(first.path.replaceAll('\\', '/'), endsWith('/previews/level.gif'));
      expect(
        second.path.replaceAll('\\', '/'),
        endsWith('/previews/level_2.gif'),
      );
      expect(await File(first.path).readAsBytes(), bytes);
      expect(image.decodeGif(first.bytes)!.numFrames, 2);
      expect(
        await LevelRepository.getDirectoryContents(
          File(first.path).parent.path,
        ),
        hasLength(2),
      );
    },
  );

  test('invalid or empty encoded formats fail without writing files', () async {
    for (final extension in ['jpeg', '../gif', 'GIF']) {
      await expectLater(
        PreviewPngExporter.exportEncoded(
          bytes: _gif([10]),
          levelFileName: 'level.json',
          extension: extension,
        ),
        throwsA(_failure(PreviewPngExportFailure.encoding)),
      );
    }
    await expectLater(
      PreviewPngExporter.exportEncoded(
        bytes: Uint8List(0),
        levelFileName: 'level.json',
        extension: 'gif',
      ),
      throwsA(_failure(PreviewPngExportFailure.encoding)),
    );
  });

  for (final size in [const Size(800, 300), const Size(320, 640)]) {
    testWidgets('format selection scrolls and remains usable at $size', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      PreviewImageExportFormat? selected;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async =>
                    selected = await showPreviewExportFormatDialog(
                      context: context,
                      t: (key, [fallback]) => fallback ?? key,
                    ),
                child: const Text('Export'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();
      final option = find.byKey(const ValueKey('previewExportGifOption'));
      await tester.ensureVisible(option);
      await tester.pumpAndSettle();
      await tester.tap(option);
      await tester.pumpAndSettle();
      expect(selected, PreviewImageExportFormat.gif);
      expect(tester.takeException(), isNull);
    });
  }
}
