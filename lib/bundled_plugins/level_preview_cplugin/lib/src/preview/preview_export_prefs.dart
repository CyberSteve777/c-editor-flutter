import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_constants.dart';
import 'package:c_editor/plugins/plugin_config_store.dart';

const kDefaultPreviewExportFolder = 'previews';

/// Legacy SharedPreferences key (migrated into plugin config once).
const kPreviewExportFolderPrefsKey = 'level_preview_export_folder';

/// Config JSON key for the export folder (Unicode path segments allowed).
const kPreviewConfigExportFolderKey = 'exportFolder';

/// ARB key for the export-folder config option title.
const kPreviewConfigExportFolderTitleKey = 'configExportFolder';

/// ARB key for the export-folder config option description.
const kPreviewConfigExportFolderDescriptionKey = 'configExportFolderDescription';

class PreviewExportPrefs {
  static Future<String> getFolderName() async {
    await _migrateLegacyIfNeeded();
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    final raw = map[kPreviewConfigExportFolderKey];
    final trimmed = raw is String ? raw.trim() : '';
    if (trimmed.isEmpty) return kDefaultPreviewExportFolder;
    return normalizeRelativeFolderPath(trimmed);
  }

  static Future<void> setFolderPath(String path) async {
    await _migrateLegacyIfNeeded();
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    map[kPreviewConfigExportFolderKey] = normalizeRelativeFolderPath(path);
    await PluginConfigStore.instance.writeMap(kLevelPreviewPluginId, map);
  }

  /// Workspace-relative paths, preserving nested folders and localized names.
  /// Absolute paths and parent traversal never escape the selected workspace.
  static String normalizeRelativeFolderPath(String raw) {
    final path = raw.trim().replaceAll('\\', '/');
    if (path.isEmpty) return kDefaultPreviewExportFolder;
    if (path.startsWith('/') || RegExp(r'[<>:"|?*\x00-\x1f]').hasMatch(path)) {
      return kDefaultPreviewExportFolder;
    }
    final parts = path.split('/');
    if (parts.contains('..')) return kDefaultPreviewExportFolder;
    final names = parts.where((part) => part.isNotEmpty && part != '.');
    return names.isEmpty ? '.' : names.join('/');
  }

  static Future<void> setFolderName(String name) async {
    await setFolderPath(sanitizeFolderName(name));
  }

  /// Keeps folder names filesystem-safe (no path separators).
  static String sanitizeFolderName(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return kDefaultPreviewExportFolder;
    s = s.replaceAll(RegExp(r'[\\/]+'), '_');
    s = s.replaceAll('..', '');
    s = s.replaceAll(RegExp(r'[<>:"|?*\x00-\x1f]'), '');
    s = s.replaceAll(RegExp(r'^[\s_]+|[\s_]+$'), '');
    if (s.isEmpty) return kDefaultPreviewExportFolder;
    return s;
  }

  static Future<void> _migrateLegacyIfNeeded() async {
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    if (map.containsKey(kPreviewConfigExportFolderKey)) return;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(kPreviewExportFolderPrefsKey)?.trim() ?? '';
    if (legacy.isEmpty) return;
    map[kPreviewConfigExportFolderKey] = normalizeRelativeFolderPath(legacy);
    await PluginConfigStore.instance.writeMap(kLevelPreviewPluginId, map);
    await prefs.remove(kPreviewExportFolderPrefsKey);
  }
}

String previewExportDirectoryPath(String workspace, String relativeFolder) {
  final relative = PreviewExportPrefs.normalizeRelativeFolderPath(
    relativeFolder,
  );
  if (relative == '.') return workspace;
  if (workspace.startsWith('web://')) {
    return workspace == 'web://'
        ? '$workspace$relative'
        : '${workspace.replaceAll(RegExp(r'/+$'), '')}/$relative';
  }
  return p.joinAll([workspace, ...relative.split('/')]);
}

bool isValidPreviewExportFolderName(String name) =>
    name.isNotEmpty &&
    name != '.' &&
    name != '..' &&
    !name.endsWith('.') &&
    !RegExp(r'[<>:"/\\|?*\x00-\x1f]').hasMatch(name) &&
    !RegExp(
      r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
      caseSensitive: false,
    ).hasMatch(name);

String previewExportFilePath(String directory, String fileName) {
  if (directory.startsWith('web://')) {
    return directory == 'web://'
        ? '$directory$fileName'
        : '$directory/$fileName';
  }
  return p.join(directory, fileName);
}

String previewExportFileName(String path) => path.startsWith('web://')
    ? path.substring(path.lastIndexOf('/') + 1)
    : p.basename(path);

String previewExportParentDirectory(String path) {
  if (!path.startsWith('web://')) return p.dirname(path);
  final slash = path.lastIndexOf('/');
  return slash < 'web://'.length ? 'web://' : path.substring(0, slash);
}

/// Repository web cache keys must retain the complete workspace-relative path.
String previewExportLibraryRelativePath(String path, String workspace) {
  final root = workspace == 'web://'
      ? workspace
      : workspace.replaceAll('\\', '/').replaceAll(RegExp(r'/+$'), '');
  final normalized = path.replaceAll('\\', '/');
  final prefix = root == 'web://' ? root : '$root/';
  if (!normalized.startsWith(prefix)) {
    throw ArgumentError('Preview export path is outside the workspace');
  }
  final relative = normalized.substring(prefix.length);
  if (relative.isEmpty || relative.split('/').contains('..')) {
    throw ArgumentError('Invalid preview export path');
  }
  return relative;
}

/// Sanitizes a level / file base name for image export.
String sanitizePreviewFileBaseName(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return 'preview';
  // Strip extension if present.
  s = s.replaceAll(
    RegExp(r'\.(json|hujson|rton|png|gif)$', caseSensitive: false),
    '',
  );
  s = s.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty) return 'preview';
  if (s.length > 120) s = s.substring(0, 120);
  return s;
}
