import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/screens/editor/events/fish_properties_entry_screen.dart';

/// Zombie + fish wave event for submarine levels.
class ZombieFishWaveEventScreen extends StatefulWidget {
  const ZombieFishWaveEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onRequestPlantSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
    this.onEditCustomFish,
    this.onInjectCustomFish,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(void Function(String) onSelected)?
  onRequestPlantSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String baseType)? onInjectCustomZombie;
  final void Function(String rtid)? onEditCustomFish;
  final String? Function(String baseFishAlias)? onInjectCustomFish;

  @override
  State<ZombieFishWaveEventScreen> createState() =>
      _ZombieFishWaveEventScreenState();
}

class _ZombieFishWaveEventScreenState extends State<ZombieFishWaveEventScreen> {
  static const _objClass = 'SpawnZombiesFishWaveActionProps';

  late PvzObject _moduleObj;
  late SpawnZombiesFishWaveActionPropsData _data;
  late String _alias;
  double _batchLevel = 1;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRow => _isDeepSeaLawn ? 6 : 5;

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
        objClass: _objClass,
        objData: SpawnZombiesFishWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnZombiesFishWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnZombiesFishWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _resolveBaseTypeName(ZombieSpawnData z) {
    final info = RtidParser.parse(z.type);
    final alias = info?.alias ?? z.type;
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (obj != null && obj.objClass == 'ZombieType') {
      final d = obj.objData;
      if (d is Map<String, dynamic> && d['TypeName'] is String) {
        return d['TypeName'] as String;
      }
    }
    return ZombiePropertiesRepository.getTypeNameByAlias(alias);
  }

  bool _isElite(ZombieSpawnData z) =>
      ZombieRepository().isElite(_resolveBaseTypeName(z));

  bool _isCustomZombie(ZombieSpawnData z) {
    return CustomZombieLevelUtils.isCustomZombieRtid(z.type);
  }

