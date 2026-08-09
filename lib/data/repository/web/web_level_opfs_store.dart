import 'dart:typed_data';

import 'package:fs_shim/fs_opfs_web.dart';

import 'package:c_editor/data/repository/web/opfs_bytes_io.dart';

/// Persistent web level storage backed by the browser Origin Private File
/// System (OPFS) via `fs_shim`.
///
/// Unlike the previous IndexedDB store, this keeps a real directory tree on
/// disk and reads file bytes lazily, so the whole library is never mirrored in
/// memory. Keys are library-relative POSIX paths (e.g. `folder/sub/level.json`).
class WebLevelOpfsStore {
  WebLevelOpfsStore._();

  static final WebLevelOpfsStore instance = WebLevelOpfsStore._();

  static const String _root = '/c_editor_levels';

  FileSystemOpfsWeb get _fs => fileSystemOpfsWeb;

  bool _ready = false;

  Future<void> ensureReady() async {
    if (_ready) return;
    await _fs.directory(_root).create(recursive: true);
    _ready = true;
  }

  String _full(String key) {
    final clean = _normalizeKey(key);
    return clean.isEmpty ? _root : '$_root/$clean';
  }

  String _normalizeKey(String key) {
    var k = key.replaceAll('\\', '/').trim();
    // Guard against virtual library scheme leaking into OPFS (creates a "web:"
    // directory). Callers should pass library-relative keys only.
    const webPrefix = 'web://';
    if (k.startsWith(webPrefix)) {
      k = k.substring(webPrefix.length);
    } else if (k.startsWith('web:/')) {
      k = k.substring('web:/'.length);
    }
    while (k.startsWith('/')) {
      k = k.substring(1);
    }
    while (k.endsWith('/')) {
      k = k.substring(0, k.length - 1);
    }
    return k;
  }

  String _relFromFull(String fullPath) {
    var rel = fullPath;
    if (rel.startsWith(_root)) {
      rel = rel.substring(_root.length);
    }
    while (rel.startsWith('/')) {
      rel = rel.substring(1);
    }
    return rel;
  }

  /// Builds a metadata-only index of every stored file (key -> byte size)
  /// without reading file contents.
  Future<Map<String, int>> indexFilesWithSizes() async {
    await ensureReady();
    final result = <String, int>{};
    await for (final entity
        in _fs.directory(_root).list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final rel = _relFromFull(entity.path);
        if (rel.isEmpty) continue;
        final stat = await entity.stat();
        result[rel] = stat.size;
      }
    }
    return result;
  }

  /// Lists every directory in the library as relative keys.
  Future<List<String>> listDirectories() async {
    await ensureReady();
    final dirs = <String>[];
    await for (final entity
        in _fs.directory(_root).list(recursive: true, followLinks: false)) {
      if (entity is Directory) {
        final rel = _relFromFull(entity.path);
        if (rel.isNotEmpty) dirs.add(rel);
      }
    }
    return dirs;
  }

  Future<Uint8List?> read(String key) async {
    await ensureReady();
    // Bypass fs_shim's synchronous boxed-list conversion (see [OpfsBytesIo]);
    // it freezes the UI on large archives. Falls through to null if absent.
    return OpfsBytesIo.read(_full(key));
  }

  Future<void> write(String key, Uint8List bytes) async {
    await ensureReady();
    // Direct File System Access API write (creates parents). Avoids fs_shim's
    // main-thread whole-buffer copy that stalls the tab on large files.
    await OpfsBytesIo.write(_full(key), bytes);
  }

  Future<void> delete(String key) async {
    await ensureReady();
    final file = _fs.file(_full(key));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> createDirectory(String key) async {
    await ensureReady();
    await _fs.directory(_full(key)).create(recursive: true);
  }

  Future<void> deleteDirectory(String key) async {
    await ensureReady();
    final dir = _fs.directory(_full(key));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<bool> fileExists(String key) async {
    await ensureReady();
    return _fs.file(_full(key)).exists();
  }

  /// Renames a file. Creates the destination's parent chain first.
  Future<void> renameFile(String oldKey, String newKey) async {
    await ensureReady();
    final src = _fs.file(_full(oldKey));
    if (!await src.exists()) return;
    await _ensureParent(newKey);
    await src.rename(_full(newKey));
  }

  /// Renames a directory (moving its whole subtree).
  Future<void> renameDirectory(String oldKey, String newKey) async {
    await ensureReady();
    final src = _fs.directory(_full(oldKey));
    if (!await src.exists()) return;
    await _ensureParent(newKey);
    await src.rename(_full(newKey));
  }

  Future<void> _ensureParent(String key) async {
    final clean = _normalizeKey(key);
    final idx = clean.lastIndexOf('/');
    if (idx <= 0) return;
    await _fs.directory(_full(clean.substring(0, idx))).create(recursive: true);
  }

  /// Wipes the whole library.
  Future<void> clear() async {
    await ensureReady();
    final root = _fs.directory(_root);
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
    await root.create(recursive: true);
  }
}
