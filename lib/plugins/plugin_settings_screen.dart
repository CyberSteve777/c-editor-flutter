import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// Screen ids treated as the plugin's settings entry when [configurable] is set.
bool isPluginSettingsScreenId(String screenId) {
  final id = screenId.trim().toLowerCase();
  if (id.isEmpty) return false;
  return id == 'settings' ||
      id == 'config' ||
      id == 'preview_settings' ||
      id.endsWith('_settings');
}

/// Picks the preferred settings screen from [screens], if any.
PluginRegisteredScreen? findPluginSettingsScreen(
  Iterable<PluginRegisteredScreen> screens,
) {
  PluginRegisteredScreen? fallback;
  for (final screen in screens) {
    if (!isPluginSettingsScreenId(screen.screenId)) continue;
    if (screen.screenId == 'settings' || screen.screenId == 'config') {
      return screen;
    }
    fallback ??= screen;
  }
  return fallback;
}
