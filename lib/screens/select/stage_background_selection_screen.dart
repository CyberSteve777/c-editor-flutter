import 'package:flutter/material.dart';
import 'package:c_editor/data/models/stage_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/animated_extended_fab.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Picker for [BackgroundImagePrefix] based on imported DelayLoad groups.
class StageBackgroundSelectionScreen extends StatefulWidget {
  const StageBackgroundSelectionScreen({
    super.key,
    required this.optionsBuilder,
    required this.currentImagePrefix,
    required this.onSelected,
    required this.onBack,
    this.onImportFromStage,
  });

  final List<StageBackgroundOption> Function() optionsBuilder;
  final String currentImagePrefix;
  final void Function(StageBackgroundOption option) onSelected;
  final VoidCallback onBack;
  final Future<bool> Function()? onImportFromStage;

  @override
  State<StageBackgroundSelectionScreen> createState() =>
      _StageBackgroundSelectionScreenState();
}

class _StageBackgroundSelectionScreenState
    extends State<StageBackgroundSelectionScreen> {
  String _searchQuery = '';
  final ScrollController _listScrollController = ScrollController();
  bool _listScrollAtTop = true;

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onListScroll);
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
    super.dispose();
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    final atTop = _listScrollController.offset <= 0;
    if (atTop != _listScrollAtTop && mounted) {
      setState(() => _listScrollAtTop = atTop);
    }
  }

  Future<void> _handleImportFromStage() async {
    if (widget.onImportFromStage == null) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.stageBackgroundNeedMorePromptTitle ??
              'Need another lawn appearance?',
        ),
        content: Text(
          l10n?.stageBackgroundNeedMorePromptMessage ??
              'Import resource groups from another stage to unlock more lawn appearances here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final imported = await widget.onImportFromStage!.call();
    if (!mounted) return;
    if (!imported) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var items = widget.optionsBuilder();
    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = items.where((option) {
        final name = ResourceNames.lookup(context, option.nameKey);
        return matchesSelectionSearch(_searchQuery, [
          option.imagePrefix,
          option.delayLoadGroup,
          option.nameKey,
          name,
        ]);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.selectStageBackground ?? 'Select lawn appearance'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SelectionSearchField(
              hintText: l10n?.searchStageBackground ?? 'Search lawn',
              query: _searchQuery,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClear: () => setState(() => _searchQuery = ''),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          items.isEmpty
              ? Center(
                  child: Text(
                    l10n?.noStageBackgroundFound ?? 'No lawn appearance found',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : GridView.builder(
                  controller: _listScrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final option = items[i];
                    final isSelected =
                        option.imagePrefix == widget.currentImagePrefix;
                    final displayName = option.nameKey.isEmpty
                        ? option.imagePrefix
                        : ResourceNames.lookup(context, option.nameKey);
                    final iconPath =
                        'assets/images/round_icons/${option.image}';
                    return Card(
                      color: isSelected
                          ? theme.colorScheme.primaryContainer
                          : null,
                      child: InkWell(
                        onTap: () => widget.onSelected(option),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: AssetImageWidget(
                                    assetPath: iconPath,
                                    altCandidates: imageAltCandidates(iconPath),
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
          if (widget.onImportFromStage != null)
            Positioned(
              right: 16,
              bottom: 16,
              child: AnimatedExtendedFab(
                visible: _listScrollAtTop,
                heroTag: 'stageBackgroundAddAnother',
                onPressed: _handleImportFromStage,
                icon: Icons.add_circle_outline,
                label:
                    l10n?.stageBackgroundAddFromStage ??
                    'Add another lawn appearance',
              ),
            ),
        ],
      ),
    );
  }
}
