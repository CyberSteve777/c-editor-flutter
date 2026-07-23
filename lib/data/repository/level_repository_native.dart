import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_popcap_zlib.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_buffer.dart';
import 'package:c_editor/utils/apple_folder_access.dart';

import '../level_library_startup_cache.dart';
import '../pvz_models.dart';
import 'level_repository_base.dart';
import 'web/web_transfer_progress.dart';

LevelRepositoryBase createLevelRepository() => LevelRepositoryNativeImpl();

class LevelRepositoryNativeImpl extends LevelRepositoryBase {
  static const _prefsFolderKey = 'folder_path';
  static const _prefsFolderBookmarkKey = 'folder_bookmark';
  static const _prefsLastLevelDirKey = 'last_level_directory';
  static const _prefsLibrariesKey = 'libraries_json';

  @override
  Future<String> ensureIosLibraryPath() => AppleFolderAccess.defaultLibraryPath();

  @override
  Future<List<FileItem>> getFavorites(
    String rootPath, {
    LevelSortMode sortMode = LevelSortMode.name,
  }) async {
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
          creationTime: stat.changed.millisecondsSinceEpoch,
          size: stat.size,
          isFavorite: true,
        ));
      }
    }
    _sortItems(list, sortMode);
    return list;
  }

  @override
  Future<bool> ensureFolderAccess() async {
    final path = await getSavedFolderPath();
    if (path == null || path.isEmpty) return false;

    if (Platform.isIOS) {
      if (await AppleFolderAccess.isAppSandboxPath(path)) return true;
      if (!await AppleFolderAccess.grantAccessForPath(path)) return false;
    }

    return await _checkFolderReadWrite(path);
  }

  Future<bool> _checkFolderReadWrite(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) return false;

      // 1. Check Read access
      // Try to list the directory to see if it's readable.
      await dir.list().take(1).toList();

      // 2. Check Write access
      // Try to create and delete a temporary hidden file.
      final testFile = File(p.join(path, '.c_editor_access_test.tmp'));
      await testFile.writeAsString('test', flush: true);
      await testFile.delete();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _requireFolderAccess() async {
    if (!await ensureFolderAccess()) {
      throw const FileSystemException(
        'Cannot access level library folder',
        'folder_access',
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
  Future<LevelLibraryStartupCache> preloadLibrarySettings(
    SharedPreferences prefs,
  ) async {
    final savedFolderPath = !Platform.isIOS
        ? prefs.getString(_prefsFolderKey)
        : await _resolveIosFolderPath(prefs);

    String? displayName;
    if (savedFolderPath != null) {
      final jsonString = prefs.getString(_prefsLibrariesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(jsonString);
          final libs = list.map((e) => LibraryItem.fromJson(e)).toList();
          for (final lib in libs) {
            if (lib.path == savedFolderPath) {
              displayName = lib.displayName;
              break;
            }
          }
        } catch (_) {}
      }
    }

    return LevelLibraryStartupCache(
      savedFolderPath: savedFolderPath,
      lastOpenedLevelDirectory: prefs.getString(_prefsLastLevelDirKey),
      webLibraryDisplayName: displayName,
    );
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

    String? bookmark;
    if (Platform.isIOS) {
      if (await AppleFolderAccess.isAppSandboxPath(path)) {
        await prefs.remove(_prefsFolderBookmarkKey);
      } else {
        bookmark = await AppleFolderAccess.createBookmark(path);
        if (bookmark != null && bookmark.isNotEmpty) {
          await prefs.setString(_prefsFolderBookmarkKey, bookmark);
        } else {
          await prefs.remove(_prefsFolderBookmarkKey);
        }
      }
    }

    // Update libraries list to ensure this path is present and has correct bookmark
    final libraries = await getLibraries();
    final index = libraries.indexWhere((lib) => lib.path == path);
    final displayName = index != -1
        ? libraries[index].displayName
        : p.basename(path).isEmpty
            ? 'Root'
            : p.basename(path);

    final newItem = LibraryItem(
      path: path,
      displayName: displayName,
      bookmark: bookmark,
    );

    if (index != -1) {
      libraries[index] = newItem;
    } else {
      libraries.add(newItem);
    }
    await setLibraries(libraries);
  }

  @override
  Future<List<LibraryItem>> getLibraries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsLibrariesKey);
    if (jsonString == null || jsonString.isEmpty) {
      // Migration: if no libraries list exists, but a folder path exists, create initial list
      final currentPath = await getSavedFolderPath();
      if (currentPath != null && currentPath.isNotEmpty) {
        String? bookmark;
        if (Platform.isIOS) {
          bookmark = prefs.getString(_prefsFolderBookmarkKey);
        }
        return [
          LibraryItem(
            path: currentPath,
            displayName: p.basename(currentPath).isEmpty
                ? 'Default Library'
                : p.basename(currentPath),
            bookmark: bookmark,
          )
        ];
      }
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => LibraryItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> setLibraries(List<LibraryItem> libraries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(libraries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsLibrariesKey, jsonString);
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
  Future<List<FileItem>> getDirectoryContents(
    String dirPath, {
    LevelSortMode sortMode = LevelSortMode.name,
  }) async {
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
            creationTime: stat.changed.millisecondsSinceEpoch,
            size: stat.size,
            isFavorite: !isDir && favoritePaths.contains(entity.path),
          ),
        );
      }
    }

    list.sort((a, b) {
      // 1. Folders always on top, sorted by name
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      if (a.isDirectory) return naturalCompare(a.name, b.name);

      // 2. Favorites always on top of other files
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;

      // 3. File sorting based on mode
      return _compareFiles(a, b, sortMode);
    });

    return list;
  }

  void _sortItems(List<FileItem> list, LevelSortMode mode) {
    list.sort((a, b) => _compareFiles(a, b, mode));
  }

  int _compareFiles(FileItem a, FileItem b, LevelSortMode mode) {
    switch (mode) {
      case LevelSortMode.name:
        return naturalCompare(a.name, b.name);
      case LevelSortMode.modified:
        // Newest first
        return b.lastModified.compareTo(a.lastModified);
      case LevelSortMode.created:
        // Newest first
        return (b.creationTime ?? 0).compareTo(a.creationTime ?? 0);
      case LevelSortMode.size:
        // Largest first
        return b.size.compareTo(a.size);
      case LevelSortMode.type:
        // JSON -> RTON -> HUJSON rank
        final rankCompare = a.extensionRank.compareTo(b.extensionRank);
        if (rankCompare != 0) return rankCompare;
        return naturalCompare(a.name, b.name);
    }
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
  Future<void> downloadAllLevelsAsZip({WebTransferProgress? onProgress}) async {}

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
  bool isSupportedLevelFileName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.rsb.smf')) {
      return !Platform.isIOS;
    }
    return super.isSupportedLevelFileName(name);
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
