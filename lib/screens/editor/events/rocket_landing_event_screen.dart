import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';

class RocketLandingEventScreen extends StatefulWidget {
  const RocketLandingEventScreen({
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
  State<RocketLandingEventScreen> createState() =>
      _RocketLandingEventScreenState();
}

class _RocketLandingEventScreenState extends State<RocketLandingEventScreen> {
  static const _objClass = 'SpawnRocketLandingWaveActionProps';
  static const _asset = 'assets/images/griditems/rocket_landing.webp';

  late String _alias;
  late PvzObject _eventObject;
  late SpawnRocketLandingWaveActionPropsData _data;
  late TextEditingController _poolCountCtrl;
  late TextEditingController _spawnCountCtrl;
  late TextEditingController _intervalCtrl;
  int _selectedX = 0;
  int _selectedY = 0;

  int get _gridRows =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$1;
  int get _gridCols =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$2;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _eventObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: SpawnRocketLandingWaveActionPropsData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_eventObject)) {
      widget.levelFile.objects.add(_eventObject);
    }
    try {
      _data = SpawnRocketLandingWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_eventObject.objData as Map),
      );
    } catch (_) {
      _data = SpawnRocketLandingWaveActionPropsData();
    }
    if (_data.rocketPool.isEmpty) {
      _data.rocketPool.add(RocketPoolEntryData());
    }
    if (_data.spawnPositionsPool.isNotEmpty) {
      _selectedX = _data.spawnPositionsPool.first.mx;
      _selectedY = _data.spawnPositionsPool.first.my;
    }
    _poolCountCtrl = TextEditingController(
      text: '${_data.rocketPool.first.count}',
    );
    _spawnCountCtrl = TextEditingController(text: '${_data.spawnCount}');
    _intervalCtrl = TextEditingController(text: '${_data.spawnInterval}');
  }

  @override
  void dispose() {
    _poolCountCtrl.dispose();
    _spawnCountCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    _eventObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasAt(int col, int row) => _data.spawnPositionsPool.any(
    (entry) => entry.mx == col && entry.my == row,
  );

  void _tapCell(int col, int row) {
    setState(() {
      _selectedX = col;
      _selectedY = row;
    });
    if (_hasAt(col, row)) {
      return;
    }
    _data.spawnPositionsPool.add(TileLocationData(mx: col, my: row));
    _sync();
  }

  void _removeAt(int col, int row) {
    _data.spawnPositionsPool.removeWhere(
      (entry) => entry.mx == col && entry.my == row,
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
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.rocketLandingHelpTitle ?? 'Rocket Landing',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.rocketLandingHelpOverview ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.rocketLandingHelpPlantsTitle ??
                      'Plants take control',
                  body: l10n?.rocketLandingHelpPlants ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.rocketLandingHelpZombiesTitle ??
                      'Zombies take control',
                  body: l10n?.rocketLandingHelpZombies ?? '',
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
            EditorAliasInputField(
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
                      l10n?.rocketLandingSettings ?? 'Rocket settings',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: _poolCountCtrl,
                      label: l10n?.rocketPoolCount ?? 'Rocket count (Count)',
                      decimal: false,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.rocketPool.first.count = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _spawnCountCtrl,
                      label:
                          l10n?.rocketSpawnCount ??
                          'Total grid items to spawn (SpawnCount)',
                      decimal: false,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.spawnCount = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _intervalCtrl,
                      label:
                          l10n?.rocketSpawnInterval ??
                          'Spawn interval (SpawnInterval, seconds)',
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.spawnInterval = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n?.rocketDisplacePlants ??
                            'Displace plants (DisplacePlants)',
                      ),
                      subtitle: Text(
                        l10n?.rocketDisplacePlantsSubtitle ??
                            'When enabled, the rocket moves plants on its landing tile to nearby empty tiles',
                      ),
                      value: _data.displacePlants,
                      onChanged: (value) {
                        _data.displacePlants = value;
                        _sync();
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n?.ignoreGravestone ??
                            'Ignore tombstone (IgnoreGraveStone)',
                      ),
                      subtitle: Text(
                        l10n?.ignoreGravestoneSubtitle ??
                            'Enable to spawn regardless of grid items',
                      ),
                      value: _data.ignoreGraveStone,
                      onChanged: (value) {
                        _data.ignoreGraveStone = value;
                        _sync();
                      },
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.positionPoolSpawnPositions ??
                          'Position pool (SpawnPositionsPool)',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool decimal = true,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
