import 'package:flutter/material.dart';

import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/main.dart'
    as level_test;
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/main.dart'
    as preview_img;
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/registration.dart'
    show kLevelTestingModPluginId;
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/registration.dart'
    show kLevelPreviewPluginId;
import 'package:c_editor/plugins/plugin_package.dart';

/// First-party plugins shipped with C-Editor (disable-only).
///
/// Each entry uses the same package contract as an external `.cplugin`:
/// `manifest.json`, `initialize(CPluginHost)`, and `assets/` (including l10n).
List<CPluginPackageSpec> get bundledPlugins => [
  CPluginPackageSpec(
    id: kLevelPreviewPluginId,
    packageRoot: 'lib/bundled_plugins/preview_img_cplugin',
    initialize: preview_img.initialize,
  ),
  CPluginPackageSpec(
    id: kLevelTestingModPluginId,
    packageRoot: 'lib/bundled_plugins/level_test_cplugin',
    initialize: level_test.initialize,
  ),
];

/// Built-in plugins use Flutter icons matching their editor entries.
/// Imported plugins use the image declared in their own manifest.
IconData? bundledPluginIcon(String pluginId) => switch (pluginId) {
  kLevelPreviewPluginId => Icons.image,
  kLevelTestingModPluginId => Icons.inventory_2,
  _ => null,
};
