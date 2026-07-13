import 'dart:typed_data';

import 'package:c_editor/data/repository/web/web_folder_picker.dart';

/// Web folder import facade (Dart-only; no File System Access API).
class WebFileSystemAccess {
  WebFileSystemAccess._();

  static final WebFileSystemAccess instance = WebFileSystemAccess._();

  final WebFolderPicker _picker = WebFolderPicker.instance;

  bool get isSupported => _picker.isSupported;

  Future<({String name, List<String> paths})?> pickFolderForImport() =>
      _picker.pickFolderForImport();

  Future<Uint8List?> readFolderImportEntry(String path) =>
      _picker.readFolderImportEntry(path);

  void releaseFolderImport() => _picker.releaseFolderImport();
}
