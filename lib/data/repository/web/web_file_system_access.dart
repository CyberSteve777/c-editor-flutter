import 'dart:js_interop';
import 'dart:typed_data';

@JS('window.cEditorFsa')
external _CEditorFsa? get _cEditorFsa;

extension type _CEditorFsa._(JSObject _) implements JSObject {
  external bool isSupported();
  external JSPromise<JSAny?> pickFolderForImport();
  external JSPromise<JSAny?> readFolderImportEntry(String path);
  external void releaseFolderImport();
}

/// Cross-browser folder import via [web/fsa_helper.js].
class WebFileSystemAccess {
  WebFileSystemAccess._();

  static final WebFileSystemAccess instance = WebFileSystemAccess._();

  bool get isSupported => _cEditorFsa?.isSupported() ?? false;

  /// Pick a folder and return only metadata; file bytes are read lazily.
  Future<({String name, List<String> paths})?> pickFolderForImport() async {
    final api = _cEditorFsa;
    if (api == null || !api.isSupported()) {
      return null;
    }
    final raw = await api.pickFolderForImport().toDart;
    if (raw == null) {
      return null;
    }
    final dartified = raw.dartify();
    if (dartified is! Map) {
      return null;
    }

    final name = dartified['name'];
    final paths = dartified['paths'];
    if (name is! String || paths is! List) {
      return null;
    }

    final normalizedPaths = <String>[];
    for (final path in paths) {
      if (path is String && path.isNotEmpty) {
        normalizedPaths.add(path);
      }
    }
    if (normalizedPaths.isEmpty) {
      return null;
    }

    return (name: name, paths: normalizedPaths);
  }

  Future<Uint8List?> readFolderImportEntry(String path) async {
    final api = _cEditorFsa;
    if (api == null) {
      return null;
    }
    final raw = await api.readFolderImportEntry(path).toDart;
    if (raw == null) {
      return null;
    }

    final dartified = raw.dartify();
    if (dartified is! Map) {
      return null;
    }

    final bytes = dartified['bytes'];
    if (bytes is Uint8List) {
      return bytes;
    }
    if (bytes is List) {
      return Uint8List.fromList(bytes.cast<int>());
    }
    return null;
  }

  void releaseFolderImport() {
    _cEditorFsa?.releaseFolderImport();
  }
}
