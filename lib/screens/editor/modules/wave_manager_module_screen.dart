import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Wave manager module editor. Ported from WaveManagerModulesPropertiesEP.kt
class WaveManagerModuleScreen extends StatefulWidget {
  const WaveManagerModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<WaveManagerModuleScreen> createState() =>
      _WaveManagerModuleScreenState();
}

class _WaveManagerModuleScreenState extends State<WaveManagerModuleScreen> {
  static const _objClass = 'WaveManagerModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late WaveManagerModuleData _data;
  late TextEditingController _startWaveCtrl;
  late TextEditingController _startPointsCtrl;
  late TextEditingController _pointIncrementCtrl;
  bool _pointSpawningEnabled = true;

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
        objClass: 'WaveManagerModuleProperties',
        objData: WaveManagerModuleData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }

    try {
      _data = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = WaveManagerModuleData();
    }

    _pointSpawningEnabled = _data.dynamicZombies.isNotEmpty;
    if (_data.dynamicZombies.isEmpty) {
      _data.dynamicZombies.add(DynamicZombieGroup());
    } else {
      for (final group in _data.dynamicZombies) {
        while (group.zombieLevel.length < group.zombiePool.length) {
          group.zombieLevel.add(1);
        }
      }
    }

    final hasLastStand = widget.levelFile.objects.any(
      (o) => o.objClass == 'LastStandMinigameProperties',
    );
    if (hasLastStand && _data.manualStartup != true) {
      _data.manualStartup = true;
      _sync();
    }

    final first = _data.dynamicZombies.first;
    _startWaveCtrl = TextEditingController(text: '${first.startingWave}');
    _startPointsCtrl = TextEditingController(text: '${first.startingPoints}');
    _pointIncrementCtrl = TextEditingController(
      text: '${first.pointIncrement}',
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _isYetiZombie(String id) {
    return id == 'yeti' || id == 'treasureyeti' || id == 'treasureyeti_egypt';
  }

  void _showYetiZombieBlockedMessage(AppLocalizations? l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.yetiZombiesNotAllowed ?? 'Yetis are not allowed here',
        ),
      ),
    );
  }

  DynamicZombieGroup get _firstGroup => _data.dynamicZombies.first;

  void _updateFirstGroup({
    int? startingWave,
    int? startingPoints,
    int? pointIncrement,
  }) {
    _firstGroup.startingWave = startingWave ?? _firstGroup.startingWave;
    _firstGroup.startingPoints = startingPoints ?? _firstGroup.startingPoints;
    _firstGroup.pointIncrement = pointIncrement ?? _firstGroup.pointIncrement;
    _sync();
  }

  void _addZombie() {
    final l10n = AppLocalizations.of(context);
    widget.onRequestZombieSelection((selectedId) {
      if (_isYetiZombie(selectedId)) {
        _showYetiZombieBlockedMessage(l10n);
        return;
      }
      final isElite = ZombieRepository().isElite(selectedId);
      if (isElite) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.eliteZombiesNotAllowed ??
                  'Elite zombies are not allowed here',
            ),
          ),
        );
        return;
      }
      final aliases = ZombieRepository().buildZombieAliases(selectedId);
      final rtid = RtidParser.build(aliases, 'ZombieTypes');
      _firstGroup.zombiePool.add(rtid);
      _firstGroup.zombieLevel.add(1);
      _sync();
    });
  }

  Future<void> _removeZombie(int index) async {
    if (index >= _firstGroup.zombiePool.length) return;
    final removed = _firstGroup.zombiePool[index];
    final info = RtidParser.parse(removed);
    var eraseOrphan = false;
    if (info?.source == 'CurrentLevel' && mounted) {
      final choice =
          await CustomZombieLevelUtils.maybePromptDeleteOrphanBeforeRemove(
            context: context,
            levelFile: widget.levelFile,
            alias: info!.alias,
          );
      if (!mounted || choice == null) return;
      eraseOrphan = choice;
    }
    _firstGroup.zombiePool.removeAt(index);
    if (index < _firstGroup.zombieLevel.length) {
      _firstGroup.zombieLevel.removeAt(index);
    }
    _sync();
    if (info?.source == 'CurrentLevel' && eraseOrphan) {
      CustomZombieLevelUtils.removeTypeAndProperties(
        widget.levelFile,
        info!.alias,
      );
      widget.onChanged();
    }
  }

  void _changeLevel(int index, int delta) {
    final current = _firstGroup.zombieLevel[index];
    final next = (current + delta).clamp(1, 10);
    _firstGroup.zombieLevel[index] = next;
    _sync();
  }

  @override
  void dispose() {
    _startWaveCtrl.dispose();
    _startPointsCtrl.dispose();
    _pointIncrementCtrl.dispose();
    super.dispose();
  }

  String _localizedText(
    BuildContext context, {
    required String zh,
    required String en,
  }) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale.startsWith('zh') ? zh : en;
  }

  String _waveManagerPropsTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n?.moduleTitle_WaveManagerProperties ??
        _localizedText(context, zh: '波次管理属性', en: 'Wave Manager Properties');
  }

  String _currentWaveManagerPropsText(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);
    return l10n?.waveManagerPropsCurrent(value) ??
        _localizedText(context, zh: '当前值：$value', en: 'Current: $value');
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Light: light green card, purple section titles. Dark: vibrant green card, purplish-pink titles.
    final propsCardColor = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE8F5E9);
    final propsTextColor = isDark ? Colors.white : const Color(0xFF1B5E20);
    final propsSubtextColor = isDark
        ? Colors.white.withValues(alpha: 0.9)
        : const Color(0xFF689F38);
    final sectionTitleColor = isDark ? pvzPurpleDark : pvzPurpleLight;
    final contentCardColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surface;

    final propsObj = widget.levelFile.objects.firstWhere(
      (o) => o.objClass == 'WaveManagerProperties',
      orElse: () => PvzObject(objClass: '', objData: {}),
    );
    final aliases = propsObj.aliases;
    final actualWaveMgrAlias = aliases != null && aliases.isNotEmpty
        ? aliases.first
        : null;

    final currentPropsAlias = RtidParser.parse(
      _data.waveManagerProps ?? '',
    )?.alias;
    final isPropsValid =
        actualWaveMgrAlias != null && currentPropsAlias == actualWaveMgrAlias;
    final waveManagerPropsTitle = _waveManagerPropsTitle(context);
    final currentWaveManagerPropsText = _currentWaveManagerPropsText(
      context,
      _data.waveManagerProps ?? 'null',
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: sectionTitleColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                title: l10n?.waveManagerModule ?? 'Wave manager module',
                themeColor: sectionTitleColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.waveManagerHelpOverview ??
                        'Enables wave manager. Without this module, wave editing is disabled.',
                  ),
                  HelpSectionData(
                    title: l10n?.pointsSection ?? 'Points',
                    body:
                        l10n?.waveManagerHelpPoints ??
                        'Point-based spawning uses this pool. Avoid elite and custom zombies.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: sectionTitleColor,
            ),
            const SizedBox(height: 16),
            Card(
              color: isPropsValid ? propsCardColor : theme.colorScheme.error,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPropsValid ? Icons.check_circle : editorWarningIcon,
                          color: isPropsValid
                              ? (isDark
                                    ? Colors.white
                                    : const Color(0xFF2E7D32))
                              : theme.colorScheme.onError,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          waveManagerPropsTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isPropsValid
                                ? propsTextColor
                                : theme.colorScheme.onError,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentWaveManagerPropsText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isPropsValid
                            ? propsSubtextColor
                            : theme.colorScheme.onError,
                      ),
                    ),
                    if (actualWaveMgrAlias == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          l10n?.noWaveManagerPropsFound ??
                              'No WaveManagerProperties object found.',
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (!isPropsValid && actualWaveMgrAlias != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.onError,
                            foregroundColor: theme.colorScheme.onPrimary,
                          ),
                          onPressed: () {
                            _data.waveManagerProps = RtidParser.build(
                              actualWaveMgrAlias,
                              'CurrentLevel',
                            );
                            _sync();
                          },
                          child: Text(
                            l10n?.fixToAlias(actualWaveMgrAlias) ??
                                'Fix to $actualWaveMgrAlias',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: contentCardColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.enablePointSpawning ??
                                'Enable point spawning',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _pointSpawningEnabled
                                ? (l10n?.pointSpawningEnabledDesc ??
                                      'Enabled (uses extra points for spawning)')
                                : (l10n?.pointSpawningDisabledDesc ??
                                      'Disabled (wave events only)'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _pointSpawningEnabled,
                      onChanged: (v) {
                        setState(() {
                          _pointSpawningEnabled = v;
                          if (v) {
                            if (_data.dynamicZombies.isEmpty) {
                              _data.dynamicZombies.add(
                                DynamicZombieGroup(
                                  startingWave: 3,
                                  startingPoints: 100,
                                  pointIncrement: 40,
                                  zombiePool: [],
                                  zombieLevel: [],
                                ),
                              );
                            }
                          } else {
                            _data.dynamicZombies = [];
                          }
                          _sync();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            if (_pointSpawningEnabled) ...[
              const SizedBox(height: 16),
              Text(
                l10n?.pointSettings ?? 'Point settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sectionTitleColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: contentCardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _intField(
                        controller: _startWaveCtrl,
                        label: l10n?.startingWave ?? 'Starting wave',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(startingWave: n);
                        },
                      ),
                      const SizedBox(height: 8),
                      _intField(
                        controller: _startPointsCtrl,
                        label: l10n?.startingPoints ?? 'Starting points',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(startingPoints: n);
                        },
                      ),
                      const SizedBox(height: 8),
                      _intField(
                        controller: _pointIncrementCtrl,
                        label: l10n?.pointIncrement ?? 'Point increment',
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) _updateFirstGroup(pointIncrement: n);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n?.zombiePool ?? 'Zombie pool',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: sectionTitleColor,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addZombie,
                    icon: const Icon(Icons.add),
                    label: Text(l10n?.add ?? 'Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._firstGroup.zombiePool.asMap().entries.map((entry) {
                final idx = entry.key;
                final rtid = entry.value;
                final alias = RtidParser.parse(rtid)?.alias ?? rtid;
                final typeName = ZombiePropertiesRepository.getTypeNameByAlias(
                  alias,
                );
                final info = ZombieRepository().getZombieById(typeName);
                final nameKey =
                    info?.name ?? ZombieRepository().getName(typeName);
                final displayName = ResourceNames.lookup(context, nameKey);
                final level = _firstGroup.zombieLevel.elementAt(idx);
                final iconPath = info?.iconAssetPath;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: contentCardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
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
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    alignment: Alignment.center,
                                    child: Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                l10n?.levelFormat(level) ?? 'Level: $level',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: level >= 6
                                      ? theme.colorScheme.error
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          tooltip: l10n?.remove ?? 'Remove',
                          onPressed: level > 1
                              ? () => _changeLevel(idx, -1)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l10n?.add ?? 'Add',
                          onPressed: level < 10
                              ? () => _changeLevel(idx, 1)
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: l10n?.delete ?? 'Delete',
                          onPressed: () => _removeZombie(idx),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
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
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
