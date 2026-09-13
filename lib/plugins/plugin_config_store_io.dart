import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugins/plugin_constants.dart';

Future<String?> readConfigFile(String pluginId) async {
  final file = await _configFile(pluginId);
  if (file == null || !await file.exists()) return null;
  return file.readAsString(encoding: utf8);
}

Future<bool> writeConfigFile(String pluginId, String utf8Json) async {
  final file = await _configFile(pluginId);
  if (file == null) return false;
  await file.parent.create(recursive: true);
  await file.writeAsString(utf8Json, encoding: utf8, flush: true);
  return true;
}

Future<void> deleteConfigFile(String pluginId) async {
  final file = await _configFile(pluginId);
  if (file != null && await file.exists()) {
    await file.delete();
  }
}

Future<File?> _configFile(String pluginId) async {
  try {
    final library = await LevelRepository.getSavedFolderPath();
    if (library == null || library.isEmpty) return null;
    return File(
      p.join(library, kPluginConfigFolderName, pluginId, kPluginConfigFileName),
    );
  } catch (_) {
    return null;
  }
}
