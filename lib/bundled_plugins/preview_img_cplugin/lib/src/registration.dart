import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_settings_screen.dart';

export 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/level_preview_constants.dart';

/// Registers the image-preview generator plugin (settings + host hook).
///
/// Level Overview itself lives in the base editor
/// (`lib/screens/level_overview/`).
void registerLevelPreview(CPluginHost host) {
  installLevelPreviewHostHooks(host);

  host.registerScreen(
    'preview_settings',
    'previewSettings',
    (context) => PreviewSettingsScreen(host: host),
  );
}

/// Installs [PluginHostHooks.openPreviewImageGenerator] for this [host].
void installLevelPreviewHostHooks(CPluginHost host) {
  PluginHostHooks.openPreviewImageGenerator =
      (
        context, {
        required PvzLevelFile levelFile,
        required ParsedLevelData parsed,
        required String fileName,
      }) async {
        if (!context.mounted) return;
        final style = await showPreviewLayoutStyleDialog(
          context: context,
          t: (key, [fallback]) => host.localize(context, key, fallback),
        );
        if (style == null || !context.mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PreviewGeneratorScreen(
              host: host,
              levelFile: levelFile,
              parsed: parsed,
              fileName: fileName,
              initialStyle: style,
            ),
          ),
        );
      };
}
