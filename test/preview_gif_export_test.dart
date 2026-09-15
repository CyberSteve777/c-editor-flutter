import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_gif_first_frames.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_gif_png_notice_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('only rendered GIF resources trigger the PNG notice', () {
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
    expect(
      previewDocumentGifSources(doc).every((source) => source.isAsset),
      isTrue,
    );
    doc.banner = PreviewBannerRef(
      kind: PreviewBannerSourceKind.userFile,
      userFilePath: '/custom.GIF',
    );
    final source = previewDocumentGifSources(doc).first;
    expect(source.path, '/custom.GIF');
    expect(source.isAsset, isFalse);
  });

  test('each unique rendered GIF contributes only its first frame', () async {
    final doc = _document([
      _sticker('a', 'a.gif'),
      _sticker('b', 'b.gif')..imagePath = '/custom.GIF',
      _sticker('a2', 'a.gif'),
      _sticker('hidden', 'hidden.gif', visible: false),
    ]);
    final loaded = <PreviewGifSource>[];
    final frames = await PreviewGifFirstFrames.load(
      doc,
      bytesLoader: (source) async {
        loaded.add(source);
        return _gif(source.isAsset ? [10, 20] : [15, 5]);
      },
    );
    try {
      expect(loaded.map((source) => source.path), ['a.gif', '/custom.GIF']);
      expect(loaded.map((source) => source.isAsset), [true, false]);
      expect(frames.images.keys, ['a.gif', '/custom.GIF']);
      for (final frame in frames.images.values) {
        expect(frame.width, 2);
        expect(frame.height, 2);
        expect(await _pixel(frame), [255, 0, 0, 255]);
      }
    } finally {
      frames.dispose();
    }
  });

  test('long source animations still export their first frame', () async {
    final frames = await PreviewGifFirstFrames.load(
      _document([_sticker('long', 'long.gif')]),
      bytesLoader: (_) async => _gif([3001, 3001]),
    );
    try {
      expect(await _pixel(frames.images['long.gif']!), [255, 0, 0, 255]);
    } finally {
      frames.dispose();
    }
  });

  test('documents without GIFs do not load images', () async {
    final frames = await PreviewGifFirstFrames.load(
      _document([_sticker('png', 'still.png')]),
      bytesLoader: (_) async => throw StateError('No GIF should be loaded'),
    );
    expect(frames.images, isEmpty);
    frames.dispose();
  });

  for (final size in [const Size(800, 300), const Size(320, 640)]) {
    testWidgets('PNG notice remains usable at $size', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      bool? selected;
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
                key: const ValueKey('openExportNotice'),
                onPressed: () async =>
                    selected = await showPreviewGifPngNoticeDialog(
                      context: context,
                      t: (key, [fallback]) => fallback ?? key,
                    ),
                child: const Text('Export'),
              ),
            ),
          ),
        ),
      );
      for (final export in [false, true]) {
        await tester.tap(find.byKey(const ValueKey('openExportNotice')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('previewGifPngNoticeDialog')),
          findsOneWidget,
        );
        expect(find.text('Export as PNG'), findsOneWidget);
        expect(find.textContaining('only their first frame'), findsOneWidget);
        final action = find.byKey(
          ValueKey(
            export ? 'previewGifPngNoticeExport' : 'previewGifPngNoticeCancel',
          ),
        );
        await tester.ensureVisible(action);
        await tester.pumpAndSettle();
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(selected, export);
        expect(
          find.byKey(const ValueKey('previewGifPngNoticeDialog')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      }
    });
  }
}
