import 'dart:js_interop';
import 'dart:typed_data';

@JS('window.cEditorFsa')
external _CEditorFsa? get _cEditorFsa;

extension type _CEditorFsa._(JSObject _) implements JSObject {
  external bool isSupported();
  external bool supportsNativeWrite();
  external String getHandleKind(JSObject handle);
  external String getHandleName(JSObject handle);
  external JSPromise<JSAny?> pickDirectory();
  external JSPromise<JSAny?> pickFolderForImport();
  external JSPromise<JSBoolean> ensurePermission(JSObject handle);
  external JSPromise<JSObject> readAllLevelFiles(JSObject handle);
  external JSPromise<JSAny?> writeFile(
    JSObject handle,
    String relativePath,
    JSUint8Array bytes,
  );
  external JSPromise<JSAny?> deleteFile(JSObject handle, String relativePath);
  external JSObject? storageHandleForPersistence(JSObject handle);
}

/// Cross-browser folder access via [web/fsa_helper.js].
///
/// Chromium uses the File System Access API (live read/write).
/// Firefox, Safari, and others use a `webkitdirectory` import fallback
/// (read on connect; levels persist in IndexedDB, export via save dialogs).
class WebFileSystemAccess {
  WebFileSystemAccess._();

  static final WebFileSystemAccess instance = WebFileSystemAccess._();

  static const kindNative = 'native';
  static const kindImport = 'import';

  bool get isSupported => _cEditorFsa?.isSupported() ?? false;

  bool get supportsNativeWrite => _cEditorFsa?.supportsNativeWrite() ?? false;

  Future<JSObject?> pickDirectory() async {
    final api = _cEditorFsa;
    if (api == null || !api.isSupported()) {
      return null;
    }
    final handle = await api.pickDirectory().toDart;
    if (handle == null) {
      return null;
    }
    return handle as JSObject;
  }

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

  String getHandleKind(JSObject handle) =>
      _cEditorFsa?.getHandleKind(handle) ?? '';

  String getHandleName(JSObject handle) =>
      _cEditorFsa?.getHandleName(handle) ?? 'Folder';

  bool isImportHandle(JSObject handle) =>
      getHandleKind(handle) == kindImport;

  bool isNativeHandle(JSObject handle) =>
      getHandleKind(handle) == kindNative;

  JSObject? storageHandleForPersistence(JSObject handle) =>
      _cEditorFsa?.storageHandleForPersistence(handle);

  Future<bool> ensurePermission(JSObject handle) async {
    final api = _cEditorFsa;
    if (api == null) {
      return false;
    }
    if (isImportHandle(handle)) {
      return true;
    }
    final result = await api.ensurePermission(handle).toDart;
    return result.toDart;
  }

  Future<Map<String, Uint8List>> readAllLevelFiles(JSObject handle) async {
    final api = _cEditorFsa;
    if (api == null) {
      return {};
    }
    final jsMap = await api.readAllLevelFiles(handle).toDart;
    final dartified = jsMap.dartify();
    if (dartified is! Map) {
      return {};
    }

    final result = <String, Uint8List>{};
    for (final entry in dartified.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String) {
        continue;
      }
      if (value is Uint8List) {
        result[key] = value;
      } else if (value is List) {
        result[key] = Uint8List.fromList(value.cast<int>());
      }
    }
    return result;
  }

  Future<void> writeFile(
    JSObject handle,
    String relativePath,
    Uint8List bytes,
  ) async {
    final api = _cEditorFsa;
    if (api == null) {
      return;
    }
    await api.writeFile(handle, relativePath, bytes.toJS).toDart;
  }

  Future<void> deleteFile(JSObject handle, String relativePath) async {
    final api = _cEditorFsa;
    if (api == null) {
      return;
    }
    await api.deleteFile(handle, relativePath).toDart;
  }
}
