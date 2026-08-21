import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';

class LunarMineVeinModuleScreen extends StatefulWidget {
  const LunarMineVeinModuleScreen({
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
  State<LunarMineVeinModuleScreen> createState() =>
      _LunarMineVeinModuleScreenState();
}

class _LunarMineVeinModuleScreenState extends State<LunarMineVeinModuleScreen> {
  static const _objClass = 'LunarMineVeinModuleProperties';
  static const _asset = 'assets/images/griditems/lunar_mine_vein.webp';

  late String _alias;
  late PvzObject _moduleObject;
  late LunarMineVeinModulePropertiesData _data;
  int _selectedX = 0;
  int _selectedY = 0;

  int get _gridRows =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$1;
  int get _gridCols =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$2;

  LunarMineVeinPlacementData? get _selectedPlacement =>
      _data.placements.firstWhereOrNull(
        (entry) => entry.gridX == _selectedX && entry.gridY == _selectedY,
      );

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _moduleObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: LunarMineVeinModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = LunarMineVeinModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = LunarMineVeinModulePropertiesData();
    }
    if (_data.placements.isNotEmpty) {
      _selectedX = _data.placements.first.gridX;
      _selectedY = _data.placements.first.gridY;
    }
  }

  void _sync() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasAt(int col, int row) =>
      _data.placements.any((entry) => entry.gridX == col && entry.gridY == row);

  void _tapCell(int col, int row) {
    setState(() {
      _selectedX = col;
      _selectedY = row;
    });
    if (_hasAt(col, row)) {
      return;
    }
    _data.placements.add(
      LunarMineVeinPlacementData(gridX: col, gridY: row, emergenceWave: 1),
    );
    _sync();
  }

  void _removeAt(int col, int row) {
    _data.placements.removeWhere(
      (entry) => entry.gridX == col && entry.gridY == row,
    );
    _sync();
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = _selectedPlacement;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.lunarMineVeinHelpTitle ?? 'Lunar Veins',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.lunarMineVeinHelpOverview ?? '',
                ),
                HelpSectionData(
                  title: l10n?.lunarMineVeinHelpWaveTitle ?? 'Wave numbering',
                  body: l10n?.lunarMineVeinHelpWave ?? '',
                ),
              ],
            ),
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
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.lunarMineVeinPlacements ??
                          'Vein placements (VeinPlacements)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.moonPlacementGestureHint ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${l10n?.selectedPosition ?? 'Selected position'}: '
                      'R${_selectedY + 1} : C${_selectedX + 1}',
                    ),
                    const SizedBox(height: 12),
                    GridOverridePlacementGrid(
                      gridRows: _gridRows,
                      gridCols: _gridCols,
                      selectedCol: _selectedX,
                      selectedRow: _selectedY,
                      onPrimaryTap: _tapCell,
                      onRemoveAt: _removeAt,
                      cellImageAt: (col, row) =>
                          _hasAt(col, row) ? _asset : null,
                      cellImageScaleAt: (_, _) => 0.92,
                    ),
                    if (selected != null) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        key: ValueKey(
                          'vein-wave-${selected.gridX}-${selected.gridY}',
                        ),
                        initialValue: '${selected.emergenceWave}',
                        decoration: InputDecoration(
                          labelText:
                              l10n?.lunarMineEmergenceWave ??
                              'Growth wave (EmergenceWave, numbered from 1)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 1) {
                            selected.emergenceWave = parsed;
                            _sync();
                          }
                        },
                      ),
                    ],
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
