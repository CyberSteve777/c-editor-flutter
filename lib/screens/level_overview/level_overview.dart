import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';

/// Opens Level Overview for the currently open editor level.
Future<void> openLevelOverviewFromOpenSession(BuildContext context) async {
  final cubit = ActiveEditorSession.instance.cubit;
  final level = cubit?.state.levelFile;
  final parsed = cubit?.state.parsedData;
  final fileName = cubit?.fileName;
  final filePath = cubit?.filePath;
  if (level == null || parsed == null || fileName == null) return;
  if (!context.mounted) return;
  await showLevelOverviewDialog(
    context,
    levelFile: level,
    parsed: parsed,
    fileName: fileName,
    filePath: filePath,
    showOpenLevel: false,
  );
}

/// Opens Level Overview for a library file (level list).
Future<void> openLevelOverviewFromPath(
  BuildContext context, {
  required String fileName,
  required String filePath,
}) async {
  final file = await LevelRepository.loadLevelFromPath(filePath);
  if (file == null || !context.mounted) return;
  final parsed = LevelParser.parseLevel(file);
  if (!context.mounted) return;
  await showLevelOverviewDialog(
    context,
    levelFile: file,
    parsed: parsed,
    fileName: fileName,
    filePath: filePath,
    showOpenLevel: true,
  );
}

Future<void> showLevelOverviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required ParsedLevelData parsed,
  required String fileName,
  String? filePath,
  bool showOpenLevel = false,
}) async {
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => EscapeClosesModal(
      child: LevelOverviewDialog(
        levelFile: levelFile,
        parsed: parsed,
        fileName: fileName,
        filePath: filePath,
        showOpenLevel: showOpenLevel,
        onClose: () => safeNavPop(ctx),
      ),
    ),
  );
}
