import 'dart:typed_data';

import 'package:c_editor/data/repository/level_repository.dart';
import 'package:path/path.dart' as p;

Future<void> writeBytes(String path, Uint8List bytes) async {
  // Web: store via level-library virtual FS using the file name only.
  final name = p.basename(path);
  final folder = p.basename(p.dirname(path));
  final key = folder.isEmpty ? name : '$folder/$name';
  await LevelRepository.prepareInternalCacheFromBytes(key, bytes);
}

Future<bool> fileExists(String path) async {
  final name = p.basename(path);
  final folder = p.dirname(path);
  return LevelRepository.fileExistsInDirectory(folder, name);
}
