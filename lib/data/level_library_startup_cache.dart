/// Cached level-library prefs loaded during app bootstrap.
class LevelLibraryStartupCache {
  const LevelLibraryStartupCache({
    this.savedFolderPath,
    this.lastOpenedLevelDirectory,
    this.webLibraryDisplayName,
    this.webReady = false,
  });

  final String? savedFolderPath;
  final String? lastOpenedLevelDirectory;
  final String? webLibraryDisplayName;
  final bool webReady;
}
