import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_zombie_properties_actions.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class HamsterZombieEventScreen extends StatefulWidget {
  const HamsterZombieEventScreen({
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
  final String? Function(String baseType)? onInjectCustomZombie;

  @override
  State<HamsterZombieEventScreen> createState() =>
      _HamsterZombieEventScreenState();
}

class _HamsterZombieEventScreenState extends State<HamsterZombieEventScreen> {
  static const _objClass = 'HamsterZombieSpawnerProps';
  late String _alias;
  late PvzObject _eventObject;
  late HamsterZombieSpawnerPropsData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    _eventObject = widget.levelFile.objects.firstWhere(
      (object) => object.aliases?.contains(_alias) == true,
      orElse: () {
        final object = PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: HamsterZombieSpawnerPropsData().toJson(),
        );
        widget.levelFile.objects.add(object);
        return object;
      },
    );
    try {
      _data = HamsterZombieSpawnerPropsData.fromJson(
        Map<String, dynamic>.from(_eventObject.objData as Map),
      );
    } catch (_) {
      _data = HamsterZombieSpawnerPropsData();
    }
  }

  void _sync() {
    _data.columnStart = 0;
    _data.columnEnd = 8;
    _eventObject.objData = _data.toJson();
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

  void _addZombie() {
    widget.onRequestZombieSelection((id) {
      final typeRtid = CustomZombieLevelUtils.defaultRtid(id);
      _data.zombies = [
        ..._data.zombies,
        HamsterZombieData(zombieInsideBallType: typeRtid),
      ];
      _sync();
    });
  }

  void _updateZombie(int index, HamsterZombieData zombie) {
    final zombies = List<HamsterZombieData>.from(_data.zombies);
    zombies[index] = zombie;
    _data.zombies = zombies;
    _sync();
  }

  void _duplicateZombie(int index) {
    final zombies = List<HamsterZombieData>.from(_data.zombies)
      ..insert(
        index + 1,
        HamsterZombieData.fromJson(_data.zombies[index].toJson()),
      );
    _data.zombies = zombies;
    _sync();
  }

  Future<void> _removeZombie(int index) async {
    final removed = _data.zombies[index];
    final alias = CustomZombieLevelUtils.resolveCustomZombieAlias(
      widget.levelFile,
      removed.zombieInsideBallType,
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
    _data.zombies = List<HamsterZombieData>.from(_data.zombies)
      ..removeAt(index);
    _sync();
    if (alias != null && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(widget.levelFile, alias);
      widget.onChanged();
    }
  }

  String _resolveBaseType(String rtid) {
    final info = RtidParser.parse(rtid);
    final alias = info?.alias ?? rtid;
    final localType = widget.levelFile.objects.firstWhereOrNull(
      (object) =>
          object.objClass == 'ZombieType' &&
          object.aliases?.contains(alias) == true,
    );
    final localData = localType?.objData;
    if (localData is Map && localData['TypeName'] is String) {
      return localData['TypeName'] as String;
    }
    return ZombiePropertiesRepository.getTypeNameByAlias(alias);
  }

  String _behaviorSummaryValue(AppLocalizations l10n, int behavior) {
    final normalized = behavior.clamp(0, 2);
    final description = switch (normalized) {
      1 => l10n.hamsterballBehaviorDetailSlowdown,
      2 => l10n.hamsterballBehaviorDetailChangeLane,
      _ => l10n.hamsterballBehaviorDetailUniform,
    };
    return '$normalized = $description';
  }

  Widget _numberField({
    required Key key,
    required String label,
    required num value,
    required bool integer,
    required ValueChanged<num> onChanged,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextFormField(
        key: key,
        initialValue: value.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [
          if (integer)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
        ],
        decoration: decoration,
        onChanged: (raw) {
          final parsed = integer ? int.tryParse(raw) : double.tryParse(raw);
          if (parsed != null) onChanged(parsed);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveEventTitleByObjClass(context, _objClass, l10n),
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutEvent,
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n.hamsterballHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.hamsterballHelpOverviewTitle,
                  body: l10n.hamsterballHelpOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.hamsterballHelpRangeTitle,
                  body: l10n.hamsterballHelpRangeBody,
                ),
                HelpSectionData(
                  title: l10n.hamsterballHelpGenerationTitle,
                  body: l10n.hamsterballHelpGenerationBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ModuleAliasInputField(
                  rtid: widget.rtid,
                  alias: _alias,
                  levelFile: widget.levelFile,
                  onAliasChanged: _handleAliasChanged,
                  onChanged: widget.onChanged,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.hamsterballGeneration,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final fields = [
                              _numberField(
                                key: const ValueKey('hamsterGroupSize'),
                                label: l10n.groupSize,
                                value: _data.groupSize,
                                integer: true,
                                onChanged: (value) {
                                  _data.groupSize = value.toInt();
                                  _sync();
                                },
                              ),
                              _numberField(
                                key: const ValueKey('hamsterTimeBetweenGroups'),
                                label: l10n.timeBetweenGroups,
                                value: _data.timeBetweenGroups,
                                integer: false,
                                onChanged: (value) {
                                  _data.timeBetweenGroups = value.toDouble();
                                  _sync();
                                },
                              ),
                              _numberField(
                                key: const ValueKey(
                                  'hamsterTimeBeforeFullSpawn',
                                ),
                                label: l10n.hamsterballTimeBeforeFullSpawn,
                                value: _data.timeBeforeFullSpawn,
                                integer: false,
                                onChanged: (value) {
                                  _data.timeBeforeFullSpawn = value.toDouble();
                                  _sync();
                                },
                              ),
                            ];
                            if (constraints.maxWidth < 720) {
                              return Column(
                                children: [
                                  for (var i = 0; i < fields.length; i++) ...[
                                    fields[i],
                                    if (i != fields.length - 1)
                                      const SizedBox(height: 12),
                                  ],
                                ],
                              );
                            }
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var i = 0; i < fields.length; i++) ...[
                                  Expanded(child: fields[i]),
                                  if (i != fields.length - 1)
                                    const SizedBox(width: 12),
                                ],
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.hamsterballZombies,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PvzAddButton(
                      onPressed: _addZombie,
                      size: 40,
                      label: l10n.hamsterballAddZombie,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_data.zombies.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      l10n.hamsterballEmptyZombies,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ..._data.zombies.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildZombieCard(entry.key, entry.value),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZombieCard(int index, HamsterZombieData zombie) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final baseType = _resolveBaseType(zombie.zombieInsideBallType);
    final repository = ZombieRepository();
    final info = repository.getZombieById(baseType);
    final displayName = ResourceNames.lookup(context, info?.name ?? baseType);
    final iconPath = info?.iconAssetPath;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (iconPath != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: AssetImageWidget(
                      assetPath: iconPath,
                      altCandidates: imageAltCandidates(iconPath),
                      width: 64,
                      height: 64,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.isEmpty ? baseType : displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        baseType,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: l10n.copy,
                  onPressed: () => _duplicateZombie(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.delete,
                  onPressed: () => _removeZombie(index),
                ),
              ],
            ),
            const Divider(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final levelField = EditorResponsiveInputField(
                  label: l10n.hamsterballZombieLevel,
                  builder: (context, decoration) =>
                      DropdownButtonFormField<int>(
                        key: ValueKey('hamsterLevel$index'),
                        initialValue: zombie.level.clamp(0, 10),
                        isExpanded: true,
                        decoration: decoration,
                        items: List.generate(
                          11,
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('$value'),
                          ),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            _updateZombie(index, zombie.copyWith(level: value));
                          }
                        },
                      ),
                );
                final speedField = _numberField(
                  key: ValueKey('hamsterSpeed$index'),
                  label: l10n.hamsterballInitialSpeed,
                  value: zombie.speedBeforeImpact,
                  integer: false,
                  onChanged: (value) => _updateZombie(
                    index,
                    zombie.copyWith(speedBeforeImpact: value.toDouble()),
                  ),
                );
                if (constraints.maxWidth < 560) {
                  return Column(
                    children: [
                      levelField,
                      const SizedBox(height: 12),
                      speedField,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: levelField),
                    const SizedBox(width: 12),
                    Expanded(child: speedField),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              l10n.hamsterballBehavior,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            RadioGroup<int>(
              groupValue: zombie.behavior.clamp(0, 2),
              onChanged: (value) {
                if (value != null) {
                  _updateZombie(index, zombie.copyWith(behavior: value));
                }
              },
              child: Wrap(
                spacing: 8,
                runSpacing: 0,
                children: [
                  SizedBox(
                    width: 190,
                    child: RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      value: 0,
                      title: Text(l10n.hamsterballBehaviorUniform),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      value: 1,
                      title: Text(l10n.hamsterballBehaviorSlowdown),
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      value: 2,
                      title: Text(l10n.hamsterballBehaviorChangeLane),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              l10n.hamsterballBehaviorSummary(
                _behaviorSummaryValue(l10n, zombie.behavior),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.hamsterballHasPlantfood),
              value: zombie.hasPlantfood,
              onChanged: (value) =>
                  _updateZombie(index, zombie.copyWith(hasPlantfood: value)),
            ),
            if (widget.onEditCustomZombie != null ||
                widget.onInjectCustomZombie != null)
              CustomZombiePropertiesSheetActions(
                levelFile: widget.levelFile,
                baseType: baseType,
                currentRtid: zombie.zombieInsideBallType,
                onEditCustomZombie: widget.onEditCustomZombie,
                onInjectCustomZombie: widget.onInjectCustomZombie,
                onRtidSelected: (rtid) => _updateZombie(
                  index,
                  zombie.copyWith(zombieInsideBallType: rtid),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
