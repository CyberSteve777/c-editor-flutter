import 'package:shared_preferences/shared_preferences.dart';

enum PreviewToolbarStyle { compact, full }

const kPreviewToolbarStylePrefsKey = 'level_preview_toolbar_style';

class PreviewToolbarPrefs {
  static Future<PreviewToolbarStyle> getStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kPreviewToolbarStylePrefsKey) == 'compact'
        ? PreviewToolbarStyle.compact
        : PreviewToolbarStyle.full;
  }

  static Future<void> setStyle(PreviewToolbarStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(kPreviewToolbarStylePrefsKey, style.name)) {
      throw StateError('Failed to save preview toolbar style');
    }
  }
}
