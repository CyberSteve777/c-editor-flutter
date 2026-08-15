import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';

bool _shouldRecommendTunnelDefendModule(
  LevelDefinitionData levelDef,
  bool hasTunnelDefendModule,
) {
  final stageInfo = RtidParser.parse(levelDef.stageModule);
  final alias = stageInfo?.alias ?? '';
  if (alias != 'UnchartedMausoleumStage' &&
      alias != 'UnchartedMausoleum2Stage') {
    return false;
  }
  return !hasTunnelDefendModule;
}

bool _isExpeditionTilesModule({
  required String alias,
  required String objClass,
  required dynamic objData,
}) {
  if (objClass != 'TunnelDefendModuleProperties') return false;
  if (alias == 'SouDaCheTunnelDefendDefault' ||
      alias.startsWith('SoudacheTunnelDefendStage')) {
    return true;
  }
  if (objData is Map) {
    return (objData['BrickMapIndex'] as num?)?.toInt() == 3;
  }
  return false;
}

class ModuleUIInfo {
  final String rtid;
  final String alias;
  final String objClass;
  final String friendlyName;
  final String description;
  final IconData icon;
  final String? assetIconPath;
  final bool isCore;
  final bool isExpeditionTiles;
  final bool canEdit;

  const ModuleUIInfo({
    required this.rtid,
    required this.alias,
    required this.objClass,
    required this.friendlyName,
    required this.description,
    required this.icon,
    this.assetIconPath,
    required this.isCore,
    this.isExpeditionTiles = false,
    required this.canEdit,
  });
}

class LevelSettingsTab extends StatefulWidget {
  const LevelSettingsTab({
    super.key,
    required this.levelDef,
    required this.objectMap,
    required this.missingModules,
    this.missingModuleWarnings,
    this.showGlacierModuleCompatibilityWarning = false,
    this.showGlacierModuleUnderwaterWarning = false,
    required this.onEditBasicInfo,
    required this.onEditModule,
    required this.onRemoveModule,
    required this.onReorderModules,
    required this.onNavigateToAddModule,
  });

  final LevelDefinitionData? levelDef;
  final Map<String, PvzObject> objectMap;
  final List<ModuleMetadata> missingModules;

  /// Module objClass -> list of plant IDs that need this module but it's missing (parallel plants warning).
  final Map<String, List<String>>? missingModuleWarnings;
  final bool showGlacierModuleCompatibilityWarning;
  final bool showGlacierModuleUnderwaterWarning;
  final VoidCallback onEditBasicInfo;
  final ValueChanged<String> onEditModule;
  final ValueChanged<String> onRemoveModule;
  final void Function({
    required bool isCoreSection,
    required int oldIndex,
    required int newIndex,
  })
  onReorderModules;
  final VoidCallback onNavigateToAddModule;

  @override
  State<LevelSettingsTab> createState() => _LevelSettingsTabState();
}

class _LevelSettingsTabState extends State<LevelSettingsTab> {
  static const _tabEditorModuleClasses = {
    'VaseBreakerPresetProperties',
    'VaseBreakerArcadeModuleProperties',
    'VaseBreakerFlowModuleProperties',
    'ZombossBattleModuleProperties',
    'ZombossBattleIntroProperties',
    'ZombossLastStandMinigameProperties',
  };

  String? pendingDeleteRtid;

  static bool _hasEditor(ModuleMetadata metadata, String objClass) {
    return (metadata.routeId != 'Unknown' &&
            metadata.routeId != 'UnknownDetail') ||
        _tabEditorModuleClasses.contains(objClass);
  }

