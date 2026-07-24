import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/level_preview_cplugin.dart';
import 'package:c_editor/plugins/plugin_package.dart';

/// First-party plugins shipped with C-Editor (disable-only).
///
/// Each entry uses the same package contract as an external `.cplugin`:
/// `manifest.json`, `initialize(CPluginHost)`, and `assets/` (including l10n).
List<CPluginPackageSpec> get bundledPlugins => [
      CPluginPackageSpec(
        id: kLevelPreviewPluginId,
        packageRoot: 'lib/bundled_plugins/level_preview_cplugin',
        initialize: initialize,
      ),
    ];
