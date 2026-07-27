import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/registration.dart';

/// Plugin entrypoint — same contract as an external `.cplugin`.
void initialize(CPluginHost host) {
  registerDynamicFetch(host);
}
