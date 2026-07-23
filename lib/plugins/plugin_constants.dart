/// Reserved level-library folder that holds imported `.cplugin` packages.
const kPluginsFolderName = '.plugins';

/// Returns true when [name] is reserved for the editor plugin store.
bool isReservedLibraryFolderName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return false;
  return trimmed == kPluginsFolderName ||
      trimmed.toLowerCase() == kPluginsFolderName;
}
