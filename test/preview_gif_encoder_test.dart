import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_gif_encoder.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;

const _width = 32;
const _height = 16;

Future<ui.Image> _render(void Function(ui.Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  draw(ui.Canvas(recorder));
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(_width, _height);
  } finally {
    picture.dispose();
  }
}

Future<Uint8List> _encode(
  List<ui.Image> frames, {
  List<int> durations = const [7, 11],
}) async {
  final encoder = PreviewGifEncoder();
  try {
    for (var index = 0; index < frames.length; index++) {
      await encoder.addFrame(frames[index], duration: durations[index]);
    }
    return encoder.finish();
  } finally {
    for (final frame in frames) {
      frame.dispose();
    }
  }
}

Matcher get _animationTooLarge => throwsA(
  isA<PreviewPngExportException>().having(
    (error) => error.failure,
    'failure',
    PreviewPngExportFailure.animationTooLarge,
  ),
);

Uint8List _transparentStickerGif() {
  final palette = image.PaletteUint8(256, 4);
  for (var index = 1; index < 256; index++) {
    palette.setRgba(index, 255, 0, 0, 255);
  }
  final encoder = image.GifEncoder(repeat: 0);
  for (var index = 0; index < 2; index++) {
    final frame = image.Image(
      width: _width,
      height: _height,
      numChannels: 1,
      palette: palette,
    );
    for (var y = 0; y < _height; y++) {
      for (var x = index * 16; x < index * 16 + 16; x++) {
        frame.setPixelIndex(x, y, 1);
      }
    }
    encoder.addFrame(frame, duration: index == 0 ? 7 : 11);
  }
  return encoder.finish()!;
}

void _expectRgb(image.Pixel pixel, int r, int g, int b) {
  expect(pixel.r, closeTo(r, 10));
  expect(pixel.g, closeTo(g, 10));
  expect(pixel.b, closeTo(b, 10));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('finishing without any GIF frame reports an encoding failure', () {
    expect(
      () => PreviewGifEncoder().finish(),
      throwsA(
        isA<PreviewPngExportException>().having(
          (error) => error.failure,
          'failure',
          PreviewPngExportFailure.encoding,
        ),
      ),
    );
  });

  test('GIF encoding size budget must be positive', () {
    expect(() => PreviewGifEncoder(maxEncodedBytes: 0), throwsArgumentError);
  });

  testWidgets(
    'GIF budget detects output growth during streaming and before finish',
    (tester) async {
      await tester.runAsync(() async {
        final frame = await _render(
          (canvas) =>
              canvas.drawPaint(ui.Paint()..color = const ui.Color(0xFFFF0000)),
        );
        final encoder = PreviewGifEncoder(maxEncodedBytes: 32);
        try {
          await encoder.addFrame(frame, duration: 7);
          await expectLater(
            encoder.addFrame(frame, duration: 11),
            _animationTooLarge,
          );
          expect(encoder.finish, _animationTooLarge);
        } finally {
          frame.dispose();
        }
      });
    },
  );

  testWidgets(
    'GIF budget checks the final delayed frame and accepts exact limit',
    (tester) async {
      await tester.runAsync(() async {
        final frame = await _render(
          (canvas) =>
              canvas.drawPaint(ui.Paint()..color = const ui.Color(0xFFFF0000)),
        );
        try {
          final baseline = PreviewGifEncoder();
          await baseline.addFrame(frame, duration: 7);
          final expectedBytes = baseline.finish();
          final tooSmall = PreviewGifEncoder(
            maxEncodedBytes: expectedBytes.lengthInBytes - 1,
          );
          await tooSmall.addFrame(frame, duration: 7);
          expect(tooSmall.finish, _animationTooLarge);
          final exact = PreviewGifEncoder(
            maxEncodedBytes: expectedBytes.lengthInBytes,
          );
          await exact.addFrame(frame, duration: 7);
          expect(exact.finish(), expectedBytes);
        } finally {
          frame.dispose();
        }
      });
    },
  );

  testWidgets(
    'transparent canvas retains transparent pixels in every GIF frame',
    (tester) async {
      await tester.runAsync(() async {
        final frames = <ui.Image>[];
        for (var index = 0; index < 2; index++) {
          frames.add(
            await _render(
              (canvas) => canvas.drawRect(
                ui.Rect.fromLTWH(index * 16.0, 0, 16, _height.toDouble()),
                ui.Paint()..color = const ui.Color(0xFFFF0000),
              ),
            ),
          );
        }
        final bytes = await _encode(frames);
        expect(String.fromCharCodes(bytes.take(6)), 'GIF89a');
        final decoded = image.decodeGif(bytes)!;
        expect(decoded.frames, hasLength(2));
        expect(decoded.width, _width);
        expect(decoded.height, _height);
        expect(decoded.loopCount, 0);
        for (var index = 0; index < 2; index++) {
          final frame = decoded.frames[index];
          final redX = index == 0 ? 4 : 20;
          final transparentX = index == 0 ? 20 : 4;
          expect(frame.getPixel(transparentX, 8).a, 0);
          expect(frame.getPixel(redX, 8).a, 255);
          _expectRgb(frame.getPixel(redX, 8), 255, 0, 0);
          expect(frame.frameDuration, index == 0 ? 70 : 110);
        }
      });
    },
  );

  testWidgets('GIF alpha uses a stable binary threshold, not RGB-only pixels', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final frame = await _render((canvas) {
        const alphas = [0, 127, 128, 255];
        for (var index = 0; index < alphas.length; index++) {
          canvas.drawRect(
            ui.Rect.fromLTWH(index * 8.0, 0, 8, _height.toDouble()),
            ui.Paint()
              ..blendMode = ui.BlendMode.src
              ..color = ui.Color.fromARGB(alphas[index], 0, 0, 255),
          );
        }
      });
      final bytes = await _encode([frame], durations: const [9]);
      final decoded = image.decodeGif(bytes)!;
      expect(
        [
          for (final x in [4, 12, 20, 28]) decoded.getPixel(x, 8).a,
        ],
        [0, 0, 255, 255],
      );
      _expectRgb(decoded.getPixel(20, 8), 0, 0, 255);
      // image's single-frame decode shortcut omits frameDuration. Validate the
      // delay parsed from the actual GIF graphics-control extension instead.
      final metadata = image.GifDecoder().startDecode(bytes)!;
      expect(metadata.frames, hasLength(1));
      expect(metadata.frames.single.duration, 9);
    });
  });

  testWidgets(
    'transparent GIF stickers stay composited over opaque backgrounds',
    (tester) async {
      await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(_transparentStickerGif());
        final output = <ui.Image>[];
        try {
          for (var index = 0; index < codec.frameCount; index++) {
            final source = await codec.getNextFrame();
            try {
              output.add(
                await _render((canvas) {
                  canvas.drawPaint(
                    ui.Paint()..color = const ui.Color(0xFF0044FF),
                  );
                  canvas.drawImage(source.image, ui.Offset.zero, ui.Paint());
                }),
              );
            } finally {
              source.image.dispose();
            }
          }
        } finally {
          codec.dispose();
        }
        final decoded = image.decodeGif(await _encode(output))!;
        expect(decoded.frames, hasLength(2));
        for (var index = 0; index < 2; index++) {
          final frame = decoded.frames[index];
          for (final pixel in frame) {
            expect(pixel.a, 255);
          }
          _expectRgb(frame.getPixel(index == 0 ? 4 : 20, 8), 255, 0, 0);
          _expectRgb(frame.getPixel(index == 0 ? 20 : 4, 8), 0, 68, 255);
        }
      });
    },
  );
}
