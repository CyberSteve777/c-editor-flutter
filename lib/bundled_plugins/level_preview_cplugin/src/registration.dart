import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/plugins/bundled_plugin.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/src/level_preview_dialog.dart';

/// Built-in level preview, registered as a disable-only bundled plugin.
class LevelPreviewBundledPlugin extends BundledPlugin {
  static const pluginId = 'com.c_editor.level_preview';

  @override
  String get id => pluginId;

  @override
  String get name => 'Level Preview';

  @override
  String get version => '1.0.0';

  @override
  String get author => 'Chara';

  @override
  String get description =>
      'Preview plants, zombies, and layout for the open or selected level.';

  @override
  void register(PluginHostImpl host) {
    host.registry.registerLevelFileAction(
      PluginLevelFileAction(
        pluginId: id,
        id: 'preview_file',
        titleBuilder: (context) =>
            AppLocalizations.of(context)?.levelPreview ?? 'Preview',
        icon: Icons.remove_red_eye,
        matchesFileName: (name) {
          final lower = name.toLowerCase();
          return lower.endsWith('.json') ||
              lower.endsWith('.hujson') ||
              lower.endsWith('.rton');
        },
        onActivate: (context, fileName, filePath) async {
          await openLevelPreviewFromPath(
            context,
            fileName: fileName,
            filePath: filePath,
          );
        },
      ),
    );
    host.registry.registerEditorAction(
      PluginEditorAction(
        pluginId: id,
        id: 'preview_editor',
        titleBuilder: (context) =>
            AppLocalizations.of(context)?.levelPreview ?? 'Preview',
        icon: Icons.remove_red_eye,
        slot: CPluginUiSlots.editorAppBar,
        onActivate: (context) async {
          await openLevelPreviewFromOpenSession(context);
        },
      ),
    );
    host.registry.registerEditorAction(
      PluginEditorAction(
        pluginId: id,
        id: 'preview_editor_overflow',
        titleBuilder: (context) =>
            AppLocalizations.of(context)?.levelPreview ?? 'Preview',
        icon: Icons.remove_red_eye,
        slot: CPluginUiSlots.editorOverflow,
        onActivate: (context) async {
          await openLevelPreviewFromOpenSession(context);
        },
      ),
    );
  }
}

Future<void> openLevelPreviewFromOpenSession(BuildContext context) async {
  final cubit = ActiveEditorSession.instance.cubit;
  final level = cubit?.state.levelFile;
  final parsed = cubit?.state.parsedData;
  final fileName = cubit?.fileName;
  if (level == null || parsed == null || fileName == null) return;
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => LevelPreviewDialog(
      levelFile: level,
      parsed: parsed,
      fileName: fileName,
      onBack: () => Navigator.pop(ctx),
    ),
  );
}

Future<void> openLevelPreviewFromPath(
  BuildContext context, {
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
  required PvzLevelFile levelFile,
  required ParsedLevelData parsed,
  required String fileName,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => LevelPreviewDialog(
      levelFile: levelFile,
      parsed: parsed,
      fileName: fileName,
      onBack: () => Navigator.pop(ctx),
    ),
  );
}
