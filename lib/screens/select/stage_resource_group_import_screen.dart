import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

enum StageResourceGroupImportMode { global, fromStage }

/// Import resource groups into custom stage lists.
class StageResourceGroupImportScreen extends StatefulWidget {
  const StageResourceGroupImportScreen({
    super.key,
    required this.mode,
    required this.existingGroups,
    required this.onImport,
    required this.onBack,
  });

  final StageResourceGroupImportMode mode;
  final Set<String> existingGroups;
  final void Function({
    required List<String> groups,
    String? sourceStageAlias,
    bool applySourceLawnAppearance,
  }) onImport;
  final VoidCallback onBack;

  @override
  State<StageResourceGroupImportScreen> createState() =>
      _StageResourceGroupImportScreenState();
}

class _StageResourceGroupImportScreenState
    extends State<StageResourceGroupImportScreen> {
  String _searchQuery = '';
  bool _applySourceLawnAppearance = false;

  Iterable<String> _globalGroups() {
    return StageCatalogRepository.knownResourceGroups.where(
      (g) => !widget.existingGroups.contains(g),
    );
  }

  Set<String> _allGroupsForStage(String alias) {
    final impl = StageCatalogRepository.catalogImplementation(alias);
    if (impl == null) return const {};
    return {
      ...CustomStageLevelUtils.stringList(impl.objdata['ResourceGroupNames']),
      ...CustomStageLevelUtils.stringList(impl.objdata['GroupsToUnloadForAds']),
    };
  }

  List<String> _groupsToAddForStage(String alias) {
    return _allGroupsForStage(alias)
        .where((g) => !widget.existingGroups.contains(g))
        .toList()
      ..sort();
  }

  int _skippedGroupCountForStage(String alias) {
    return _allGroupsForStage(alias)
        .where(widget.existingGroups.contains)
        .length;
  }

  List<String> _filteredGlobalGroups() {
    var items = _globalGroups().toList()..sort();
    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = items.where((group) {
        final key = StageCatalogRepository.resourceGroupKey(group);
        return matchesSelectionSearch(_searchQuery, [
          group,
          key,
          ResourceNames.lookup(context, key),
        ]);
      }).toList();
    }
    return items;
  }

  List<StageBaseOption> _filteredStages() {
    var items = StageCatalogRepository.stageBaseOptions();
    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = items.where((option) {
        final nameKey = _stageNameKey(option.alias);
        final name = ResourceNames.lookup(context, nameKey);
        return matchesSelectionSearch(_searchQuery, [
          name,
          nameKey,
          option.alias,
          option.objclass,
          option.backgroundImagePrefix ?? '',
          option.backgroundResourceGroup ?? '',
        ]);
      }).toList();
    }
    return items;
  }

  String _groupLabel(String group) => ResourceNames.lookup(
        context,
        StageCatalogRepository.resourceGroupKey(group),
      );

  String _stageNameKey(String alias) => 'stage_$alias';

  Future<void> _confirmImportFromStage(StageBaseOption option) async {
    final l10n = AppLocalizations.of(context);
    final stageName = ResourceNames.lookup(
      context,
      _stageNameKey(option.alias),
    );
    final toAdd = _groupsToAddForStage(option.alias);
    final skipped = _skippedGroupCountForStage(option.alias);

    if (toAdd.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(stageName),
          content: Text(
            l10n?.importResourceGroupsFromStageAllPresent ??
                'All resource groups from this stage are already in this level.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.ok ?? 'OK'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        var applyLawnAppearance = _applySourceLawnAppearance;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(
              l10n?.importResourceGroupsFromStageTitle ??
                  'Add resource groups from stage?',
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n?.importResourceGroupsFromStageMessage(stageName) ??
                        'The following resource groups from $stageName will be added:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (skipped > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n?.importResourceGroupsFromStageSkipped(skipped) ??
                          '$skipped resource group(s) already in this level will be skipped.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...toAdd.map(
                    (group) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _groupLabel(group),
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  group,
                                  style: theme.textTheme.bodySmall?.copyWith(
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
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      l10n?.importResourceGroupsApplySourceLawnAppearance ??
                          'Also use this stage\'s lawn appearance',
                      style: theme.textTheme.bodyMedium,
                    ),
                    value: applyLawnAppearance,
                    onChanged: (value) {
                      setDialogState(() => applyLawnAppearance = value ?? false);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  _applySourceLawnAppearance = applyLawnAppearance;
                  Navigator.pop(ctx, true);
                },
                child: Text(l10n?.confirm ?? 'Confirm'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed != true || !mounted) return;
    widget.onImport(
      groups: toAdd,
      sourceStageAlias: option.alias,
      applySourceLawnAppearance: _applySourceLawnAppearance,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isFromStage = widget.mode == StageResourceGroupImportMode.fromStage;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          isFromStage
              ? (l10n?.importResourceGroupFromStage ?? 'Import from stage')
              : (l10n?.importResourceGroupGlobal ?? 'Import resource group'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SelectionSearchField(
              hintText: isFromStage
                  ? (l10n?.searchStage ?? 'Search stage')
                  : (l10n?.searchResourceGroup ?? 'Search resource group'),
              query: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
          Expanded(
            child: isFromStage
                ? _buildStagePicker(context, l10n, theme)
                : _buildGlobalGroupList(context, l10n, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalGroupList(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    final groups = _filteredGlobalGroups();
    if (groups.isEmpty) {
      return Center(
        child: Text(
          l10n?.noResourceGroupFound ?? 'No resource group found',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final group = groups[i];
        final label = _groupLabel(group);
        return Card(
          child: ListTile(
            title: Text(label),
            subtitle: Text(group),
            trailing: const Icon(Icons.add),
            onTap: () => widget.onImport(
              groups: [group],
              applySourceLawnAppearance: false,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStagePicker(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    final stages = _filteredStages();
    if (stages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n?.noStageFound ?? 'No stage found',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: stages.length,
      itemBuilder: (_, i) {
        final option = stages[i];
        final stageName = ResourceNames.lookup(
          context,
          _stageNameKey(option.alias),
        );
        return _CatalogStageGridItem(
          stageName: stageName,
          alias: option.alias,
          iconFileName: option.iconName,
          onTap: () => _confirmImportFromStage(option),
        );
      },
    );
  }
}

class _CatalogStageGridItem extends StatelessWidget {
  const _CatalogStageGridItem({
    required this.stageName,
    required this.alias,
    required this.iconFileName,
    required this.onTap,
  });

  final String stageName;
  final String alias;
  final String iconFileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = 'assets/images/round_icons/$iconFileName';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: AssetImageWidget(
                    assetPath: iconPath,
                    altCandidates: imageAltCandidates(iconPath),
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stageName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                alias,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
