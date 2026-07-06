import 'dart:typed_data';

import 'package:idb_shim/idb_browser.dart';

/// Persists the virtual web level library in the browser IndexedDB.
class WebLevelIdbStore {
  WebLevelIdbStore._();

  static final WebLevelIdbStore instance = WebLevelIdbStore._();

  static const _dbName = 'c_editor_levels';
  static const _dbVersion = 1;
  static const _filesStore = 'files';
  static const _metaStore = 'meta';

  static const metaDirectoriesKey = 'directories';
  static const metaDirectoryHandleKey = 'directory_handle';
  static const metaDirectoryNameKey = 'directory_name';
  static const metaDirectoryModeKey = 'directory_mode';

  Database? _db;

  Future<Database> _database() async {
    if (_db != null) {
      return _db!;
    }
    final factory = getIdbFactory();
    if (factory == null) {
      throw StateError('IndexedDB is not available in this environment.');
    }
    _db = await factory.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (VersionChangeEvent event) {
        final db = event.database;
        if (!db.objectStoreNames.contains(_filesStore)) {
          db.createObjectStore(_filesStore);
        }
        if (!db.objectStoreNames.contains(_metaStore)) {
          db.createObjectStore(_metaStore);
        }
      },
    );
    return _db!;
  }

  Future<Map<String, Uint8List>> loadFiles() async {
    final db = await _database();
    final txn = db.transaction(_filesStore, idbModeReadOnly);
    final store = txn.objectStore(_filesStore);
    final keys = await store.getAllKeys();
    final files = <String, Uint8List>{};
    for (final key in keys) {
      if (key is! String) {
        continue;
      }
      final value = await store.getObject(key);
      if (value is Uint8List) {
        files[key] = value;
      }
    }
    await txn.completed;
    return files;
  }

  Future<Set<String>> loadDirectories() async {
    final raw = await getMeta<List<dynamic>>(metaDirectoriesKey);
    if (raw == null) {
      return {};
    }
    return raw.whereType<String>().toSet();
  }

  Future<void> putFile(String path, Uint8List bytes) async {
    final db = await _database();
    final txn = db.transaction(_filesStore, idbModeReadWrite);
    await txn.objectStore(_filesStore).put(bytes, path);
    await txn.completed;
  }

  Future<void> deleteFile(String path) async {
    final db = await _database();
    final txn = db.transaction(_filesStore, idbModeReadWrite);
    await txn.objectStore(_filesStore).delete(path);
    await txn.completed;
  }

  Future<void> clearFiles() async {
    final db = await _database();
    final txn = db.transaction(_filesStore, idbModeReadWrite);
    await txn.objectStore(_filesStore).clear();
    await txn.completed;
  }

  Future<void> putMeta(String key, Object? value) async {
    final db = await _database();
    final txn = db.transaction(_metaStore, idbModeReadWrite);
    if (value == null) {
      await txn.objectStore(_metaStore).delete(key);
    } else {
      await txn.objectStore(_metaStore).put(value, key);
    }
    await txn.completed;
  }

  Future<T?> getMeta<T>(String key) async {
    final db = await _database();
    final txn = db.transaction(_metaStore, idbModeReadOnly);
    final value = await txn.objectStore(_metaStore).getObject(key);
    await txn.completed;
    return value as T?;
  }

  Future<void> saveDirectories(Set<String> directories) async {
    await putMeta(metaDirectoriesKey, directories.toList()..sort());
  }

  Future<void> clearAll() async {
    await clearFiles();
    final db = await _database();
    final txn = db.transaction(_metaStore, idbModeReadWrite);
    await txn.objectStore(_metaStore).clear();
    await txn.completed;
  }
}
