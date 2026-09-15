import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/data/repository/level_repository.dart';

import 'preview_png_writer.dart' as writer;

enum PreviewPngExportFailure { encoding, libraryNotConfigured }

/// A known export failure that the interface can describe with localization.
/// Filesystem and unexpected encoding errors retain their original exceptions.
class PreviewPngExportException implements Exception {
  const PreviewPngExportException(this.failure);

  final PreviewPngExportFailure failure;

  @override
  String toString() => 'PreviewPngExportException(${failure.name})';
}

class PreviewExportResult {
  const PreviewExportResult({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

class PreviewPngExporter {
  /// Encodes [image] as PNG and writes under the level library export folder.
  static Future<PreviewExportResult> export({
    required ui.Image image,
    required String levelFileName,
    int pixelRatio = 1,
  }) async {
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
    }
    final bytes = byteData.buffer.asUint8List(
      byteData.offsetInBytes,
      byteData.lengthInBytes,
    );

    if (bytes.isEmpty) {
      throw const PreviewPngExportException(PreviewPngExportFailure.encoding);
    }
    final libraryPath = await LevelRepository.getSavedFolderPath();
    if (libraryPath == null || libraryPath.isEmpty) {
      throw const PreviewPngExportException(
        PreviewPngExportFailure.libraryNotConfigured,
      );
    }

    final folderName = await PreviewExportPrefs.getFolderName();
    final base = sanitizePreviewFileBaseName(levelFileName);
    final dirPath = previewExportDirectoryPath(libraryPath, folderName);
    var fileName = '$base.png';
    var outPath = previewExportFilePath(dirPath, fileName);
    var n = 2;
    while (await writer.fileExists(outPath)) {
      fileName = '${base}_$n.png';
      outPath = previewExportFilePath(dirPath, fileName);
      n++;
    }

    await writer.writeBytes(outPath, bytes);
    return PreviewExportResult(path: outPath, bytes: bytes);
  }
}
