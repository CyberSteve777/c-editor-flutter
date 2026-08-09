import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart'
    show
        window,
        FileSystemDirectoryHandle,
        FileSystemFileHandle,
        FileSystemGetDirectoryOptions,
        FileSystemGetFileOptions,
        FileSystemWritableFileStream;

/// Direct Origin Private File System byte I/O.
///
/// `fs_shim`'s `File.readAsBytes` / `writeAsBytes` wrap the (async, non-blocking)
/// OPFS disk API in a synchronous byte-by-byte `List<int>` re-materialization
/// plus a full extra copy. For a 128 MB archive that is ~128M iterations on the
/// UI isolate and freezes the tab. These helpers talk to the File System Access
/// API directly (`getFile()` -> `arrayBuffer()` for reads, `createWritable()` ->
/// `write()` for writes), so the only heavy work is the browser's own native,
/// asynchronous copy — no boxed-list conversion on the main thread.
///
/// Paths are absolute POSIX paths matching the layout `fs_shim` uses, e.g.
/// `/c_editor_levels/folder/level.json`. Directory structure is still managed by
/// `fs_shim`; these helpers only move raw bytes for the hot read/write paths.
class OpfsBytesIo {
  const OpfsBytesIo._();

  static List<String> _segments(String fullPath) {
    return fullPath
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static Future<FileSystemDirectoryHandle> _root() {
    return window.navigator.storage.getDirectory().toDart;
  }

  /// Reads the file at [fullPath], or returns `null` if it does not exist.
  static Future<Uint8List?> read(String fullPath) async {
    final segments = _segments(fullPath);
    if (segments.isEmpty) return null;
    try {
      var dir = await _root();
      for (var i = 0; i < segments.length - 1; i++) {
        dir = await dir.getDirectoryHandle(segments[i]).toDart;
      }
      final fileHandle = await dir.getFileHandle(segments.last).toDart;
      final file = await fileHandle.getFile().toDart;
      final buffer = await file.arrayBuffer().toDart;
      return buffer.toDart.asUint8List();
    } catch (_) {
      // NotFoundError (missing file/dir) or any traversal failure -> treat as
      // absent, matching the previous `exists()` guard.
      return null;
    }
  }

  /// Writes [bytes] to [fullPath], creating parent directories as needed.
  static Future<void> write(String fullPath, Uint8List bytes) async {
    final segments = _segments(fullPath);
    if (segments.isEmpty) {
      throw ArgumentError('Cannot write to empty OPFS path.');
    }
    var dir = await _root();
    for (var i = 0; i < segments.length - 1; i++) {
      dir = await dir
          .getDirectoryHandle(
            segments[i],
            FileSystemGetDirectoryOptions(create: true),
          )
          .toDart;
    }
    final FileSystemFileHandle fileHandle = await dir
        .getFileHandle(
          segments.last,
          FileSystemGetFileOptions(create: true),
        )
        .toDart;
    final FileSystemWritableFileStream writable =
        await fileHandle.createWritable().toDart;
    try {
      if (bytes.isNotEmpty) {
        await writable.write(bytes.toJS).toDart;
      }
    } finally {
      await writable.close().toDart;
    }
  }
}
