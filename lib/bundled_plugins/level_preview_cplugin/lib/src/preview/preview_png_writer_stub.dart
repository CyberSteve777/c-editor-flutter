import 'dart:typed_data';

import 'package:c_editor/data/repository/level_repository.dart';
import 'preview_export_prefs.dart';

Future<void> writeBytes(String path, Uint8List bytes) async {
  final workspace = await LevelRepository.getSavedFolderPath();
  if (workspace == null || workspace.isEmpty) {
    throw StateError('Level library folder is not configured');
  }
  final key = previewExportLibraryRelativePath(path, workspace);
  if (!await LevelRepository.prepareInternalCacheFromBytes(key, bytes)) {
    throw StateError('Failed to save preview image');
  }
}

Future<bool> fileExists(String path) async {
  final name = previewExportFileName(path);
  final folder = previewExportParentDirectory(path);
  return LevelRepository.fileExistsInDirectory(folder, name);
}
