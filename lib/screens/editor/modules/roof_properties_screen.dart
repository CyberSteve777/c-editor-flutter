import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
  late TextEditingController _startColController;
  late TextEditingController _endColController;

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
    _startColController = TextEditingController(
      text: '${_data.flowerPotStartColumn}',
    );
    _endColController = TextEditingController(
      text: '${_data.flowerPotEndColumn}',
    );
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

  @override
  void dispose() {
    _startColController.dispose();
    _endColController.dispose();
    super.dispose();
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
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context) * 0.7,
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.roofFlowerPotColumns ??
                          'Flower pot columns (0–8)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _startColController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n?.startColumn ?? 'Start column',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 0 && n <= _maxColumn) {
                                _data.flowerPotStartColumn = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _endColController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: l10n?.endColumn ?? 'End column',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 0 && n <= _maxColumn) {
                                _data.flowerPotEndColumn = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                      ],
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
