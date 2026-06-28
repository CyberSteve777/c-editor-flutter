import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Parachute/Bass/Spider rain event editor. Ported from Z-Editor-master
/// ParachuteRainEventEP.kt, BassRainEventEP.kt, SpiderRainEventEP.kt
/// Zombie IDs allowed for Parachute Rain (lost pilot, Z Corp helpdesk only).
const List<String> _parachuteRainAllowedZombieIds = [
  'lostcity_lostpilot',
  'zcorp_helpdesk',
];

/// Zombie IDs allowed for Bass Rain (eighties_bass, heian_ninja, all future jetpacks).
const List<String> _bassRainAllowedZombieIds = [
  'eighties_bass',
  'heian_ninja',
  'future_jetpack',
  'future_jetpack_veteran',
  'future_jetpack_disco',
  'kongfu_rocket',
  'birthday_jetpack',
];

class ParachuteRainEventScreen extends StatefulWidget {
  const ParachuteRainEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.eventSubtitle,
    required this.eventObjClass,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final String eventSubtitle;

  /// 'ParachuteRainZombieSpawnerProps', 'BassRainZombieSpawnerProps', or 'SpiderRainZombieSpawnerProps'
  final String eventObjClass;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<ParachuteRainEventScreen> createState() =>
      _ParachuteRainEventScreenState();
}

class _ParachuteRainEventScreenState extends State<ParachuteRainEventScreen> {
  late PvzObject _moduleObj;
  late ParachuteRainEventData _data;
  late String _alias;
  late final String _objClass;

