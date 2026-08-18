import 'package:c_editor/screens/export/export_screen.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/dynamic_offer_flow.dart';

/// Built-in external-dynamic plugin id (must match `manifest.json`).
const kDynamicFetchPluginId = 'team.international2c.dynamic_fetch';

/// Wires [PluginHostHooks.offerExternalDynamic] when this plugin is enabled.
void registerDynamicFetch(CPluginHost host) {
  // The download hook lives inside the global level-testing package flow.
  // Register that host screen as a level-independent destination so the
  // Plugins page can expose a direct entry under Features & screens.
  host.registerScreen(
    'level_testing_mod',
    'levelTestingMod',
    (_) => const ExportScreen(),
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
