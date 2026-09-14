import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/level_preview_constants.dart';
import 'package:c_editor/plugins/plugin_config_store.dart';

enum PreviewToolbarStyle { compact, full }

/// Legacy SharedPreferences key (migrated into plugin config once).
const kPreviewToolbarStylePrefsKey = 'level_preview_toolbar_style';

/// Config JSON key for toolbar presentation.
const kPreviewConfigToolbarStyleKey = 'toolbarStyle';

/// ARB key for the toolbar-style config option title.
const kPreviewConfigToolbarStyleTitleKey = 'configToolbarStyle';

/// ARB key for the toolbar-style config option description.
const kPreviewConfigToolbarStyleDescriptionKey = 'configToolbarStyleDescription';

class PreviewToolbarPrefs {
  static Future<PreviewToolbarStyle> getStyle() async {
    await _migrateLegacyIfNeeded();
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    final raw = map[kPreviewConfigToolbarStyleKey];
    return raw == 'compact'
        ? PreviewToolbarStyle.compact
        : PreviewToolbarStyle.full;
  }

  static Future<void> setStyle(PreviewToolbarStyle style) async {
    await _migrateLegacyIfNeeded();
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    map[kPreviewConfigToolbarStyleKey] = style.name;
    await PluginConfigStore.instance.writeMap(kLevelPreviewPluginId, map);
  }

  static Future<void> _migrateLegacyIfNeeded() async {
    final map = await PluginConfigStore.instance.readMap(kLevelPreviewPluginId);
    if (map.containsKey(kPreviewConfigToolbarStyleKey)) return;
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(kPreviewToolbarStylePrefsKey);
    if (legacy == null || legacy.isEmpty) return;
    map[kPreviewConfigToolbarStyleKey] =
        legacy == 'compact' ? 'compact' : 'full';
    await PluginConfigStore.instance.writeMap(kLevelPreviewPluginId, map);
    await prefs.remove(kPreviewToolbarStylePrefsKey);
  }
}
