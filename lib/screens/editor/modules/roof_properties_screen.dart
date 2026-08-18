import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Roof properties. Ported from Z-Editor-master RoofPropertiesEP.kt
class RoofPropertiesScreen extends StatefulWidget {
  const RoofPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<RoofPropertiesScreen> createState() => _RoofPropertiesScreenState();
}

class _RoofPropertiesScreenState extends State<RoofPropertiesScreen> {
  static const _objClass = 'RoofProperties';
  static const _flowerPotAsset = 'assets/images/griditems/flowerpot.webp';
  static const _gridRows = 5;
  static const _gridCols = 9;
  static const _maxColumn = 8;

  late String _alias;
  late PvzObject _moduleObj;
  late RoofPropertiesData _data;

  bool get _isRoofLawn =>
      LevelParser.isRoofLawn(widget.levelDef, widget.levelFile);

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
        objClass: 'RoofProperties',
        objData: RoofPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RoofPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RoofPropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasFlowerPotInColumn(int col) {
    final start = _data.flowerPotStartColumn;
    final end = _data.flowerPotEndColumn;
    final lo = start < end ? start : end;
    final hi = start > end ? start : end;
    return col >= lo && col <= hi;
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

  Widget _buildPreviewGrid(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final lawnColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8E8);

    return scaleTableForDesktop(
      context: context,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            key: const ValueKey('roofFlowerPotPreviewGrid'),
            decoration: BoxDecoration(
              color: lawnColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final hasPot = _hasFlowerPotInColumn(col);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.dividerColor,
                              width: 0.5,
                            ),
                          ),
                          child: hasPot
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    final inset = 5.0;
                                    final side =
                                        (constraints.maxWidth <
                                                constraints.maxHeight
                                            ? constraints.maxWidth
                                            : constraints.maxHeight) -
                                        inset * 2;
                                    return Center(
                                      child: AssetImageWidget(
                                        assetPath: _flowerPotAsset,
                                        width: side,
                                        height: side,
                                        fit: BoxFit.contain,
                                      ),
                                    );
                                  },
                                )
                              : null,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _setStartColumn(int value) {
    if (value < 0 || value > _maxColumn) return;
    _data.flowerPotStartColumn = value;
    _sync();
  }

  void _setEndColumn(int value) {
    if (value < 0 || value > _maxColumn) return;
    _data.flowerPotEndColumn = value;
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
            if (!_isRoofLawn) ...[
              Card(
                key: const ValueKey('roofLawnMismatchWarning'),
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        editorErrorIcon,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.stageMismatch ?? 'Lawn Type Mismatch',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.roofFlowerPotLawnMismatchWarning ??
                                  'The current lawn is not a Roof lawn. This module may not work and could cause the level to crash.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.roofFlowerPotColumns ?? 'Flower Pot Range',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoofColumnStepper(
                      key: const ValueKey('roofFlowerPotStartColumnStepper'),
                      label:
                          l10n?.roofFlowerPotStartColumn ??
                          'Start column (StartColumn)',
                      value: _data.flowerPotStartColumn,
                      min: 0,
                      max: _maxColumn,
                      onChanged: _setStartColumn,
                    ),
                    const SizedBox(height: 12),
                    _RoofColumnStepper(
                      key: const ValueKey('roofFlowerPotEndColumnStepper'),
                      label:
                          l10n?.roofFlowerPotEndColumn ??
                          'End column (EndColumn)',
                      value: _data.flowerPotEndColumn,
                      min: 0,
                      max: _maxColumn,
                      onChanged: _setEndColumn,
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
                      l10n?.roofFlowerPotPreview ?? 'Flower pot preview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPreviewGrid(theme),
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

class _RoofColumnStepper extends StatelessWidget {
  const _RoofColumnStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            key: const ValueKey('decrease'),
            icon: const Icon(Icons.remove),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('increase'),
            icon: const Icon(Icons.add),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
