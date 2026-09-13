import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:c_editor/data/repository/level_repository.dart';

import 'preview_document.dart';
import 'preview_png_exporter.dart';

/// Paths share the same identity used by the canvas' image-frame overrides.
class PreviewGifSource {
  const PreviewGifSource(this.path, {required this.isAsset});

  final String path;
  final bool isAsset;
}

List<PreviewGifSource> previewDocumentGifSources(PreviewDocument document) {
  final sources = <String, PreviewGifSource>{};
  void add(String? path, {required bool isAsset}) {
    if (path == null || !path.toLowerCase().endsWith('.gif')) return;
    sources.putIfAbsent(path, () => PreviewGifSource(path, isAsset: isAsset));
  }

  final banner = document.banner;
  if (banner.kind == PreviewBannerSourceKind.userFile) {
    add(banner.userFilePath, isAsset: false);
  } else {
    add(banner.assetPath, isAsset: true);
  }
  for (final layer in document.layers.where((layer) => layer.visible)) {
    if (layer.kind == PreviewLayerKind.image) {
      if (layer.imagePath != null) {
        add(layer.imagePath, isAsset: false);
      } else {
        add(layer.imageAsset, isAsset: true);
      }
    } else if (layer.kind == PreviewLayerKind.iconGrid) {
      final sections = previewEffectiveSections(layer);
      final useLawn =
          layer.lawnRows != null &&
          layer.lawnCols != null &&
          layer.lawnRows! > 0 &&
          layer.lawnCols! > 0 &&
          sections.any((section) => section.items.any((item) => item.hasCell));
      for (final section in sections) {
        final items = useLawn || section.rows.isEmpty
            ? section.items
            : [for (final row in section.rows) ...row.items];
        for (final item in items) {
          add(item.assetPath, isAsset: true);
        }
      }
    }
  }
  return sources.values.toList(growable: false);
}

typedef PreviewGifBytesLoader = Future<Uint8List> Function(PreviewGifSource);

Future<Uint8List> _loadSource(PreviewGifSource source) async {
  if (source.isAsset) {
    final data = await rootBundle.load(source.path);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  final bytes = await LevelRepository.readLibraryFileBytes(source.path);
  if (bytes == null) {
    throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
  }
  return bytes;
}

class _GifFrames {
  _GifFrames(this.images, this.durations);

  final List<ui.Image> images;
  final List<int> durations;
  int get cycle => durations.fold(0, (sum, duration) => sum + duration);

  ui.Image imageAt(int time) {
    var remaining = time % cycle;
    for (var i = 0; i < images.length; i++) {
      if (remaining < durations[i]) return images[i];
      remaining -= durations[i];
    }
    return images.last;
  }
}

/// A deterministic shared timeline, not real-time screen recording. Flutter's
/// codec supplies composited GIF frames, including disposal and transparency.
/// Only decoded source images are retained; rendered output is streamed.
class PreviewGifAnimation {
  PreviewGifAnimation._(this._sources, this.frameTimes);

  final Map<String, _GifFrames> _sources;

  /// Frame start times and the final end time, in GIF centiseconds.
  final List<int> frameTimes;

  static Future<PreviewGifAnimation> load(
    PreviewDocument document, {
    PreviewGifBytesLoader? bytesLoader,
  }) async {
    final sources = <String, _GifFrames>{};
    final ownedImages = <ui.Image>[];
    var pixels = 0;
    try {
      for (final source in previewDocumentGifSources(document)) {
        final bytes = await (bytesLoader ?? _loadSource)(source);
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        ui.ImageDescriptor? descriptor;
        ui.Codec? codec;
        try {
          descriptor = await ui.ImageDescriptor.encoded(buffer);
          // Avoid decoding oversized source frames at their original size when
          // the complete output canvas itself is only this design size.
          final scale = math.min(
            1.0,
            math.min(1144 / descriptor.width, 878 / descriptor.height),
          );
          codec = await descriptor.instantiateCodec(
            targetWidth: math.max(1, (descriptor.width * scale).round()),
            targetHeight: math.max(1, (descriptor.height * scale).round()),
          );
          if (codec.frameCount > 300) _tooLarge();
          final images = <ui.Image>[];
          final durations = <int>[];
          for (var i = 0; i < codec.frameCount; i++) {
            final frame = await codec.getNextFrame();
            ownedImages.add(frame.image);
            pixels += frame.image.width * frame.image.height;
            if (pixels > 32 * 1024 * 1024) _tooLarge();
            images.add(frame.image);
            durations.add(
              math.max(1, (frame.duration.inMilliseconds / 10).round()),
            );
          }
          sources[source.path] = _GifFrames(images, durations);
        } finally {
          codec?.dispose();
          descriptor?.dispose();
          buffer.dispose();
        }
      }
      if (sources.isEmpty) {
        throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
      }
      var total = 1;
      for (final frames in sources.values) {
        total = total ~/ _gcd(total, frames.cycle) * frames.cycle;
        if (total > 6000) _tooLarge();
      }
      final times = <int>{0, total};
      for (final frames in sources.values) {
        for (var start = 0; start < total; start += frames.cycle) {
          var time = start;
          for (final duration in frames.durations) {
            time += duration;
            times.add(time);
            if (times.length > 601) _tooLarge();
          }
        }
      }
      return PreviewGifAnimation._(sources, times.toList()..sort());
    } catch (_) {
      for (final image in ownedImages) {
        image.dispose();
      }
      rethrow;
    }
  }

  Map<String, ui.Image> imagesAt(int time) => {
    for (final entry in _sources.entries) entry.key: entry.value.imageAt(time),
  };

  void dispose() {
    for (final frames in _sources.values) {
      for (final image in frames.images) {
        image.dispose();
      }
    }
    _sources.clear();
  }
}

int _gcd(int a, int b) {
  while (b != 0) {
    final remainder = a % b;
    a = b;
    b = remainder;
  }
  return a;
}

Never _tooLarge() => throw const PreviewPngExportException(
  PreviewPngExportFailure.animationTooLarge,
);
