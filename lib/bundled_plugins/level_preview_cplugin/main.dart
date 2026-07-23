import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/src/registration.dart';

/// Bundled plugin entrypoint (mirrors custom `.cplugin` `initialize`).
///
/// For in-app registration use [LevelPreviewBundledPlugin]; this function
/// exists so the package layout matches author plugins.
void initialize(CPluginHost host) {
  if (host is PluginHostImpl) {
    LevelPreviewBundledPlugin().register(host);
  }
}
