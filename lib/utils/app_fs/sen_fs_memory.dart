import 'dart:convert';
import 'dart:typed_data';

import 'sen_fs.dart';

/// In-memory [SenIo] backend used for the web RSB pipeline (and unit tests).
///
/// Paths are normalized to forward slashes so the sen tools — which mix
/// `path.join` (platform separator) and hard-coded `\\`/`/` — resolve to the
/// same key regardless of separator.
class MemorySenIo extends SenIo {
  final Map<String, Uint8List> _files = {};
  final Set<String> _dirs = {};

  /// Seeds the workspace with an initial set of files (keys are paths).
  void seed(Map<String, Uint8List> files) {
    files.forEach(writeBuffer);
  }

  /// A snapshot of every stored file, keyed by normalized path.
  Map<String, Uint8List> get files => Map.unmodifiable(_files);

  String _norm(String path) {
    var p = path.replaceAll('\\', '/');
    while (p.contains('//')) {
      p = p.replaceAll('//', '/');
    }
    if (p.length > 1 && p.endsWith('/')) {
      p = p.substring(0, p.length - 1);
    }
    return p;
  }

  void _registerParents(String normPath) {
    var idx = normPath.lastIndexOf('/');
    while (idx > 0) {
      final dir = normPath.substring(0, idx);
      if (!_dirs.add(dir)) break;
      idx = dir.lastIndexOf('/');
    }
  }

  @override
  Uint8List readBuffer(String path) {
    final data = _files[_norm(path)];
    if (data == null) {
      throw Exception('File not found: $path');
    }
    return data;
  }

  @override
  void writeBuffer(String path, Uint8List data) {
    final key = _norm(path);
    _files[key] = data;
    _registerParents(key);
  }

  @override
  String readFile(String path) => utf8.decode(readBuffer(path));

  @override
  void writeFile(String path, String data) {
    writeBuffer(path, Uint8List.fromList(utf8.encode(data)));
  }

  @override
  bool fileExists(String path) => _files.containsKey(_norm(path));

  @override
  bool directoryExists(String path) {
    final key = _norm(path);
    if (_dirs.contains(key)) return true;
    final prefix = '$key/';
    return _files.keys.any((k) => k.startsWith(prefix));
  }

  @override
  void createDirectory(String path) {
    final key = _norm(path);
    _dirs.add(key);
    _registerParents('$key/x');
  }

  @override
  List<String> listDirectory(String path, {bool recursive = false}) {
    final key = _norm(path);
    final prefix = key.isEmpty ? '' : '$key/';
    if (recursive) {
      return _files.keys.where((k) => k.startsWith(prefix)).toList();
    }
    final children = <String>{};
    void collect(Iterable<String> keys) {
      for (final k in keys) {
        if (!k.startsWith(prefix)) continue;
        final rest = k.substring(prefix.length);
        if (rest.isEmpty) continue;
        final slash = rest.indexOf('/');
        final child = slash == -1 ? rest : rest.substring(0, slash);
        children.add('$prefix$child');
      }
    }

    collect(_files.keys);
    collect(_dirs);
    return children.toList();
  }
}
