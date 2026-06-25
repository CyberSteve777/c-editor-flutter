import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/utils/3rdParty/sen_popcap_zlib.dart';
import 'package:c_editor/utils/3rdParty/sen_buffer.dart';
import 'package:c_editor/utils/apple_folder_access.dart';

import '../pvz_models.dart';
import 'level_repository_base.dart';

LevelRepositoryBase createLevelRepository() => LevelRepositoryNativeImpl();

class LevelRepositoryNativeImpl extends LevelRepositoryBase {
  static const _prefsFolderKey = 'folder_path';
  static const _prefsFolderBookmarkKey = 'folder_bookmark';
  static const _prefsLastLevelDirKey = 'last_level_directory';

  @override
  Future<String> ensureIosLibraryPath() => AppleFolderAccess.defaultLibraryPath();

  @override
  Future<List<FileItem>> getFavorites(String rootPath) async {
    final favoritePaths = await readFavoriteLevelPaths();
    final list = <FileItem>[];
    for (final path in favoritePaths) {
      final file = File(path);
      if (await file.exists() && path.startsWith(rootPath)) {
        final stat = await file.stat();
        list.add(FileItem(
          name: p.basename(path),
          path: path,
          isDirectory: false,
          lastModified: stat.modified.millisecondsSinceEpoch,
          size: stat.size,
          isFavorite: true,
        ));
      }
    }
    list.sort((a, b) => naturalCompare(a.name, b.name));
    return list;
  }

  @override
  Future<bool> ensureFolderAccess() async {
    if (!Platform.isIOS) return true;
    final path = await getSavedFolderPath();
    if (path == null || path.isEmpty) return false;
    if (await AppleFolderAccess.isAppSandboxPath(path)) return true;
    return AppleFolderAccess.grantAccessForPath(path);
  }

  Future<void> _requireFolderAccess() async {
    if (!Platform.isIOS) return;
    if (!await ensureFolderAccess()) {
      throw const FileSystemException(
        'Cannot access level library folder',
        'apple_folder_access',
      );
    }
  }

  Future<String?> _resolveIosFolderPath(SharedPreferences prefs) async {
    final bookmark = prefs.getString(_prefsFolderBookmarkKey);
    if (bookmark != null && bookmark.isNotEmpty) {
      final resolved = await AppleFolderAccess.resolveBookmark(bookmark);
      if (resolved != null && resolved.isNotEmpty) {
        final stored = prefs.getString(_prefsFolderKey);
        if (stored != resolved) {
          await prefs.setString(_prefsFolderKey, resolved);
        }
        return resolved;
      }
    }

    final path = prefs.getString(_prefsFolderKey);
    if (path == null || path.isEmpty) return null;

    if (await AppleFolderAccess.isAppSandboxPath(path)) {
      if (await Directory(path).exists()) return path;
      final defaultPath = await ensureIosLibraryPath();
      await prefs.setString(_prefsFolderKey, defaultPath);
      await prefs.remove(_prefsFolderBookmarkKey);
      return defaultPath;
    }

    return path;
  }

