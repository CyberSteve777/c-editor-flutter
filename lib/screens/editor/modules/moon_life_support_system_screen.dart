import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class MoonLifeSupportSystemScreen extends StatefulWidget {
  const MoonLifeSupportSystemScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
    required this.onRequestPlantSelection,
    this.onModeToggled,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(
    List<String> initialSelectedIds,
    void Function(List<String>) onSelected,
  )
  onRequestPlantSelection;
  final void Function(String newRtid)? onModeToggled;

  @override
  State<MoonLifeSupportSystemScreen> createState() =>
      _MoonLifeSupportSystemScreenState();
}

class _MoonLifeSupportSystemScreenState
    extends State<MoonLifeSupportSystemScreen> {
  static const _defaultAlias = 'MoonLifeSupportSystemModule';
  static const _objClass = 'MoonLifeSupportSystemProperties';

  late String _alias;
  late MoonLifeSupportSystemPropertiesData _data;
  late TextEditingController _capacityCtrl;
  late TextEditingController _ratioCtrl;
  late TextEditingController _countdownCtrl;

  bool get _isCustomMode =>
      RtidParser.parse(widget.rtid)?.source == 'CurrentLevel';

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (object) => object.aliases?.contains(_alias) == true,
    );
    try {
      _data = existing == null
          ? MoonLifeSupportSystemPropertiesData()
          : MoonLifeSupportSystemPropertiesData.fromJson(
              Map<String, dynamic>.from(existing.objData as Map),
            );
    } catch (_) {
      _data = MoonLifeSupportSystemPropertiesData();
    }
    _capacityCtrl = TextEditingController(text: '${_data.initialCapacity}');
    _ratioCtrl = TextEditingController(text: '${_data.bufferOverloadRatio}');
    _countdownCtrl = TextEditingController(text: '${_data.penaltyCountdown}');
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    _ratioCtrl.dispose();
    _countdownCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final object = widget.levelFile.objects.firstWhereOrNull(
      (candidate) => candidate.aliases?.contains(_alias) == true,
    );
    if (object != null) {
      object.objData = _data.toJson();
    }
    widget.onChanged();
    setState(() {});
  }

  void _toggleCustom(bool enabled) {
    if (enabled) {
      final rtid = enableToggleableModuleCustomLevel(
        levelFile: widget.levelFile,
        levelDef: widget.levelDef,
        currentRtid: widget.rtid,
        currentAlias: _alias,
        defaultAlias: _defaultAlias,
        objClass: _objClass,
        objData: _data.toJson(),
      );
      widget.onChanged();
      widget.onModeToggled?.call(rtid);
      return;
    }
    final rtid = revertToggleableModuleToLevelModules(
      levelFile: widget.levelFile,
      levelDef: widget.levelDef,
      currentRtid: widget.rtid,
      currentAlias: _alias,
      defaultAlias: _defaultAlias,
      onAliasUpdated: () => _alias = _defaultAlias,
    );
    widget.onChanged();
    widget.onModeToggled?.call(rtid);
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

  void _chooseImmunePlants() {
    widget.onRequestPlantSelection(_data.plantImmunityList.plants, (plants) {
      _data.plantImmunityList.plants = List<String>.from(plants);
      _sync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.tertiary;
    final isCustom = _isCustomMode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.moonLifeSupportHelpTitle ?? 'Life Support System',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.moonLifeSupportHelpOverview ?? '',
                ),
                HelpSectionData(
                  title: l10n?.moonLifeSupportHelpProtocolsTitle ?? 'Protocols',
                  body: l10n?.moonLifeSupportHelpProtocols ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.moonLifeSupportHelpPlantFoodTitle ??
                      'Independent cooldowns',
                  body: l10n?.moonLifeSupportHelpPlantFood ?? '',
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
            Card(
              child: SwitchListTile(
                secondary: Icon(Icons.battery_charging_full, color: color),
                title: Text(l10n?.customLocalParams ?? 'Custom local params'),
                subtitle: Text(
                  isCustom
                      ? (l10n?.currentModeLocal ??
                            'Current: local (@CurrentLevel)')
                      : (l10n?.currentModeSystem ??
                            'Current: system default (@LevelModules)'),
                ),
                value: isCustom,
                onChanged: _toggleCustom,
              ),
            ),
            if (isCustom) ...[
              const SizedBox(height: 16),
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
                requiresCustomLocal: true,
                customLocalEnabled: true,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n?.moonLifeSupportPowerSettings ?? 'Power settings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _numberField(
                        controller: _capacityCtrl,
                        label:
                            l10n?.moonInitialCapacity ??
                            'Initial capacity (InitialCapacity)',
                        decimal: false,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            _data.initialCapacity = parsed;
                            _sync();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _numberField(
                        controller: _ratioCtrl,
                        label:
                            l10n?.moonBufferOverloadRatio ??
                            'Required hibernation ratio (BufferOverloadRatio)',
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            _data.bufferOverloadRatio = parsed;
                            _sync();
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _numberField(
                        controller: _countdownCtrl,
                        label:
                            l10n?.moonPenaltyCountdown ??
                            'Hibernation countdown (PenaltyCountdown, seconds)',
                        onChanged: (value) {
                          final parsed = double.tryParse(value);
                          if (parsed != null && parsed >= 0) {
                            _data.penaltyCountdown = parsed;
                            _sync();
                          }
                        },
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n?.moonPlantImmunityList ??
                            'Plants with independent cooldowns '
                                '(PlantImmunityList)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.moonPlantImmunityListHint ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_data.plantImmunityList.plants.isEmpty)
                        Text(l10n?.emptyList ?? 'Empty list')
                      else
                        ..._data.plantImmunityList.plants.map(
                          (plant) => _ImmunePlantTile(
                            plant: plant,
                            onRemove: () {
                              _data.plantImmunityList.plants.remove(plant);
                              _sync();
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _chooseImmunePlants,
                        icon: const Icon(Icons.eco),
                        label: Text(
                          l10n?.moonSelectImmunePlants ?? 'Select plants',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool decimal = true,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}

class _ImmunePlantTile extends StatelessWidget {
  const _ImmunePlantTile({required this.plant, required this.onRemove});

  final String plant;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final repository = PlantRepository();
    final info = repository.getPlantInfoById(plant);
    final path = info?.icon == null
        ? 'assets/images/others/unknown.webp'
        : 'assets/images/plants/${info!.icon}';
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: AssetImageWidget(
        assetPath: path,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        altCandidates: imageAltCandidates(path),
      ),
      title: Text(ResourceNames.lookup(context, repository.getName(plant))),
      subtitle: Text(plant),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: onRemove,
      ),
    );
  }
}
