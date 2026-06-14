import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Spawn modern portals event editor. Ported from Z-Editor-master ModernPortalEventEP.kt
class ModernPortalsEventScreen extends StatefulWidget {
  const ModernPortalsEventScreen({
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
  State<ModernPortalsEventScreen> createState() =>
      _ModernPortalsEventScreenState();
}

class _ModernPortalsEventScreenState extends State<ModernPortalsEventScreen> {
  late PvzObject _moduleObj;
  late PortalEventData _data;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef);
  }

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final alias = LevelParser.extractAlias(widget.rtid);
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: 'SpawnModernPortalsWaveActionProps',
        objData: PortalEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PortalEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PortalEventData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _showPreviewDialog(BuildContext context, AppLocalizations? l10n, PortalWorldDef def) {
    showDialog(
      context: context,
      builder: (ctx) => _buildPreviewDialog(ctx, l10n, def),
    );
  }

  String _portalDisplayName(AppLocalizations? l10n, PortalWorldDef def) {
    switch (def.typeCode) {
      case 'egypt':
        return l10n?.portalTypeEgypt ?? def.name;
      case 'egypt_2':
        return l10n?.portalTypeEgypt2 ?? def.name;
      case 'pirate':
        return l10n?.portalTypePirate ?? def.name;
      case 'west':
        return l10n?.portalTypeWest ?? def.name;
      case 'future':
        return l10n?.portalTypeFuture ?? def.name;
      case 'future_2':
        return l10n?.portalTypeFuture2 ?? def.name;
      case 'dark':
        return l10n?.portalTypeDark ?? def.name;
      case 'beach':
        return l10n?.portalTypeBeach ?? def.name;
      case 'iceage':
        return l10n?.portalTypeIceAge ?? def.name;
      case 'lostcity':
        return l10n?.portalTypeLostCity ?? def.name;
      case 'eighties':
        return l10n?.portalTypeEighties ?? def.name;
      case 'dino':
        return l10n?.portalTypeDino ?? def.name;
      case 'dangerroom_egypt':
        return l10n?.portalTypeEndlessEgypt ?? def.name;
      case 'dangerroom_pirate':
        return l10n?.portalTypeEndlessPirate ?? def.name;
      case 'dangerroom_west':
        return l10n?.portalTypeEndlessWest ?? def.name;
      case 'dangerroom_future':
        return l10n?.portalTypeEndlessFuture ?? def.name;
      case 'dangerroom_dark':
        return l10n?.portalTypeEndlessDark ?? def.name;
      case 'dangerroom_beach':
        return l10n?.portalTypeEndlessBeach ?? def.name;
      case 'dangerroom_iceage':
        return l10n?.portalTypeEndlessIceAge ?? def.name;
      case 'dangerroom_lostcity':
        return l10n?.portalTypeEndlessLostCity ?? def.name;
      case 'dangerroom_eighties':
        return l10n?.portalTypeEndlessEighties ?? def.name;
      case 'dangerroom_dino':
        return l10n?.portalTypeEndlessDino ?? def.name;
      case 'pvz1_Zombotany':
        return l10n?.portalTypeZombotany ?? def.name;
      case 'pvz1_Slime':
        return l10n?.portalTypeSlimeZombies ?? def.name;
      case 'pvz1_Universe':
        return l10n?.portalTypeUniverse42 ?? def.name;
      case 'pvz1_Uncharted':
        return l10n?.portalTypeUniverse41 ?? def.name;
      case 'pvz1_elite_roman_healer_normal':
        return l10n?.portalTypeEliteHealerNormal ?? def.name;
      case 'pvz1_elite_skycity_electric_normal':
        return l10n?.portalTypeEliteElectricNormal ?? def.name;
      case 'pvz1_elite_roman_ballista_normal':
        return l10n?.portalTypeEliteBallistaNormal ?? def.name;
      case 'pvz1_elite_heian_onmyoji_normal':
        return l10n?.portalTypeEliteOnmyojiNormal ?? def.name;
      case 'pvz1_elite_roman_healer_hard':
        return l10n?.portalTypeEliteHealerHard ?? def.name;
      case 'pvz1_elite_skycity_electric_hard':
        return l10n?.portalTypeEliteElectricHard ?? def.name;
      case 'pvz1_elite_roman_ballista_hard':
        return l10n?.portalTypeEliteBallistaHard ?? def.name;
      case 'pvz1_elite_heian_onmyoji_hard':
        return l10n?.portalTypeEliteOnmyojiHard ?? def.name;
      case 'iceage_hunter_elite':
        return l10n?.portalTypeEliteHunter ?? def.name;
      case 'iceage_chief_elite':
        return l10n?.portalTypeEliteChief ?? def.name;
      case 'iceage_weaselhoarder_elite':
        return l10n?.portalTypeEliteWeasel ?? def.name;
      case 'bumpercar_elite':
        return l10n?.portalTypeEliteBumperCar ?? def.name;
      case 'dark_wizard_elite':
        return l10n?.portalTypeEliteWizard ?? def.name;
      case 'dark_king_elite':
        return l10n?.portalTypeEliteKing ?? def.name;
      default:
        return def.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final alias = LevelParser.extractAlias(widget.rtid);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n?.editAlias(alias) ?? 'Edit $alias'),
            Text(
              l10n?.eventTimeRift ?? 'Event: Time rift',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.eventTimeRift ?? 'Time rift event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpModernPortalsBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.portalType ?? 'Portal type',
                  body: l10n?.eventHelpModernPortalsType ?? '',
                ),
                HelpSectionData(
                  title: l10n?.ignoreGravestone ?? 'Ignore gravestone',
                  body: l10n?.eventHelpModernPortalsIgnore ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.selectedPosition ?? 'Selected position',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'R${_data.portalRow + 1} : C${_data.portalColumn + 1}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      scaleTableForDesktop(
                        context: context,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: AspectRatio(
                            aspectRatio: _gridCols / _gridRows,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: _gridCols,
                                childAspectRatio: 1,
                              ),
                              itemCount: _gridCols * _gridRows,
                              itemBuilder: (context, i) {
                                final col = i % _gridCols;
                                final row = i ~/ _gridCols;
                            final isSelected =
                                row == _data.portalRow && col == _data.portalColumn;
                            return GestureDetector(
                              onTap: () {
                                _data = PortalEventData(
                                  portalType: _data.portalType,
                                  portalColumn: col,
                                  portalRow: row,
                                  spawnEffect: _data.spawnEffect,
                                  spawnSoundID: _data.spawnSoundID,
                                  ignoreGraveStone: _data.ignoreGraveStone,
                                );
                                _sync();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: theme.colorScheme.onPrimary,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
                        l10n?.portalType ?? 'Portal type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PortalRepository.portalDefinitions.map((def) {
                          final isSelected =
                              def.typeCode == _data.portalType;
                          return SizedBox(
                            width: 130,
                            child: Card(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                              child: InkWell(
                                onTap: () {
                                  _data = PortalEventData(
                                    portalType: def.typeCode,
                                    portalColumn: _data.portalColumn,
                                    portalRow: _data.portalRow,
                                    spawnEffect: _data.spawnEffect,
                                    spawnSoundID: _data.spawnSoundID,
                                    ignoreGraveStone: _data.ignoreGraveStone,
                                  );
                                  _sync();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _portalDisplayName(l10n, def),
                                          style: theme.textTheme.bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                        IconButton(
                                        icon: const Icon(Icons.info_outline),
                                        iconSize: 18,
                                        onPressed: () =>
                                            _showPreviewDialog(context, l10n, def),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text(l10n?.ignoreGravestone ?? 'Ignore gravestone (IgnoreGraveStone)'),
                  subtitle: Text(
                    l10n?.ignoreGravestoneSubtitle ?? 'Enable to spawn regardless of obstacles',
                  ),
                  value: _data.ignoreGraveStone,
                  onChanged: (v) {
                    _data = PortalEventData(
                      portalType: _data.portalType,
                      portalColumn: _data.portalColumn,
                      portalRow: _data.portalRow,
                      spawnEffect: _data.spawnEffect,
                      spawnSoundID: _data.spawnSoundID,
                      ignoreGraveStone: v,
                    );
                    _sync();
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewDialog(BuildContext context, AppLocalizations? l10n, PortalWorldDef def) {
    final theme = Theme.of(context);
    final zombieRepo = ZombieRepository();
    final portalName = _portalDisplayName(l10n, def);

    return AlertDialog(
      title: Text(l10n?.zombiePreview(portalName) ?? '$portalName - Zombie preview'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.thisPortalSpawns ?? 'This portal spawns:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...def.representativeZombies.map((typeName) {
              final zombie = zombieRepo.getZombieById(typeName);
              final iconPath = zombie?.iconAssetPath;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    iconPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            child: Text(
                              zombieRepo.getName(typeName).isNotEmpty
                                  ? zombieRepo.getName(typeName)[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ResourceNames.lookup(context, zombieRepo.getName(typeName)),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          typeName,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }
}
