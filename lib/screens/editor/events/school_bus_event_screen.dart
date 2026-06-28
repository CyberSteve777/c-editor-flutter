import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Ice cream truck (school bus) wave event editor (`SchoolBusWaveActionProps`).
class SchoolBusEventScreen extends StatefulWidget {
  const SchoolBusEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<SchoolBusEventScreen> createState() => _SchoolBusEventScreenState();
}

class _SchoolBusEventScreenState extends State<SchoolBusEventScreen> {
  static const _objClass = 'SchoolBusWaveActionProps';

  late PvzObject _moduleObj;
  late SchoolBusWaveActionPropsData _data;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRow => _isDeepSeaLawn ? 6 : 5;

  static const _levelMin = 0;
  static const _levelMax = 10;

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
        objData: SchoolBusWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SchoolBusWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SchoolBusWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _updateDes(SchoolBusDesData des) {
    _data = SchoolBusWaveActionPropsData(des: des);
    _sync();
  }

  void _updateParams(SchoolBusParamsData params) {
    _updateDes(
      SchoolBusDesData(
        row: _data.des.row,
        type: _data.des.type,
        params: params,
      ),
    );
  }

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final params = _data.des.params;
      _updateParams(
        SchoolBusParamsData(
          schoolBusHitPoints: params.schoolBusHitPoints,
          schoolBusSpeed: params.schoolBusSpeed,
          zombies: [
            ...params.zombies,
            SchoolBusZombieData(typeName: id, level: 0),
          ],
        ),
      );
    });
  }

  Future<void> _removeZombie(int index) async {
    final params = _data.des.params;
    final removed = params.zombies[index];
    final alias = CustomZombieLevelUtils.resolveCustomZombieAlias(
      widget.levelFile,
      removed.typeName,
    );
    var eraseOrphan = false;
    if (alias != null && mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    final zombies = List<SchoolBusZombieData>.from(params.zombies)
      ..removeAt(index);
    _updateParams(
      SchoolBusParamsData(
        schoolBusHitPoints: params.schoolBusHitPoints,
        schoolBusSpeed: params.schoolBusSpeed,
        zombies: zombies,
      ),
    );
    if (alias != null && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(widget.levelFile, alias);
      widget.onChanged();
    }
  }

  void _updateZombie(int index, SchoolBusZombieData z) {
    final params = _data.des.params;
    final zombies = List<SchoolBusZombieData>.from(params.zombies);
    zombies[index] = z;
    _updateParams(
      SchoolBusParamsData(
        schoolBusHitPoints: params.schoolBusHitPoints,
        schoolBusSpeed: params.schoolBusSpeed,
        zombies: zombies,
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final des = _data.des;
    final params = des.params;
    final busType = des.type == schoolBusNormalType
        ? schoolBusNormalType
        : schoolBusSpecialType;

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
              title:
                  l10n?.eventTitle_SchoolBusWaveActionProps ??
                  'Ice cream truck spawn',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpSchoolBusBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.schoolBusHelpRows ?? 'Row',
                  body: l10n?.eventHelpSchoolBusRows ?? '',
                ),
                HelpSectionData(
                  title: l10n?.schoolBusType ?? 'Type',
                  body: l10n?.eventHelpSchoolBusType ?? '',
                ),
                HelpSectionData(
                  title: l10n?.schoolBusHelpZombies ?? 'Zombies',
                  body: l10n?.eventHelpSchoolBusZombies ?? '',
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
                      DropdownButtonFormField<int>(
                        initialValue: des.row.clamp(1, _maxRow),
                        items: List.generate(_maxRow, (i) => i + 1)
                            .map(
                              (r) =>
                                  DropdownMenuItem(value: r, child: Text('$r')),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            _updateDes(
                              SchoolBusDesData(
                                row: v,
                                type: des.type,
                                params: params,
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: l10n?.schoolBusRow ?? 'Row',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: busType,
                        items: [
                          DropdownMenuItem(
                            value: schoolBusNormalType,
                            child: Text(l10n?.schoolBusTypeNormal ?? 'Normal'),
                          ),
                          DropdownMenuItem(
                            value: schoolBusSpecialType,
                            child: Text(
                              l10n?.schoolBusTypeSpecial ?? 'Special',
                            ),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            _updateDes(
                              SchoolBusDesData(
                                row: des.row,
                                type: v,
                                params: params,
                              ),
                            );
                          }
                        },
                        decoration: InputDecoration(
                          labelText: l10n?.schoolBusType ?? 'Type',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('hp_${params.schoolBusHitPoints}'),
                        initialValue: params.schoolBusHitPoints.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.schoolBusHitPoints ??
                              'Truck health (SchoolBusHitPoints)',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final hp = int.tryParse(v);
                          if (hp != null && hp > 0) {
                            _updateParams(
                              SchoolBusParamsData(
                                schoolBusHitPoints: hp,
                                schoolBusSpeed: params.schoolBusSpeed,
                                zombies: params.zombies,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('sp_${params.schoolBusSpeed}'),
                        initialValue: params.schoolBusSpeed.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.schoolBusSpeed ??
                              'Truck speed (SchoolBusSpeed)',
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final sp = double.tryParse(v);
                          if (sp != null && sp >= 0) {
                            _updateParams(
                              SchoolBusParamsData(
                                schoolBusHitPoints: params.schoolBusHitPoints,
                                schoolBusSpeed: sp,
                                zombies: params.zombies,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.schoolBusZombies ?? 'Contained zombies (Zombies)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...params.zombies.asMap().entries.map((e) {
                        final zi = e.key;
                        final z = e.value;
                        final nameKey = ZombieRepository().getName(z.typeName);
                        final name = ResourceNames.lookup(context, nameKey);
                        final iconPath = ZombieRepository()
                            .getZombieById(z.typeName)
                            ?.iconAssetPath;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (iconPath != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: AssetImageWidget(
                                    assetPath: iconPath,
                                    altCandidates: imageAltCandidates(iconPath),
                                    width: 32,
                                    height: 32,
                                  ),
                                )
                              else
                                const SizedBox(width: 40),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name.isNotEmpty ? name : z.typeName,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (z.typeName.isNotEmpty)
                                      Text(
                                        z.typeName,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                child: DropdownButtonFormField<int>(
                                  initialValue: z.level.clamp(
                                    _levelMin,
                                    _levelMax,
                                  ),
                                  items:
                                      List.generate(
                                            _levelMax - _levelMin + 1,
                                            (i) => _levelMin + i,
                                          )
                                          .map(
                                            (lv) => DropdownMenuItem(
                                              value: lv,
                                              child: Text('$lv'),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateZombie(
                                        zi,
                                        SchoolBusZombieData(
                                          typeName: z.typeName,
                                          level: v,
                                        ),
                                      );
                                    }
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.schoolBusZombieLevel ?? 'Level',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => _removeZombie(zi),
                              ),
                            ],
                          ),
                        );
                      }),
                      PvzAddButton(
                        onPressed: _addZombie,
                        size: 36,
                        label: l10n?.schoolBusAddZombie ?? 'Add zombie',
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
}
