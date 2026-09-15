/// Reserved level-library folder that holds imported `.cplugin` packages.
const kPluginsFolderName = '.plugins';

/// Reserved level-library folder for per-plugin UTF-8 JSON config files.
const kPluginConfigFolderName = '.plugin_config';

/// Config file name inside `{kPluginConfigFolderName}/{pluginId}/`.
const kPluginConfigFileName = 'config.json';

/// Returns true when [name] is reserved for the editor plugin store / config.
bool isReservedLibraryFolderName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return false;
  final lower = trimmed.toLowerCase();
  return trimmed == kPluginsFolderName ||
      lower == kPluginsFolderName ||
      trimmed == kPluginConfigFolderName ||
      lower == kPluginConfigFolderName;
}
