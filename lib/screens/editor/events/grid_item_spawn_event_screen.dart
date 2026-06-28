import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart'
    show ZombieRepository, ZombieTag;
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Spawn zombies from grid item event editor. Ported from Z-Editor-master GridItemSpawnerEventEP.kt.
/// Uses jittered-style zombie icon cards, bottom sheet editing, and button handling.
class GridItemSpawnEventScreen extends StatefulWidget {
  const GridItemSpawnEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestGridItemSelection,
    required this.onRequestZombieSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestGridItemSelection;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<GridItemSpawnEventScreen> createState() =>
      _GridItemSpawnEventScreenState();
}

class _GridItemSpawnEventScreenState extends State<GridItemSpawnEventScreen> {
  static const _objClass = 'SpawnZombiesFromGridItemSpawnerProps';

  late PvzObject _moduleObj;
  late SpawnZombiesFromGridItemData _data;
  late String _alias;

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
        objData: SpawnZombiesFromGridItemData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpawnZombiesFromGridItemData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpawnZombiesFromGridItemData();
    }
    for (final z in _data.zombies) {
      if (_isElite(z)) {
        z.level = null;
      } else if ((z.level ?? 1) < 1) {
        z.level = 1;
      }
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    GridItemRepository.cleanupUnusedCustomGridItemTypes(widget.levelFile);
    widget.onChanged();
    setState(() {});
  }

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
    return ZombieRepository().isElite(_resolveBaseTypeName(zombie));
  }

  bool _isCustomZombie(ZombieSpawnData zombie) {
    return CustomZombieLevelUtils.isCustomZombieRtid(zombie.type);
  }

  void _addGridType() {
    widget.onRequestGridItemSelection((id) {
      final rtid = GridItemRepository.buildGridItemTypeRtid(
        id,
        widget.levelFile,
      );
      _data = SpawnZombiesFromGridItemData(
        waveStartMessage: _data.waveStartMessage,
        zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
        gridTypes: [..._data.gridTypes, rtid],
        zombies: _data.zombies,
      );
      _sync();
    });
  }

  void _removeGridType(int index) {
    final gridTypes = List<String>.from(_data.gridTypes)..removeAt(index);
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: gridTypes,
      zombies: _data.zombies,
    );
    _sync();
  }

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final isElite =
          ZombieRepository()
              .getZombieById(id)
              ?.tags
              .contains(ZombieTag.elite) ??
          false;
      _data = SpawnZombiesFromGridItemData(
        waveStartMessage: _data.waveStartMessage,
        zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
        gridTypes: _data.gridTypes,
        zombies: [
          ..._data.zombies,
          ZombieSpawnData(type: rtid, level: isElite ? null : 1, row: null),
        ],
      );
      _sync();
    });
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
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
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

  void _updateZombie(int index, ZombieSpawnData zombie) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    zombies[index] = zombie;
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
  }

  void _replaceZombieType(int index, String newRtid) {
    final zombies = List<ZombieSpawnData>.from(_data.zombies);
    final current = zombies[index];
    final baseType = ZombiePropertiesRepository.getTypeNameByAlias(
      RtidParser.parse(newRtid)?.alias ?? newRtid,
    );
    final isEliteNew = ZombieRepository().isElite(baseType);
    zombies[index] = ZombieSpawnData(
      type: newRtid,
      level: isEliteNew ? null : current.level,
      row: current.row,
    );
    _data = SpawnZombiesFromGridItemData(
      waveStartMessage: _data.waveStartMessage,
      zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
      gridTypes: _data.gridTypes,
      zombies: zombies,
    );
    _sync();
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final zombie = _data.zombies[index];
    final isElite = _isElite(zombie);
    final baseType = _resolveBaseTypeName(zombie);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = info?.name ?? baseType;
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(zombie);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        int rowValue = zombie.row ?? 0;
        int levelValue = zombie.level ?? 0;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (iconPath != null && iconPath.isNotEmpty)
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                            DropdownMenuItem(
                              value: 0,
                              child: Text(l10n?.random ?? 'Random'),
                            ),
                            ...List.generate(_maxRow, (i) => i + 1).map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(l10n?.rowN(v) ?? 'Row $v'),
                              ),
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
                                level: zombie.level,
                              ),
                            );
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
                                final aliases = ZombieRepository()
                                    .buildZombieAliases(id);
                                final rtid = RtidParser.build(
                                  aliases,
                                  'ZombieTypes',
                                );
                                _replaceZombieType(index, rtid);
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
                      l10n?.eliteZombiesUseDefaultLevel ??
                          'Elite zombies use default level.',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  else ...[
                    SwitchListTile(
                      title: Text(l10n?.autoLevel ?? 'Auto level'),
                      value: levelValue == 0,
                      onChanged: (v) {
                        setModalState(() => levelValue = v ? 0 : 1);
                        _updateZombie(
                          index,
                          ZombieSpawnData(
                            type: zombie.type,
                            row: zombie.row,
                            level: v ? null : 1,
                          ),
                        );
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
                              _updateZombie(
                                index,
                                ZombieSpawnData(
                                  type: zombie.type,
                                  row: zombie.row,
                                  level: newLevel,
                                ),
                              );
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
                            final copy = ZombieSpawnData(
                              type: zombie.type,
                              row: rowValue == 0 ? null : rowValue,
                              level: isElite
                                  ? null
                                  : (levelValue == 0 ? null : levelValue),
                            );
                            _data = SpawnZombiesFromGridItemData(
                              waveStartMessage: _data.waveStartMessage,
                              zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
                              gridTypes: _data.gridTypes,
                              zombies: [..._data.zombies, copy],
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
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
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
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final zombieRepo = ZombieRepository();
    final objectAliases = widget.levelFile.objects
        .expand((o) => o.aliases ?? [])
        .toSet();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
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
            tooltip: l10n?.tooltipAboutEvent ?? 'About this event',
            onPressed: () {
              if (l10n == null) return;
              showEditorHelpDialog(
                context,
                title: l10n.eventGraveSpawn,
                sections: [
                  HelpSectionData(
                    title: l10n.overview,
                    body: l10n.eventHelpGraveSpawnBody,
                  ),
                  HelpSectionData(
                    title: l10n.zombieSpawnWait,
                    body: l10n.eventHelpGraveSpawnZombieWait,
                  ),
                ],
              );
            },
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.basicParameters ?? 'Basic parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.waveStartMessage ?? '',
                        decoration: InputDecoration(
                          labelText:
                              l10n?.waveStartMessage ?? 'Wave start message',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) {
                          _data = SpawnZombiesFromGridItemData(
                            waveStartMessage: v.isEmpty ? null : v,
                            zombieSpawnWaitTime: _data.zombieSpawnWaitTime,
                            gridTypes: _data.gridTypes,
                            zombies: _data.zombies,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.zombieSpawnWaitTime.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.zombieSpawnWaitSec ??
                              'Zombie spawn wait (seconds)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = SpawnZombiesFromGridItemData(
                              waveStartMessage: _data.waveStartMessage,
                              zombieSpawnWaitTime: n,
                              gridTypes: _data.gridTypes,
                              zombies: _data.zombies,
                            );
                            _sync();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.gridTypes ?? 'Grid types',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  PvzAddButton(
                    onPressed: _addGridType,
                    size: 40,
                    label: l10n?.add ?? 'Add',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._data.gridTypes.asMap().entries.map((e) {
                final idx = e.key;
                final rtid = e.value;
                final parsed = RtidParser.parse(rtid);
                final gridAlias = parsed?.alias ?? rtid;
                final isValid = parsed?.source == 'CurrentLevel'
                    ? objectAliases.contains(gridAlias)
                    : GridItemRepository.isValid(gridAlias);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isValid ? null : theme.colorScheme.errorContainer,
                  child: ListTile(
                    leading: GridItemIcon(
                      typeName: gridAlias,
                      size: 40,
                      fit: BoxFit.contain,
                    ),
                    title: Text(() {
                      final d = ResourceNames.lookup(
                        context,
                        'griditem_$gridAlias',
                      );
                      return d != 'griditem_$gridAlias' ? d : gridAlias;
                    }()),
                    subtitle: Text(gridAlias, style: theme.textTheme.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: l10n?.delete ?? 'Delete',
                      onPressed: () => _removeGridType(idx),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.zombiesCount(_data.zombies.length) ??
                        'Zombies: ${_data.zombies.length}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._data.zombies.asMap().entries.map((e) {
                    final idx = e.key;
                    final z = e.value;
                    final baseType = _resolveBaseTypeName(z);
                    final info = zombieRepo.getZombieById(baseType);
                    final iconPath = info?.iconAssetPath;
                    final isElite = _isElite(z);
                    return ZombieIconCard(
                      iconPath: iconPath,
                      levelDisplay: isElite
                          ? 'E'
                          : (z.level == null ? '0' : '${z.level}'),
                      isElite: isElite,
                      isCustom: _isCustomZombie(z),
                      onTap: () => _showZombieEditSheet(idx),
                    );
                  }),
                  PvzAddButton(onPressed: _addZombie, size: 56),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
