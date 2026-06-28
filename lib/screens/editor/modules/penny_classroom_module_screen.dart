import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Penny classroom module (global plant levels). Ported from PennyClassroomModulePropertiesEP.kt
class PennyClassroomModuleScreen extends StatefulWidget {
  const PennyClassroomModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;

  @override
  State<PennyClassroomModuleScreen> createState() =>
      _PennyClassroomModuleScreenState();
}

class _PennyClassroomModuleScreenState
    extends State<PennyClassroomModuleScreen> {
  static const _objClass = 'PennyClassroomModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PennyClassroomModuleData _data;
  double _batchLevel = 1.0;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'PennyClassroomModuleProperties',
        objData: PennyClassroomModuleData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PennyClassroomModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PennyClassroomModuleData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addPlants() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlantSelectionScreen(
          isMultiSelect: true,
          onPlantSelected: (_) {},
          onMultiPlantSelected: (ids) {
            Navigator.pop(context);
            final map = Map<String, int>.from(_data.plantMap);
            final level = _batchLevel.round();
            map.removeWhere((key, _) => !ids.contains(key));
            for (final id in ids) {
              map.putIfAbsent(id, () => level);
            }
            _data = PennyClassroomModuleData(plantMap: map);
            _sync();
          },
          onBack: () => Navigator.pop(context),
          initialSelectedIds: _data.plantMap.keys.toList(),
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
  }

  void _applyBatch() {
    final level = _batchLevel.round();
    final map = Map<String, int>.from(_data.plantMap);
    for (final key in map.keys) {
      map[key] = level;
    }
    _data = PennyClassroomModuleData(plantMap: map);
    _sync();
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final entries = _data.plantMap.entries.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n.globalPlantLevels,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.globalPlantLevelsOverview,
                ),
                HelpSectionData(
                  title: l10n.scope,
                  body: l10n.globalPlantLevelsScope,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.layers),
                      const SizedBox(width: 8),
                      Text(
                        l10n.batchLevelFormat(_batchLevel.round()),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: entries.isEmpty ? null : _applyBatch,
                        child: Text(l10n.applyBatch),
                      ),
                    ],
                  ),
                  Slider(
                    value: _batchLevel,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _batchLevel.round().toString(),
                    onChanged: (v) => setState(() => _batchLevel = v),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _addPlants,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addPlants),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Text(
                      l10n.noPlantsConfigured,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _PlantLevelRow(
                        l10n: l10n,
                        plantId: entry.key,
                        level: entry.value,
                        onLevelChange: (val) {
                          final map = Map<String, int>.from(_data.plantMap);
                          map[entry.key] = val;
                          _data = PennyClassroomModuleData(plantMap: map);
                          _sync();
                        },
                        onDelete: () {
                          final map = Map<String, int>.from(_data.plantMap);
                          map.remove(entry.key);
                          _data = PennyClassroomModuleData(plantMap: map);
                          _sync();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlantLevelRow extends StatelessWidget {
  const _PlantLevelRow({
    required this.l10n,
    required this.plantId,
    required this.level,
    required this.onLevelChange,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final String plantId;
  final int level;
  final ValueChanged<int> onLevelChange;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final info = PlantRepository().getPlantInfoById(plantId);
    final path = info?.icon != null
        ? 'assets/images/plants/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AssetImageWidget(
                assetPath: path,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                altCandidates: imageAltCandidates(path),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ResourceNames.lookup(
                      context,
                      PlantRepository().getName(plantId),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(l10n.levelLabel),
                      Expanded(
                        child: Slider(
                          value: level.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: level.toString(),
                          onChanged: (v) => onLevelChange(v.round()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.delete,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
