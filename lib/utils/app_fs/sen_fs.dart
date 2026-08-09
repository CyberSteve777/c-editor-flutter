import 'dart:convert';
import 'dart:typed_data';

import 'sen_fs_stub.dart' if (dart.library.io) 'sen_fs_native.dart' as platform;

/// Minimal, synchronous filesystem contract used by the sen pack/unpack tools.
///
/// This lives outside the `3rdParty/sen` folder on purpose: the sen sources are
/// third-party (GPL) and must stay free of any concrete filesystem backend. The
/// sen code only talks to [senIo], and the app installs a backend
/// ([IoSenIo] on native, [MemorySenIo] on web/workers) at runtime.
abstract class SenIo {
  Uint8List readBuffer(String path);

  void writeBuffer(String path, Uint8List data);

  String readFile(String path);

  void writeFile(String path, String data);

  bool fileExists(String path);

  bool directoryExists(String path);

  void createDirectory(String path);

  /// Lists entries directly under [path] (or the whole subtree when
  /// [recursive] is true), returning full, joinable paths.
  List<String> listDirectory(String path, {bool recursive = false});

  dynamic readJson(String path) => jsonDecode(readFile(path));

  void writeJson(String path, dynamic data, [String indent = '\t']) {
    writeFile(path, JsonEncoder.withIndent(indent).convert(data));
  }
}

SenIo _current = platform.createDefaultSenIo();

/// The active filesystem backend used by the sen tools. Defaults to a native
/// `dart:io` backend on VM/Flutter and an in-memory backend on the web.
SenIo get senIo => _current;

set senIo(SenIo value) => _current = value;

/// Runs [body] with [io] installed as the active backend, restoring the
/// previous one afterwards. Used to give each web export its own in-memory
/// workspace without leaking state between runs.
T runWithSenIo<T>(SenIo io, T Function() body) {
  final previous = _current;
  _current = io;
  try {
    return body();
  } finally {
    _current = previous;
  }
}
