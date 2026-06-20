import 'package:flutter/material.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart' show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Full-screen stage selection. Ported from Z-Editor-master StageSelectionScreen.kt
class StageSelectionScreen extends StatefulWidget {
  const StageSelectionScreen({
    super.key,
    required this.currentStageRtid,
    required this.onStageSelected,
    required this.onBack,
  });

  final String currentStageRtid;
  final void Function(String) onStageSelected;
  final VoidCallback onBack;

  @override
  State<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends State<StageSelectionScreen> {
  StageType _selectedType = StageType.all;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentAlias = RtidParser.parse(widget.currentStageRtid)?.alias ?? '';
    var items = StageRepository.getByType(_selectedType);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      items = items.where((s) {
        final name = ResourceNames.lookup(context, StageRepository.getName(s.alias));
        return name.toLowerCase().contains(q) || s.alias.toLowerCase().contains(q);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        title: Text(l10n?.selectStage ?? 'Select stage'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SelectionSearchField(
                  hintText: l10n?.searchStage ?? 'Search stage',
                  query: _searchQuery,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: StageType.values.map((t) {
                    return AccentBarChoiceChip(
                      label: _typeLabel(t, l10n),
                      selected: _selectedType == t,
                      onSelected: (_) => setState(() => _selectedType = t),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: items.isEmpty
          ? Center(
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
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final stage = items[i];
                final isSelected = stage.alias == currentAlias;
                return _StageGridItem(
                  stage: stage,
                  stageName: ResourceNames.lookup(context, StageRepository.getName(stage.alias)),
                  isSelected: isSelected,
                  onTap: () {
                    widget.onStageSelected(RtidParser.build(stage.alias, 'LevelModules'));
                  },
                );
              },
            ),
    );
  }

  String _typeLabel(StageType t, AppLocalizations? l10n) {
    switch (t) {
      case StageType.all: return l10n?.stageTypeAll ?? 'All';
      case StageType.main: return l10n?.stageTypeMain ?? 'Main';
      case StageType.extra: return l10n?.stageTypeExtra ?? 'Extra';
      case StageType.seasons: return l10n?.stageTypeSeasons ?? 'Seasons';
      case StageType.special: return l10n?.stageTypeSpecial ?? 'Special';
    }
  }
}

class _StageGridItem extends StatelessWidget {
  const _StageGridItem({
    required this.stage,
    required this.stageName,
    required this.isSelected,
    required this.onTap,
  });

  final StageItem stage;
  final String stageName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
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
                  child: stage.iconName != null
                      ? AssetImageWidget(
                          assetPath: 'assets/images/round_icons/${stage.iconName!}',
                          altCandidates: imageAltCandidates('assets/images/round_icons/${stage.iconName!}'),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                      : const AssetImageWidget(
                          assetPath: 'assets/images/others/unknown.webp',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stageName,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stage.alias,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