  /// Returns localized plant name for display; falls back to a readable form of id if no translation.
  static String _plantDisplayName(
    BuildContext context,
    PlantRepository repo,
    String plantId,
  ) {
    final key = repo.getName(plantId);
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    return plantId
        .split('_')
        .map(
          (s) => s.isEmpty
              ? ''
              : s[0].toUpperCase() + s.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final levelDef = widget.levelDef;

    if (levelDef == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noLevelDefinition ?? 'No level definition',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.noLevelDefinitionHint ??
                    'Level definition module is missing.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final currentModulesList = levelDef.modules.map((rtid) {
      final info = RtidParser.parse(rtid);
      final alias = info?.alias ?? 'Unknown';
      String? objClass;

      if (info?.source == 'CurrentLevel') {
        objClass = widget.objectMap[alias]?.objClass;
      } else {
        objClass = ReferenceRepository.instance.getObjClass(alias);
      }
      objClass ??= 'UnknownObject';

      final metadata = ModuleRegistry.getMetadataForAlias(alias, objClass);
      final rawObjData = info?.source == 'CurrentLevel'
          ? widget.objectMap[alias]?.objData
          : ReferenceRepository.instance.objectForAlias(alias)?.objData;
      final isExpeditionTiles = _isExpeditionTilesModule(
        alias: alias,
        objClass: objClass,
        objData: rawObjData,
      );

      return ModuleUIInfo(
        rtid: rtid,
        alias: alias,
        objClass: objClass,
        friendlyName: metadata.getTitle(context),
        description: metadata.getDescription(context),
        icon: metadata.icon,
        assetIconPath: metadata.assetIconPath,
        isCore: metadata.isCore,
        isExpeditionTiles: isExpeditionTiles,
        canEdit: _hasEditor(metadata, objClass),
      );
    }).toList();

    final coreModules = currentModulesList.where((m) => m.isCore).toList();
    final miscModules = currentModulesList.where((m) => !m.isCore).toList();

    final existingObjClasses = currentModulesList
        .map((m) => m.objClass)
        .toSet();
    final activeConflicts = ConflictRegistry.getActiveConflicts(
      context,
      existingObjClasses,
    );
    final hasTunnelDefendModule = currentModulesList.any(
      (m) =>
          m.objClass == 'TunnelDefendModuleProperties' && !m.isExpeditionTiles,
    );
    final showTunnelDefendRecommendation = _shouldRecommendTunnelDefendModule(
      levelDef,
      hasTunnelDefendModule,
    );
    final hasExpeditionTilesModule = currentModulesList.any(
      (m) => m.isExpeditionTiles,
    );
    final showExpeditionTilesRecommendation =
        LevelParser.isSouDaCheLawn(levelDef, _levelFileFromObjectMap()) &&
        !hasExpeditionTilesModule;
    final showExpeditionTilesMismatchWarning =
        hasExpeditionTilesModule &&
        LevelParser.isUnderwaterWorldSixRowLawn(
          levelDef,
          _levelFileFromObjectMap(),
        );
    final showTunnelExpeditionCompatibilityWarning =
        hasTunnelDefendModule && hasExpeditionTilesModule;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SettingEntryCard(
              title: l10n?.levelBasicInfo ?? 'Level basic info',
              subtitle:
                  l10n?.levelBasicInfoSubtitle ??
                  'Name, number, description, stage',
              icon: Icons.edit_note,
              onClick: widget.onEditBasicInfo,
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.editableModules ?? 'Editable modules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (coreModules.isNotEmpty)
              _ReorderableModuleList(
                modules: coreModules,
                isCore: true,
                removeTooltip: l10n?.removeModule ?? 'Remove module',
                reorderHint: _moduleReorderHint(context, l10n),
                onEditModule: widget.onEditModule,
                onDelete: (rtid) => setState(() => pendingDeleteRtid = rtid),
                onReorder: (oldIndex, newIndex) => widget.onReorderModules(
                  isCoreSection: true,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                ),
              ),
            const SizedBox(height: 20),
            if (miscModules.isNotEmpty) ...[
              Text(
                l10n?.parameterModules ?? 'Parameter modules',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              _ReorderableModuleList(
                modules: miscModules,
                isCore: false,
                removeTooltip: l10n?.removeModule ?? 'Remove module',
                reorderHint: _moduleReorderHint(context, l10n),
                onEditModule: widget.onEditModule,
                onDelete: (rtid) => setState(() => pendingDeleteRtid = rtid),
                onReorder: (oldIndex, newIndex) => widget.onReorderModules(
                  isCoreSection: false,
                  oldIndex: oldIndex,
                  newIndex: newIndex,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Add Module Button
            InkWell(
              onTap: widget.onNavigateToAddModule,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n?.addNewModule ?? 'Add new module',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Conflicts
            ...activeConflicts.map(
              (pair) => Card(
                color: Theme.of(context).colorScheme.errorContainer,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pair.first,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pair.second,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Missing module for parallel plants (same style as conflicts)
            if (widget.missingModuleWarnings != null &&
                widget.missingModuleWarnings!.isNotEmpty)
              ...widget.missingModuleWarnings!.entries.map((e) {
                final meta = ModuleRegistry.getMetadata(e.key);
                final moduleName = meta.getTitle(context);
                final repo = PlantRepository();
                final plantList = e.value
                    .map((id) => _plantDisplayName(context, repo, id))
                    .join(', ');
                final message = AppLocalizations.of(
                  context,
                )!.missingModuleForPlantsWarning(moduleName, plantList);
                return Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n?.missingPlantModuleWarningTitle ??
                                    'Missing module for parallel plants',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            // Missing Essentials
            if (widget.missingModules.isNotEmpty)
              EditorWarningBanner(
                title: l10n?.missingModules ?? 'Missing modules',
                message:
                    l10n?.missingModulesRecommended ??
                    'The level might not function correctly. Recommended to add:',
                children: widget.missingModules
                    .map(
                      (meta) => Text(
                        '• ${meta.getTitle(context)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: editorWarningBannerForeground(
                            Theme.of(context).brightness,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

            if (widget.showGlacierModuleCompatibilityWarning) ...[
              const SizedBox(height: 12),
              EditorWarningBanner(
                title:
                    l10n?.glacierModuleCompatibilityWarningTitle ??
                    'Ice Chunk Module requirements',
                message:
                    l10n?.glacierModuleCompatibilityWarning ??
                    'This module only works with the Zomboss Battle module '
                        'and an Ice Age Zomboss Mech (zombossmech_iceage). '
                        'Add or fix those settings so glacier blocks can spawn zombies.',
              ),
            ],

            if (widget.showGlacierModuleUnderwaterWarning) ...[
              const SizedBox(height: 12),
              EditorWarningBanner(
                title:
                    l10n?.glacierModuleUnderwaterWarningTitle ??
                    'Underwater World appearance incompatibility',
                message:
                    l10n?.glacierModuleUnderwaterWarning ??
                    'Avoid using the Frostbite Caves Zomboss and the Ice Chunk Module on an Underwater World lawn. This combination can harm the level appearance and may cause crashes.',
              ),
            ],

            if (showTunnelDefendRecommendation) ...[
              const SizedBox(height: 12),
              EditorWarningBanner(
                title:
                    l10n?.recommendedTunnelDefendTitle ??
                    'Tunnel pathways strongly recommended',
                message:
                    l10n?.recommendedTunnelDefendBody ??
                    'The tiles in Underground Palace Secret Realm lawns must be placed through the "Underground Palace Pathways" module. If this module is not added, the lawns may appear overly empty in-game.',
              ),
            ],
            if (showExpeditionTilesRecommendation) ...[
              const SizedBox(height: 12),
              EditorWarningBanner(
                title:
                    l10n?.recommendedExpeditionTilesTitle ??
                    'Works with the "Expedition Tiles" module',
                message:
                    l10n?.recommendedExpeditionTilesBody ??
                    'Add the "Expedition Tiles" module to work around the lawn\'s missing tiles and create an experience that more closely matches Expedition Gate.',
              ),
            ],
            if (showTunnelExpeditionCompatibilityWarning) ...[
              const SizedBox(height: 12),
              EditorWarningBanner(
                title:
                    l10n?.tunnelExpeditionCompatibilityWarningTitle ??
                    'Use Underground Palace Pathways with Expedition Tiles carefully',
                message:
                    l10n?.tunnelExpeditionCompatibilityWarningBody ??
                    'Using the "Underground Palace Pathways" module together with the "Expedition Tiles" module can cause tile textures to overlap and may affect the level\'s overall appearance. If you must use both, be extremely careful.',
              ),
            ],
            if (showExpeditionTilesMismatchWarning) ...[
              const SizedBox(height: 12),
              _ErrorBanner(
                title: l10n?.stageMismatch ?? 'Lawn Type Mismatch',
                message:
                    l10n?.expeditionTilesUnderwaterMismatchWarning ??
                    'The current lawn uses an Underwater World appearance, which is incompatible with the Expedition Tiles module and will cause the level to crash.',
              ),
            ],
          ],
        ),
        if (pendingDeleteRtid != null)
          AlertDialog(
            title: Text(l10n?.removeModule ?? 'Remove module'),
            content: Text(
              l10n?.removeModuleConfirm ??
                  'Remove this module? Local custom modules (@CurrentLevel) and their data will be deleted permanently.',
            ),
            actions: [
              TextButton(
                onPressed: () => setState(() => pendingDeleteRtid = null),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.onRemoveModule(pendingDeleteRtid!);
                  setState(() => pendingDeleteRtid = null);
                },
                child: Text(
                  l10n?.confirmRemove ?? 'Remove',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
      ],
    );
  }

  PvzLevelFile _levelFileFromObjectMap() {
    return PvzLevelFile(objects: widget.objectMap.values.toList());
  }

  static String _moduleReorderHint(
    BuildContext context,
    AppLocalizations? l10n,
  ) {
    final desktop =
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;
    return desktop
        ? (l10n?.presetPlantListReorderHintDesktop ??
              'Drag the ⋮⋮ handle to reorder.')
        : (l10n?.presetPlantListReorderHint ??
              'Long press the ⋮⋮ handle and drag to reorder.');
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(editorErrorIcon, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReorderableModuleList extends StatelessWidget {
  const _ReorderableModuleList({
    required this.modules,
    required this.isCore,
    required this.removeTooltip,
    required this.reorderHint,
    required this.onEditModule,
    required this.onDelete,
    required this.onReorder,
  });

  final List<ModuleUIInfo> modules;
  final bool isCore;
  final String removeTooltip;
  final String reorderHint;
  final ValueChanged<String> onEditModule;
  final ValueChanged<String> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reorderHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: modules.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final item = modules[index];
            return _ReorderableModuleTile(
              key: ValueKey(item.rtid),
              info: item,
              isCore: isCore,
              reorderIndex: index,
              removeTooltip: removeTooltip,
              onClick: item.canEdit ? () => onEditModule(item.rtid) : null,
              onDelete: () => onDelete(item.rtid),
            );
          },
        ),
      ],
    );
  }
}

class _ReorderableModuleTile extends StatelessWidget {
  const _ReorderableModuleTile({
    super.key,
    required this.info,
    required this.isCore,
    required this.reorderIndex,
    required this.removeTooltip,
    this.onClick,
    required this.onDelete,
  });

  final ModuleUIInfo info;
  final bool isCore;
  final int reorderIndex;
  final String removeTooltip;
  final VoidCallback? onClick;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final handleColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.85,
    );
    final iconColor = isCore ? theme.colorScheme.primary : Colors.grey;
    final titleStyle = isCore
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        : const TextStyle(color: Colors.grey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ReorderableDragStartListener(
                index: reorderIndex,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Icon(Icons.drag_indicator, color: handleColor),
                  ),
                ),
              ),
              if (info.assetIconPath != null)
                SizedBox(
                  width: isCore ? 28 : 20,
                  height: isCore ? 28 : 20,
                  child: AssetImageWidget(
                    assetPath: info.assetIconPath!,
                    fit: BoxFit.contain,
                    altCandidates: imageAltCandidates(info.assetIconPath!),
                  ),
                )
              else
                Icon(info.icon, color: iconColor, size: isCore ? 28 : 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCore
                          ? info.friendlyName
                          : '${info.friendlyName} (${info.alias})',
                      style: titleStyle,
                    ),
                    if (isCore) ...[
                      Text(
                        info.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(info.alias, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: isCore ? 24 : 16,
                  color: iconColor,
                ),
                tooltip: removeTooltip,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingEntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onClick;

  const _SettingEntryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
