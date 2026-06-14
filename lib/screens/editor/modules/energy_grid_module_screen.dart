import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';
import 'package:c_editor/widgets/grid_override_wave_groups_bar.dart';

class EnergyGridModuleScreen extends StatefulWidget {
  const EnergyGridModuleScreen({
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
  State<EnergyGridModuleScreen> createState() => _EnergyGridModuleScreenState();
}

class _EnergyGridModuleScreenState extends State<EnergyGridModuleScreen> {
  static const _tileAsset = 'assets/images/griditems/energyGrid.webp';

  late PvzObject _moduleObj;
  late EnergyGridPropertiesData _data;
  int _selectedIndex = -1;
  int _selectedX = 0;
  int _selectedY = 0;
  EnergyGridOverrideWaveData? _overrideToDelete;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  EnergyGridOverrideWaveData? get _selectedOverride {
    if (_selectedIndex < 0 || _selectedIndex >= _data.overrides.length) {
      return null;
    }
    return _data.overrides[_selectedIndex];
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    if (_data.overrides.isNotEmpty) {
      _selectedIndex = 0;
    }
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? 'EnergyGrid';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'EnergyGridProperties',
        objData: EnergyGridPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = EnergyGridPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = EnergyGridPropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _syncOverrides(List<EnergyGridOverrideWaveData> overrides) {
    _data = EnergyGridPropertiesData(overrides: overrides);
    _sync();
  }

  void _addOverride() {
    final newOverride = EnergyGridOverrideWaveData(
      wave: _data.overrides.isEmpty
          ? gridOverrideFirstWave
          : _data.overrides.last.wave + 1,
    );
    _syncOverrides([..._data.overrides, newOverride]);
    setState(() => _selectedIndex = _data.overrides.length - 1);
  }

  void _deleteOverride(EnergyGridOverrideWaveData target) {
    _syncOverrides(_data.overrides.where((e) => e != target).toList());
    if (_selectedIndex >= _data.overrides.length) {
      _selectedIndex = _data.overrides.isEmpty
          ? -1
          : _data.overrides.length - 1;
    }
  }

  void _updateSelectedOverride(EnergyGridOverrideWaveData updated) {
    if (_selectedIndex < 0 || _selectedIndex >= _data.overrides.length) return;
    final list = List<EnergyGridOverrideWaveData>.from(_data.overrides);
    list[_selectedIndex] = updated;
    _syncOverrides(list);
  }

  void _writeSelectedItems(List<EnergyGridOverrideItemData> items) {
    final current = _selectedOverride;
    if (current == null) return;
    _updateSelectedOverride(
      EnergyGridOverrideWaveData(wave: current.wave, itemList: items),
    );
  }

  bool _hasTileAt(int col, int row) {
    return (_selectedOverride?.itemList ?? [])
        .any((e) => e.mX == col && e.mY == row);
  }

  void _placeAt(int col, int row) {
    final items = _selectedOverride?.itemList ?? [];
    _selectedX = col;
    _selectedY = row;
    final next = List<EnergyGridOverrideItemData>.from(items)
      ..removeWhere((e) => e.mX == col && e.mY == row)
      ..add(EnergyGridOverrideItemData(mX: col, mY: row));
    _writeSelectedItems(next);
  }

  void _removeAt(int col, int row) {
    if (!_hasTileAt(col, row)) return;
    final items = List<EnergyGridOverrideItemData>.from(
      _selectedOverride?.itemList ?? [],
    )..removeWhere((e) => e.mX == col && e.mY == row);
    _writeSelectedItems(items);
  }

  void _handlePrimaryTap(int col, int row) {
    if (_hasTileAt(col, row)) {
      setState(() {
        _selectedX = col;
        _selectedY = row;
      });
      return;
    }
    _placeAt(col, row);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = l10n?.energyGridModuleTitle ?? 'Taiji Tiles';
    final helpTitle = l10n?.energyGridModuleHelpTitle ?? 'Taiji Tiles module';
    final selected = _selectedOverride;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: helpTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.energyGridModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.energyGridModuleHelpOverviewBody ??
                      'Places Taiji Tiles on the lawn for wave 1. '
                          'Use this module to configure tile positions in the level file.',
                ),
                HelpSectionData(
                  title: l10n?.energyGridModuleHelpPlacement ?? 'Placement',
                  body:
                      l10n?.energyGridModuleHelpPlacementBody ??
                      'Tap an empty tile to place a Taiji Tile (one per tile). '
                          'Right-click or long-press a tile to remove it.',
                ),
                HelpSectionData(
                  title: l10n?.energyGridModuleHelpWaveLimit ?? 'Wave limit',
                  body:
                      l10n?.energyGridModuleHelpWaveLimitBody ??
                      'Due to a game limitation, only wave 1 entries take effect in-game. '
                          'Other wave groups can still be edited and are saved to the level file, '
                          'but only wave 1 appears in the wave timeline tab.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.gridOverrideModuleAppearances ?? 'Wave groups',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                GridOverrideWaveGroupsBar(
                  itemCount: _data.overrides.length,
                  selectedIndex: _selectedIndex,
                  onSelected: (idx) => setState(() => _selectedIndex = idx),
                  onDeleteAt: (idx) => setState(
                    () => _overrideToDelete = _data.overrides[idx],
                  ),
                  onAdd: _addOverride,
                  groupLabel: (idx) =>
                      '${l10n?.airDropShipGroupLabel ?? "Group"} ${idx + 1}',
                ),
                if (selected != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    margin: EdgeInsets.zero,
                    key: ValueKey('energy_grid_panel_$_selectedIndex'),
                    child: Padding(
                      padding: kGridOverrideModuleSectionPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.appearanceLabel ?? "Appearance"} ${_selectedIndex + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            initialValue: '${selected.wave}',
                            decoration: InputDecoration(
                              labelText:
                                  l10n?.gridOverrideModuleWaveFieldOneBased ??
                                  'Wave (1 = first wave)',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null && n >= 1) {
                                _updateSelectedOverride(
                                  EnergyGridOverrideWaveData(
                                    wave: n,
                                    itemList: selected.itemList,
                                  ),
                                );
                              }
                            },
                          ),
                          if (selected.wave != gridOverrideFirstWave) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n?.gridOverrideModuleTimelineNote ??
                                  'Only wave 1 entries appear in the wave timeline tab.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            '${l10n?.selectedPosition ?? "Selected position"}: R${_selectedY + 1} : C${_selectedX + 1}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.energyGridModuleTapToPlace ??
                                'Tap an empty tile to place a Taiji Tile.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridOverridePlacementGrid(
                            gridRows: _gridRows,
                            gridCols: _gridCols,
                            selectedCol: _selectedX,
                            selectedRow: _selectedY,
                            onPrimaryTap: _handlePrimaryTap,
                            onRemoveAt: _removeAt,
                            cellImageAt: (col, row) =>
                                _hasTileAt(col, row) ? _tileAsset : null,
                            cellImageScaleAt: (_, __) => 0.92,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_overrideToDelete != null) _buildDeleteDialog(l10n),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog(AppLocalizations? l10n) {
    final target = _overrideToDelete!;
    final index = _data.overrides.indexOf(target);
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm(
              '${l10n?.airDropShipGroupLabel ?? "Group"} ${index + 1}',
            ) ??
            'Remove group ${index + 1}?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _overrideToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _deleteOverride(target);
            setState(() => _overrideToDelete = null);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n?.remove ?? 'Remove'),
        ),
      ],
    );
  }
}
