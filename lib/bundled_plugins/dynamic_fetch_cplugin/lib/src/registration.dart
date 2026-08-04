import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/dynamic_offer_flow.dart';

/// Built-in external-dynamic plugin id (must match `manifest.json`).
const kDynamicFetchPluginId = 'team.international2c.dynamic_fetch';

/// Wires [PluginHostHooks.offerExternalDynamic] when this plugin is enabled.
void registerDynamicFetch(CPluginHost host) {
  PluginHostHooks.offerExternalDynamic = (
    context, {
    required libraryPath,
    skipInitialPrompt = false,
  }) {
    return runExternalDynamicOffer(
      context,
      host: host,
      libraryPath: libraryPath,
      skipInitialPrompt: skipInitialPrompt,
    );
  };
}
