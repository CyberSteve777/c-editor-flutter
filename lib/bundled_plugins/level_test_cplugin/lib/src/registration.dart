import 'package:flutter/material.dart';
import 'package:c_editor/screens/export/export_screen.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/dynamic_offer_flow.dart';

/// Built-in level-testing-mod plugin id (must match `manifest.json`).
const kLevelTestingModPluginId = 'team.international2c.level_testing_mod';

/// Deprecated alias for [kLevelTestingModPluginId].
const kDynamicFetchPluginId = kLevelTestingModPluginId;

/// Wires [PluginHostHooks.offerExternalDynamic] when this plugin is enabled.
void registerLevelTestingMod(CPluginHost host) {
  // The download hook lives inside the global level-testing package flow.
  // Register that host screen as a level-independent destination so the
  // Plugins page can expose a direct entry under Features & screens.
  host.registerScreen(
    'level_testing_mod',
    'levelTestingMod',
    (_) => const ExportScreen(),
  );

  final packageIcon = Icons.inventory_2.codePoint;
  host.registerUiElement(
    'level_testing_mod_overflow',
    'levelTestingMod',
    CPluginUiSlots.levelListOverflow,
    (_) => const ExportScreen(),
    packageIcon,
  );

  PluginHostHooks.offerExternalDynamic =
      (context, {required libraryPath, skipInitialPrompt = false}) {
        return runExternalDynamicOffer(
          context,
          host: host,
          libraryPath: libraryPath,
          skipInitialPrompt: skipInitialPrompt,
        );
      };
}

/// Deprecated alias for [registerLevelTestingMod].
void registerDynamicFetch(CPluginHost host) => registerLevelTestingMod(host);
