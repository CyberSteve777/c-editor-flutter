import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../pvz_models.dart';
import 'level_repository_base.dart';

/// Virtual path prefix for web - files opened via picker have no real path.
const String _webPathPrefix = 'web://';

String _normalizeWebDirPath(String path) {
  if (path.isEmpty || path == _webPathPrefix) return _webPathPrefix;
  var value = path;
  if (!value.startsWith(_webPathPrefix)) {
    value = '$_webPathPrefix$value';
  }
  while (value.endsWith('/') && value.length > _webPathPrefix.length) {
    value = value.substring(0, value.length - 1);
  }
  return value;
}

String _webJoin(String dirPath, String name) {
  final dir = _normalizeWebDirPath(dirPath);
  final cleanName = name.replaceAll('\\', '/').trim();
  if (dir == _webPathPrefix) {
    return '$_webPathPrefix$cleanName';
  }
  return '$dir/$cleanName';
}

String _parentWebDir(String path) {
  final normalized = _normalizeWebDirPath(path);
  if (normalized == _webPathPrefix) return _webPathPrefix;
  final idx = normalized.lastIndexOf('/');
  if (idx < _webPathPrefix.length) return _webPathPrefix;
  return normalized.substring(0, idx);
}

String _relativeFromWebPath(String path) {
  final normalized = _normalizeWebDirPath(path);
  if (normalized == _webPathPrefix) return '';
  return normalized.substring(_webPathPrefix.length);
}

String _leafNameFromWebPath(String path) {
  final rel = path.startsWith(_webPathPrefix)
      ? _relativeFromWebPath(path)
      : path;
  final clean = rel.replaceAll('\\', '/');
  final idx = clean.lastIndexOf('/');
  return idx >= 0 ? clean.substring(idx + 1) : clean;
}

String _extensionFromName(String name) {
  final leaf = _leafNameFromWebPath(name);
  final idx = leaf.lastIndexOf('.');
  if (idx <= 0 || idx == leaf.length - 1) return '';
  return leaf.substring(idx + 1).toLowerCase();
}

String _fileNameFromPath(String filePath) {
  if (filePath.startsWith(_webPathPrefix)) {
    return filePath.substring(_webPathPrefix.length);
  }
  return p.basename(filePath);
}

LevelRepositoryBase createLevelRepository() => LevelRepositoryWebImpl();

class LevelRepositoryWebImpl extends LevelRepositoryBase {
  static const _prefsFolderKey = 'folder_path';
  static const _prefsLastLevelDirKey = 'last_level_directory';

  final Map<String, Uint8List> _memoryCache = {};
  final Set<String> _directories = {_webPathPrefix};

