import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/module_instance_utils.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_eighties_speaker_presets.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_properties_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_base_selection_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_properties_view_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/reserved_column_preview_grid.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

class ZombossMechBattleTab extends StatefulWidget {
  const ZombossMechBattleTab({
    super.key,
    required this.levelFile,
    required this.onChanged,
    this.moduleRtid,
    this.onOpenGlacierModule,
    this.onOpenInitialGridItems,
  });

  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final String? moduleRtid;
  final VoidCallback? onOpenGlacierModule;
  final VoidCallback? onOpenInitialGridItems;

  @override
  State<ZombossMechBattleTab> createState() => _ZombossMechBattleTabState();
}

class _ZombossMechBattleTabState extends State<ZombossMechBattleTab> {
  PvzObject? _battleObj;
  bool _hasMultipleBattleModules = false;
  PvzObject? _introObj;
  bool _hasIntroModule = false;
  late ZombossMechBattleModuleData _battleData;
  ZombossMechBattleIntroData? _introData;
  String _selectedBaseId = '';
  bool _catalogReady = false;
  bool _catalogLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevelData();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _catalogLoading = true;
    });
    await ZombossMechRepository.ensureLoaded();
    if (!mounted) return;
    setState(() {
      _catalogLoading = false;
      _catalogReady = ZombossMechRepository.allZombossMechs.isNotEmpty;
      if (_catalogReady) {
        _syncBaseSelectionFromMechType();
      }
    });
  }

  void _loadLevelData() {
    final battleObjects = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombossBattleModuleProperties')
        .toList();
    _hasMultipleBattleModules = battleObjects.length > 1;
    _battleObj = widget.moduleRtid == null
        ? (battleObjects.length == 1 ? battleObjects.single : null)
        : ModuleInstanceUtils.findCurrentLevelObject(
            levelFile: widget.levelFile,
            rtid: widget.moduleRtid!,
            expectedObjClass: 'ZombossBattleModuleProperties',
          );
    _introObj = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombossBattleIntroProperties')
        .firstOrNull;
    _hasIntroModule = levelHasModule(
      widget.levelFile,
      'ZombossBattleIntroProperties',
    );

    if (_battleObj != null && _battleObj!.objData is Map) {
      _battleData = ZombossMechBattleModuleData.fromJson(
        Map<String, dynamic>.from(_battleObj!.objData as Map),
      );
    } else {
      _battleData = ZombossMechBattleModuleData();
    }

    if (_introObj != null && _introObj!.objData is Map) {
      _introData = ZombossMechBattleIntroData.fromJson(
        Map<String, dynamic>.from(_introObj!.objData as Map),
      );
    } else {
      _introData = null;
    }
  }

  ZombossMechCatalogEntry? get _currentCatalog =>
      ZombossMechRepository.getCatalog(_selectedBaseId);

  bool get _isCustomSelected {
    final catalog = _currentCatalog;
    if (catalog == null || !catalog.hasCustomInstance) return false;
    return ZombossMechRepository.isCustomVariation(
      _battleData.zombossMechType,
      catalog,
    );
  }

  void _syncBaseSelectionFromMechType() {
    _selectedBaseId = ZombossMechRepository.resolveBaseId(
      _selectedBaseId.isEmpty ? null : _selectedBaseId,
      _battleData.zombossMechType,
    );
    if (_selectedBaseId.isEmpty) {
      _selectedBaseId = ZombossMechRepository.allZombossMechs.first.id;
    }
    final base = ZombossMechRepository.getBase(_selectedBaseId);
    if (base != null &&
        !_isCustomSelected &&
        !base.variations.contains(_battleData.zombossMechType) &&
        base.variations.isNotEmpty) {
      _applyVariation(base.variations.first, persist: false);
    }
  }

  void _saveData() {
    if (_battleObj != null) {
      _battleObj!.objData = _battleData.toJson();
    }
    if (_introObj != null && _introData != null) {
      _introObj!.objData = _introData!.toJson();
    }
    widget.onChanged();
  }

  void _sync({VoidCallback? extra}) {
    extra?.call();
    _saveData();
    setState(() {});
  }

  void _applyVariation(String variation, {bool persist = true}) {
    final base = ZombossMechRepository.findBaseForVariation(variation);
    final phaseCount = base?.defaultPhaseCount ?? _battleData.zombossStageCount;
    final spawnPos = ZombossMechRepository.spawnPositionForVariation(variation);
    final omitSpawn = ZombossMechRepository.omitsSpawnPosition(variation);

    void apply() {
      _battleData.zombossMechType = variation;
      _battleData.zombossStageCount = phaseCount;
      if (!omitSpawn && spawnPos != null) {
        _battleData.zombossSpawnGridPosition = spawnPos;
      }
      _introData?.zombossPhaseCount = phaseCount;
      if (base != null) {
        _selectedBaseId = base.id;
      }
    }

    if (persist) {
      _sync(extra: apply);
    } else {
      apply();
    }
  }

  void _applyCustomVariation({bool persist = true}) {
    final catalog = _currentCatalog;
    if (catalog == null || !catalog.hasCustomInstance) return;
    final sourceVariation = _isCustomSelected
        ? null
        : _battleData.zombossMechType;

    void apply() {
      ZombossMechRepository.ensureCustomPropertiesInLevel(
        catalog: catalog,
        levelFile: widget.levelFile,
        sourceVariation: sourceVariation,
      );
      _battleData.zombossMechType = catalog.editableInstance;
      final stages = ZombossMechRepository.findCustomPropertiesInLevel(
        catalog: catalog,
        levelFile: widget.levelFile,
      )?.objData;
      if (stages is Map && stages['Stages'] is List) {
        final count = (stages['Stages'] as List).length;
        if (count > 0) {
          _battleData.zombossStageCount = count;
          _introData?.zombossPhaseCount = count;
        }
      } else {
        _battleData.zombossStageCount = catalog.defaultPhaseCount;
        _introData?.zombossPhaseCount = catalog.defaultPhaseCount;
      }
      final spawnPos = ZombossMechRepository.spawnPositionForVariation(
        catalog.editableInstance,
      );
      if (!ZombossMechRepository.omitsSpawnPosition(catalog.editableInstance) &&
          spawnPos != null) {
        _battleData.zombossSpawnGridPosition = spawnPos;
      }
    }

    if (persist) {
      _sync(extra: apply);
    } else {
      apply();
    }
  }

  Future<bool> _confirmEightiesSpeakerPreset() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            scrollable: true,
            title: Text(
              l10n?.zombossMechEightiesSpeakerPresetPromptTitle ??
                  'Pre-place Zomboss speakers?',
            ),
            content: Text(
              l10n?.zombossMechEightiesSpeakerPresetPrompt ??
                  'The first phase of the Eighties Zomboss normally needs its dedicated speakers on the lawn. Pre-place them at the official level positions?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  l10n?.zombossMechSwitchBaseOnly ?? 'Switch mech only',
                ),
              ),
              FilledButton(
                key: const ValueKey('applyEightiesSpeakerPreset'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  l10n?.zombossMechPreplaceSpeakers ?? 'Pre-place speakers',
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _confirmRemoveEightiesSpeakerPreset() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            scrollable: true,
            title: Text(
              l10n?.zombossMechEightiesSpeakerRemovePromptTitle ??
                  'Remove pre-placed speakers?',
            ),
            content: Text(
              l10n?.zombossMechEightiesSpeakerRemovePrompt ??
                  'You are switching away from the Eighties Zomboss. Remove its previously pre-placed speakers?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n?.zombossMechKeepSpeakers ?? 'Keep speakers'),
              ),
              FilledButton(
                key: const ValueKey('removeEightiesSpeakerPreset'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  l10n?.zombossMechRemoveSpeakers ?? 'Remove speakers',
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onBaseChanged(String baseId) async {
    if (baseId == _selectedBaseId) return;
    final base = ZombossMechRepository.getBase(baseId);
    if (base == null || base.variations.isEmpty) return;

    final previousBaseId = _selectedBaseId;
    final enteringEighties =
        previousBaseId != ZombossEightiesSpeakerPresets.baseId &&
        baseId == ZombossEightiesSpeakerPresets.baseId;
    final leavingEighties =
        previousBaseId == ZombossEightiesSpeakerPresets.baseId &&
        baseId != ZombossEightiesSpeakerPresets.baseId;
    final applyEightiesSpeakers = enteringEighties
        ? await _confirmEightiesSpeakerPreset()
        : false;
    if (!mounted) return;
    final removeEightiesSpeakers =
        leavingEighties &&
            ZombossEightiesSpeakerPresets.hasPresetSpeakers(widget.levelFile)
        ? await _confirmRemoveEightiesSpeakerPreset()
        : false;
    if (!mounted) return;

    final catalog = ZombossMechRepository.getCatalog(baseId);
    final keepCustom =
        catalog != null &&
        ZombossMechRepository.isCustomVariation(
          _battleData.zombossMechType,
          catalog,
        );

    String pickVariation() {
      if (keepCustom && catalog.hasCustomInstance) {
        return catalog.editableInstance;
      }
      if (base.variations.contains(_battleData.zombossMechType)) {
        return _battleData.zombossMechType;
      }
      return base.variations.first;
    }

    _sync(
      extra: () {
        _selectedBaseId = baseId;
        final variation = pickVariation();
        if (catalog != null &&
            catalog.hasCustomInstance &&
            variation == catalog.editableInstance) {
          _applyCustomVariation(persist: false);
        } else {
          _applyVariation(variation, persist: false);
        }
        if (baseId == GlacierModulePresets.iceAgeBaseId) {
          GlacierModulePresets.applyToLevel(
            widget.levelFile,
            GlacierModulePresets.defaultPreset,
          );
        }
        if (applyEightiesSpeakers) {
          ZombossEightiesSpeakerPresets.applyToLevel(widget.levelFile);
        } else if (removeEightiesSpeakers) {
          ZombossEightiesSpeakerPresets.removeFromLevel(widget.levelFile);
        }
      },
    );
  }

  Future<bool> _confirmGlacierPreset(GlacierModulePreset preset) async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            scrollable: true,
            title: Text(
              l10n?.glacierModuleVariationPresetPromptTitle ??
                  'Enable matching Ice Chunk preset?',
            ),
            content: Text(
              preset.isBlank
                  ? (l10n?.glacierModuleCustomVariationPresetPrompt ??
                        'The custom Frostbite Caves Zomboss uses a blank Ice Chunk preset by default. Apply that blank preset now?')
                  : (l10n?.glacierModuleVariationPresetPrompt ??
                        'The Frostbite Caves Zomboss summons zombies through Ice Chunks, whose contents are configured by the Ice Chunk Module. You are switching to another Frostbite Caves Zomboss variation. Also enable the Ice Chunk Module preset used by that variation in the original game?'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  l10n?.zombossMechSwitchVariationOnly ??
                      'Switch variation only',
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n?.glacierModuleEnablePreset ?? 'Enable preset'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onVariationChanged(String? value) async {
    if (value == null) return;
    final isCustom = value == kZombossMechCustomVariationValue;
    final targetVariation = isCustom
        ? _currentCatalog?.editableInstance
        : value;
    if (targetVariation == null || targetVariation.isEmpty) return;
    if (targetVariation == _battleData.zombossMechType) return;

    final preset = GlacierModulePresets.forVariation(targetVariation);
    final applyPreset = preset == null
        ? false
        : await _confirmGlacierPreset(preset);
    if (!mounted) return;

    _sync(
      extra: () {
        if (isCustom) {
          _applyCustomVariation(persist: false);
        } else {
          _applyVariation(targetVariation, persist: false);
        }
        if (applyPreset) {
          GlacierModulePresets.applyToLevel(widget.levelFile, preset);
        }
      },
    );
  }

  Future<void> _openBaseSelection() async {
    final baseId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ZombossMechBaseSelectionScreen(selectedBaseId: _selectedBaseId),
      ),
    );
    if (baseId != null && mounted) {
      await _onBaseChanged(baseId);
    }
  }

  String? _variationDropdownValue(
    List<String> variations,
    String? currentVariation,
  ) {
    if (_isCustomSelected) return kZombossMechCustomVariationValue;
    if (currentVariation != null && variations.contains(currentVariation)) {
      return currentVariation;
    }
    return variations.isNotEmpty ? variations.first : null;
  }

  void _openCustomEditor() {
    final catalog = _currentCatalog;
    if (catalog == null || !catalog.hasCustomInstance) return;
    if (!_isCustomSelected) {
      _applyCustomVariation();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombossMechPropertiesScreen(
          catalog: catalog,
          levelFile: widget.levelFile,
          introData: _introData,
          onChanged: widget.onChanged,
          onBack: () => Navigator.pop(context),
          onStageCountChanged: (count) {
            _battleData.zombossStageCount = count;
            _introData?.zombossPhaseCount = count;
            _saveData();
          },
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openPropertiesView() {
    final catalog = _currentCatalog;
    if (catalog == null || _isCustomSelected) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechPropertiesViewScreen(
          catalog: catalog,
          levelFile: widget.levelFile,
          mechType: _battleData.zombossMechType,
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  String _displayName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  String _variationLabel(BuildContext context, String variation) {
    final baseId = ZombossMechRepository.resolveBaseId(
      _selectedBaseId,
      variation,
    );
    if (baseId.isEmpty) return _displayName(context, variation);
    return ZombossMechL10n.variationLabel(
      context,
      baseId,
      variation,
      fallback: variation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_battleObj == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _hasMultipleBattleModules
                ? (l10n?.zombossMultipleModuleSelectionHint ??
                      'Multiple Boss modules were found. Select the instance to edit from the module list in Level Settings.')
                : (l10n?.missingZombossMechModule ??
                      'Missing ZombossBattleModuleProperties'),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_catalogLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_catalogReady) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noZombossMechFound ?? 'No ZombossMech found',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              if (ZombossMechRepository.loadError != null) ...[
                const SizedBox(height: 8),
                Text(
                  ZombossMechRepository.loadError!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadCatalog,
                icon: const Icon(Icons.refresh),
                label: Text(l10n?.refresh ?? 'Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    final currentBase = ZombossMechRepository.getBase(_selectedBaseId);
    final catalog = _currentCatalog;
    final variations = currentBase?.variations ?? <String>[];
    final showCustomOption = catalog?.hasCustomInstance ?? false;
    final isPlantPuzzleVariation = GlacierModulePresets.isPlantPuzzleVariation(
      _battleData.zombossMechType,
    );
    final propertiesLabel = ZombossMechRepository.propertiesDisplayLabel(
      _battleData.zombossMechType,
      catalog: catalog,
    );
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!_hasIntroModule)
          Card(
            color: theme.colorScheme.errorContainer,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    editorErrorIcon,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.missingIntroModule ?? 'Missing Intro Module',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n?.missingIntroModuleHint ??
                              'Level is missing ZombossBattleIntroProperties.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Text(
          l10n?.zombossMechSelection ?? 'ZombossMech selection',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (currentBase != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ZombossMechBaseCard(
              baseId: currentBase.id,
              icon: currentBase.icon,
              compact: true,
              hideBorder: true,
              onTap: _openBaseSelection,
              trailing: Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Tooltip(
          message: l10n?.zombossMechVariationHint ?? '',
          child: SeparatedOptionPickerField<String>(
            labelText:
                l10n?.zombossMechVariationLabel ?? 'ZombossMech variation',
            value: _variationDropdownValue(
              variations,
              variations.contains(_battleData.zombossMechType)
                  ? _battleData.zombossMechType
                  : null,
            ),
            items: [
              for (final v in variations)
                SeparatedOptionPickerItem(
                  value: v,
                  label: _variationLabel(context, v),
                  subtitle: v,
                ),
              if (showCustomOption)
                SeparatedOptionPickerItem(
                  value: kZombossMechCustomVariationValue,
                  label: l10n?.zombossMechCustomVariation ?? 'Custom',
                  subtitle: catalog?.editableInstance,
                ),
            ],
            enabled: variations.isNotEmpty || showCustomOption,
            onChanged: _onVariationChanged,
          ),
        ),
        if (_isCustomSelected) ...[
          const SizedBox(height: 12),
          Tooltip(
            message: l10n?.customZombossMechEditHint ?? '',
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCustomEditor,
                icon: const Icon(Icons.edit),
                label: Text(l10n?.editCustomZombossMech ?? 'Edit'),
              ),
            ),
          ),
        ] else if (catalog != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openPropertiesView,
              icon: const Icon(Icons.info_outline),
              label: Text(l10n?.viewZombossMechProperties ?? 'View properties'),
            ),
          ),
        ],
        if (propertiesLabel != null) ...[
          const SizedBox(height: 16),
          Text(
            l10n?.zombossMechUsedProperties ?? 'Used properties',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(
            propertiesLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n?.parameters ?? 'Parameters',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        _StepperControl(
          label: l10n?.reservedColumnCount ?? 'Reserved column count',
          tooltip: l10n?.reservedColumnCountHint ?? '',
          value: _battleData.reservedColumnCount,
          onChanged: (val) =>
              _sync(extra: () => _battleData.reservedColumnCount = val),
          min: 0,
          max: 9,
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            l10n?.reservedColumnPreview ?? 'Reserved column preview',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: ReservedColumnPreviewGrid(
            gridRows: gridRows,
            gridCols: gridCols,
            reservedColumnCount: _battleData.reservedColumnCount,
          ),
        ),
        if (ZombossMechRepository.isIceAgeMechVariation(
              _battleData.zombossMechType,
            ) &&
            !isPlantPuzzleVariation) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onOpenGlacierModule,
              icon: const Icon(Icons.ac_unit),
              label: Text(
                l10n?.zombossMechOpenGlacierModule ?? 'Open glacier module',
              ),
            ),
          ),
        ],
        if (_selectedBaseId == ZombossEightiesSpeakerPresets.baseId) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const ValueKey('openInitialGridItemsFromEighties'),
              onPressed: widget.onOpenInitialGridItems,
              icon: const Icon(Icons.grid_view_outlined),
              label: Text(
                l10n?.zombossMechConfigureInitialGridItems ??
                    'Configure preset grid items',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip = '',
    this.min = 0,
    this.max = 100,
  });

  final String label;
  final String tooltip;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip.isNotEmpty ? tooltip : label,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
