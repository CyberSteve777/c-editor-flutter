import 'package:c_editor/plugin_api.dart';

/// Eval-safe entrypoint for packing as an external `.cplugin`.
///
/// Only imports [plugin_api] so dart_eval can compile this file without the
/// heavy in-process `registration.dart` / dialog host code.
///
/// In-process bundled load still uses `../lib/main.dart` (see plugin README).
void initialize(CPluginHost host) {
  // Icons.remove_red_eye.codePoint — numeric so this eval-safe file stays
  // free of flutter/material. Host maps it via pluginMaterialIcon().
  const eye = 0xe8f4;
  const extensions = '.json,.hujson,.rton';

  host.registerLevelFileAction(
    'preview_file',
    'levelPreview',
    (context, fileName, filePath) async {
      await host.openLevelPreview(context, filePath, fileName);
    },
    eye,
    extensions,
  );
  // Overflow menu only — avoid duplicating an AppBar icon.
  host.registerEditorAction(
    'preview_editor',
    'levelPreview',
    'editorOverflow',
    (context) async {
      await host.openLevelPreview(context);
    },
    eye,
  );
}
