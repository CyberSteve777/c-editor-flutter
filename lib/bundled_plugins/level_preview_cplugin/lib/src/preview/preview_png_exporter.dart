import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:path/path.dart' as p;

import 'preview_png_writer.dart' as writer;

class PreviewExportResult {
  const PreviewExportResult({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

class PreviewPngExporter {
  /// Renders [boundary] to PNG and writes under the level library export folder.
  static Future<PreviewExportResult> export({
    required ui.Image image,
    required String levelFileName,
    int pixelRatio = 1,
  }) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode preview PNG');
    }
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    final libraryPath = await LevelRepository.getSavedFolderPath();
    if (libraryPath == null || libraryPath.isEmpty) {
      throw StateError('Level library folder is not configured');
    }

    final folderName = await PreviewExportPrefs.getFolderName();
    final base = sanitizePreviewFileBaseName(levelFileName);
    final dirPath = p.join(libraryPath, folderName);
    var fileName = '$base.png';
    var outPath = p.join(dirPath, fileName);
    var n = 2;
    while (await writer.fileExists(outPath)) {
      fileName = '${base}_$n.png';
      outPath = p.join(dirPath, fileName);
      n++;
    }

    await writer.writeBytes(outPath, bytes);
    return PreviewExportResult(path: outPath, bytes: bytes);
  }
}
