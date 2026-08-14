import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Bowling minigame editor. Ported from Z-Editor-master BowlingMinigamePropertiesEP.kt
class BowlingMinigameScreen extends StatefulWidget {
  const BowlingMinigameScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<BowlingMinigameScreen> createState() => _BowlingMinigameScreenState();
}

class _BowlingMinigameScreenState extends State<BowlingMinigameScreen> {
  static const _objClass = 'BowlingMinigameProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late BowlingMinigamePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: 'BowlingMinigameProperties',
        objData: BowlingMinigamePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BowlingMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BowlingMinigamePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _showHelp(
    BuildContext context,
    AppLocalizations? l10n,
    Color accentColor,
  ) {
    showEditorHelpDialog(
      context,
      isEvent: false,
      title: l10n?.bowlingMinigame ?? 'Bulb Bowling module',
      themeColor: accentColor,
      sections: [
        HelpSectionData(
          title: l10n?.overview ?? 'Overview',
          body:
              l10n?.bowlingMinigameHelpOverview ??
              'Sets the no-planting line column for bulb bowling levels.',
        ),
        HelpSectionData(
          title: l10n?.bowlingFoulLine ?? 'No-planting line',
          body:
              l10n?.bowlingMinigameHelpFoulLine ??
              'Column index from the left (0-based).',
        ),
      ],
    );
  }

  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzGreenDark : pvzGreenLight;
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
    final isDeepSeaLawn = LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
    final minFoulLine = isDeepSeaLawn ? -1 : 0;
    final maxFoulLine = isDeepSeaLawn ? gridCols - 1 : gridCols;
    final foulLine = _data.bowlingFoulLine
        .clamp(minFoulLine, maxFoulLine)
        .toInt();
    final previewBoundary = foulLine + (isDeepSeaLawn ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => _showHelp(context, l10n, accentColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.bowlingMinigameParams ?? 'Parameters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      key: const ValueKey('bowlingFoulLineStepper'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${l10n?.bowlingFoulLine ?? 'No-planting line'}: $foulLine',
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: foulLine > minFoulLine
                                ? () {
                                    _data.bowlingFoulLine = foulLine - 1;
                                    _sync();
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: foulLine < maxFoulLine
                                ? () {
                                    _data.bowlingFoulLine = foulLine + 1;
                                    _sync();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.bowlingFoulLinePreview ??
                          'No-planting line preview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BowlingFoulLinePreview(
                      rows: gridRows,
                      columns: gridCols,
                      foulLine: previewBoundary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BowlingFoulLinePreview extends StatelessWidget {
  const _BowlingFoulLinePreview({
    required this.rows,
    required this.columns,
    required this.foulLine,
  });

  final int rows;
  final int columns;
  final int foulLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.55);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: AspectRatio(
          aspectRatio: columns / rows,
          child: LayoutBuilder(
            builder: (context, constraints) {
              const lineWidth = 4.0;
              final boundaryX = constraints.maxWidth * foulLine / columns;
              final lineLeft = (boundaryX - lineWidth / 2)
                  .clamp(0.0, constraints.maxWidth - lineWidth)
                  .toDouble();
              return Stack(
                key: const ValueKey('bowlingFoulLinePreviewGrid'),
                children: [
                  Positioned.fill(
                    child: Column(
                      children: List.generate(
                        rows,
                        (_) => Expanded(
                          child: Row(
                            children: List.generate(
                              columns,
                              (_) => Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.22),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: lineLeft,
                    top: 0,
                    bottom: 0,
                    width: lineWidth,
                    child: const ColoredBox(
                      key: ValueKey('bowlingFoulLinePreviewLine'),
                      color: Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
