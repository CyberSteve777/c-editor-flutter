import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Zombie potion module editor. Ported from PotionPropertiesEP.kt
class ZombiePotionModuleScreen extends StatefulWidget {
  const ZombiePotionModuleScreen({
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
  State<ZombiePotionModuleScreen> createState() =>
      _ZombiePotionModuleScreenState();
}

class _ZombiePotionModuleScreenState extends State<ZombiePotionModuleScreen> {
  static const _objClass = 'ZombiePotionModuleProperties';
  static const _initialField = 'Initial';
  static const _maxCountField = 'MaxCount';
  static const _potionSpawnTimerField = 'PotionSpawnTimer';
  static const _potionTypesField = 'PotionTypes';
  late String _alias;
  late PvzObject _moduleObj;
  late ZombiePotionModulePropertiesData _data;
  late TextEditingController _initialCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxTimerCtrl;

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
        objClass: _objClass,
        objData: ZombiePotionModulePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ZombiePotionModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ZombiePotionModulePropertiesData();
    }
    _initialCtrl = TextEditingController(text: '${_data.initialPotionCount}');
    _maxCtrl = TextEditingController(text: '${_data.maxPotionCount}');
    _minCtrl = TextEditingController(text: '${_data.potionSpawnTimer.min}');
    _maxTimerCtrl = TextEditingController(
      text: '${_data.potionSpawnTimer.max}',
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addPotionType() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GridItemSelectionScreen(
          filterMode: GridItemFilterMode.all,
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
          onGridItemSelected: (id) {
            Navigator.pop(context);
            final list = List<String>.from(_data.potionTypes);
            if (!list.contains(id)) {
              list.add(id);
              _data = ZombiePotionModulePropertiesData(
                initialPotionCount: _data.initialPotionCount,
                maxPotionCount: _data.maxPotionCount,
                potionSpawnTimer: _data.potionSpawnTimer,
                potionTypes: list,
              );
              _sync();
            }
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _removePotionType(String id) {
    final list = List<String>.from(_data.potionTypes)..remove(id);
    _data = ZombiePotionModulePropertiesData(
      initialPotionCount: _data.initialPotionCount,
      maxPotionCount: _data.maxPotionCount,
      potionSpawnTimer: _data.potionSpawnTimer,
      potionTypes: list,
    );
    _sync();
  }

  @override
  void dispose() {
    _initialCtrl.dispose();
    _maxCtrl.dispose();
    _minCtrl.dispose();
    _maxTimerCtrl.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;
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
              isEvent: false,
              title: l10n.zombiePotionHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpZombiePotionBody,
                ),
                HelpSectionData(
                  title: l10n.moduleHelpZombiePotionMechanism,
                  body: l10n.moduleHelpZombiePotionMechanismBody,
                ),
                HelpSectionData(
                  title: l10n.moduleHelpZombiePotionPotionTypes,
                  body: l10n.moduleHelpZombiePotionTypes,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.counts,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _intField(
                            controller: _initialCtrl,
                            label: localizedPropertyLabel(
                              context,
                              l10n.initialCount,
                              _initialField,
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.initialPotionCount = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _intField(
                            controller: _maxCtrl,
                            label: localizedPropertyLabel(
                              context,
                              l10n.maximumCount,
                              _maxCountField,
                            ),
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.maxPotionCount = n;
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
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedPropertyLabel(
                        context,
                        l10n.spawnInterval,
                        _potionSpawnTimerField,
                      ),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _intField(
                            controller: _minCtrl,
                            label: l10n.minimumIntervalSeconds,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.potionSpawnTimer.min = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _intField(
                            controller: _maxTimerCtrl,
                            label: l10n.maximumIntervalSeconds,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.potionSpawnTimer.max = n;
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
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditorResponsiveActionRow(
                      content: Text(
                        localizedPropertyLabel(
                          context,
                          l10n.potionTypeList,
                          _potionTypesField,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      action: TextButton.icon(
                        onPressed: _addPotionType,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.add),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_data.potionTypes.isEmpty)
                      Text(
                        l10n.noPotionTypes,
                        style: theme.textTheme.bodySmall,
                      ),
                    ..._data.potionTypes.map((id) {
                      final displayName = ResourceNames.lookup(
                        context,
                        'griditem_$id',
                      );
                      final name = displayName != 'griditem_$id'
                          ? displayName
                          : id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: PresetAwareGridItemIcon(
                            typeName: id,
                            size: 40,
                            fit: BoxFit.contain,
                          ),
                          title: Text(name),
                          subtitle: Text(id),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n.delete,
                            onPressed: () => _removePotionType(id),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _intField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
