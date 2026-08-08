import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_portal_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';

class CustomPortalPropertiesScreen extends StatefulWidget {
  const CustomPortalPropertiesScreen({
    super.key,
    required this.levelFile,
    this.existingPortalType,
    this.basePortalType,
  });

  final PvzLevelFile levelFile;
  final String? existingPortalType;
  final String? basePortalType;

  @override
  State<CustomPortalPropertiesScreen> createState() =>
      _CustomPortalPropertiesScreenState();
}

class _CustomPortalPropertiesScreenState
    extends State<CustomPortalPropertiesScreen> {
  late Map<String, dynamic> _data;
  CustomPortalInfo? _existing;

  bool get _isNew => _existing == null;

  @override
  void initState() {
    super.initState();
    final type = widget.existingPortalType;
    _existing = type == null
        ? null
        : CustomPortalLevelUtils.find(widget.levelFile, type);
    final existingData = _existing?.properties.objData;
    _data = existingData is Map
        ? PortalRepository.cloneMap(Map<String, dynamic>.from(existingData))
        : PortalRepository.clonePropertiesData(widget.basePortalType);
    _replaceBuggyHydraOptions();
  }

  void _replaceBuggyHydraOptions() {
    if (_data['PopAnim'] == 'POPANIM_EFFECTS_ZOMBOSS_HYDRA_MIRROR') {
      _data['PopAnim'] = PortalRepository.popAnimCodes.first;
      _data['PopAnimRenderOffset'] = {'x': 96, 'y': 125};
      _data['SpawnAnimation'] = 'spawn';
      _data['CloseAnimation'] = 'end';
    }
    if (_data['ZombieSpawnMethod'] == 'HydraRandom') {
      _data['ZombieSpawnMethod'] = PortalRepository.spawnMethodCodes.first;
      _data.remove('MinQuantity');
      _data.remove('MaxQuantity');
    }
  }

  List<String> get _zombieIds {
    final raw = _data['ZombieTypesToSpawn'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => entry['ZombieTypeName']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<int> get _zombieWeights {
    final raw = _data['ZombieTypesToSpawn'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => _asInt(entry['Weight'], 1))
        .toList();
  }

  void _setZombies(List<String> ids, List<int> weights) {
    setState(() {
      _data['ZombieTypesToSpawn'] = [
        for (var index = 0; index < ids.length; index++)
          {
            'ZombieTypeName': ids[index],
            'Weight': index < weights.length ? weights[index] : 1,
          },
      ];
    });
  }

  void _setPopAnim(String value) {
    setState(() {
      _data['PopAnim'] = value;
      final usesLargeOffset = value == 'POPANIM_EFFECTS_MODERN_PORTAL_PVZ1';
      _data['PopAnimRenderOffset'] = usesLargeOffset
          ? {'x': 105, 'y': 115}
          : {'x': 96, 'y': 125};
      _data['SpawnAnimation'] = 'spawn';
      _data['CloseAnimation'] = 'end';
    });
  }

  void _save() {
    final existing = _existing;
    final portalType = existing == null
        ? CustomPortalLevelUtils.create(
            levelFile: widget.levelFile,
            propertiesData: _data,
          )
        : existing.portalType;
    if (existing != null) {
      CustomPortalLevelUtils.updateProperties(existing, _data);
    }
    Navigator.pop(context, portalType);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spawnMethod =
        _data['ZombieSpawnMethod']?.toString() ??
        PortalRepository.spawnMethodCodes.first;
    final hasInterval = _data['TimeBetweenSpawns'] is Map;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isNew
              ? (l10n?.customPortalCreateTitle ?? 'Create custom portal')
              : (l10n?.customPortalEditTitle ?? 'Edit custom portal'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(onPressed: _save, child: Text(l10n?.save ?? 'Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n?.customPortalAppearanceSection ?? 'Portal appearance',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue:
                        PortalRepository.worldCodes.contains(_data['World'])
                        ? _data['World'].toString()
                        : null,
                    decoration: editorInputDecoration(
                      context,
                      labelText: _portalPropertyLabel(
                        l10n?.customPortalWorld ?? 'World',
                        'World',
                      ),
                    ),
                    items: [
                      for (final code in PortalRepository.worldCodes)
                        DropdownMenuItem(
                          value: code,
                          child: Text('${_worldName(context, code)} ($code)'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _data['World'] = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue:
                        PortalRepository.popAnimCodes.contains(_data['PopAnim'])
                        ? _data['PopAnim'].toString()
                        : null,
                    decoration: editorInputDecoration(
                      context,
                      labelText: _portalPropertyLabel(
                        l10n?.customPortalPopAnimation ?? 'Portal animation',
                        'PopAnim',
                      ),
                    ),
                    items: [
                      for (final code in PortalRepository.popAnimCodes)
                        DropdownMenuItem(
                          value: code,
                          child: Text(
                            '${_popAnimName(l10n, code)} ($code)',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) _setPopAnim(value);
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
                    l10n?.customPortalSpawnSection ?? 'Zombie spawning',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue:
                        PortalRepository.spawnMethodCodes.contains(spawnMethod)
                        ? spawnMethod
                        : null,
                    decoration: editorInputDecoration(
                      context,
                      labelText: _portalPropertyLabel(
                        l10n?.customPortalSpawnMethod ?? 'Spawn method',
                        'ZombieSpawnMethod',
                      ),
                    ),
                    items: [
                      for (final code in PortalRepository.spawnMethodCodes)
                        DropdownMenuItem(
                          value: code,
                          child: Text(
                            '${_spawnMethodName(l10n, code)} ($code)',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _data['ZombieSpawnMethod'] = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  ZombossMechWeightedZombieListEditor(
                    fieldLabel: _portalPropertyLabel(
                      l10n?.customPortalZombieTypes ?? 'Zombie types',
                      'ZombieTypesToSpawn',
                    ),
                    weightLabel: _portalPropertyLabel(
                      l10n?.zombieWeight ?? 'Zombie weight',
                      'Weight',
                    ),
                    zombieIds: _zombieIds,
                    weights: _zombieWeights,
                    editable: true,
                    onChanged: _setZombies,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _portalPropertyLabel(
                        l10n?.customPortalSpawnInterval ?? 'Spawn interval',
                        'TimeBetweenSpawns',
                      ),
                    ),
                    subtitle: Text(
                      l10n?.customPortalSpawnIntervalSubtitle ??
                          'Optionally limit the time between zombie spawns.',
                    ),
                    value: hasInterval,
                    onChanged: (enabled) {
                      setState(() {
                        if (enabled) {
                          _data['TimeBetweenSpawns'] = {'Min': 1.0, 'Max': 1.0};
                        } else {
                          _data.remove('TimeBetweenSpawns');
                        }
                      });
                    },
                  ),
                  if (hasInterval) ...[
                    const SizedBox(height: 8),
                    _intervalField(
                      context,
                      field: 'Min',
                      label:
                          l10n?.minimumIntervalSeconds ??
                          'Minimum interval (seconds)',
                    ),
                    const SizedBox(height: 12),
                    _intervalField(
                      context,
                      field: 'Max',
                      label:
                          l10n?.maximumIntervalSeconds ??
                          'Maximum interval (seconds)',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intervalField(
    BuildContext context, {
    required String field,
    required String label,
  }) {
    final interval = Map<String, dynamic>.from(
      _data['TimeBetweenSpawns'] as Map,
    );
    return TextFormField(
      initialValue: '${interval[field] ?? 1.0}',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: editorInputDecoration(
        context,
        labelText: _portalPropertyLabel(label, field),
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed == null) return;
        final next = Map<String, dynamic>.from(
          _data['TimeBetweenSpawns'] as Map,
        );
        next[field] = parsed;
        _data['TimeBetweenSpawns'] = next;
      },
    );
  }

  String _worldName(BuildContext context, String code) {
    if (code == 'twister') {
      return AppLocalizations.of(context)?.customPortalWorldTwister ??
          'Temporal Energy';
    }
    final stage = switch (code) {
      'egypt' => 'EgyptStage',
      'pirate' => 'PirateStage',
      'west' => 'WestStage',
      'future' => 'FutureStage',
      'dark' => 'DarkStage',
      'beach' => 'BeachStage',
      'iceage' => 'IceageStage',
      'lostcity' => 'LostCityStage',
      'eighties' => 'EightiesStage',
      'dino' => 'DinoStage',
      'kongfu' => 'KongfuStage',
      'steam' => 'SteamStage',
      'renai' => 'RenaiStage',
      'heian' => 'HeianStage',
      _ => '',
    };
    if (stage.isEmpty) return code;
    final key = 'stage_$stage';
    final localized = ResourceNames.lookup(context, key);
    return localized == key ? code : localized;
  }

  String _popAnimName(AppLocalizations? l10n, String code) => switch (code) {
    'POPANIM_EFFECTS_MODERN_PORTAL' =>
      l10n?.customPortalAnimationModern ?? 'Modern Day portal',
    'POPANIM_EFFECTS_MODERN_PORTAL_PVZ1' =>
      l10n?.customPortalAnimationMemoryLane ?? 'Memory Lane portal',
    'POPANIM_EFFECTS_ZOMBOSS_HYDRA_MIRROR' =>
      l10n?.customPortalAnimationHydra ?? 'Spell Chanter mirror',
    _ => code,
  };

  String _spawnMethodName(AppLocalizations? l10n, String code) =>
      switch (code) {
        'NonRandomShuffled' =>
          l10n?.customPortalSpawnMethodShuffled ?? 'Shuffled sequence',
        'NonRandomInOrder' =>
          l10n?.customPortalSpawnMethodInOrder ?? 'In order',
        'HydraRandom' =>
          l10n?.customPortalSpawnMethodHydra ?? 'Spell Chanter random',
        _ => code,
      };

  String _portalPropertyLabel(String localizedName, String codeName) {
    final normalizedName = localizedName
        .replaceAll('（', ' (')
        .replaceAll('）', ')');
    return '$normalizedName ($codeName)';
  }

  int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
