import 'package:flutter/material.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models.dart';
import 'package:z_editor/data/repository/zomboss_mech_repository.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/l10n/resource_names.dart';
import 'package:z_editor/screens/editor/others/custom_zomboss_mech_properties_screen.dart';
import 'package:z_editor/widgets/asset_image.dart';
import 'package:z_editor/widgets/editor_components.dart';

class ZombossMechBattleTab extends StatefulWidget {
  const ZombossMechBattleTab({
    super.key,
    required this.levelFile,
    required this.onChanged,
    this.onOpenGlacierModule,
  });

  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback? onOpenGlacierModule;

  @override
  State<ZombossMechBattleTab> createState() => _ZombossMechBattleTabState();
}

class _ZombossMechBattleTabState extends State<ZombossMechBattleTab> {
  PvzObject? _battleObj;
  PvzObject? _introObj;
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
    _battleObj = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombossBattleModuleProperties')
        .firstOrNull;
    _introObj = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombossBattleIntroProperties')
        .firstOrNull;

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

    void apply() {
      ZombossMechRepository.ensureCustomPropertiesInLevel(
        catalog: catalog,
        levelFile: widget.levelFile,
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

  void _onBaseChanged(String? baseId) {
    if (baseId == null || baseId == _selectedBaseId) return;
    final base = ZombossMechRepository.getBase(baseId);
    if (base == null || base.variations.isEmpty) return;

    final catalog = ZombossMechRepository.getCatalog(baseId);
    final keepCustom = catalog != null &&
        ZombossMechRepository.isCustomVariation(
          _battleData.zombossMechType,
          catalog,
        );

    String pickVariation() {
      if (keepCustom && catalog != null && catalog.hasCustomInstance) {
        return catalog.editableInstance;
      }
      if (base.variations.contains(_battleData.zombossMechType)) {
        return _battleData.zombossMechType;
      }
      return base.variations.first;
    }

    _sync(extra: () {
      _selectedBaseId = baseId;
      final variation = pickVariation();
      if (catalog != null &&
          catalog.hasCustomInstance &&
          variation == catalog.editableInstance) {
        _applyCustomVariation(persist: false);
      } else {
        _applyVariation(variation, persist: false);
      }
    });
  }

  void _onVariationChanged(String? value) {
    if (value == null) return;
    if (value == kZombossMechCustomVariationValue) {
      _applyCustomVariation();
      return;
    }
    if (value == _battleData.zombossMechType) return;
    _applyVariation(value);
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

  String _displayName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (_battleObj == null) {
      return Center(
        child: Text(
          l10n?.missingZombossMechModule ??
              'Missing ZombossBattleModuleProperties',
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
              Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
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

    final bases = ZombossMechRepository.allZombossMechs;
    final currentBase = ZombossMechRepository.getBase(_selectedBaseId);
    final catalog = _currentCatalog;
    final variations = currentBase?.variations ?? <String>[];
    final showCustomOption = catalog?.hasCustomInstance ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_introObj == null)
          Card(
            color: theme.colorScheme.errorContainer,
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: theme.colorScheme.onErrorContainer),
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
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AssetImageWidget(
                        assetPath:
                            'assets/images/zombies/${currentBase.icon}',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(context, currentBase.id),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _isCustomSelected
                              ? (l10n?.zombossMechCustomVariation ?? 'Custom')
                              : _battleData.zombossMechType,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (_isCustomSelected &&
                            catalog != null &&
                            catalog.editableInstancePropsName.isNotEmpty)
                          Text(
                            catalog.editableInstancePropsName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Tooltip(
          message: l10n?.zombossMechBaseHint ?? '',
          child: DropdownButtonFormField<String>(
            value: _selectedBaseId.isEmpty ? null : _selectedBaseId,
            decoration: editorInputDecoration(
              context,
              labelText: l10n?.zombossMechBaseLabel ?? 'Base ZombossMech',
            ),
            items: bases
                .map(
                  (b) => DropdownMenuItem(
                    value: b.id,
                    child: Text(_displayName(context, b.id)),
                  ),
                )
                .toList(),
            onChanged: _onBaseChanged,
          ),
        ),
        const SizedBox(height: 12),
        Tooltip(
          message: l10n?.zombossMechVariationHint ?? '',
          child: DropdownButtonFormField<String>(
            value: _variationDropdownValue(
              variations,
              variations.contains(_battleData.zombossMechType)
                  ? _battleData.zombossMechType
                  : null,
            ),
            decoration: editorInputDecoration(
              context,
              labelText:
                  l10n?.zombossMechVariationLabel ?? 'ZombossMech variation',
            ),
            items: [
              for (final v in variations)
                DropdownMenuItem(
                  value: v,
                  child: Text(_displayName(context, v)),
                ),
              if (showCustomOption)
                DropdownMenuItem(
                  value: kZombossMechCustomVariationValue,
                  child: Text(l10n?.zombossMechCustomVariation ?? 'Custom'),
                ),
            ],
            onChanged: variations.isEmpty && !showCustomOption
                ? null
                : _onVariationChanged,
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
        if (ZombossMechRepository.isIceAgeMechVariation(
          _battleData.zombossMechType,
        )) ...[
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