  @override
  Future<String?> getSavedFolderPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsFolderKey);
  }

  @override
  Future<void> setSavedFolderPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsFolderKey, path);
  }

  @override
  Future<List<FileItem>> getFavorites(String rootPath) async {
    final favoritePaths = await readFavoriteLevelPaths();
    final items = <FileItem>[];

    for (final entry in _memoryCache.entries) {
      final fullPath = entry.key.startsWith(_webPathPrefix)
          ? entry.key
          : '$_webPathPrefix${entry.key}';

      if (favoritePaths.contains(fullPath)) {
        final name = _leafNameFromWebPath(fullPath);
        items.add(
          FileItem(
            name: name,
            path: fullPath,
            isDirectory: false,
            lastModified: 0,
            size: entry.value.length,
            isFavorite: true,
          ),
        );
      }
    }

    items.sort((a, b) => naturalCompare(a.name, b.name));
    return items;
  }

  @override
  Future<String> ensureIosLibraryPath() async => _webPathPrefix;

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
  Future<String> getCacheDir() async => _webPathPrefix;

  @override
  Future<bool> fileExistsInDirectory(String dirPath, String fileName) async {
    final filePath = _webJoin(dirPath, fileName);
    final key = _relativeFromWebPath(filePath);
    return _memoryCache.containsKey(key);
  }

  @override
  Future<List<FileItem>> getDirectoryContents(String dirPath) async {
    if (!dirPath.startsWith(_webPathPrefix)) return [];
    final normalized = _normalizeWebDirPath(dirPath);
    _directories.add(_webPathPrefix);

    final favoritePaths = await readFavoriteLevelPaths();
    final items = <FileItem>[];

    final childDirs = _directories
        .where((d) => d != normalized && _parentWebDir(d) == normalized)
        .toList();
    for (final dir in childDirs) {
      items.add(
        FileItem(
          name: _leafNameFromWebPath(dir),
          path: dir,
          isDirectory: true,
          lastModified: 0,
          size: 0,
        ),
      );
    }

    for (final entry in _memoryCache.entries) {
      final fullPath = entry.key.startsWith(_webPathPrefix)
          ? _normalizeWebDirPath(entry.key)
          : '$_webPathPrefix${entry.key}';
      if (_parentWebDir(fullPath) != normalized) continue;
      final name = _leafNameFromWebPath(fullPath);
      if (!isSupportedLevelFileName(name)) continue;
      items.add(
        FileItem(
          name: name,
          path: fullPath,
          isDirectory: false,
          lastModified: 0,
          size: entry.value.length,
          isFavorite: favoritePaths.contains(fullPath),
        ),
      );
    }

    items.sort((a, b) {
      if (a.isDirectory != b.isDirectory) return a.isDirectory ? -1 : 1;
      if (!a.isDirectory && a.isFavorite != b.isFavorite) {
        return a.isFavorite ? -1 : 1;
      }
      return naturalCompare(a.name, b.name);
    });
    return items;
  }

  @override
  Future<bool> createDirectory(String parentPath, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.contains('/') || trimmed.contains('\\')) {
      return false;
    }
    final parent = _normalizeWebDirPath(parentPath);
    if (!_directories.contains(parent)) return false;
    final newDir = _webJoin(parent, trimmed);
    if (_directories.contains(newDir)) return false;
    final newKey = _relativeFromWebPath(newDir);
    if (_memoryCache.containsKey(newKey)) return false;
    _directories.add(newDir);
    return true;
  }

  @override
  Future<bool> renameItem(
    String currentDirPath,
    String oldName,
    String newName,
    bool isDirectory,
  ) async {
    final currentDir = _normalizeWebDirPath(currentDirPath);
    final oldPath = _webJoin(currentDir, oldName);
    final newPath = _webJoin(currentDir, newName);
    if (newName.trim().isEmpty ||
        newName.contains('/') ||
        newName.contains('\\')) {
      return false;
    }
    if (isDirectory) {
      if (!_directories.contains(oldPath) || _directories.contains(newPath)) {
        return false;
      }
      final newKey = _relativeFromWebPath(newPath);
      if (_memoryCache.containsKey(newKey)) return false;

      final oldPrefix = '$oldPath/';
      final dirsToRename = _directories
          .where((d) => d == oldPath || d.startsWith(oldPrefix))
          .toList();
      final filesToRename = _memoryCache.entries
          .where(
            (e) =>
                ('$_webPathPrefix${e.key}') == oldPath ||
                ('$_webPathPrefix${e.key}').startsWith(oldPrefix),
          )
          .toList();

      for (final d in dirsToRename) {
        _directories.remove(d);
      }
      for (final d in dirsToRename) {
        final renamed = d == oldPath
            ? newPath
            : '$newPath/${d.substring(oldPrefix.length)}';
        _directories.add(renamed);
      }

      for (final e in filesToRename) {
        _memoryCache.remove(e.key);
      }
      for (final e in filesToRename) {
        final full = '$_webPathPrefix${e.key}';
        final renamedFull = full == oldPath
            ? newPath
            : '$newPath/${full.substring(oldPrefix.length)}';
        _memoryCache[_relativeFromWebPath(renamedFull)] = e.value;
      }
      await moveFavoriteLevelPathPrefix(oldPath, newPath);
      return true;
    }

    final oldKey = _relativeFromWebPath(oldPath);
    final newKey = _relativeFromWebPath(newPath);
    if (!_memoryCache.containsKey(oldKey)) return false;
    if (_memoryCache.containsKey(newKey) || _directories.contains(newPath)) {
      return false;
    }
    final content = _memoryCache.remove(oldKey)!;
    _memoryCache[newKey] = content;
    await moveFavoriteLevelPath(oldPath, newPath);
    return true;
  }

  @override
  Future<void> deleteItem(
    String currentDirPath,
    String fileName,
    bool isDirectory,
  ) async {
    final currentDir = _normalizeWebDirPath(currentDirPath);
    final targetPath = _webJoin(currentDir, fileName);
    if (isDirectory) {
      final prefix = '$targetPath/';
      _directories.removeWhere((d) => d == targetPath || d.startsWith(prefix));
      _memoryCache.removeWhere((k, _) {
        final full = '$_webPathPrefix$k';
        return full == targetPath || full.startsWith(prefix);
      });
      _directories.add(_webPathPrefix);
      await removeFavoriteLevelPathPrefix(targetPath);
      return;
    }
    _memoryCache.remove(_relativeFromWebPath(targetPath));
    await removeFavoriteLevelPath(targetPath);
  }

  @override
  Future<bool> copyLevelToTarget(
    String srcPath,
    String targetDirPath,
    String targetFileName,
  ) async {
    final srcName = _fileNameFromPath(srcPath);
    final targetPath = _webJoin(targetDirPath, targetFileName);
    final targetKey = _relativeFromWebPath(targetPath);
    if (!_memoryCache.containsKey(srcName)) return false;
    if (_memoryCache.containsKey(targetKey)) return false;
    _memoryCache[targetKey] = _memoryCache[srcName]!;
    await removeFavoriteLevelPath(targetPath);
    return true;
  }

  @override
  Future<bool> moveFile(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    if (srcDirPath == destDirPath) return false;
    final srcKey = _relativeFromWebPath(_webJoin(srcDirPath, fileName));
    final dstKey = _relativeFromWebPath(_webJoin(destDirPath, fileName));
    if (!_memoryCache.containsKey(srcKey) || _memoryCache.containsKey(dstKey)) {
      return false;
    }
    _memoryCache[dstKey] = _memoryCache.remove(srcKey)!;
    await moveFavoriteLevelPath(
      _webJoin(srcDirPath, fileName),
      _webJoin(destDirPath, fileName),
    );
    return true;
  }

  @override
  Future<bool> moveFileOverwriting(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) async {
    if (srcDirPath == destDirPath) return false;
    final srcPath = _webJoin(srcDirPath, fileName);
    final destPath = _webJoin(destDirPath, fileName);
    final srcKey = _relativeFromWebPath(_webJoin(srcDirPath, fileName));
    final dstKey = _relativeFromWebPath(_webJoin(destDirPath, fileName));
    if (!_memoryCache.containsKey(srcKey)) return false;
    _memoryCache.remove(dstKey);
    _memoryCache[dstKey] = _memoryCache.remove(srcKey)!;
    await moveFavoriteLevelPath(srcPath, destPath, clearDestination: true);
    return true;
  }

  @override
  Future<String?> moveFileWithName(
    String srcDirPath,
    String fileName,
    String destDirPath,
    String newFileName,
  ) async {
    if (srcDirPath == destDirPath) return null;
    final srcPath = _webJoin(srcDirPath, fileName);
    final destPath = _webJoin(destDirPath, newFileName);
    final srcKey = _relativeFromWebPath(_webJoin(srcDirPath, fileName));
    final dstKey = _relativeFromWebPath(_webJoin(destDirPath, newFileName));
    if (!_memoryCache.containsKey(srcKey)) return null;
    if (_memoryCache.containsKey(dstKey)) return null;
    _memoryCache[dstKey] = _memoryCache.remove(srcKey)!;
    await moveFavoriteLevelPath(srcPath, destPath);
    return newFileName;
  }

  @override
  Future<int> clearAllInternalCache() async {
    final count = _memoryCache.length;
    _memoryCache.clear();
    _directories
      ..clear()
      ..add(_webPathPrefix);
    return count;
  }

  @override
  Future<bool> prepareInternalCache(String sourcePath, String fileName) async {
    final sourceKey = _fileNameFromPath(sourcePath);
    if (_memoryCache.containsKey(sourceKey)) return true;
    if (_memoryCache.containsKey(fileName)) return true;
    return false;
  }

  @override
  Future<bool> prepareInternalCacheFromString(
    String fileName,
    String content,
  ) async {
    _memoryCache[fileName] = Uint8List.fromList(utf8.encode(content));
    var dir = _parentWebDir('$_webPathPrefix$fileName');
    while (true) {
      _directories.add(dir);
      if (dir == _webPathPrefix) break;
      dir = _parentWebDir(dir);
    }
    return true;
  }

  @override
  Future<bool> prepareInternalCacheFromBytes(
    String fileName,
    List<int> bytes,
  ) async {
    _memoryCache[fileName] = Uint8List.fromList(bytes);
    var dir = _parentWebDir('$_webPathPrefix$fileName');
    while (true) {
      _directories.add(dir);
      if (dir == _webPathPrefix) break;
      dir = _parentWebDir(dir);
    }
    return true;
  }

  @override
  Future<PvzLevelFile?> loadLevel(String fileName) async {
    final content = _memoryCache[fileName];
    if (content == null) return null;
    return decodeLevelBytes(fileName, content);
  }

  @override
  Future<PvzLevelFile?> loadLevelFromPath(String filePath) async {
    final fileName = _fileNameFromPath(filePath);
    return loadLevel(fileName);
  }

  @override
  Future<void> saveAndExport(String filePath, PvzLevelFile levelData) async {
    final fileName = _fileNameFromPath(filePath);
    _memoryCache[fileName] = encodeLevelBytes(fileName, levelData);
  }

  @override
  Future<void> downloadLevel(String fileName) async {
    Uint8List? content = _memoryCache[fileName];
    if (content == null && fileName.startsWith(_webPathPrefix)) {
      content = _memoryCache[_relativeFromWebPath(fileName)];
    }
    if (content == null) {
      final targetLeaf = _leafNameFromWebPath(fileName);
      final matches = _memoryCache.entries
          .where((e) => _leafNameFromWebPath(e.key) == targetLeaf)
          .toList();
      if (matches.length == 1) {
        content = matches.first.value;
        fileName = _leafNameFromWebPath(matches.first.key);
      }
    }
    if (content == null) return;
    final downloadName = _leafNameFromWebPath(fileName);
    final ext = _extensionFromName(downloadName);
    await FilePicker.saveFile(
      dialogTitle: 'Save level',
      fileName: downloadName,
      type: FileType.custom,
      allowedExtensions: [ext.isEmpty ? 'json' : ext],
      bytes: content,
    );
  }

  @override
  Future<void> downloadAllLevelsAsZip() async {
    if (_memoryCache.isEmpty) return;
    final archive = Archive();
    for (final entry in _memoryCache.entries) {
      archive.addFile(ArchiveFile(entry.key, entry.value.length, entry.value));
    }
    final zipBytes = ZipEncoder().encode(archive);
    await _triggerDownloadBytes('levels.zip', Uint8List.fromList(zipBytes));
  }

  Future<void> _triggerDownloadBytes(String fileName, Uint8List bytes) async {
    await FilePicker.saveFile(
      dialogTitle: 'Save file',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['zip'],
      bytes: bytes,
    );
  }

  @override
  Future<bool> createLevelFromTemplate(
    String currentDirPath,
    String templateName,
    String newFileName,
    String assetContent,
  ) async {
    final filePath = _webJoin(currentDirPath, newFileName);
    final key = _relativeFromWebPath(filePath);
    if (_memoryCache.containsKey(key)) return false;
    _memoryCache[key] = Uint8List.fromList(utf8.encode(assetContent));
    await removeFavoriteLevelPath(filePath);
    return true;
  }

  @override
  Future<String?> convertLevelFile({
    required String sourcePath,
    required String sourceName,
    required String targetExtension,
    String? targetName,
  }) async {
    final srcName = _fileNameFromPath(sourcePath);
    final bytes = _memoryCache[srcName];
    if (bytes == null) return null;
    final level = decodeLevelBytes(sourceName, bytes);
    if (level == null) return null;
    final sourceDir = _parentWebDir('$_webPathPrefix$srcName');
    final targetNameOnly =
        targetName ??
        '${baseNameWithoutLevelExtension(sourceName)}$targetExtension';
    final targetPath = _webJoin(sourceDir, targetNameOnly);
    final target = _relativeFromWebPath(targetPath);
    if (_memoryCache.containsKey(target)) return null;
    _memoryCache[target] = encodeLevelBytes(target, level);
    await removeFavoriteLevelPath(targetPath);
    return target;
  }
}
