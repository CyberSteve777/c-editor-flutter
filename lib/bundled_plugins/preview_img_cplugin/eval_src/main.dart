import 'package:c_editor/plugin_api.dart';

/// Eval-safe entrypoint for packing as an external `.cplugin`.
///
/// Overview UI now lives in the host. This plugin only exposes settings and
/// the image-preview generator (via host hooks when loaded in-process).
/// Eval packs register a settings screen title only; generator requires the
/// bundled in-process host hook.
void initialize(CPluginHost host) {
  host.registerScreen(
    'preview_settings',
    'previewSettings',
    (context) {
      return Center(child: Text('Preview settings'));
    },
  );
}
