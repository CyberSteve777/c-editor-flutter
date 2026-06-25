import 'dart:io';

import 'package:accessing_security_scoped_resource/accessing_security_scoped_resource.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// iOS security-scoped folder access and bookmark persistence.
class AppleFolderAccess {
  static const _bookmarkChannel = MethodChannel('c_editor/folder_bookmark');

  static AppleScopedResource? _activeResource;
  static String? _activePath;

  static Future<bool> grantAccessForPath(String path) async {
    if (!Platform.isIOS) return true;
    if (_activePath == path && _activeResource?.granted == true) {
      return true;
    }

    await releaseAccess();

    final pathResource = AppleScopedResource(path, isFilePath: true);
    await pathResource.requestAccess();
    if (pathResource.granted) {
      _activeResource = pathResource;
      _activePath = path;
      return true;
    }

    final urlResource = AppleScopedResource(
      Uri.directory(path).toString(),
    );
    await urlResource.requestAccess();
    if (urlResource.granted) {
      _activeResource = urlResource;
      _activePath = path;
      return true;
    }

    return false;
  }

  static Future<void> releaseAccess() async {
    await _activeResource?.release();
    _activeResource = null;
    _activePath = null;
  }

  static Future<String?> createBookmark(String path) async {
    if (!Platform.isIOS) return null;
    try {
      final bookmark = await _bookmarkChannel.invokeMethod<String>(
        'createBookmark',
        path,
      );
      return bookmark;
    } on PlatformException {
      return null;
    }
  }

  static Future<String?> resolveBookmark(String bookmark) async {
    if (!Platform.isIOS) return null;
    try {
      final path = await _bookmarkChannel.invokeMethod<String>(
        'resolveBookmark',
        bookmark,
      );
      return path;
    } on PlatformException {
      return null;
    }
  }

  static Future<String> defaultLibraryPath() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'C-Editor Levels'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<bool> isAppSandboxPath(String path) async {
    final docs = await getApplicationDocumentsDirectory();
    final support = await getApplicationSupportDirectory();
    final normalized = p.normalize(path);
    return normalized.startsWith(p.normalize(docs.path)) ||
        normalized.startsWith(p.normalize(support.path));
  }
}
