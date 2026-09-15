import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class LevelPowerupModuleScreen extends StatefulWidget {
  const LevelPowerupModuleScreen({
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
  State<LevelPowerupModuleScreen> createState() =>
      _LevelPowerupModuleScreenState();
}

class _LevelPowerupModuleScreenState extends State<LevelPowerupModuleScreen> {
  static const _objClass = 'LevelPowerupModuleProperties';

  late String _alias;
  late PvzObject _moduleObject;
  late LevelPowerupModulePropertiesData _data;
  final Map<LevelPowerupEntryData, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _moduleObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: LevelPowerupModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = LevelPowerupModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = LevelPowerupModulePropertiesData();
    }
    for (final entry in _data.powerups) {
      _controllers[entry] = TextEditingController(
        text: '${entry.freeUseCount}',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sync() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  List<String> get _availablePowerupTypes => LevelPowerupModulePropertiesData
      .supportedTypeNames
      .where(
        (typeName) =>
            !_data.powerups.any((entry) => entry.typeName == typeName),
      )
      .toList();

  IconData _iconForPowerup(String typeName) {
    return switch (typeName) {
      'powerupflickzombie' => Icons.swipe_vertical,
      'powerupwizardfinger' => Icons.bolt,
      'poweruppinchzombie' => Icons.content_cut,
      _ => Icons.touch_app,
    };
  }

  String _titleForPowerup(AppLocalizations l10n, String typeName) {
    return switch (typeName) {
      'powerupflickzombie' => l10n.powerToss,
      'powerupwizardfinger' => l10n.powerZap,
      'poweruppinchzombie' => l10n.powerPinch,
      _ => typeName,
    };
  }

  void _reorderPowerup(int oldIndex, int newIndex) {
    final entry = _data.powerups.removeAt(oldIndex);
    _data.powerups.insert(newIndex, entry);
    _sync();
  }

  void _removePowerup(LevelPowerupEntryData entry) {
    if (!_data.powerups.remove(entry)) return;
    _controllers.remove(entry)?.dispose();
    _sync();
  }

  Future<void> _addPowerup() async {
    final availableTypes = _availablePowerupTypes;
    if (availableTypes.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final selectedType = await showEditorChoiceDialog<String>(
      context,
      dialogKey: const ValueKey('powerupAddDialog'),
      title: l10n.powerUpsAddTitle,
      options: [
        for (final typeName in availableTypes)
          EditorChoiceDialogOption(
            key: ValueKey('powerupAddOption_$typeName'),
            value: typeName,
            icon: _iconForPowerup(typeName),
            title: _titleForPowerup(l10n, typeName),
            subtitle: typeName,
          ),
      ],
    );
    if (!mounted || selectedType == null) return;
    final entry = LevelPowerupEntryData(typeName: selectedType);
    _data.powerups.add(entry);
    _controllers[entry] = TextEditingController(text: '${entry.freeUseCount}');
    _sync();
  }

  @override
  Widget build(BuildContext context) {
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
              title: l10n.powerUpsHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.powerUpsHelpOverview,
                ),
                HelpSectionData(
                  title: l10n.powerUpsOrder,
                  body: l10n.powerUpsOrderInfo,
                ),
                HelpSectionData(
                  title: l10n.powerToss,
                  body: l10n.powerTossInfo,
                ),
                HelpSectionData(title: l10n.powerZap, body: l10n.powerZapInfo),
                HelpSectionData(
                  title: l10n.powerPinch,
                  body: l10n.powerPinchInfo,
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
                    l10n.powerUpsHelpTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  key: const ValueKey('powerupAddButton'),
                  tooltip: l10n.powerUpsAddTitle,
                  onPressed: _availablePowerupTypes.isEmpty
                      ? null
                      : _addPowerup,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_data.powerups.length > 1) ...[
              const SizedBox(height: 4),
              Text(
                defaultTargetPlatform == TargetPlatform.android ||
                        defaultTargetPlatform == TargetPlatform.iOS
                    ? l10n.presetPlantListReorderHint
                    : l10n.presetPlantListReorderHintDesktop,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            if (_data.powerups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l10n.emptyList,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                itemCount: _data.powerups.length,
                onReorderItem: _reorderPowerup,
                itemBuilder: (context, index) {
                  final entry = _data.powerups[index];
                  return _buildPowerupCard(entry: entry, index: index);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupCard({
    required LevelPowerupEntryData entry,
    required int index,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final typeName = entry.typeName;
    final icon = _iconForPowerup(typeName);
    final title = _titleForPowerup(l10n, typeName);
    return Card(
      key: ObjectKey(entry),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReorderableDragStartListener(
                  key: ValueKey('powerupDragHandle_$typeName'),
                  index: index,
                  child: SizedBox(
                    width: 40,
                    height: 44,
                    child: Center(
                      child: Icon(
                        Icons.drag_indicator,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Icon(icon, size: 36, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        typeName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('powerupDelete_$typeName'),
                  tooltip: l10n.delete,
                  onPressed: () => _removePowerup(entry),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            );
            final countField = SizedBox(
              width: constraints.maxWidth < 520 ? double.infinity : 300,
              child: EditorResponsiveInputField(
                label: l10n.powerUpsFreeUseCount,
                builder: (context, decoration) => TextField(
                  key: ValueKey('powerupFreeUseCount_$typeName'),
                  controller: _controllers[entry],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: decoration,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0) return;
                    entry.freeUseCount = parsed;
                    _sync();
                  },
                ),
              ),
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 16), countField],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 24),
                countField,
              ],
            );
          },
        ),
      ),
    );
  }
}
