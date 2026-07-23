import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_storage.dart';

const _prefsEnabledKey = 'cplugin_enabled_ids';

/// File-system plugin storage under the level library's [kPluginsFolderName].
class NativePluginStorage implements PluginStorage {
  NativePluginStorage(this._prefs);

  final SharedPreferences _prefs;

  Future<Directory> _pluginsRoot() async {
    final library = await LevelRepository.getSavedFolderPath();
    if (library == null || library.isEmpty) {
      throw StateError(
        'Select a level library folder before installing plugins',
      );
    }
    final dir = Directory(p.join(library, kPluginsFolderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _pluginDir(String id) async {
    final root = await _pluginsRoot();
    return Directory(p.join(root.path, id));
  }

  @override
  Future<Set<String>> enabledIds() async {
    final list = _prefs.getStringList(_prefsEnabledKey) ?? const [];
    return list.toSet();
  }

  Future<void> _setEnabledIds(Set<String> ids) async {
    await _prefs.setStringList(_prefsEnabledKey, ids.toList()..sort());
  }

  @override
  Future<List<InstalledPluginRecord>> listInstalled() async {
    final enabled = await enabledIds();
    final result = <InstalledPluginRecord>[];

    Directory root;
    try {
      root = await _pluginsRoot();
    } catch (_) {
      // No library selected yet — no imported plugins.
      return result;
    }

    if (!await root.exists()) return result;

    await for (final entity in root.list()) {
      if (entity is! Directory) continue;
      final id = p.basename(entity.path);
      try {
        final record = await _readPluginDir(entity, enabled.contains(id));
        if (record != null) result.add(record);
      } catch (_) {
        // Skip corrupt plugin folders.
      }
    }

    result.sort((a, b) => a.manifest.name.compareTo(b.manifest.name));
    return result;
  }

  Future<InstalledPluginRecord?> _readPluginDir(
    Directory dir,
    bool enabled,
  ) async {
    final manifestFile = File(p.join(dir.path, 'manifest.json'));
    final evcFile = File(p.join(dir.path, 'plugin.evc'));
    if (!await manifestFile.exists() || !await evcFile.exists()) {
      return null;
    }
    final manifest =
        CPluginManifest.fromJsonString(await manifestFile.readAsString());
    final evcBytes = await evcFile.readAsBytes();
    final assets = <String, Uint8List>{};
    final assetsDir = Directory(p.join(dir.path, 'assets'));
    if (await assetsDir.exists()) {
      await for (final entity in assetsDir.list(recursive: true)) {
        if (entity is! File) continue;
        final rel = p
            .relative(entity.path, from: assetsDir.path)
            .replaceAll('\\', '/');
        assets[rel] = await entity.readAsBytes();
      }
    }
    return InstalledPluginRecord(
      manifest: manifest,
      evcBytes: evcBytes,
      assets: assets,
      enabled: enabled,
      kind: PluginKind.imported,
    );
  }

  @override
  Future<void> savePackage(
    CPluginPackage package, {
    required bool enabled,
  }) async {
    final dir = await _pluginDir(package.manifest.id);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    await dir.create(recursive: true);

    await File(p.join(dir.path, 'manifest.json'))
        .writeAsString(package.manifest.toJsonString());
    await File(p.join(dir.path, 'plugin.evc'))
        .writeAsBytes(package.evcBytes, flush: true);

    if (package.assets.isNotEmpty) {
      final assetsDir = Directory(p.join(dir.path, 'assets'));
      await assetsDir.create(recursive: true);
      for (final entry in package.assets.entries) {
        final file = File(p.join(assetsDir.path, entry.key));
        await file.parent.create(recursive: true);
        await file.writeAsBytes(entry.value, flush: true);
      }
    }

    await File(p.join(dir.path, 'package.cplugin'))
        .writeAsBytes(package.rawZipBytes, flush: true);

    final ids = await enabledIds();
    if (enabled) {
      ids.add(package.manifest.id);
    } else {
      ids.remove(package.manifest.id);
    }
    await _setEnabledIds(ids);
  }

  @override
  Future<void> setEnabled(String pluginId, bool enabled) async {
    final ids = await enabledIds();
    if (enabled) {
      ids.add(pluginId);
    } else {
      ids.remove(pluginId);
    }
    await _setEnabledIds(ids);
  }

  @override
  Future<void> uninstall(String pluginId) async {
    try {
      final dir = await _pluginDir(pluginId);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {
      // Library may be unset; still clear enabled flag.
    }
    final ids = await enabledIds();
    ids.remove(pluginId);
    await _setEnabledIds(ids);
  }
}

PluginStorage createPluginStorage(SharedPreferences prefs) =>
    NativePluginStorage(prefs);