  @override
  Future<String?> getSavedFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    if (!Platform.isIOS) {
      return prefs.getString(_prefsFolderKey);
    }
    return _resolveIosFolderPath(prefs);
  }

  @override
  Future<void> setSavedFolderPath(String path) async {
    if (Platform.isIOS && !await AppleFolderAccess.isAppSandboxPath(path)) {
      await AppleFolderAccess.grantAccessForPath(path);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsFolderKey, path);

    if (!Platform.isIOS) return;

    if (await AppleFolderAccess.isAppSandboxPath(path)) {
      await prefs.remove(_prefsFolderBookmarkKey);
      return;
    }

    final bookmark = await AppleFolderAccess.createBookmark(path);
    if (bookmark != null && bookmark.isNotEmpty) {
      await prefs.setString(_prefsFolderBookmarkKey, bookmark);
    } else {
      await prefs.remove(_prefsFolderBookmarkKey);
    }
  }

  @override
  Future<void> setLastOpenedLevelDirectory(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLastLevelDirKey, path);
  }

  @override
  Future<String?> getLastOpenedLevelDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsLastLevelDirKey);
  }

  @override
  Future<String> getCacheDir() async {
    // Internal working copy of levels — keep under app support. Using Documents
    // was unreliable on Linux (XDG user dirs / headless) and blocked opening files.
    final base = await getApplicationSupportDirectory();
    final cacheDir = Directory(p.join(base.path, 'level_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  @override
  Future<bool> fileExistsInDirectory(String dirPath, String fileName) async {
    await _requireFolderAccess();
    final path = p.join(dirPath, fileName);
    return File(path).exists();
  }

  @override
  Future<List<FileItem>> getDirectoryContents(String dirPath) async {
    await _requireFolderAccess();
    final dir = Directory(dirPath);
    if (!await dir.exists()) return [];

    final favoritePaths = await readFavoriteLevelPaths();
    final list = <FileItem>[];
    final entities = await dir
        .list()
        .toList()
        .timeout(const Duration(seconds: 30));
    for (final entity in entities) {
      final stat = await entity.stat();
      final name = p.basename(entity.path);
      final isDir = stat.type == FileSystemEntityType.directory;
      final isLevel = !isDir && isSupportedLevelFileName(name);
      if (isDir || isLevel) {
        list.add(
          FileItem(
            name: name,
            path: entity.path,
            isDirectory: isDir,
            lastModified: stat.modified.millisecondsSinceEpoch,
            size: stat.size,
            isFavorite: !isDir && favoritePaths.contains(entity.path),
          ),
        );
      }
    }

    list.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      if (!a.isDirectory && a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return naturalCompare(a.name, b.name);
    });
    return list;
  }

  @override
  Future<bool> createDirectory(String parentPath, String name) async {
    await _requireFolderAccess();
    final dir = Directory(p.join(parentPath, name));
    if (await dir.exists()) return false;
    await dir.create(recursive: true);
    return true;
  }

  @override
  Future<bool> renameItem(
    String currentDirPath,
    String oldName,
    String newName,
    bool isDirectory,
  ) async {
    await _requireFolderAccess();
    final oldPath = p.join(currentDirPath, oldName);
    final newPath = p.join(currentDirPath, newName);
    if (await File(newPath).exists() || await Directory(newPath).exists()) {
      return false;
    }
    try {
      if (isDirectory) {
        await Directory(oldPath).rename(newPath);
      } else {
        await File(oldPath).rename(newPath);
      }
      if (isDirectory) {
        await moveFavoriteLevelPathPrefix(oldPath, newPath);
      } else {
        await moveFavoriteLevelPath(oldPath, newPath);
      }
      if (!isDirectory) {
        final cacheDir = await getCacheDir();
        final oldCache = p.join(cacheDir, oldName);
        final newCache = p.join(cacheDir, newName);
        if (await File(oldCache).exists()) {
          await File(oldCache).rename(newCache);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> deleteItem(
    String currentDirPath,
    String fileName,
    bool isDirectory,
  ) async {
    await _requireFolderAccess();
    final targetPath = p.join(currentDirPath, fileName);
    if (isDirectory) {
      await Directory(targetPath).delete(recursive: true);
      await removeFavoriteLevelPathPrefix(targetPath);
    } else {
      await File(targetPath).delete();
      await removeFavoriteLevelPath(targetPath);
      final cacheDir = await getCacheDir();
      final cacheFile = File(p.join(cacheDir, fileName));
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
    }
  }

  @override
  Future<bool> copyLevelToTarget(
    String srcPath,
    String targetDirPath,
    String targetFileName,
  ) async {
    await _requireFolderAccess();
    final destPath = p.join(targetDirPath, targetFileName);
    if (await File(destPath).exists()) return false;
    try {
      await File(srcPath).copy(destPath);
      await removeFavoriteLevelPath(destPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> moveFile(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    await _requireFolderAccess();
    if (srcDirPath == destDirPath) return false;
    final srcPath = p.join(srcDirPath, fileName);
    final destPath = p.join(destDirPath, fileName);
    if (await File(destPath).exists()) return false;
    try {
      await File(srcPath).rename(destPath);
      final cacheDir = await getCacheDir();
      final cacheFile = File(p.join(cacheDir, fileName));
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      await moveFavoriteLevelPath(srcPath, destPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> moveFileOverwriting(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    await _requireFolderAccess();
    if (srcDirPath == destDirPath) return false;
    final srcPath = p.join(srcDirPath, fileName);
    final destPath = p.join(destDirPath, fileName);
    try {
      if (await File(destPath).exists()) {
        await File(destPath).delete();
      }
      await File(srcPath).rename(destPath);
      await moveFavoriteLevelPath(srcPath, destPath, clearDestination: true);
      final cacheDir = await getCacheDir();
      final cacheFile = File(p.join(cacheDir, fileName));
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String?> moveFileWithName(
    String srcDirPath,
    String fileName,
    String destDirPath,
    String newFileName,
  ) async {
    await _requireFolderAccess();
    if (srcDirPath == destDirPath) return null;
    final srcPath = p.join(srcDirPath, fileName);
    final destPath = p.join(destDirPath, newFileName);
    try {
      final copied = await copyLevelToTarget(srcPath, destDirPath, newFileName);
      if (!copied) return null;
      await File(srcPath).delete();
      final cacheDir = await getCacheDir();
      final cacheFile = File(p.join(cacheDir, fileName));
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      await moveFavoriteLevelPath(srcPath, destPath);
      return newFileName;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> clearAllInternalCache() async {
    final cacheDir = await getCacheDir();
    final dir = Directory(cacheDir);
    var count = 0;
    await for (final entity in dir.list()) {
      if (entity is File && isSupportedLevelFileName(p.basename(entity.path))) {
        await entity.delete();
        count++;
      }
    }
    return count;
  }

  @override
  Future<bool> prepareInternalCache(String sourcePath, String fileName) async {
    try {
      await _requireFolderAccess();
      final cacheDir = await getCacheDir();
      final destPath = p.join(cacheDir, fileName);
      await File(sourcePath).copy(destPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> prepareInternalCacheFromBytes(
    String fileName,
    List<int> bytes,
  ) async {
    return false;
  }

  @override
  Future<bool> prepareInternalCacheFromString(
    String fileName,
    String content,
  ) async {
    return false;
  }

  @override
  Future<PvzLevelFile?> loadLevel(String fileName) async {
    final cacheDir = await getCacheDir();
    final file = File(p.join(cacheDir, fileName));
    if (!await file.exists()) return null;
    try {
      final bytes = await file.readAsBytes();
      return decodeLevelBytes(fileName, bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PvzLevelFile?> loadLevelFromPath(String filePath) async {
    await _requireFolderAccess();
    final file = File(filePath);
    if (!await file.exists()) return null;
    try {
      final bytes = await file.readAsBytes();
      return decodeLevelBytes(p.basename(filePath), bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> downloadLevel(String fileName) async {}

  @override
  Future<void> downloadAllLevelsAsZip() async {}

  @override
  Future<void> saveAndExport(String filePath, PvzLevelFile levelData) async {
    await _requireFolderAccess();
    final fileName = p.basename(filePath);
    final bytes = encodeLevelBytes(fileName, levelData);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    final cacheDir = await getCacheDir();
    final cachePath = p.join(cacheDir, fileName);
    await File(cachePath).writeAsBytes(bytes, flush: true);
  }

  @override
  Future<String?> convertLevelFile({
    required String sourcePath,
    required String sourceName,
    required String targetExtension,
    String? targetName,
  }) async {
    await _requireFolderAccess();
    final srcFile = File(sourcePath);
    if (!await srcFile.exists()) return null;
    final parent = p.dirname(sourcePath);
    final base = baseNameWithoutLevelExtension(sourceName);
    final target = targetName ?? '$base$targetExtension';
    final targetPath = p.join(parent, target);
    if (await File(targetPath).exists()) return null;

    // ZLib compress — any file → .zlib
    if (targetExtension == '.zlib') {
      try {
        final bytes = await srcFile.readAsBytes();
        final buf = SenBuffer.fromBytes(bytes);
        final compressed = PopCapZlib.compress(buf, false);
        await File(targetPath).writeAsBytes(compressed.toBytes(), flush: true);
        await removeFavoriteLevelPath(targetPath);
        return target;
      } catch (_) {
        return null;
      }
    }

    // ZLib decompress — .zlib → original
    if (sourceName.toLowerCase().endsWith('.zlib')) {
      try {
        final bytes = await srcFile.readAsBytes();
        final buf = SenBuffer.fromBytes(bytes);
        final decompressed = PopCapZlib.uncompress(buf, false);
        await File(
          targetPath,
        ).writeAsBytes(decompressed.toBytes(), flush: true);
        await removeFavoriteLevelPath(targetPath);
        return target;
      } catch (_) {
        return null;
      }
    }

    // existing level format conversion
    final level = decodeLevelBytes(sourceName, await srcFile.readAsBytes());
    if (level == null) return null;
    final outBytes = encodeLevelBytes(target, level);
    await File(targetPath).writeAsBytes(outBytes, flush: true);
    await removeFavoriteLevelPath(targetPath);
    return target;
  }

  @override
  Future<bool> createLevelFromTemplate(
    String currentDirPath,
    String templateName,
    String newFileName,
    String assetContent,
  ) async {
    await _requireFolderAccess();
    final destPath = p.join(currentDirPath, newFileName);
    if (await File(destPath).exists()) return false;
    try {
      await File(destPath).writeAsString(assetContent);
      await removeFavoriteLevelPath(destPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
