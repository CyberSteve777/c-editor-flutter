import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/zombie_row_lane_drag_drop_editor.dart';
import 'package:c_editor/widgets/zombie_row_lane_utils.dart';
import 'package:c_editor/widgets/zombie_selection_flow.dart';

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
  Map<int, int?> _zombieLevels = {};
  bool _zombieDragging = false;

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

  int? _readJsonInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);
    return null;
  }

  List<dynamic>? _waveJsonList(dynamic objData) {
    if (objData is! Map) return null;
    final waves = objData['Waves'];
    return waves is List ? waves : null;
  }

  Map<int, int?> _readWaveZombieLevels(dynamic objData, int waveIndex) {
    final waves = _waveJsonList(objData);
    if (waves == null || waveIndex < 0 || waveIndex >= waves.length) {
      return {};
    }
    final wave = waves[waveIndex];
    if (wave is! Map || wave['Zombies'] is! List) return {};
    final zombies = wave['Zombies'] as List;
    final result = <int, int?>{};
    for (var i = 0; i < zombies.length; i++) {
      final zombie = zombies[i];
      if (zombie is Map && zombie.containsKey('Level')) {
        result[i] = _readJsonInt(zombie['Level']);
      }
    }
    return result;
  }

  Map<int, Map<int, int?>> _readAllWaveZombieLevels(dynamic objData) {
    final waves = _waveJsonList(objData);
    if (waves == null) return {};
    final result = <int, Map<int, int?>>{};
    for (var i = 0; i < waves.length; i++) {
      final levels = _readWaveZombieLevels(objData, i);
      if (levels.isNotEmpty) result[i] = levels;
    }
    return result;
  }

  Map<String, dynamic> _withLevelAfterType(
    Map<dynamic, dynamic> source,
    int? level,
  ) {
    final result = <String, dynamic>{};
    var inserted = false;
    source.forEach((key, value) {
      final keyString = key.toString();
      if (keyString == 'Level') return;
      result[keyString] = value;
      if (keyString == 'Type' && level != null) {
        result['Level'] = level;
        inserted = true;
      }
    });
    if (!inserted && level != null) {
      result['Level'] = level;
    }
    return result;
  }

  void _applyWaveZombieLevels(
    dynamic objData,
    Map<int, Map<int, int?>> levelsByWave,
  ) {
    final waves = _waveJsonList(objData);
    if (waves == null) return;
    levelsByWave.forEach((waveIndex, levels) {
      if (waveIndex < 0 || waveIndex >= waves.length) return;
      final wave = waves[waveIndex];
      if (wave is! Map || wave['Zombies'] is! List) return;
      final zombies = wave['Zombies'] as List;
      for (var i = 0; i < zombies.length; i++) {
        final zombie = zombies[i];
        if (zombie is Map) {
          zombies[i] = _withLevelAfterType(zombie, levels[i]);
        }
      }
    });
  }

  String _zombieBaseId(String rtid) {
    return RtidParser.parse(rtid)?.alias ?? ZombieDisplayUtils.codename(rtid);
  }

  bool _isEliteRtid(String rtid) {
    return ZombieRepository().isElite(_zombieBaseId(rtid));
  }

  int? _normalizeZombieLevel(String rtid, int? level) {
    if (_isEliteRtid(rtid) || level == null) return null;
    return level < 1 ? 1 : level;
  }

  int? _levelForZombie(int index) {
    if (index < 0 || index >= _wave.zombies.length) return null;
    return _normalizeZombieLevel(
      _wave.zombies[index].type,
      _zombieLevels[index],
    );
  }

  void _setZombieLevelInMemory(int index, String rtid, int? level) {
    final normalized = _normalizeZombieLevel(rtid, level);
    if (normalized == null) {
      _zombieLevels.remove(index);
    } else {
      _zombieLevels[index] = normalized;
    }
  }

  void _loadZombieLevels(dynamic objData, int waveIndex) {
    final rawLevels = _readWaveZombieLevels(objData, waveIndex);
    _zombieLevels = {};
    for (var i = 0; i < _wave.zombies.length; i++) {
      _setZombieLevelInMemory(i, _wave.zombies[i].type, rawLevels[i]);
    }
  }

  Map<int, int?> _normalizedCurrentWaveLevels() {
    final result = <int, int?>{};
    for (var i = 0; i < _wave.zombies.length; i++) {
      final level = _normalizeZombieLevel(
        _wave.zombies[i].type,
        _zombieLevels[i],
      );
      if (level != null) result[i] = level;
    }
    return result;
  }

  WaveGeneratorPropertiesData _expectationData() {
    final scriptedTypes = <String>{};
    for (final wave in _generatorData.waves) {
      for (final zombie in wave.zombies) {
        scriptedTypes.add(zombie.type);
      }
    }

    final expectationWaves = _generatorData.waves.map((wave) {
      return WaveGeneratorWaveData(
        disableRandomSpawns: wave.disableRandomSpawns,
        zombies: wave.zombies,
        spawnPlantFoodCount: wave.spawnPlantFoodCount,
        addToZombiePool: wave.addToZombiePool
            .where((entry) => !scriptedTypes.contains(entry.type))
            .toList(),
        wavePointStart: wave.wavePointStart,
        wavePointIncrement: wave.wavePointIncrement,
        colNumPlantIsDragged: wave.colNumPlantIsDragged,
        waitUntilAllZombiesDie: wave.waitUntilAllZombiesDie,
      );
    }).toList();

    return WaveGeneratorPropertiesData(
      addToZombiePool: scriptedTypes
          .map((type) => WaveGeneratorPoolEntryData(type: type))
          .toList(),
      flagWaveInterval: _generatorData.flagWaveInterval,
      waveCount: _generatorData.waveCount,
      waveSpendingPoints: _generatorData.waveSpendingPoints,
      waveSpendingPointIncrement: _generatorData.waveSpendingPointIncrement,
      waves: expectationWaves,
    );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    final rawObjData = obj?.objData;
    _generatorData = obj != null
        ? WaveGeneratorLevelUtils.parseObject(obj)
        : WaveGeneratorPropertiesData(waves: [WaveGeneratorWaveData()]);
    final idx = widget.waveIndex - 1;
    if (idx >= 0 && idx < _generatorData.waves.length) {
      _wave = _generatorData.waves[idx];
    } else {
      _wave = WaveGeneratorWaveData();
    }
    _loadZombieLevels(rawObjData, idx);
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

  Widget _buildLabeledNumberField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    int? helperMaxLines,
    required ValueChanged<String> onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          softWrap: true,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            helperText: helperText,
            helperMaxLines: helperMaxLines,
          ),
          keyboardType: TextInputType.number,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _assignWaveZombies(
    List<WaveGeneratorZombieEntryData> zombies, {
    bool sortRows = false,
  }) {
    if (sortRows) {
      final parallelLevels = List<int?>.generate(
        zombies.length,
        (i) => _zombieLevels[i],
      );
      sortWaveGeneratorZombieListByRow(
        zombies,
        maxRow: _rowCount,
        parallelLevels: parallelLevels,
      );
      _zombieLevels = {};
      for (var i = 0; i < parallelLevels.length; i++) {
        final level = parallelLevels[i];
        if (level != null) {
          _zombieLevels[i] = level;
        }
      }
    }
    _wave = _copyWave(zombies: zombies);
    _sync();
  }

  void _sync() {
    final obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (obj == null) return;
    final idx = widget.waveIndex - 1;
    if (idx < 0 || idx >= _generatorData.waves.length) return;
    final allLevels = _readAllWaveZombieLevels(obj.objData);
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
    allLevels[idx] = _normalizedCurrentWaveLevels();
    obj.objData = _generatorData.toJson();
    _applyWaveZombieLevels(obj.objData, allLevels);
    widget.onChanged();
    setState(() {});
  }

  bool _isYetiZombie(String id) {
    return id == 'yeti' || id == 'treasureyeti' || id == 'treasureyeti_egypt';
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
      disableRandomSpawns: disableRandomSpawns ?? _wave.disableRandomSpawns,
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
    return ZombieDisplayUtils.iconPath(rtid, levelFile: widget.levelFile);
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

  void _updateZombie(
    int index,
    WaveGeneratorZombieEntryData updated, {
    int? level,
    bool replaceLevel = false,
  }) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies);
    final rowChanged = list[index].row != updated.row;
    list[index] = updated;
    _setZombieLevelInMemory(
      index,
      updated.type,
      replaceLevel ? level : _zombieLevels[index],
    );
    _assignWaveZombies(list, sortRows: rowChanged);
  }

  void _setZombieLevel(int index, int? level) {
    if (index < 0 || index >= _wave.zombies.length) return;
    _setZombieLevelInMemory(index, _wave.zombies[index].type, level);
    _sync();
  }

  void _removeZombie(int index) {
    final list = List<WaveGeneratorZombieEntryData>.from(_wave.zombies)
      ..removeAt(index);
    final shiftedLevels = <int, int?>{};
    _zombieLevels.forEach((key, value) {
      if (key < index) {
        shiftedLevels[key] = value;
      } else if (key > index) {
        shiftedLevels[key - 1] = value;
      }
    });
    _zombieLevels = shiftedLevels;
    _assignWaveZombies(list);
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
      final newIndex = _wave.zombies.length;
      _setZombieLevelInMemory(newIndex, rtid, null);
      _assignWaveZombies(
        [
          ..._wave.zombies,
          WaveGeneratorZombieEntryData(type: rtid, row: rowStr),
        ],
        sortRows: true,
      );
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
      data: _expectationData(),
      waveIndex: widget.waveIndex,
      isFlagWave: _isFlagWave,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final expectationData = _expectationData();
    final points = WaveGeneratorPointAnalysis.pointsAtWave(
      expectationData,
      widget.waveIndex,
      isFlagWave: _isFlagWave,
    );
    final showExpectation = WaveGeneratorPointAnalysis.showExpectationForWave(
      expectationData,
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
                  body:
                      l10n?.waveGeneratorWaveScreenHelpBody ??
                      'Edit scripted spawns and wave-specific options. Random spawns use the cumulative zombie pool and spending points.',
                ),
                HelpSectionData(
                  title: l10n?.expectation ?? 'Expectation',
                  body:
                      l10n?.waveGeneratorExpectationPoolNote ??
                      'Pool expectation shows likely random spawns from AddToZombiePool. Other zombies may still appear when points are high enough.',
                ),
                HelpSectionData(
                  title: l10n?.waveGeneratorModuleHelpRow ?? 'Row',
                  body:
                      l10n?.waveGeneratorModuleHelpRowBody ??
                      'Row values are 1-based strings in JSON ("?" = random).',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: _zombieDragging
              ? const NeverScrollableScrollPhysics()
              : null,
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
                      _buildLabeledNumberField(
                        controller: _plantFoodCtrl,
                        label:
                            l10n?.waveGeneratorSpawnPlantFood ??
                            'Plant food drops (SpawnPlantFoodCount)',
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
                      _buildLabeledNumberField(
                        controller: _pointStartCtrl,
                        label:
                            l10n?.waveGeneratorWavePointStart ??
                            'Wave point start (WavePointStart)',
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
                      const SizedBox(height: 12),
                      _buildLabeledNumberField(
                        controller: _pointIncrementCtrl,
                        label:
                            l10n?.waveGeneratorWavePointIncrement ??
                            'Wave point increment (WavePointIncrement)',
                        onChanged: (v) {
                          final trimmed = v.trim();
                          if (trimmed.isEmpty) {
                            _wave = _copyWave(clearWavePointIncrement: true);
                          } else {
                            final n = int.tryParse(trimmed);
                            if (n != null) {
                              _wave = _copyWave(wavePointIncrement: n);
                            }
                          }
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildLabeledNumberField(
                        controller: _blackHoleCtrl,
                        label:
                            l10n?.columnsDragged ??
                            'Columns dragged (ColNumPlantIsDragged)',
                        helperText: l10n?.waveGeneratorBlackHoleFieldHint,
                        helperMaxLines: 10,
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
                              for (
                                var i = 0;
                                i < _wave.addToZombiePool.length;
                                i++
                              )
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
    return ZombieRowLaneDragDropEditor(
      maxRow: _rowCount,
      rowLabel: (row) => l10n?.rowN(row) ?? 'Row $row',
      randomRowLabel: l10n?.randomRow ?? l10n?.random ?? 'Random row',
      items: _wave.zombies.asMap().entries.map((entry) {
        final idx = entry.key;
        final z = entry.value;
        final isElite = _isEliteRtid(z.type);
        final level = _levelForZombie(idx);
        return ZombieLaneIconData(
          identity: z,
          listIndex: idx,
          rowValue: _rowValue(z.row),
          iconPath: _zombieIcon(z.type),
          levelDisplay: isElite ? 'E' : (level == null ? '0' : '$level'),
          isElite: isElite,
          isCustom: false,
        );
      }).toList(),
      onTap: _showZombieEditSheet,
      onMove: _handleZombieDragDropMove,
      onAddToRow: (row) => _addZombie(rowValue: row),
      onDraggingChanged: (dragging) =>
          setState(() => _zombieDragging = dragging),
    );
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _wave.zombies[index];
    final iconPath = _zombieIcon(zombie.type);
    final displayName = _zombieDisplayName(zombie.type);
    final isElite = _isEliteRtid(zombie.type);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        var rowValue = _rowValue(zombie.row);
        var levelValue = _levelForZombie(index) ?? 0;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ZombieEditSheetIdentityTile(
                      iconPath: iconPath,
                      displayName: displayName,
                      isCustom: false,
                      onChange: () => _changeZombieTypeFromSheet(
                        sheetContext: ctx,
                        index: index,
                        currentRow: rowValue == 0 ? '?' : '$rowValue',
                        levelValue: levelValue,
                        isElite: isElite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: rowValue,
                      decoration: InputDecoration(
                        labelText: l10n?.row ?? 'Row',
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(l10n?.random ?? 'Random'),
                        ),
                        ...List.generate(_rowCount, (i) => i + 1).map(
                          (v) => DropdownMenuItem(
                            value: v,
                            child: Text(l10n?.rowN(v) ?? 'Row $v'),
                          ),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setModalState(() => rowValue = v);
                        _setZombieRow(index, v);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (isElite)
                      Text(
                        l10n?.eliteZombiesUseDefaultLevel ??
                            'Elite zombies use default level.',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else ...[
                      SwitchListTile(
                        title: Text(l10n?.autoLevel ?? 'Auto level'),
                        value: levelValue == 0,
                        onChanged: (v) {
                          final nextLevel = v ? 0 : 1;
                          setModalState(() => levelValue = nextLevel);
                          _setZombieLevel(index, v ? null : 1);
                        },
                      ),
                      if (levelValue != 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.levelFormat(levelValue) ??
                                  'Level: $levelValue',
                            ),
                            Slider(
                              value: levelValue.toDouble(),
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: '$levelValue',
                              onChanged: (v) {
                                final newLevel = v.round();
                                setModalState(() => levelValue = newLevel);
                                _setZombieLevel(index, newLevel);
                              },
                            ),
                          ],
                        ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final rowStr = rowValue == 0 ? '?' : '$rowValue';
                              final copy = WaveGeneratorZombieEntryData(
                                type: zombie.type,
                                row: rowStr,
                              );
                              final newIndex = _wave.zombies.length;
                              _setZombieLevelInMemory(
                                newIndex,
                                zombie.type,
                                isElite
                                    ? null
                                    : (levelValue == 0 ? null : levelValue),
                              );
                              _wave = _copyWave(
                                zombies: [..._wave.zombies, copy],
                              );
                              _sync();
                              Navigator.pop(ctx);
                            },
                            icon: const Icon(Icons.copy),
                            label: Text(l10n?.copy ?? 'Copy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              _removeZombie(index);
                            },
                            icon: const Icon(Icons.delete),
                            label: Text(l10n?.delete ?? 'Delete'),
                          ),
                        ),
                      ],
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
