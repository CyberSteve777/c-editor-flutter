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
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Zombie spawn event editor for JitteredWave and GroundSpawner.
/// Ported from Z-Editor-master JitteredWaveEventEP.kt, SpawnZombiesFromGroundEventEP.kt
class ZombieSpawnEventScreen extends StatefulWidget {
  const ZombieSpawnEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.eventSubtitle,
    required this.isGroundSpawner,
    required this.onRequestZombieSelection,
    this.onRequestPlantSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final String eventSubtitle;
  final bool isGroundSpawner;
  final void Function(void Function(String) onSelected) onRequestZombieSelection;
  final void Function(void Function(String) onSelected)? onRequestPlantSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<ZombieSpawnEventScreen> createState() => _ZombieSpawnEventScreenState();
}

class _ZombieSpawnEventScreenState extends State<ZombieSpawnEventScreen> {
  late PvzObject _moduleObj;
  late dynamic _data;
  double _batchLevel = 1;

  bool get _isDeepSeaLawn => LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

  static const _jamOptions = [
    (null, 'None'),
    ('jam_pop', 'Pop'),
    ('jam_rap', 'Rap'),
    ('jam_metal', 'Metal'),
    ('jam_punk', 'Punk'),
    ('jam_8bit', '8-Bit'),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    final objClass = widget.isGroundSpawner
        ? 'SpawnZombiesFromGroundSpawnerProps'
        : 'SpawnZombiesJitteredWaveActionProps';
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: objClass,
        objData: widget.isGroundSpawner
            ? SpawnZombiesFromGroundData().toJson()
            : WaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      if (widget.isGroundSpawner) {
        _data = SpawnZombiesFromGroundData.fromJson(
          Map<String, dynamic>.from(_moduleObj.objData as Map),
        );
      } else {
        _data = WaveActionData.fromJson(
          Map<String, dynamic>.from(_moduleObj.objData as Map),
        );
      }
    } catch (_) {
      _data = widget.isGroundSpawner
          ? SpawnZombiesFromGroundData()
          : WaveActionData();
    }
    for (final zombie in _zombies) {
      if (_isElite(zombie)) {
        zombie.level = null;
      } else if ((zombie.level ?? 1) < 1) {
        zombie.level = 1;
      }
    }
  }

  List<ZombieSpawnData> get _zombies =>
      widget.isGroundSpawner
          ? (_data as SpawnZombiesFromGroundData).zombies
          : (_data as WaveActionData).zombies;

  String _resolveBaseTypeName(ZombieSpawnData zombie) {
    final info = RtidParser.parse(zombie.type);
    final alias = info?.alias ?? zombie.type;
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (obj != null && obj.objClass == 'ZombieType') {
      final data = obj.objData;
      if (data is Map<String, dynamic> && data['TypeName'] is String) {
        return data['TypeName'] as String;
      }
    }
    return ZombiePropertiesRepository.getTypeNameByAlias(alias);
  }

  bool _isElite(ZombieSpawnData zombie) {
    final baseType = _resolveBaseTypeName(zombie);
    return ZombieRepository().isElite(baseType);
  }

  bool _isCustomZombie(ZombieSpawnData zombie) {
    return CustomZombieLevelUtils.isCustomZombieRtid(zombie.type);
  }

  void _sync() {
    _moduleObj.objData = widget.isGroundSpawner
        ? (_data as SpawnZombiesFromGroundData).toJson()
        : (_data as WaveActionData).toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addZombie({int? row}) {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final zombies = List<ZombieSpawnData>.from(_zombies)
        ..add(ZombieSpawnData(type: rtid, level: null, row: row));
      _updateZombies(zombies);
    });
  }

  void _updateZombies(List<ZombieSpawnData> zombies) {
    if (widget.isGroundSpawner) {
      _data = SpawnZombiesFromGroundData(
        columnStart: (_data as SpawnZombiesFromGroundData).columnStart,
        columnEnd: (_data as SpawnZombiesFromGroundData).columnEnd,
        additionalPlantFood: (_data as SpawnZombiesFromGroundData).additionalPlantFood,
        spawnPlantName: (_data as SpawnZombiesFromGroundData).spawnPlantName,
        zombies: zombies,
      );
    } else {
      _data = WaveActionData(
        notificationEvents: (_data as WaveActionData).notificationEvents,
        additionalPlantFood: (_data as WaveActionData).additionalPlantFood,
        spawnPlantName: (_data as WaveActionData).spawnPlantName,
        zombies: zombies,
      );
    }
    _sync();
  }

  Future<void> _removeZombie(int index, {bool? eraseOrphanProperties}) async {
    final removed = _zombies[index];
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
    final zombies = List<ZombieSpawnData>.from(_zombies)..removeAt(index);
    _updateZombies(zombies);
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _updateZombie(int index, ZombieSpawnData zombie) {
    final zombies = List<ZombieSpawnData>.from(_zombies);
    zombies[index] = zombie;
    _updateZombies(zombies);
  }

  void _applyBatchLevel() {
    final level = _batchLevel.round();
    final zombies = _zombies.map((z) {
      if (_isElite(z)) {
        return ZombieSpawnData(type: z.type, row: z.row, level: null);
      }
      return ZombieSpawnData(type: z.type, row: z.row, level: level);
    }).toList();
    _updateZombies(zombies);
  }

  void _updateNotificationEvent(String? value) {
    if (widget.isGroundSpawner) return;
    final list = value == null ? null : <String>[value];
    _data = WaveActionData(
      notificationEvents: list,
      additionalPlantFood: (_data as WaveActionData).additionalPlantFood,
      spawnPlantName: (_data as WaveActionData).spawnPlantName,
      zombies: _zombies,
    );
    _sync();
  }

  void _updateAdditionalPlantFood(int count) {
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final currentPlants = List<String>.from(data.spawnPlantName ?? []);
      if (currentPlants.length > count) {
        currentPlants.removeRange(count, currentPlants.length);
      }
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: count == 0 ? null : count,
        spawnPlantName: currentPlants.isEmpty ? null : currentPlants,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final currentPlants = List<String>.from(data.spawnPlantName ?? []);
      if (currentPlants.length > count) {
        currentPlants.removeRange(count, currentPlants.length);
      }
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: count == 0 ? null : count,
        spawnPlantName: currentPlants.isEmpty ? null : currentPlants,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  void _addSpawnPlant(String plantId) {
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      list.add(plantId);
      final count = data.additionalPlantFood ?? 0;
      final nextCount = count < list.length ? list.length : count;
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: nextCount == 0 ? null : nextCount,
        spawnPlantName: list,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      list.add(plantId);
      final count = data.additionalPlantFood ?? 0;
      final nextCount = count < list.length ? list.length : count;
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: nextCount == 0 ? null : nextCount,
        spawnPlantName: list,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  void _removeSpawnPlantAt(int index) {
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
      _data = SpawnZombiesFromGroundData(
        columnStart: data.columnStart,
        columnEnd: data.columnEnd,
        additionalPlantFood: data.additionalPlantFood,
        spawnPlantName: list.isEmpty ? null : list,
        zombies: data.zombies,
      );
    } else {
      final data = _data as WaveActionData;
      final list = List<String>.from(data.spawnPlantName ?? []);
      if (index >= 0 && index < list.length) {
        list.removeAt(index);
      }
      _data = WaveActionData(
        notificationEvents: data.notificationEvents,
        additionalPlantFood: data.additionalPlantFood,
        spawnPlantName: list.isEmpty ? null : list,
        zombies: data.zombies,
      );
    }
    _sync();
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _zombies[index];
    final isElite = _isElite(zombie);
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = info?.name ?? baseType;
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(zombie);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        int rowValue = zombie.row ?? 0;
        int levelValue = zombie.level ?? 0;
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
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                ResourceNames.lookup(context, displayName),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isCustom) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: pvzOrangeLight,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n?.customLabel ??
                                      'Custom',
                                  style: TextStyle(
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
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: rowValue,
                          decoration: InputDecoration(
                            labelText: l10n?.row ?? 'Row',
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: 0, child: Text(l10n?.random ?? 'Random')),
                            ...List.generate(_isDeepSeaLawn ? 6 : 5, (i) => i + 1).map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(l10n?.rowN(v) ?? 'Row $v'),
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setModalState(() => rowValue = v);
                            final updated = ZombieSpawnData(
                              type: zombie.type,
                              row: v == 0 ? null : v,
                              level: zombie.level,
                              direction: fromLeft ? 'left' : null,
                            );
                            _updateZombie(index, updated);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            Future.microtask(() {
                              widget.onRequestZombieSelection((id) {
                                final aliases =
                                    ZombieRepository().buildZombieAliases(id);
                                final rtid =
                                    RtidParser.build(aliases, 'ZombieTypes');
                                final isEliteNew =
                                    ZombieRepository().isElite(id);
                                _updateZombie(
                                  index,
                                  ZombieSpawnData(
                                    type: rtid,
                                    row: zombie.row,
                                    level: isEliteNew ? null : zombie.level,
                                    direction: fromLeft ? 'left' : null,
                                  ),
                                );
                              });
                            });
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: Text(l10n?.change ?? 'Change'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isElite)
                    Text(
                      l10n?.eliteZombiesUseDefaultLevel ?? 'Elite zombies use default level.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else ...[
                    SwitchListTile(
                      title: Text(l10n?.autoLevel ?? 'Auto level'),
                      value: levelValue == 0,
                      onChanged: (v) {
                        setModalState(() => levelValue = v ? 0 : 1);
                        final updated = ZombieSpawnData(
                          type: zombie.type,
                          row: zombie.row,
                          level: v ? null : 1,
                          direction: fromLeft ? 'left' : null,
                        );
                        _updateZombie(index, updated);
                      },
                    ),
                    if (levelValue != 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n?.levelFormat(levelValue) ?? 'Level: $levelValue'),
                          Slider(
                            value: levelValue.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '$levelValue',
                            onChanged: (v) {
                              final newLevel = v.round();
                              setModalState(() => levelValue = newLevel);
                              final updated = ZombieSpawnData(
                                type: zombie.type,
                                row: zombie.row,
                                level: newLevel,
                                direction: fromLeft ? 'left' : null,
                              );
                              _updateZombie(index, updated);
                            },
                          ),
                        ],
                      ),
                  ],
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text(l10n?.zombieFromLeft ?? 'From left'),
                    value: fromLeft,
                    onChanged: (v) {
                      setModalState(() => fromLeft = v);
                      final updated = ZombieSpawnData(
                        type: zombie.type,
                        row: zombie.row,
                        level: zombie.level,
                        direction: v ? 'left' : null,
                      );
                      _updateZombie(index, updated);
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
                              level: isElite ? null : (levelValue == 0 ? null : levelValue),
                              direction: fromLeft ? 'left' : null,
                            );
                            final list = List<ZombieSpawnData>.from(_zombies)
                              ..add(copy);
                            _updateZombies(list);
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
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () {
                            CustomZombieLevelUtils.handleDeleteFromBottomSheet(
                              sheetContext: ctx,
                              parentContext: context,
                              levelFile: widget.levelFile,
                              zombieTypeRtid: zombie.type,
                              onRemove: (eraseOrphan) =>
                                  _removeZombie(index, eraseOrphanProperties: eraseOrphan),
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
                            direction: zombie.direction,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n?.editAlias(alias) ?? 'Edit $alias'),
            Text(
              widget.eventSubtitle,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: widget.isGroundSpawner
                  ? (l10n?.eventGroundSpawnTitle ?? 'Ground spawn event')
                  : (l10n?.eventStandardSpawnTitle ?? 'Standard spawn event'),
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpStandardOverview ?? 'Configure zombies that spawn in this wave. Level 0 follows map tier.',
                ),
                HelpSectionData(
                  title: l10n?.row ?? 'Row',
                  body: _isDeepSeaLawn
                      ? (l10n?.eventHelpStandardRowDeepSea ?? 'Rows 0–5 (6-row lawn). Leave unset for random row.')
                      : (l10n?.eventHelpStandardRow ?? 'Rows 0–4. Leave unset for random row.'),
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
              if (widget.isGroundSpawner) _buildColumnRangeCard(theme, l10n),
              if (widget.isGroundSpawner) const SizedBox(height: 16),
              if (!widget.isGroundSpawner) _buildNotificationCard(theme, l10n),
              if (!widget.isGroundSpawner) const SizedBox(height: 16),
              _buildLaneRows(context, theme, l10n),
              const SizedBox(height: 16),
              _buildBatchLevelCard(theme, l10n),
              const SizedBox(height: 16),
              _buildDropConfigCard(context, theme, l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnRangeCard(ThemeData theme, AppLocalizations? l10n) {
    final d = _data as SpawnZombiesFromGroundData;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.columnRange ?? 'Column range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: d.columnStart.toString(),
                    decoration: InputDecoration(
                      labelText: l10n?.columnStartLabel ?? 'Start [ColumnStart]',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = SpawnZombiesFromGroundData(
                          columnStart: n,
                          columnEnd: d.columnEnd,
                          additionalPlantFood: d.additionalPlantFood,
                          spawnPlantName: d.spawnPlantName,
                          zombies: d.zombies,
                        );
                        _sync();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: d.columnEnd.toString(),
                    decoration: InputDecoration(
                      labelText: l10n?.columnEndLabel ?? 'End [ColumnEnd]',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        _data = SpawnZombiesFromGroundData(
                          columnStart: d.columnStart,
                          columnEnd: n,
                          additionalPlantFood: d.additionalPlantFood,
                          spawnPlantName: d.spawnPlantName,
                          zombies: d.zombies,
                        );
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
    );
  }

  Widget _buildNotificationCard(ThemeData theme, AppLocalizations? l10n) {
    final data = _data as WaveActionData;
    final current = data.notificationEvents?.isNotEmpty == true
        ? data.notificationEvents!.first
        : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.music_note, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  l10n?.backgroundMusicLevelJam ?? 'Background music (LevelJam)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: current,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _jamOptions
                  .map(
                    (e) => DropdownMenuItem<String?>(
                      value: e.$1,
                      child: Text(e.$2),
                    ),
                  )
                  .toList(),
              onChanged: _updateNotificationEvent,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.onlyAppliesRockEra ?? 'Only applies to Rock era maps.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaneRows(BuildContext context, ThemeData theme, AppLocalizations? l10n) {
    return Column(
      children: [
        for (var row = 1; row <= (_isDeepSeaLawn ? 6 : 5); row++) ...[
          _buildLaneRow(
            context,
            theme,
            label: l10n?.rowN(row) ?? 'Row $row',
            rowValue: row,
            zombies: _zombies
                .asMap()
                .entries
                .where((e) => e.value.row == row)
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
        _buildLaneRow(
          context,
          theme,
          label: l10n?.randomRow ?? 'Random row',
          rowValue: 0,
          zombies: _zombies
              .asMap()
              .entries
              .where((e) => (e.value.row ?? 0) == 0)
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
    required List<MapEntry<int, ZombieSpawnData>> zombies,
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
                  final baseType = _resolveBaseTypeName(z);
                  final info = ZombieRepository().getZombieById(baseType);
                  final iconPath = info?.iconAssetPath;
                  final isElite = _isElite(z);
                  return ZombieIconCard(
                    iconPath: iconPath,
                    levelDisplay: isElite ? 'E' : (z.level == null ? '0' : '${z.level}'),
                    isElite: isElite,
                    isCustom: _isCustomZombie(z),
                    onTap: () => _showZombieEditSheet(idx),
                  );
                }),
                PvzAddButton(
                  onPressed: () => _addZombie(
                    row: rowValue == 0 ? null : rowValue,
                  ),
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
                        title: Text(l10n?.applyBatchLevel ?? 'Apply batch level?'),
                        content: Text(
                          l10n?.applyBatchLevelContent(_batchLevel.round()) ?? 'Set all zombies in this wave to level ${_batchLevel.round()} (elite unchanged).',
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
              l10n?.appliesToAllNonElite ?? 'Applies to all non-elite zombies in this wave.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropConfigCard(BuildContext context, ThemeData theme, AppLocalizations? l10n) {
    final int count;
    final List<String> plants;
    if (widget.isGroundSpawner) {
      final data = _data as SpawnZombiesFromGroundData;
      count = data.additionalPlantFood ?? 0;
      plants = List<String>.from(data.spawnPlantName ?? []);
    } else {
      final data = _data as WaveActionData;
      count = data.additionalPlantFood ?? 0;
      plants = List<String>.from(data.spawnPlantName ?? []);
    }
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
                      : (l10n?.dropConfigPlantFood ?? 'Drop config (Plant Food)'),
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
                        ? (l10n?.zombiesCarryingPlants ?? 'Zombies carrying plants')
                        : (l10n?.zombiesCarryingPlantFood ?? 'Zombies carrying plant food'),
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
                avatar: Icon(Icons.add_circle_outline, size: 18, color: theme.colorScheme.primary),
                label: Text(ResourceNames.lookup(context, 'Add plant')),
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

}
