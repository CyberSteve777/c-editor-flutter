import 'package:shared_preferences/shared_preferences.dart';

const kDefaultPreviewExportFolder = 'previews';
const kPreviewExportFolderPrefsKey = 'level_preview_export_folder';

class PreviewExportPrefs {
  static Future<String> getFolderName() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(kPreviewExportFolderPrefsKey);
    final trimmed = raw?.trim() ?? '';
    if (trimmed.isEmpty) return kDefaultPreviewExportFolder;
    return sanitizeFolderName(trimmed);
  }

  static Future<void> setFolderName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      kPreviewExportFolderPrefsKey,
      sanitizeFolderName(name),
    );
  }

  /// Keeps folder names filesystem-safe (no path separators).
  static String sanitizeFolderName(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return kDefaultPreviewExportFolder;
    s = s.replaceAll(RegExp(r'[\\/]+'), '_');
    s = s.replaceAll('..', '');
    s = s.replaceAll(RegExp(r'[^A-Za-z0-9_\- ]'), '');
    s = s.replaceAll(RegExp(r'^[\s_]+|[\s_]+$'), '');
    if (s.isEmpty) return kDefaultPreviewExportFolder;
    return s;
  }
}

/// Sanitizes a level / file base name for PNG export.
String sanitizePreviewFileBaseName(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return 'preview';
  // Strip extension if present.
  s = s.replaceAll(RegExp(r'\.(json|hujson|rton|png)$', caseSensitive: false), '');
  s = s.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1f]'), '_');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (s.isEmpty) return 'preview';
  if (s.length > 120) s = s.substring(0, 120);
  return s;
}
