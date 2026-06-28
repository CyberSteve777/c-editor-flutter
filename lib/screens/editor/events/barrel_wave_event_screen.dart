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

/// Barrel wave event editor. Rows are 1-based (1–5 standard, 1–6 Deep Sea).
/// Barrel types: empty, zombie (monster), explosive.
class BarrelWaveEventScreen extends StatefulWidget {
  const BarrelWaveEventScreen({
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
  State<BarrelWaveEventScreen> createState() => _BarrelWaveEventScreenState();
}

class _BarrelWaveEventScreenState extends State<BarrelWaveEventScreen> {
  static const _objClass = 'BarrelWaveActionProps';

  late PvzObject _moduleObj;
  late BarrelWaveEventData _data;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRow => _isDeepSeaLawn ? 6 : 5;

  static const _barrelTypeEmpty = 'barrelempty';
  static const _barrelTypeZombie = 'barrelmoster';
  static const _barrelTypeExplosive = 'barrelpowder';

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
        objData: BarrelWaveEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BarrelWaveEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BarrelWaveEventData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _barrelTypeLabel(String type, AppLocalizations? l10n) {
    switch (type) {
      case _barrelTypeEmpty:
        return l10n?.barrelWaveTypeEmpty ?? 'Empty';
      case _barrelTypeZombie:
        return l10n?.barrelWaveTypeZombie ?? 'Zombie';
      case _barrelTypeExplosive:
        return l10n?.barrelWaveTypeExplosive ?? 'Explosive';
      default:
        return type;
    }
  }

  void _addBarrel() {
    final row = _data.barrels.isEmpty
        ? 1
        : (_data.barrels.last.row.clamp(1, _maxRow));
    final entry = BarrelEntryData(
      row: row,
      type: _barrelTypeEmpty,
      params: BarrelParamsData(barrelHitPoints: 1100, barrelSpeed: 0.1),
    );
    _data = BarrelWaveEventData(barrels: [..._data.barrels, entry]);
    _sync();
  }

  Future<void> _removeBarrel(int index) async {
    final l10n = AppLocalizations.of(context);
    final isLast = _data.barrels.length == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.barrelWaveDeleteTitle ?? 'Delete barrel'),
        content: Text(
          isLast
              ? (l10n?.barrelWaveDeleteLastHint ??
                    'This is the last barrel. The event will have no barrels. Continue?')
              : (l10n?.barrelWaveDeleteConfirm ?? 'Delete this barrel?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final barrels = List<BarrelEntryData>.from(_data.barrels)..removeAt(index);
    _data = BarrelWaveEventData(barrels: barrels);
    _sync();
  }

  void _updateBarrel(int index, BarrelEntryData entry) {
    final barrels = List<BarrelEntryData>.from(_data.barrels);
    barrels[index] = entry;
    _data = BarrelWaveEventData(barrels: barrels);
    _sync();
  }

  void _addZombieToBarrel(int barrelIndex) {
    widget.onRequestZombieSelection((id) {
      final entry = _data.barrels[barrelIndex];
      final params = entry.params ?? BarrelParamsData();
      final zombies = List<BarrelZombieData>.from(params.zombies)
        ..add(BarrelZombieData(typeName: id, level: 1));
      _updateBarrel(
        barrelIndex,
        BarrelEntryData(
          row: entry.row,
          type: entry.type,
          params: BarrelParamsData(
            barrelHitPoints: params.barrelHitPoints,
            barrelSpeed: params.barrelSpeed,
            zombies: zombies,
          ),
        ),
      );
    });
  }

  Future<void> _removeZombieFromBarrel(int barrelIndex, int zombieIndex) async {
    final entry = _data.barrels[barrelIndex];
    final params = entry.params!;
    final removed = params.zombies[zombieIndex];
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
    final zombies = List<BarrelZombieData>.from(params.zombies)
      ..removeAt(zombieIndex);
    _updateBarrel(
      barrelIndex,
      BarrelEntryData(
        row: entry.row,
        type: entry.type,
        params: BarrelParamsData(
          barrelHitPoints: params.barrelHitPoints,
          barrelSpeed: params.barrelSpeed,
          zombies: zombies,
        ),
      ),
    );
    if (alias != null && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(widget.levelFile, alias);
      widget.onChanged();
    }
  }

  void _updateBarrelZombie(
    int barrelIndex,
    int zombieIndex,
    BarrelZombieData z,
  ) {
    final entry = _data.barrels[barrelIndex];
    final params = entry.params!;
    final zombies = List<BarrelZombieData>.from(params.zombies);
    zombies[zombieIndex] = z;
    _updateBarrel(
      barrelIndex,
      BarrelEntryData(
        row: entry.row,
        type: entry.type,
        params: BarrelParamsData(
          barrelHitPoints: params.barrelHitPoints,
          barrelSpeed: params.barrelSpeed,
          zombies: zombies,
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
              title: l10n?.eventBarrelWave ?? 'Barrel wave event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpBarrelWaveBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.barrelWaveHelpTypes ?? 'Barrel types',
                  body: l10n?.eventHelpBarrelWaveTypes ?? '',
                ),
                HelpSectionData(
                  title: l10n?.barrelWaveHelpRows ?? 'Rows',
                  body: l10n?.eventHelpBarrelWaveRows ?? '',
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
                l10n?.barrelWaveRowsHint ??
                    'Rows are 1-based (1–$_maxRow). Deep Sea supports 6 rows.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_data.barrels.length, (i) {
                return _buildBarrelCard(context, i, theme, l10n);
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addBarrel,
                icon: const Icon(Icons.add),
                label: Text(l10n?.barrelWaveAddBarrel ?? 'Add barrel'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarrelCard(
    BuildContext context,
    int index,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final entry = _data.barrels[index];
    final isZombie = entry.type == _barrelTypeZombie;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${l10n?.barrelWaveBarrel ?? 'Barrel'} ${index + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeBarrel(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    l10n?.barrelWaveRow ?? 'Row',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: entry.row.clamp(1, _maxRow),
                    items: List.generate(_maxRow, (i) => i + 1)
                        .map(
                          (r) => DropdownMenuItem(value: r, child: Text('$r')),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        _updateBarrel(
                          index,
                          BarrelEntryData(
                            row: v,
                            type: entry.type,
                            params: entry.params,
                          ),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    l10n?.barrelWaveType ?? 'Type',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: entry.type,
                    items: [
                      DropdownMenuItem(
                        value: _barrelTypeEmpty,
                        child: Text(_barrelTypeLabel(_barrelTypeEmpty, l10n)),
                      ),
                      DropdownMenuItem(
                        value: _barrelTypeZombie,
                        child: Text(_barrelTypeLabel(_barrelTypeZombie, l10n)),
                      ),
                      DropdownMenuItem(
                        value: _barrelTypeExplosive,
                        child: Text(
                          _barrelTypeLabel(_barrelTypeExplosive, l10n),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        final oldParams = entry.params ?? BarrelParamsData();
                        final params = BarrelParamsData(
                          barrelHitPoints: oldParams.barrelHitPoints,
                          barrelSpeed: oldParams.barrelSpeed,
                          barrelBlowDamageAmount: v == _barrelTypeExplosive
                              ? (oldParams.barrelBlowDamageAmount ?? 3000)
                              : null,
                          zombies: v == _barrelTypeZombie
                              ? List<BarrelZombieData>.from(oldParams.zombies)
                              : [],
                        );
                        _updateBarrel(
                          index,
                          BarrelEntryData(
                            row: entry.row,
                            type: v,
                            params: params,
                          ),
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildParamsFields(index, entry, theme, l10n),
            if (isZombie) ...[
              const SizedBox(height: 12),
              Text(
                l10n?.barrelWaveZombies ?? 'Zombies',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...?entry.params?.zombies.asMap().entries.map((e) {
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
                        ),
                      Expanded(
                        child: Text(name, overflow: TextOverflow.ellipsis),
                      ),
                      SizedBox(
                        width: 56,
                        child: TextFormField(
                          key: ValueKey('zombie_lv_${index}_$zi'),
                          initialValue: z.level.toString(),
                          decoration: InputDecoration(
                            labelText:
                                l10n?.barrelWaveZombieLevel ?? 'Zombie level',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final lv = int.tryParse(v);
                            if (lv != null && lv >= 1 && lv <= 10) {
                              _updateBarrelZombie(
                                index,
                                zi,
                                BarrelZombieData(
                                  typeName: z.typeName,
                                  level: lv,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => _removeZombieFromBarrel(index, zi),
                      ),
                    ],
                  ),
                );
              }),
              PvzAddButton(
                onPressed: () => _addZombieToBarrel(index),
                size: 36,
                label: l10n?.barrelWaveAddZombie ?? 'Add zombie',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParamsFields(
    int index,
    BarrelEntryData entry,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final params = entry.params ?? BarrelParamsData();
    final isExplosive = entry.type == _barrelTypeExplosive;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                l10n?.barrelWaveHitPoints ?? 'Hit points',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: params.barrelHitPoints.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final hp = int.tryParse(v);
                  if (hp != null && hp > 0) {
                    _updateBarrelParams(index, entry, barrelHitPoints: hp);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Text(
                l10n?.barrelWaveSpeed ?? 'Speed',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: params.barrelSpeed.toString(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) {
                  final sp = double.tryParse(v);
                  if (sp != null && sp >= 0) {
                    _updateBarrelParams(index, entry, barrelSpeed: sp);
                  }
                },
              ),
            ),
          ],
        ),
        if (isExplosive) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  l10n?.barrelWaveExplosionDamage ?? 'Explosion damage',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: TextFormField(
                  initialValue: (params.barrelBlowDamageAmount ?? 3000)
                      .toString(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final dmg = int.tryParse(v);
                    if (dmg != null && dmg >= 0) {
                      _updateBarrelParams(
                        index,
                        entry,
                        barrelBlowDamageAmount: dmg,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _updateBarrelParams(
    int index,
    BarrelEntryData entry, {
    int? barrelHitPoints,
    double? barrelSpeed,
    int? barrelBlowDamageAmount,
  }) {
    final params = entry.params ?? BarrelParamsData();
    _updateBarrel(
      index,
      BarrelEntryData(
        row: entry.row,
        type: entry.type,
        params: BarrelParamsData(
          barrelHitPoints: barrelHitPoints ?? params.barrelHitPoints,
          barrelSpeed: barrelSpeed ?? params.barrelSpeed,
          barrelBlowDamageAmount:
              barrelBlowDamageAmount ?? params.barrelBlowDamageAmount,
          zombies: params.zombies,
        ),
      ),
    );
  }
}