  @override
  void initState() {
    super.initState();
    _objClass = widget.eventObjClass;
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
        objData: ParachuteRainEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ParachuteRainEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ParachuteRainEventData();
    }
    // Normalize zombie to allowed list for Parachute/Bass rain (without calling onChanged during build)
    final allowedIds = _getAllowedZombieIds();
    if (allowedIds.isNotEmpty && !allowedIds.contains(_data.spiderZombieName)) {
      _data = ParachuteRainEventData(
        columnStart: _data.columnStart,
        columnEnd: _data.columnEnd,
        groupSize: _data.groupSize,
        spiderCount: _data.spiderCount,
        spiderZombieName: allowedIds.first,
        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
        timeBetweenGroups: _data.timeBetweenGroups,
        zombieFallTime: _data.zombieFallTime,
        waveStartMessage: _data.waveStartMessage,
      );
      _moduleObj.objData = _data.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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
                  l10n?.eventParachuteRain ??
                  'Parachute/Bass/Spider rain event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpParachuteRainBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.logic ?? 'Logic',
                  body: l10n?.eventHelpParachuteRainLogic ?? '',
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
              _buildZombieConfigCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildCountCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildRangeTimeCard(context, theme, l10n),
              const SizedBox(height: 16),
              _buildMessageCard(theme, l10n),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getAllowedZombieIds() {
    switch (widget.eventObjClass) {
      case 'ParachuteRainZombieSpawnerProps':
        return _parachuteRainAllowedZombieIds;
      case 'BassRainZombieSpawnerProps':
        return _bassRainAllowedZombieIds;
      default:
        return const [];
    }
  }

  Widget _buildZombieConfigCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final allowedIds = _getAllowedZombieIds();
    final useDropdown = allowedIds.isNotEmpty;

    if (useDropdown) {
      final currentId = allowedIds.contains(_data.spiderZombieName)
          ? _data.spiderZombieName
          : allowedIds.first;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.groups,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n?.zombieTypeSpiderZombieName ??
                        'Zombie type (SpiderZombieName)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 80),
                child: DropdownButtonFormField<String>(
                  initialValue: currentId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 16,
                    ),
                  ),
                  isExpanded: true,
                  iconSize: 48,
                  menuMaxHeight: 520,
                  items: allowedIds.map((id) {
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: _ZombieDropdownRow(zombieId: id, iconSize: 48),
                      ),
                    );
                  }).toList(),
                  selectedItemBuilder: (context) => allowedIds.map((id) {
                    return _ZombieDropdownRow(zombieId: id, iconSize: 48);
                  }).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    _data = ParachuteRainEventData(
                      columnStart: _data.columnStart,
                      columnEnd: _data.columnEnd,
                      groupSize: _data.groupSize,
                      spiderCount: _data.spiderCount,
                      spiderZombieName: id,
                      timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                      timeBetweenGroups: _data.timeBetweenGroups,
                      zombieFallTime: _data.zombieFallTime,
                      waveStartMessage: _data.waveStartMessage,
                    );
                    _sync();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Spider rain or unknown: keep full zombie selection button
    final typeName = _data.spiderZombieName.isNotEmpty
        ? ZombiePropertiesRepository.getTypeNameByAlias(_data.spiderZombieName)
        : null;
    final iconPath = typeName != null && typeName.isNotEmpty
        ? ZombieRepository().getZombieById(typeName)?.iconAssetPath
        : null;
    final nameKey = typeName != null && typeName.isNotEmpty
        ? ZombieRepository().getName(typeName)
        : null;
    final displayName = nameKey != null
        ? ResourceNames.lookup(context, nameKey)
        : null;
    final zombieDisplay = _data.spiderZombieName.isEmpty
        ? (l10n?.noneSelected ?? 'None selected')
        : (displayName != null && displayName != nameKey
              ? displayName
              : typeName ?? _data.spiderZombieName);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.groups, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n?.zombieTypeSpiderZombieName ??
                      'Zombie type (SpiderZombieName)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: iconPath != null
                        ? AssetImageWidget(
                            assetPath: iconPath,
                            altCandidates: imageAltCandidates(iconPath),
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.person_outline,
                              size: 28,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    zombieDisplay,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    widget.onRequestZombieSelection((id) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: _data.columnEnd,
                        groupSize: _data.groupSize,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: id,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    });
                  },
                  child: Text(l10n?.selectZombie ?? 'Select zombie'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.spawnCount ?? 'Spawn count',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: l10n?.totalSpiderCount ?? 'Total (SpiderCount)',
                    value: _data.spiderCount,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: _data.columnEnd,
                        groupSize: _data.groupSize,
                        spiderCount: v,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: l10n?.perBatchGroupSize ?? 'Per batch (GroupSize)',
                    value: _data.groupSize,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: _data.columnEnd,
                        groupSize: v,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
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

  Widget _buildRangeTimeCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.columnRangeTiming ?? 'Column range & timing',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _NumberField(
                    label: l10n?.startColumn ?? 'Start column',
                    value: _data.columnStart,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: v,
                        columnEnd: _data.columnEnd,
                        groupSize: _data.groupSize,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NumberField(
                    label: l10n?.endColumn ?? 'End column',
                    value: _data.columnEnd,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: v,
                        groupSize: _data.groupSize,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DoubleField(
                    label:
                        l10n?.timeBetweenGroups ?? 'Time between batches (s)',
                    value: _data.timeBetweenGroups,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: _data.columnEnd,
                        groupSize: _data.groupSize,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: v,
                        zombieFallTime: _data.zombieFallTime,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DoubleField(
                    label: l10n?.fallTime ?? 'Fall time (s)',
                    value: _data.zombieFallTime,
                    onChanged: (v) {
                      _data = ParachuteRainEventData(
                        columnStart: _data.columnStart,
                        columnEnd: _data.columnEnd,
                        groupSize: _data.groupSize,
                        spiderCount: _data.spiderCount,
                        spiderZombieName: _data.spiderZombieName,
                        timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                        timeBetweenGroups: _data.timeBetweenGroups,
                        zombieFallTime: v,
                        waveStartMessage: _data.waveStartMessage,
                      );
                      _sync();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DoubleField(
              label: l10n?.timeBeforeSpawn ?? 'Time before full spawn (s)',
              value: _data.timeBeforeFullSpawn,
              onChanged: (v) {
                _data = ParachuteRainEventData(
                  columnStart: _data.columnStart,
                  columnEnd: _data.columnEnd,
                  groupSize: _data.groupSize,
                  spiderCount: _data.spiderCount,
                  spiderZombieName: _data.spiderZombieName,
                  timeBeforeFullSpawn: v,
                  timeBetweenGroups: _data.timeBetweenGroups,
                  zombieFallTime: _data.zombieFallTime,
                  waveStartMessage: _data.waveStartMessage,
                );
                _sync();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(ThemeData theme, AppLocalizations? l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveStartMessageLabel ?? 'Red subtitle (WaveStartMessage)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: _data.waveStartMessage,
              decoration: InputDecoration(
                hintText:
                    l10n?.optionalWarningText ??
                    'Optional warning text before spawn',
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                _data = ParachuteRainEventData(
                  columnStart: _data.columnStart,
                  columnEnd: _data.columnEnd,
                  groupSize: _data.groupSize,
                  spiderCount: _data.spiderCount,
                  spiderZombieName: _data.spiderZombieName,
                  timeBeforeFullSpawn: _data.timeBeforeFullSpawn,
                  timeBetweenGroups: _data.timeBetweenGroups,
                  zombieFallTime: _data.zombieFallTime,
                  waveStartMessage: v,
                );
                _sync();
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One row for dropdown: zombie icon + localized name.
class _ZombieDropdownRow extends StatelessWidget {
  const _ZombieDropdownRow({required this.zombieId, this.iconSize = 48});

  final String zombieId;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final zombie = ZombieRepository().getZombieById(zombieId);
    final nameKey = ZombieRepository().getName(zombieId);
    final displayName = ResourceNames.lookup(context, nameKey);
    final iconPath = zombie?.iconAssetPath;
    final size = iconSize.toInt();
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (iconPath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: size.toDouble(),
              height: size.toDouble(),
              child: AssetImageWidget(
                assetPath: iconPath,
                altCandidates: imageAltCandidates(iconPath),
                width: size.toDouble(),
                height: size.toDouble(),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: iconSize * 0.35),
        ],
        Expanded(child: Text(displayName, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}

class _DoubleField extends StatelessWidget {
  const _DoubleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: value.toString(),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (v) {
        final n = double.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}
