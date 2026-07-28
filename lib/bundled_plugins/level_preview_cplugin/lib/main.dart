import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/registration.dart';

/// Plugin entrypoint — same contract as an external `.cplugin`.
void initialize(CPluginHost host) {
  registerLevelPreview(host);
}
