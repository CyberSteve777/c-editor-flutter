import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';

/// Full-screen editor for a single wave inside [WaveGeneratorProperties].
class WaveGeneratorWaveScreen extends StatefulWidget {
  const WaveGeneratorWaveScreen({
    super.key,
    required this.waveIndex,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  /// 1-based wave index.
  final int waveIndex;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
      onRequestZombieSelection;

  @override
  State<WaveGeneratorWaveScreen> createState() =>
      _WaveGeneratorWaveScreenState();
}

class _WaveGeneratorWaveScreenState extends State<WaveGeneratorWaveScreen> {
  late WaveGeneratorPropertiesData _generatorData;
  late WaveGeneratorWaveData _wave;
  late TextEditingController _plantFoodCtrl;
  late TextEditingController _pointStartCtrl;
  late TextEditingController _pointIncrementCtrl;
  late TextEditingController _blackHoleCtrl;

  int get _rowCount {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  bool get _isFlagWave {
    final interval = _generatorData.flagWaveInterval <= 0
        ? 10
        : _generatorData.flagWaveInterval;
    return widget.waveIndex % interval == 0 ||
        widget.waveIndex == _generatorData.waves.length;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    _generatorData = obj != null
        ? WaveGeneratorLevelUtils.parseObject(obj)
        : WaveGeneratorPropertiesData(waves: [WaveGeneratorWaveData()]);
    final idx = widget.waveIndex - 1;
    if (idx >= 0 && idx < _generatorData.waves.length) {
      _wave = _generatorData.waves[idx];
    } else {
      _wave = WaveGeneratorWaveData();
    }
    _plantFoodCtrl = TextEditingController(
      text: _wave.spawnPlantFoodCount?.toString() ?? '',
    );
    _pointStartCtrl = TextEditingController(
      text: _wave.wavePointStart?.toString() ?? '',
    );
    _pointIncrementCtrl = TextEditingController(
      text: _wave.wavePointIncrement?.toString() ?? '',
    );
    _blackHoleCtrl = TextEditingController(
      text: _wave.colNumPlantIsDragged?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _plantFoodCtrl.dispose();
    _pointStartCtrl.dispose();
    _pointIncrementCtrl.dispose();
    _blackHoleCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (obj == null) return;
    final idx = widget.waveIndex - 1;
    if (idx < 0 || idx >= _generatorData.waves.length) return;
    final waves = List<WaveGeneratorWaveData>.from(_generatorData.waves);
    waves[idx] = _wave;
    _generatorData = WaveGeneratorPropertiesData(
      addToZombiePool: _generatorData.addToZombiePool,
      flagWaveInterval: _generatorData.flagWaveInterval,
      waveCount: _generatorData.waveCount,
      waveSpendingPoints: _generatorData.waveSpendingPoints,
      waveSpendingPointIncrement: _generatorData.waveSpendingPointIncrement,
      waves: waves,
    );
    _generatorData.syncWaveCount();
    obj.objData = _generatorData.toJson();
    widget.onChanged();
    setState(() {});
  }


  bool _isYetiZombie(String id) {
    return id == 'yeti' ||
        id == 'treasureyeti' ||
        id == 'treasureyeti_egypt';
  }

  void _showYetiZombieBlockedMessage(AppLocalizations? l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.yetiZombiesNotAllowed ?? 'Yetis are not allowed here',
        ),
      ),
    );
  }

  WaveGeneratorWaveData _copyWave({
    bool? disableRandomSpawns,
    List<WaveGeneratorZombieEntryData>? zombies,
    int? spawnPlantFoodCount,
    List<WaveGeneratorPoolEntryData>? addToZombiePool,
    int? wavePointStart,
    int? wavePointIncrement,
    int? colNumPlantIsDragged,
    bool? waitUntilAllZombiesDie,
    bool clearSpawnPlantFood = false,
    bool clearWavePointStart = false,
    bool clearWavePointIncrement = false,
    bool clearColNumPlantIsDragged = false,
  }) {
    return WaveGeneratorWaveData(
      disableRandomSpawns:
          disableRandomSpawns ?? _wave.disableRandomSpawns,
      zombies: zombies ?? _wave.zombies,
      spawnPlantFoodCount: clearSpawnPlantFood
          ? null
          : (spawnPlantFoodCount ?? _wave.spawnPlantFoodCount),
      addToZombiePool: addToZombiePool ?? _wave.addToZombiePool,
      wavePointStart: clearWavePointStart
          ? null
          : (wavePointStart ?? _wave.wavePointStart),
      wavePointIncrement: clearWavePointIncrement
          ? null
          : (wavePointIncrement ?? _wave.wavePointIncrement),
      colNumPlantIsDragged: clearColNumPlantIsDragged
          ? null
          : (colNumPlantIsDragged ?? _wave.colNumPlantIsDragged),
      waitUntilAllZombiesDie:
          waitUntilAllZombiesDie ?? _wave.waitUntilAllZombiesDie,
    );
  }

  String _zombieDisplayName(String rtid) {
    return ZombieDisplayUtils.localizedName(
      context,
      typeOrRtid: rtid,
      levelFile: widget.levelFile,
    );
  }

  String _zombieCodename(String rtid) {
    return ZombieDisplayUtils.codename(rtid);
  }

  String? _zombieIcon(String rtid) {
    return ZombieDisplayUtils.iconPath(
      rtid,
      levelFile: widget.levelFile,
    );
  }

  int _rowValue(String? row) {
    if (row == null || row.isEmpty || row == '?') {
      return 0;
    }
    return int.tryParse(row) ?? 0;
  }

  void _setZombieRow(int index, int rowValue) {
    final zombie = _wave.zombies[index];
    final rowStr = rowValue == 0 ? '?' : '$rowValue';
    _updateZombie(
      index,
      WaveGeneratorZombieEntryData(type: zombie.type, row: rowStr),
    );
  }

  void _updateZombie(int index, WaveGeneratorZombieEntryData updated) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies);
    list[index] = updated;
    _wave = _copyWave(zombies: list);
    _sync();
  }

  void _removeZombie(int index) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies)
      ..removeAt(index);
    _wave = _copyWave(zombies: list);
    _sync();
  }

  void _addZombie({required int rowValue}) {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      final rtid = RtidParser.build(
        ZombieRepository().buildZombieAliases(selectedId),
        'ZombieTypes',
      );
      if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.waveGeneratorCustomZombieBlocked ??
                  'Custom zombies are not supported in wave generator levels.',
            ),
          ),
        );
        return;
      }
      final rowStr = rowValue == 0 ? '?' : '$rowValue';
      _wave = _copyWave(
        zombies: [
          ..._wave.zombies,
          WaveGeneratorZombieEntryData(type: rtid, row: rowStr),
        ],
      );
      _sync();
    });
  }

  void _removePoolEntry(int index) {
    final pool = List<WaveGeneratorPoolEntryData>.from(_wave.addToZombiePool)
      ..removeAt(index);
    _wave = _copyWave(addToZombiePool: pool);
    _sync();
  }

  void _addPoolEntry() {
    if (_wave.disableRandomSpawns) return;
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      if (_isYetiZombie(selectedId)) {
        _showYetiZombieBlockedMessage(l10n);
        return;
      }
      if (ZombieRepository().isElite(selectedId)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.eliteZombiesNotAllowed ??
                  'Elite zombies are not allowed here',
            ),
          ),
        );
        return;
      }
      final rtid = RtidParser.build(
        ZombieRepository().buildZombieAliases(selectedId),
        'ZombieTypes',
      );
      if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.waveGeneratorCustomZombieBlocked ??
                  'Custom zombies are not supported.',
            ),
          ),
        );
        return;
      }
      _wave = _copyWave(
        addToZombiePool: [
          ..._wave.addToZombiePool,
          WaveGeneratorPoolEntryData(type: rtid),
        ],
      );
      _sync();
    });
  }

  void _showExpectation() {
    showWaveGeneratorExpectationDialog(
      context,
      data: _generatorData,
      waveIndex: widget.waveIndex,
      isFlagWave: _isFlagWave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final points = WaveGeneratorPointAnalysis.pointsAtWave(
      _generatorData,
      widget.waveIndex,
      isFlagWave: _isFlagWave,
    );
    final showExpectation = WaveGeneratorPointAnalysis.showExpectationForWave(
      _generatorData,
      widget.waveIndex,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n?.waveLabel ?? 'Wave'} ${widget.waveIndex}'),
            Text(
              l10n?.waveGeneratorWaveScreenSubtitle ?? 'Wave generator wave',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          if (showExpectation)
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              tooltip: l10n?.expectation ?? 'Expectation',
              onPressed: _showExpectation,
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'Help',
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.waveGeneratorWaveScreenHelpTitle ?? 'Wave editor',
              sections: [
                HelpSectionData(
                  title: l10n?.waveGeneratorModuleHelpOverview ?? 'Overview',
                  body: l10n?.waveGeneratorWaveScreenHelpBody ??
                      'Edit scripted spawns and wave-specific options. Random spawns use the cumulative zombie pool and spending points.',
                ),
                HelpSectionData(
                  title: l10n?.expectation ?? 'Expectation',
                  body: l10n?.waveGeneratorExpectationPoolNote ??
                      'Pool expectation shows likely random spawns from AddToZombiePool. Other zombies may still appear when points are high enough.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showExpectation)
                Card(
                  child: InkWell(
                    onTap: _showExpectation,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.wavePointsShort(points) ??
                                      '$points pts.',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n?.waveGeneratorExpectationTapHint ??
                                      'Tap to view random spawn expectation',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ),
              if (showExpectation) const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(
                        l10n?.waveGeneratorDisableRandomSpawns ??
                            'Disable random spawns (DisableRandomSpawns)',
                      ),
                      subtitle: Text(
                        l10n?.waveGeneratorDisableRandomSpawnsHint ?? '',
                      ),
                      value: _wave.disableRandomSpawns,
                      onChanged: (v) {
                        _wave = _copyWave(disableRandomSpawns: v);
                        _sync();
                      },
                    ),
                    SwitchListTile(
                      title: Text(
                        l10n?.waveGeneratorWaitUntilAllDie ??
                            'Wait until all zombies die (WaitUntilAllZombiesDie)',
                      ),
                      value: _wave.waitUntilAllZombiesDie ?? false,
                      onChanged: (v) {
                        _wave = _copyWave(waitUntilAllZombiesDie: v);
                        _sync();
                      },
                    ),
                  ],
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
                        l10n?.zombieList ?? 'Zombie list',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLaneRows(context, theme, l10n),
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
                      TextFormField(
                        controller: _plantFoodCtrl,
                        decoration: InputDecoration(
                          labelText: l10n?.waveGeneratorSpawnPlantFood ??
                              'Plant food drops (SpawnPlantFoodCount)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final trimmed = v.trim();
                          if (trimmed.isEmpty) {
                            _wave = _copyWave(clearSpawnPlantFood: true);
                          } else {
                            final n = int.tryParse(trimmed);
                            if (n != null) {
                              _wave = _copyWave(spawnPlantFoodCount: n);
                            }
                          }
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pointStartCtrl,
                              decoration: InputDecoration(
                                labelText: l10n?.waveGeneratorWavePointStart ??
                                    'Wave point start (WavePointStart)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final trimmed = v.trim();
                                if (trimmed.isEmpty) {
                                  _wave = _copyWave(clearWavePointStart: true);
                                } else {
                                  final n = int.tryParse(trimmed);
                                  if (n != null) {
                                    _wave = _copyWave(wavePointStart: n);
                                  }
                                }
                                _sync();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _pointIncrementCtrl,
                              decoration: InputDecoration(
                                labelText:
                                    l10n?.waveGeneratorWavePointIncrement ??
                                        'Wave point increment (WavePointIncrement)',
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final trimmed = v.trim();
                                if (trimmed.isEmpty) {
                                  _wave =
                                      _copyWave(clearWavePointIncrement: true);
                                } else {
                                  final n = int.tryParse(trimmed);
                                  if (n != null) {
                                    _wave = _copyWave(wavePointIncrement: n);
                                  }
                                }
                                _sync();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _blackHoleCtrl,
                        decoration: InputDecoration(
                          labelText: l10n?.columnsDragged ??
                              'Columns dragged (ColNumPlantIsDragged)',
                          border: const OutlineInputBorder(),
                          helperText: l10n?.waveGeneratorBlackHoleFieldHint,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final trimmed = v.trim();
                          if (trimmed.isEmpty) {
                            _wave = _copyWave(clearColNumPlantIsDragged: true);
                          } else {
                            final n = int.tryParse(trimmed);
                            if (n != null) {
                              _wave = _copyWave(colNumPlantIsDragged: n);
                            }
                          }
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (!_wave.disableRandomSpawns)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n?.waveGeneratorWavePoolAdd ??
                                    'Add to pool this wave (AddToZombiePool)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              tooltip: l10n?.addType ?? 'Add',
                              onPressed: _addPoolEntry,
                            ),
                          ],
                        ),
                        if (_wave.addToZombiePool.isEmpty)
                          Text(
                            l10n?.waveGeneratorEmptyPool ??
                                'No zombies in the initial pool.',
                            style: theme.textTheme.bodySmall,
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var i = 0;
                                  i < _wave.addToZombiePool.length;
                                  i++)
                                WaveGeneratorZombieTile(
                                  style:
                                      WaveGeneratorZombieTileStyle.poolCompact,
                                  localizedName: _zombieDisplayName(
                                    _wave.addToZombiePool[i].type,
                                  ),
                                  codename: _zombieCodename(
                                    _wave.addToZombiePool[i].type,
                                  ),
                                  iconPath: _zombieIcon(
                                    _wave.addToZombiePool[i].type,
                                  ),
                                  onDelete: () => _removePoolEntry(i),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaneRows(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        for (var row = 1; row <= _rowCount; row++) ...[
          _buildLaneRow(
            context,
            theme,
            label: l10n?.rowN(row) ?? 'Row $row',
            rowValue: row,
            zombies: _wave.zombies
                .asMap()
                .entries
                .where((e) => _rowValue(e.value.row) == row)
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        _buildLaneRow(
          context,
          theme,
          label: l10n?.randomRow ?? l10n?.random ?? 'Random row',
          rowValue: 0,
          zombies: _wave.zombies
              .asMap()
              .entries
              .where((e) => _rowValue(e.value.row) == 0)
              .toList(),
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _buildLaneRow(
    BuildContext context,
    ThemeData theme, {
    required String label,
    required int rowValue,
    required List<MapEntry<int, WaveGeneratorZombieEntryData>> zombies,
    Color? color,
  }) {
    final laneColor = color ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: laneColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${zombies.length}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...zombies.map((entry) {
                  final idx = entry.key;
                  final z = entry.value;
                  return ZombieIconCard(
                    iconPath: _zombieIcon(z.type),
                    levelDisplay: '',
                    showLevelBadge: false,
                    isElite: false,
                    isCustom: false,
                    onTap: () => _showZombieEditSheet(idx),
                  );
                }),
                PvzAddButton(
                  onPressed: () => _addZombie(rowValue: rowValue),
                  useSecondaryColor: rowValue == 0,
                  size: 56,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _wave.zombies[index];
    final iconPath = _zombieIcon(zombie.type);
    final displayName = _zombieDisplayName(zombie.type);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        var rowValue = _rowValue(zombie.row);
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        if (iconPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              altCandidates: imageAltCandidates(iconPath),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.row ?? 'Row',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text(l10n?.random ?? 'Random'),
                          selected: rowValue == 0,
                          onSelected: (_) {
                            setModalState(() => rowValue = 0);
                            _setZombieRow(index, 0);
                          },
                        ),
                        ...List.generate(_rowCount, (i) => i + 1).map(
                          (r) => FilterChip(
                            label: Text(l10n?.rowN(r) ?? '$r'),
                            selected: rowValue == r,
                            onSelected: (_) {
                              setModalState(() => rowValue = r);
                              _setZombieRow(index, r);
                            },
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      child: Text(
                        l10n?.waveGeneratorRowHint ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        widget.onRequestZombieSelection((id) {
                          final rtid = RtidParser.build(
                            ZombieRepository().buildZombieAliases(id),
                            'ZombieTypes',
                          );
                          if (RtidParser.parse(rtid)?.source == 'CurrentLevel') {
                            return;
                          }
                          _updateZombie(
                            index,
                            WaveGeneratorZombieEntryData(
                              type: rtid,
                              row: zombie.row,
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n?.change ?? 'Change'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                        foregroundColor:
                            Theme.of(context).colorScheme.onError,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _removeZombie(index);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(l10n?.delete ?? 'Delete'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
