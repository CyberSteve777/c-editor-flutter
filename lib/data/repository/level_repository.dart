import '../pvz_models.dart';
import 'level_repository_base.dart';
import 'level_repository_web.dart'
    if (dart.library.io) 'level_repository_native.dart'
    as impl;

export '../pvz_models.dart' show PvzLevelFile;
export 'level_repository_base.dart' show FileItem, LevelRepositoryBase;

class LevelRepository {
  static final LevelRepositoryBase _impl = impl.createLevelRepository();

  static Future<String?> getSavedFolderPath() => _impl.getSavedFolderPath();

  static Future<void> setSavedFolderPath(String path) =>
      _impl.setSavedFolderPath(path);

  static Future<String> ensureIosLibraryPath() => _impl.ensureIosLibraryPath();

  static Future<List<FileItem>> getFavorites(String rootPath) => _impl.getFavorites(rootPath);

  static Future<bool> ensureFolderAccess() => _impl.ensureFolderAccess();

  static Future<void> setLastOpenedLevelDirectory(String path) =>
      _impl.setLastOpenedLevelDirectory(path);

  static Future<String?> getLastOpenedLevelDirectory() =>
      _impl.getLastOpenedLevelDirectory();

  static Future<String> getCacheDir() => _impl.getCacheDir();

  static Future<bool> fileExistsInDirectory(String dirPath, String fileName) =>
      _impl.fileExistsInDirectory(dirPath, fileName);

  static bool isSupportedLevelFileName(String name) =>
      _impl.isSupportedLevelFileName(name);

  static String baseNameWithoutLevelExtension(String name) =>
      _impl.baseNameWithoutLevelExtension(name);

  static Future<List<FileItem>> getDirectoryContents(String dirPath) =>
      _impl.getDirectoryContents(dirPath);

  static Future<void> setFavoriteLevelPath(String path, bool isFavorite) =>
      _impl.setFavoriteLevelPath(path, isFavorite);

  static Future<bool> createDirectory(String parentPath, String name) =>
      _impl.createDirectory(parentPath, name);

  static Future<bool> renameItem(
    String currentDirPath,
    String oldName,
    String newName,
    bool isDirectory,
  ) => _impl.renameItem(currentDirPath, oldName, newName, isDirectory);

  static Future<void> deleteItem(
    String currentDirPath,
    String fileName,
    bool isDirectory,
  ) => _impl.deleteItem(currentDirPath, fileName, isDirectory);

  static Future<String> getNextAvailableNameForTemplate(
    String dirPath,
    String defaultBaseName,
  ) => _impl.getNextAvailableNameForTemplate(dirPath, defaultBaseName);

  static Future<String> getNextAvailableCopyName(
    String dirPath,
    String baseNameWithoutExt,
  ) => _impl.getNextAvailableCopyName(dirPath, baseNameWithoutExt);

  static Future<bool> copyLevelToTarget(
    String srcPath,
    String targetDirPath,
    String targetFileName,
  ) => _impl.copyLevelToTarget(srcPath, targetDirPath, targetFileName);

  static Future<bool> moveFile(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) => _impl.moveFile(srcDirPath, fileName, destDirPath);

  static Future<bool> moveFileOverwriting(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) => _impl.moveFileOverwriting(srcDirPath, fileName, destDirPath);

  static Future<String?> moveFileAsCopy(
    String srcDirPath,
    String fileName,
    String destDirPath,
  ) => _impl.moveFileAsCopy(srcDirPath, fileName, destDirPath);

  static Future<String?> moveFileWithName(
    String srcDirPath,
    String fileName,
    String destDirPath,
    String newFileName,
  ) => _impl.moveFileWithName(srcDirPath, fileName, destDirPath, newFileName);

  static Future<int> clearAllInternalCache() => _impl.clearAllInternalCache();

  static Future<bool> prepareInternalCache(
    String sourcePath,
    String fileName,
  ) => _impl.prepareInternalCache(sourcePath, fileName);

  static Future<bool> prepareInternalCacheFromBytes(
    String fileName,
    List<int> bytes,
  ) => _impl.prepareInternalCacheFromBytes(fileName, bytes);

  static Future<bool> prepareInternalCacheFromString(
    String fileName,
    String content,
  ) => _impl.prepareInternalCacheFromString(fileName, content);

  static Future<PvzLevelFile?> loadLevel(String fileName) =>
      _impl.loadLevel(fileName);

  static Future<PvzLevelFile?> loadLevelFromPath(String filePath) =>
      _impl.loadLevelFromPath(filePath);

  static Future<void> saveAndExport(String filePath, PvzLevelFile levelData) =>
      _impl.saveAndExport(filePath, levelData);

  static Future<void> downloadLevel(String fileName) =>
      _impl.downloadLevel(fileName);

  static Future<void> downloadAllLevelsAsZip() =>
      _impl.downloadAllLevelsAsZip();

  static Future<List<String>> getTemplateList() => _impl.getTemplateList();

  static List<String> parseTemplateManifest(String jsonString) =>
      _impl.parseTemplateManifest(jsonString);

  static Future<bool> createLevelFromTemplate(
    String currentDirPath,
    String templateName,
    String newFileName,
    String assetContent,
  ) => _impl.createLevelFromTemplate(
    currentDirPath,
    templateName,
    newFileName,
    assetContent,
  );

  static Future<String> getFirstAvailableIndexedName(
    String dirPath,
    String baseName,
    String extension,
  ) => _impl.getFirstAvailableIndexedName(dirPath, baseName, extension);

  static Future<String?> convertLevelFile({
    required String sourcePath,
    required String sourceName,
    required String targetExtension,
    String? targetName,
  }) => _impl.convertLevelFile(
    sourcePath: sourcePath,
    sourceName: sourceName,
    targetExtension: targetExtension,
    targetName: targetName,
  );
}
