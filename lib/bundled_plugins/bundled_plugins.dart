import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/main.dart'
    as dynamic_fetch;
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/main.dart'
    as level_preview;
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/registration.dart'
    show kDynamicFetchPluginId;
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/registration.dart'
    show kLevelPreviewPluginId;
import 'package:c_editor/plugins/plugin_package.dart';

/// First-party plugins shipped with C-Editor (disable-only).
///
/// Each entry uses the same package contract as an external `.cplugin`:
/// `manifest.json`, `initialize(CPluginHost)`, and `assets/` (including l10n).
List<CPluginPackageSpec> get bundledPlugins => [
      CPluginPackageSpec(
        id: kLevelPreviewPluginId,
        packageRoot: 'lib/bundled_plugins/level_preview_cplugin',
        initialize: level_preview.initialize,
      ),
      CPluginPackageSpec(
        id: kDynamicFetchPluginId,
        packageRoot: 'lib/bundled_plugins/dynamic_fetch_cplugin',
        initialize: dynamic_fetch.initialize,
      ),
    ];
