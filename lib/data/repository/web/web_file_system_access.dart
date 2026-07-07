import 'dart:js_interop';
import 'dart:typed_data';

@JS('window.cEditorFsa')
external _CEditorFsa? get _cEditorFsa;

extension type _CEditorFsa._(JSObject _) implements JSObject {
  external bool isSupported();
  external JSPromise<JSAny?> pickFolderForImport();
}

/// Cross-browser folder import via [web/fsa_helper.js].
class WebFileSystemAccess {
  WebFileSystemAccess._();

  static final WebFileSystemAccess instance = WebFileSystemAccess._();

  bool get isSupported => _cEditorFsa?.isSupported() ?? false;

  /// Pick a folder for import and read all level files in one JS call.
  Future<({String name, Map<String, Uint8List> files})?> pickFolderForImport() async {
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
    final entries = dartified['entries'];
    if (name is! String || entries is! List) {
      return null;
    }

    final files = <String, Uint8List>{};
    for (final item in entries) {
      if (item is! Map) {
        continue;
      }
      final path = item['path'];
      final bytes = item['bytes'];
      if (path is! String || bytes is! List) {
        continue;
      }
      files[path] = Uint8List.fromList(bytes.cast<int>());
    }

    return (name: name, files: files);
  }
}