  void _addZombie({int? row}) {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final zombies = List<ZombieSpawnData>.from(_data.zombies)
        ..add(ZombieSpawnData(type: rtid, level: 1, row: row));
      _data = SpawnZombiesFishWaveActionPropsData(
        notificationEvents: _data.notificationEvents,
        additionalPlantFood: _data.additionalPlantFood,
        spawnPlantName: _data.spawnPlantName,
        zombies: zombies,
        fishes: _data.fishes,
      );
      _sync();
    });
  }

  void _updateZombie(int index, ZombieSpawnData z) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    zombies[index] = z;
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: _data.additionalPlantFood,
      spawnPlantName: _data.spawnPlantName,
      zombies: zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  Future<void> _removeZombie(int index, {bool? eraseOrphanProperties}) async {
    final removed = _data.zombies[index];
    final info = RtidParser.parse(removed.type);
    var eraseOrphan = eraseOrphanProperties ?? false;
    if (info?.source == 'CurrentLevel' &&
        eraseOrphanProperties == null &&
        mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: info!.alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    final zombies = List<ZombieSpawnData>.from(_data.zombies)..removeAt(index);
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: _data.additionalPlantFood,
      spawnPlantName: _data.spawnPlantName,
      zombies: zombies,
      fishes: _data.fishes,
    );
    _sync();
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _openFishProperties() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FishPropertiesEntryScreen(
          levelFile: widget.levelFile,
          fishes: _data.fishes,
          onChanged: (newFishes) {
            _data = SpawnZombiesFishWaveActionPropsData(
              notificationEvents: _data.notificationEvents,
              additionalPlantFood: _data.additionalPlantFood,
              spawnPlantName: _data.spawnPlantName,
              zombies: _data.zombies,
              fishes: newFishes,
            );
            _sync();
          },
          onBack: () => Navigator.pop(context),
          onEditCustomFish: widget.onEditCustomFish,
          onInjectCustomFish: widget.onInjectCustomFish,
        ),
      ),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final hasFishes = _data.fishes.isNotEmpty;

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
              title: l10n?.eventZombieFishWave ?? 'Zombie Fish Wave',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpZombieFishWaveBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.fishPropertiesGrid ?? 'Fish placement',
                  body: l10n?.eventHelpZombieFishWaveFish ?? '',
                ),
                HelpSectionData(
                  title: l10n?.batchLevel ?? 'Batch level',
                  body:
                      l10n?.eventHelpBatchLevel ??
                      'Set level for all non-elite zombies in this wave.',
                ),
                HelpSectionData(
                  title: l10n?.dropConfigPlantFood ?? 'Drop config',
                  body:
                      l10n?.eventHelpDropConfig ??
                      'Plant food or plant cards carried by zombies.',
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
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.zombieList ?? 'Zombies',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_maxRow, (row) {
                final rowVal = row + 1;
                final zombies = _data.zombies
                    .asMap()
                    .entries
                    .where((e) => (e.value.row ?? 0) == rowVal)
                    .toList();
                return _buildLaneRow(
                  context,
                  theme,
                  l10n,
                  label: l10n?.rowN(rowVal) ?? 'Row $rowVal',
                  rowValue: rowVal,
                  zombies: zombies,
                );
              }),
              _buildLaneRow(
                context,
                theme,
                l10n,
                label: l10n?.randomRow ?? 'Random row',
                rowValue: 0,
                zombies: _data.zombies
                    .asMap()
                    .entries
                    .where((e) => (e.value.row ?? 0) == 0)
                    .toList(),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              _buildBatchLevelCard(theme, l10n),
              const SizedBox(height: 16),
              _buildDropConfigCard(context, theme, l10n),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pets, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.fishPropertiesButton ?? 'Fish properties',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _openFishProperties,
                        icon: Icon(hasFishes ? Icons.edit : Icons.add),
                        label: Text(
                          hasFishes
                              ? (l10n?.editFishProperties ??
                                    'Edit fish properties')
                              : (l10n?.addFishProperties ??
                                    'Add fish properties'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _applyBatchLevel() {
    final level = _batchLevel.round();
    final zombies = _data.zombies.map((z) {
      if (_isElite(z)) {
        return ZombieSpawnData(type: z.type, row: z.row, level: null);
      }
      return ZombieSpawnData(type: z.type, row: z.row, level: level);
    }).toList();
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: _data.additionalPlantFood,
      spawnPlantName: _data.spawnPlantName,
      zombies: zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _updateAdditionalPlantFood(int count) {
    final plants = _data.spawnPlantName ?? [];
    final newPlants = count <= plants.length
        ? plants.take(count).toList()
        : [...plants, ...List.filled(count - plants.length, 'sunflower')];
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: count,
      spawnPlantName: newPlants.isEmpty ? null : newPlants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _addSpawnPlant(String id) {
    final plants = List<String>.from(_data.spawnPlantName ?? []);
    plants.add(id);
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: (_data.additionalPlantFood ?? 0) + 1,
      spawnPlantName: plants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  void _removeSpawnPlantAt(int index) {
    final plants = List<String>.from(_data.spawnPlantName ?? []);
    plants.removeAt(index);
    _data = SpawnZombiesFishWaveActionPropsData(
      notificationEvents: _data.notificationEvents,
      additionalPlantFood: (plants.length) > 0 ? plants.length : null,
      spawnPlantName: plants.isEmpty ? null : plants,
      zombies: _data.zombies,
      fishes: _data.fishes,
    );
    _sync();
  }

  Widget _buildBatchLevelCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.layers, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  l10n?.batchLevel ?? 'Batch level',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_batchLevel.round()}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _batchLevel,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _batchLevel.round().toString(),
                    onChanged: (v) => setState(() => _batchLevel = v),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(
                          l10n?.applyBatchLevel ?? 'Apply batch level?',
                        ),
                        content: Text(
                          l10n?.applyBatchLevelContent(_batchLevel.round()) ??
                              'Set all zombies in this wave to level ${_batchLevel.round()} (elite unchanged).',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n?.cancel ?? 'Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n?.apply ?? 'Apply'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) _applyBatchLevel();
                  },
                  child: Text(l10n?.apply ?? 'Apply'),
                ),
              ],
            ),
            Text(
              l10n?.appliesToAllNonElite ??
                  'Applies to all non-elite zombies in this wave.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropConfigCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final count = _data.additionalPlantFood ?? 0;
    final plants = List<String>.from(_data.spawnPlantName ?? []);
    final isDroppingPlants = plants.length == count && plants.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.eco, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  isDroppingPlants
                      ? (l10n?.dropConfigPlants ?? 'Drop config (Plants)')
                      : (l10n?.dropConfigPlantFood ??
                            'Drop config (Plant Food)'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: count > 0
                      ? () => _updateAdditionalPlantFood(count - 1)
                      : null,
                ),
                Text('$count'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _updateAdditionalPlantFood(count + 1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isDroppingPlants
                        ? (l10n?.zombiesCarryingPlants ??
                              'Zombies carrying plants')
                        : (l10n?.zombiesCarryingPlantFood ??
                              'Zombies carrying plant food'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (plants.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: plants.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final id = entry.value;
                  final info = PlantRepository().getPlantInfoById(id);
                  final name = info?.name ?? id;
                  final iconPath = info?.iconAssetPath;
                  return InputChip(
                    label: Text(ResourceNames.lookup(context, name)),
                    avatar: iconPath != null
                        ? ClipOval(
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              altCandidates: imageAltCandidates(iconPath),
                              width: 20,
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.local_florist, size: 16),
                    onDeleted: () => _removeSpawnPlantAt(idx),
                  );
                }).toList(),
              ),
            if (widget.onRequestPlantSelection != null) ...[
              const SizedBox(height: 8),
              InputChip(
                avatar: Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(l10n?.addPlant ?? 'Add plant'),
                onPressed: () {
                  widget.onRequestPlantSelection!.call((id) {
                    _addSpawnPlant(id);
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLaneRow(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n, {
    required String label,
    required int rowValue,
    required List<MapEntry<int, ZombieSpawnData>> zombies,
    Color? color,
  }) {
    final laneColor = color ?? theme.colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
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
                Text('${zombies.length}', style: theme.textTheme.bodySmall),
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
                  final baseType = _resolveBaseTypeName(z);
                  final info = ZombieRepository().getZombieById(baseType);
                  final iconPath = info?.iconAssetPath;
                  final isElite = _isElite(z);
                  return ZombieIconCard(
                    iconPath: iconPath,
                    levelDisplay: isElite ? 'E' : '${z.level ?? 1}',
                    isElite: isElite,
                    isCustom: _isCustomZombie(z),
                    onTap: () => _showZombieEditSheet(idx, z),
                  );
                }),
                PvzAddButton(
                  onPressed: () =>
                      _addZombie(row: rowValue == 0 ? null : rowValue),
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

  void _showZombieEditSheet(int index, ZombieSpawnData zombie) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final isCustom = _isCustomZombie(zombie);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        int rowValue = zombie.row ?? 0;
        int levelValue = zombie.level ?? 1;
        bool fromLeft = zombie.direction == 'left';
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (info?.iconAssetPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: AssetImageWidget(
                              assetPath: info!.iconAssetPath!,
                              altCandidates: imageAltCandidates(
                                info.iconAssetPath!,
                              ),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  info != null
                                      ? ResourceNames.lookup(context, info.name)
                                      : baseType,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCustom) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: pvzOrangeLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n?.customLabel ?? 'Custom',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue: rowValue.clamp(0, _maxRow),
                      decoration: const InputDecoration(
                        labelText: 'Row',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 0,
                          child: Text(l10n?.random ?? 'Random'),
                        ),
                        ...List.generate(_maxRow, (i) => i + 1).map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        setModalState(() => rowValue = v);
                        _updateZombie(
                          index,
                          ZombieSpawnData(
                            type: zombie.type,
                            row: v == 0 ? null : v,
                            level: levelValue,
                            direction: fromLeft ? 'left' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(l10n?.zombieFromLeft ?? 'From left'),
                      value: fromLeft,
                      onChanged: (v) {
                        setModalState(() => fromLeft = v);
                        _updateZombie(
                          index,
                          ZombieSpawnData(
                            type: zombie.type,
                            row: rowValue == 0 ? null : rowValue,
                            level: levelValue,
                            direction: v ? 'left' : null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final copy = ZombieSpawnData(
                                type: zombie.type,
                                row: rowValue == 0 ? null : rowValue,
                                level: levelValue,
                                direction: fromLeft ? 'left' : null,
                              );
                              _data = SpawnZombiesFishWaveActionPropsData(
                                notificationEvents: _data.notificationEvents,
                                additionalPlantFood: _data.additionalPlantFood,
                                spawnPlantName: _data.spawnPlantName,
                                zombies: [..._data.zombies, copy],
                                fishes: _data.fishes,
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
                              CustomZombieLevelUtils.handleDeleteFromBottomSheet(
                                sheetContext: ctx,
                                parentContext: context,
                                levelFile: widget.levelFile,
                                zombieTypeRtid: zombie.type,
                                onRemove: (eraseOrphan) => _removeZombie(
                                  index,
                                  eraseOrphanProperties: eraseOrphan,
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                            label: Text(l10n?.delete ?? 'Delete'),
                          ),
                        ),
                      ],
                    ),
                    if (widget.onEditCustomZombie != null ||
                        widget.onInjectCustomZombie != null)
                      CustomZombiePropertiesSheetActions(
                        levelFile: widget.levelFile,
                        baseType: baseType,
                        currentRtid: zombie.type,
                        onEditCustomZombie: widget.onEditCustomZombie,
                        onInjectCustomZombie: widget.onInjectCustomZombie,
                        onCloseSheet: () => Navigator.pop(ctx),
                        onRtidSelected: (rtid) {
                          _updateZombie(
                            index,
                            ZombieSpawnData(
                              type: rtid,
                              row: zombie.row,
                              level: zombie.level,
                              direction: zombie.direction == 'left'
                                  ? 'left'
                                  : null,
                            ),
                          );
                        },
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
