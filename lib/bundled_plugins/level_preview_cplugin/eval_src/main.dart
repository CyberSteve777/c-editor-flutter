import 'package:c_editor/plugin_api.dart';

/// Eval-safe entrypoint for packing as an external `.cplugin`.
///
/// Only imports [plugin_api] so dart_eval can compile this file without the
/// heavy in-process `registration.dart` / dialog host code.
///
/// In-process bundled load still uses `../main.dart` (see plugin README).
void initialize(CPluginHost host) {
  const eye = 0xe8f4; // Icons.remove_red_eye.codePoint
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
  host.registerEditorAction(
    'preview_editor',
    'levelPreview',
    'editorAppBar',
    (context) async {
      await host.openLevelPreview(context);
    },
    eye,
  );
  host.registerEditorAction(
    'preview_editor_overflow',
    'levelPreview',
    'editorOverflow',
    (context) async {
      await host.openLevelPreview(context);
    },
    eye,
  );
}
