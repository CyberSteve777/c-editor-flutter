import 'package:c_editor/bundled_plugins/level_preview_cplugin/level_preview_cplugin.dart';
import 'package:c_editor/plugins/bundled_plugin.dart';

/// First-party plugins shipped with C-Editor (disable-only).
List<BundledPlugin> get bundledPlugins => [
      LevelPreviewBundledPlugin(),
    ];
