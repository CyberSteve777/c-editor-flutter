import 'dart:convert';
import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_storage.dart';

const _prefsEnabledKey = 'cplugin_enabled_ids';

/// IndexedDB-backed plugin storage for Flutter web.
class WebPluginStorage implements PluginStorage {
  WebPluginStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _dbName = 'c_editor_plugins';
  static const _dbVersion = 1;
  static const _store = 'plugins';

  Database? _db;

  Future<Database> _database() async {
    if (_db != null) return _db!;
    final factory = getIdbFactory();
    if (factory == null) {
      throw StateError('IndexedDB is not available in this environment.');
    }
    _db = await factory.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(_store)) {
          db.createObjectStore(_store);
        }
      },
    );
    return _db!;
  }

  @override
  Future<Set<String>> enabledIds() async {
    final list = _prefs.getStringList(_prefsEnabledKey) ?? const [];
    return list.toSet();
  }

  Future<void> _setEnabledIds(Set<String> ids) async {
    await _prefs.setStringList(_prefsEnabledKey, ids.toList()..sort());
  }

  Map<String, dynamic> _encode(CPluginPackage package) {
    final assets = <String, String>{};
    for (final e in package.assets.entries) {
      assets[e.key] = base64Encode(e.value);
    }
    return {
      'manifest': package.manifest.toJson(),
      'evc': base64Encode(package.evcBytes),
      'assets': assets,
      'zip': base64Encode(package.rawZipBytes),
    };
  }

  InstalledPluginRecord _decode(Map map, bool enabled) {
    final manifestJson = Map<String, dynamic>.from(map['manifest'] as Map);
    final manifest = CPluginManifest.fromJson(manifestJson);
    final evc = Uint8List.fromList(base64Decode(map['evc'] as String));
    final assetsRaw = Map<String, dynamic>.from(map['assets'] as Map? ?? {});
    final assets = <String, Uint8List>{};
    for (final e in assetsRaw.entries) {
      assets[e.key] = Uint8List.fromList(base64Decode(e.value as String));
    }
    return InstalledPluginRecord(
      manifest: manifest,
      evcBytes: evc,
      assets: assets,
      enabled: enabled,
      kind: PluginKind.imported,
    );
  }

  @override
  Future<List<InstalledPluginRecord>> listInstalled() async {
    final db = await _database();
    final enabled = await enabledIds();
    final txn = db.transaction(_store, idbModeReadOnly);
    final store = txn.objectStore(_store);
    final keys = await store.getAllKeys();
    final result = <InstalledPluginRecord>[];
    for (final key in keys) {
      if (key is! String) continue;
      final value = await store.getObject(key);
      if (value is Map) {
        result.add(_decode(value, enabled.contains(key)));
      }
    }
    await txn.completed;
    result.sort((a, b) => a.manifest.name.compareTo(b.manifest.name));
    return result;
  }

  @override
  Future<void> savePackage(
    CPluginPackage package, {
    required bool enabled,
  }) async {
    final db = await _database();
    final txn = db.transaction(_store, idbModeReadWrite);
    await txn
        .objectStore(_store)
        .put(_encode(package), package.manifest.id);
    await txn.completed;

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
    final db = await _database();
    final txn = db.transaction(_store, idbModeReadWrite);
    await txn.objectStore(_store).delete(pluginId);
    await txn.completed;
    final ids = await enabledIds();
    ids.remove(pluginId);
    await _setEnabledIds(ids);
  }
}

PluginStorage createPluginStorage(SharedPreferences prefs) =>
    WebPluginStorage(prefs);
