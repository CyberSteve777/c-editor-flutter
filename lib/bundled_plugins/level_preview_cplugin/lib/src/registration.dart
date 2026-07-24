import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_dialog.dart';

/// Built-in level preview plugin id (must match `manifest.json`).
const kLevelPreviewPluginId = 'team.international2c.level_preview';

/// Wires host hooks and registers UI via the public [CPluginHost] API.
///
/// This is the same entrypoint used when the plugin is packed as a `.cplugin`.
void registerLevelPreview(CPluginHost host) {
  installLevelPreviewHostHooks();

  const eye = 0xe8f4; // Icons.remove_red_eye.codePoint
  const extensions = '.json,.hujson,.rton';

  host.registerLevelFileAction(
    'preview_file',
    'levelPreview',
    (context, fileName, filePath) => host.openLevelPreview(
      context,
      filePath,
      fileName,
    ),
    eye,
    extensions,
  );
  host.registerEditorAction(
    'preview_editor',
    'levelPreview',
    CPluginUiSlots.editorAppBar,
    (context) => host.openLevelPreview(context),
    eye,
  );
  host.registerEditorAction(
    'preview_editor_overflow',
    'levelPreview',
    CPluginUiSlots.editorOverflow,
    (context) => host.openLevelPreview(context),
    eye,
  );
}

/// Installs [PluginHostHooks.openLevelPreview] once (idempotent).
void installLevelPreviewHostHooks() {
  PluginHostHooks.openLevelPreview ??= (
    context, {
    required host,
    filePath,
    fileName,
  }) async {
    if (filePath != null && filePath.isNotEmpty) {
      await openLevelPreviewFromPath(
        context,
        host: host,
        fileName: fileName ?? filePath.split(RegExp(r'[\\/]')).last,
        filePath: filePath,
      );
      return;
    }
    await openLevelPreviewFromOpenSession(context, host: host);
  };
}

Future<void> openLevelPreviewFromOpenSession(
  BuildContext context, {
  required CPluginHost host,
}) async {
  final cubit = ActiveEditorSession.instance.cubit;
  final level = cubit?.state.levelFile;
  final parsed = cubit?.state.parsedData;
  final fileName = cubit?.fileName;
  if (level == null || parsed == null || fileName == null) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => LevelPreviewDialog(
      host: host,
      levelFile: level,
      parsed: parsed,
      fileName: fileName,
      onBack: () => Navigator.pop(ctx),
    ),
  );
}

Future<void> openLevelPreviewFromPath(
  BuildContext context, {
  required CPluginHost host,
  required String fileName,
  required String filePath,
}) async {
  final file = await LevelRepository.loadLevelFromPath(filePath);
  if (file == null || !context.mounted) return;
  final parsed = LevelParser.parseLevel(file);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => LevelPreviewDialog(
      host: host,
      levelFile: file,
      parsed: parsed,
      fileName: fileName,
      onBack: () => Navigator.pop(ctx),
    ),
  );
}

/// Convenience when [PvzLevelFile] is already loaded.
Future<void> openLevelPreviewDialog(
  BuildContext context, {
  required CPluginHost host,
  required PvzLevelFile levelFile,
  required ParsedLevelData parsed,
  required String fileName,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => LevelPreviewDialog(
      host: host,
      levelFile: levelFile,
      parsed: parsed,
      fileName: fileName,
      onBack: () => Navigator.pop(ctx),
    ),
  );
}
