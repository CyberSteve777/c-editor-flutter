import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;

import 'preview_png_exporter.dart';

class _GifPixels {
  const _GifPixels(this.bytes, this.width, this.height);

  final Uint8List bytes;
  final int width;
  final int height;
}

image.Image _quantize(_GifPixels pixels) {
  final indexed = image.quantize(
    image.Image.fromBytes(
      width: pixels.width,
      height: pixels.height,
      bytes: pixels.bytes.buffer,
      bytesOffset: pixels.bytes.offsetInBytes,
      numChannels: 4,
    ),
    numberOfColors: 255,
    dither: image.DitherKernel.floydSteinberg,
  );
  // RGB quantization discards alpha. Reserve one palette entry for the binary
  // transparency GIF supports, while reusing the existing indexed pixels.
  final rgb = indexed.palette!;
  final rgba = image.PaletteUint8(256, 4);
  for (var index = 0; index < 255; index++) {
    rgba.setRgba(
      index,
      rgb.getRed(index),
      rgb.getGreen(index),
      rgb.getBlue(index),
      255,
    );
  }
  rgba.setRgba(255, 0, 0, 0, 0);
  indexed.palette = rgba;
  for (var y = 0; y < pixels.height; y++) {
    for (var x = 0; x < pixels.width; x++) {
      if (pixels.bytes[(y * pixels.width + x) * 4 + 3] < 128) {
        indexed.setPixelIndex(x, y, 255);
      }
    }
  }
  return indexed;
}

/// Keeps only the previous indexed output frame, rather than buffering every
/// full-resolution RGBA screenshot. Palette conversion runs off the UI isolate
/// on native platforms; on web, compute uses its supported inline fallback.
class PreviewGifEncoder {
  PreviewGifEncoder({@visibleForTesting int maxEncodedBytes = 64 * 1024 * 1024})
    : _maxEncodedBytes = maxEncodedBytes {
    if (maxEncodedBytes <= 0) {
      throw ArgumentError.value(maxEncodedBytes, 'maxEncodedBytes');
    }
  }

  final int _maxEncodedBytes;
  final _encoder = image.GifEncoder(repeat: 0);

  void _checkEncodedSize(int byteCount) {
    if (byteCount > _maxEncodedBytes) {
      throw const PreviewPngExportException(
        PreviewPngExportFailure.animationTooLarge,
      );
    }
  }

  Future<void> addFrame(ui.Image frame, {required int duration}) async {
    final data = await frame.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    if (data == null) {
      throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
    }
    final paletteFrame = await compute(
      _quantize,
      _GifPixels(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        frame.width,
        frame.height,
      ),
      debugLabel: 'preview GIF palette',
    );
    _encoder.addFrame(paletteFrame, duration: duration);
    _checkEncodedSize(_encoder.output?.length ?? 0);
  }

  Uint8List finish() {
    _checkEncodedSize(_encoder.output?.length ?? 0);
    final bytes = _encoder.finish();
    if (bytes == null) {
      throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
    }
    _checkEncodedSize(bytes.lengthInBytes);
    return bytes;
  }
}
