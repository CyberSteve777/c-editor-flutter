import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Storm zombie spawner event editor. Ported from Z-Editor-master StormSpawnerEventEP.kt.
/// Uses jittered-style zombie icon cards, bottom sheet editing, and button handling.
/// Supports zombie levels (game supports this even though original editor did not).
class StormEventScreen extends StatefulWidget {
  const StormEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
    this.onEditCustomZombie,
    this.onInjectCustomZombie,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;
  final void Function(String rtid)? onEditCustomZombie;
  final String? Function(String alias)? onInjectCustomZombie;

  @override
  State<StormEventScreen> createState() => _StormEventScreenState();
}

class _StormEventScreenState extends State<StormEventScreen> {
  static const _objClass = 'StormZombieSpawnerProps';

  late PvzObject _moduleObj;
  late StormZombieSpawnerPropsData _data;
  late String _alias;

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
        objData: StormZombieSpawnerPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = StormZombieSpawnerPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = StormZombieSpawnerPropsData();
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
    widget.onChanged();
    setState(() {});
  }

  String _resolveBaseTypeName(StormZombieData z) {
    final info = RtidParser.parse(z.type);
    final alias = info?.alias ?? z.type;
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

  bool _isElite(StormZombieData z) {
    return ZombieRepository().isElite(_resolveBaseTypeName(z));
  }

  bool _isCustomZombie(StormZombieData z) {
    return CustomZombieLevelUtils.isCustomZombieRtid(z.type);
  }

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final aliases = ZombieRepository().buildZombieAliases(id);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      final isElite = ZombieRepository().isElite(id);
      _data = StormZombieSpawnerPropsData(
        columnStart: _data.columnStart,
        columnEnd: _data.columnEnd,
        groupSize: _data.groupSize,
        timeBetweenGroups: _data.timeBetweenGroups,
        type: _data.type,
        zombies: [
          ..._data.zombies,
          StormZombieData(type: rtid, level: isElite ? null : 1),
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
    final zombies = List<StormZombieData>.from(_data.zombies)..removeAt(index);
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
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

  void _replaceZombieType(int index, String newRtid, [int? preserveLevel]) {
    final zombies = List<StormZombieData>.from(_data.zombies);
    final current = zombies[index];
    final isEliteNew = ZombieRepository().isElite(
      ZombiePropertiesRepository.getTypeNameByAlias(
        RtidParser.parse(newRtid)?.alias ?? newRtid,
      ),
    );
    zombies[index] = StormZombieData(
      type: newRtid,
      level: isEliteNew ? null : (preserveLevel ?? current.level ?? 1),
    );
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
      zombies: zombies,
    );
    _sync();
  }

  void _updateZombieLevel(int index, int? level) {
    final zombies = List<StormZombieData>.from(_data.zombies);
    zombies[index] = StormZombieData(type: zombies[index].type, level: level);
    _data = StormZombieSpawnerPropsData(
      columnStart: _data.columnStart,
      columnEnd: _data.columnEnd,
      groupSize: _data.groupSize,
      timeBetweenGroups: _data.timeBetweenGroups,
      type: _data.type,
      zombies: zombies,
    );
    _sync();
  }

  void _showZombieEditSheet(int index) {
    final l10n = AppLocalizations.of(context);
    final z = _data.zombies[index];
    final isElite = _isElite(z);
    final baseType = _resolveBaseTypeName(z);
    final info = ZombieRepository().getZombieById(baseType);
    final displayName = info?.name ?? baseType;
    final iconPath = info?.iconAssetPath;
    final isCustom = _isCustomZombie(z);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        int levelValue = z.level ?? 0;
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
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Future.microtask(() {
                        widget.onRequestZombieSelection((id) {
                          final aliases = ZombieRepository().buildZombieAliases(
                            id,
                          );
                          final rtid = RtidParser.build(aliases, 'ZombieTypes');
                          final isEliteNew = ZombieRepository().isElite(id);
                          _replaceZombieType(
                            index,
                            rtid,
                            isEliteNew
                                ? null
                                : (levelValue == 0 ? null : levelValue),
                          );
                        });
                      });
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: Text(l10n?.change ?? 'Change'),
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
                        _updateZombieLevel(index, v ? null : 1);
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
                              _updateZombieLevel(index, newLevel);
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
                            final copy = StormZombieData(
                              type: z.type,
                              level: isElite
                                  ? null
                                  : (levelValue == 0 ? null : levelValue),
                            );
                            _data = StormZombieSpawnerPropsData(
                              columnStart: _data.columnStart,
                              columnEnd: _data.columnEnd,
                              groupSize: _data.groupSize,
                              timeBetweenGroups: _data.timeBetweenGroups,
                              type: _data.type,
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
                              zombieTypeRtid: z.type,
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
                      currentRtid: z.type,
                      onEditCustomZombie: widget.onEditCustomZombie,
                      onInjectCustomZombie: widget.onInjectCustomZombie,
                      onCloseSheet: () => Navigator.pop(ctx),
                      onRtidSelected: (rtid) =>
                          _replaceZombieType(index, rtid, z.level),
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final zombieRepo = ZombieRepository();

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
              title: l10n?.stormEvent ?? 'Storm event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpStormOverview ??
                      'Sandstorm or snowstorm quickly delivers zombies to the front. Excold storm can freeze plants.',
                ),
                HelpSectionData(
                  title: l10n?.columnRange ?? 'Column range',
                  body:
                      l10n?.eventHelpStormColumnRange ??
                      'Columns 0–9. Left edge is 0, right is 9. Start column must be less than end column.',
                ),
                HelpSectionData(
                  title: l10n?.zombieLevels ?? 'Zombie levels',
                  body:
                      l10n?.zombieLevelsBody ??
                      'Storm zombies support level 1-10. Elite zombies use default level.',
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.spawnParameters ?? 'Spawn parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        children: ['sandstorm', 'snowstorm', 'excoldstorm']
                            .map(
                              (t) => ChoiceChip(
                                label: Text(
                                  t == 'sandstorm'
                                      ? (l10n?.sandstorm ?? 'Sandstorm')
                                      : t == 'snowstorm'
                                      ? (l10n?.snowstorm ?? 'Snowstorm')
                                      : (l10n?.excoldStorm ?? 'Excold storm'),
                                ),
                                selected: _data.type == t,
                                onSelected: (_) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: _data.columnStart,
                                    columnEnd: _data.columnEnd,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: t,
                                    zombies: _data.zombies,
                                  );
                                  _sync();
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: _data.columnStart.toString(),
                              decoration: InputDecoration(
                                labelText: l10n?.columnStart ?? 'Column start',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: n,
                                    columnEnd: _data.columnEnd,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: _data.type,
                                    zombies: _data.zombies,
                                  );
                                  _sync();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              initialValue: _data.columnEnd.toString(),
                              decoration: InputDecoration(
                                labelText: l10n?.columnEnd ?? 'Column end',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null) {
                                  _data = StormZombieSpawnerPropsData(
                                    columnStart: _data.columnStart,
                                    columnEnd: n,
                                    groupSize: _data.groupSize,
                                    timeBetweenGroups: _data.timeBetweenGroups,
                                    type: _data.type,
                                    zombies: _data.zombies,
                                  );
                                  _sync();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.groupSize.toString(),
                        decoration: InputDecoration(
                          labelText: l10n?.groupSize ?? 'Group size',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = StormZombieSpawnerPropsData(
                              columnStart: _data.columnStart,
                              columnEnd: _data.columnEnd,
                              groupSize: n,
                              timeBetweenGroups: _data.timeBetweenGroups,
                              type: _data.type,
                              zombies: _data.zombies,
                            );
                            _sync();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.timeBetweenGroups.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.timeBetweenGroups ?? 'Time between groups',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = StormZombieSpawnerPropsData(
                              columnStart: _data.columnStart,
                              columnEnd: _data.columnEnd,
                              groupSize: _data.groupSize,
                              timeBetweenGroups: n,
                              type: _data.type,
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
                    l10n?.zombiesCount(_data.zombies.length) ??
                        'Zombies (${_data.zombies.length})',
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
