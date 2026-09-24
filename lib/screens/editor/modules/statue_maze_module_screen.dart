import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class StatueMazeModuleScreen extends StatefulWidget {
  const StatueMazeModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<StatueMazeModuleScreen> createState() => _StatueMazeModuleScreenState();
}

class _StatueMazeModuleScreenState extends State<StatueMazeModuleScreen> {
  static const _objClass = 'StatueMazeModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late StatueMazeModulePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    _moduleObj = widget.levelFile.objects.firstWhere(
      (object) => object.aliases?.contains(_alias) == true,
      orElse: () => PvzObject(
        aliases: [_alias],
        objClass: _objClass,
        objData: StatueMazeModulePropertiesData.createDefault().toJson(),
      ),
    );
    try {
      _data = StatueMazeModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = StatueMazeModulePropertiesData.createDefault();
    }
    if (_data.sets.isEmpty) {
      _data.sets.add(StatueMazeSetData.createDefault());
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

  void _addSet() {
    _data.sets.add(StatueMazeSetData.createDefault());
    _sync();
  }

  void _removeSet(int index) {
    if (_data.sets.length <= 1) return;
    _data.sets.removeAt(index);
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_StatueMazeModuleProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpStatueMazeOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.statueMazeSets,
                  body: l10n.moduleHelpStatueMazeSetsBody,
                ),
                HelpSectionData(
                  title: l10n.statueMazeTiles,
                  body: l10n.moduleHelpStatueMazeTilesBody,
                ),
                HelpSectionData(
                  title: l10n.statueMazeRotations,
                  body: l10n.moduleHelpStatueMazeRotationsBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.statueMazeSets,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _addSet,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.statueMazeAddSet),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _data.sets.length; i++)
              _SetCard(
                index: i,
                set: _data.sets[i],
                canRemove: _data.sets.length > 1,
                onChanged: _sync,
                onRemove: () => _removeSet(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.index,
    required this.set,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final StatueMazeSetData set;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.statueMazeSet(index + 1),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    tooltip: l10n.statueMazeRemoveSet,
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _intField(
              context,
              label: l10n.statueMazeMatrixSize,
              value: set.matrixSize,
              onChanged: (v) {
                set.matrixSize = v;
                onChanged();
              },
            ),
            _doubleField(
              context,
              label: l10n.statueMazeDisplayTime,
              value: set.displayTime,
              onChanged: (v) {
                set.displayTime = v;
                onChanged();
              },
            ),
            _intField(
              context,
              label: l10n.statueMazeTargetNum,
              value: set.targetNum,
              onChanged: (v) {
                set.targetNum = v;
                onChanged();
              },
            ),
            _intField(
              context,
              label: l10n.statueMazeBonusLife,
              value: set.bonusLife,
              onChanged: (v) {
                set.bonusLife = v;
                onChanged();
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.statueMazeTiles, style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            for (var t = 0; t < set.tiles.length; t++)
              EditorOptionTile(
                title: Text('${l10n.statueMazeTileType} ${t + 1}'),
                subtitle: Text(
                  set.tiles[t].type == 'ac'
                      ? l10n.statueMazeTileTypeAllCorrect
                      : l10n.statueMazeTileTypeCorrect,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.statueMazeTileType,
                      onPressed: () {
                        set.tiles[t].type =
                            set.tiles[t].type == 'c' ? 'ac' : 'c';
                        onChanged();
                      },
                      icon: const Icon(Icons.swap_horiz),
                    ),
                    IconButton(
                      tooltip: l10n.statueMazeRemoveTile,
                      onPressed: () {
                        set.tiles.removeAt(t);
                        onChanged();
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  set.tiles.add(StatueMazeTileData(type: 'c'));
                  onChanged();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.statueMazeAddTile),
              ),
            ),
            const SizedBox(height: 8),
            Text(l10n.statueMazeRotations, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l10n.statueMazeRotationsHint,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            if (set.rotations.isEmpty)
              Text(l10n.statueMazeNoRotations, style: theme.textTheme.bodySmall),
            for (var r = 0; r < set.rotations.length; r++)
              _RotationEditor(
                rotation: set.rotations[r],
                onChanged: onChanged,
                onRemove: () {
                  set.rotations.removeAt(r);
                  onChanged();
                },
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  set.rotations.add(StatueMazeRotationData());
                  onChanged();
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.statueMazeRotations),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intField(
    BuildContext context, {
    required String label,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EditorResponsiveInputField(
        label: label,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        builder: (context, decoration) => TextFormField(
          initialValue: '$value',
          decoration: decoration,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            final n = int.tryParse(v.trim());
            if (n != null && n >= 0) onChanged(n);
          },
        ),
      ),
    );
  }

  Widget _doubleField(
    BuildContext context, {
    required String label,
    required double value,
    required void Function(double) onChanged,
  }) {
    final text = value == value.roundToDouble() ? '${value.toInt()}' : '$value';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: EditorResponsiveInputField(
        label: label,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        builder: (context, decoration) => TextFormField(
          initialValue: text,
          decoration: decoration,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (v) {
            final n = double.tryParse(v.trim());
            if (n != null) onChanged(n);
          },
        ),
      ),
    );
  }
}

class _RotationEditor extends StatelessWidget {
  const _RotationEditor({
    required this.rotation,
    required this.onChanged,
    required this.onRemove,
  });

  final StatueMazeRotationData rotation;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.statueMazeTileType,
                  onPressed: () {
                    rotation.type = rotation.type == 'c' ? 'ac' : 'c';
                    onChanged();
                  },
                  icon: Icon(
                    rotation.type == 'c'
                        ? Icons.rotate_right
                        : Icons.rotate_left,
                  ),
                ),
                Expanded(
                  child: Text(
                    rotation.type == 'c'
                        ? l10n.statueMazeTileTypeCorrect
                        : l10n.statueMazeTileTypeAllCorrect,
                  ),
                ),
                IconButton(
                  tooltip: l10n.statueMazeRemoveRotationConfirm,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            EditorResponsiveInputField(
              label: l10n.statueMazeWaitDuration,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              builder: (context, decoration) => TextFormField(
                initialValue: '${rotation.waitDuration}',
                decoration: decoration,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) {
                  final n = double.tryParse(v.trim());
                  if (n != null) {
                    rotation.waitDuration = n;
                    onChanged();
                  }
                },
              ),
            ),
            const SizedBox(height: 8),
            EditorResponsiveInputField(
              label: l10n.statueMazeRotateTime,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              builder: (context, decoration) => TextFormField(
                initialValue: '${rotation.rotateTime}',
                decoration: decoration,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (v) {
                  final n = double.tryParse(v.trim());
                  if (n != null) {
                    rotation.rotateTime = n;
                    onChanged();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
