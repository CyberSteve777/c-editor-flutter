import 'package:flutter/material.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

class NarrativeSearchResults {
  const NarrativeSearchResults({
    required this.byTitle,
    required this.byContent,
    required this.bySpeaker,
  });

  final List<NarrativeEntry> byTitle;
  final List<NarrativeEntry> byContent;
  final List<NarrativeEntry> bySpeaker;

  bool get isEmpty => byTitle.isEmpty && byContent.isEmpty && bySpeaker.isEmpty;
}

NarrativeSearchResults searchNarratives(
  NarrativeCatalog catalog,
  NarrativeCategory category,
  String query,
) {
  final normalized = query.trim().toLowerCase();
  final entries = catalog.forCategory(category);
  if (normalized.isEmpty) {
    return NarrativeSearchResults(
      byTitle: entries,
      byContent: const [],
      bySpeaker: const [],
    );
  }

  bool contains(Iterable<String> values) =>
      values.any((value) => value.toLowerCase().contains(normalized));

  return NarrativeSearchResults(
    byTitle: entries
        .where((entry) => contains([entry.title, entry.id, entry.groupId]))
        .toList(growable: false),
    byContent: entries
        .where((entry) => contains(entry.dialogueText))
        .toList(growable: false),
    bySpeaker: entries
        .where(
          (entry) => contains([...entry.speakerNames, ...entry.characters]),
        )
        .toList(growable: false),
  );
}

class NarrativeSelectionScreen extends StatefulWidget {
  const NarrativeSelectionScreen({
    super.key,
    required this.currentValue,
    required this.onSelected,
    required this.catalog,
  });

  final Object? currentValue;
  final ValueChanged<Object?> onSelected;
  final NarrativeCatalog catalog;

  @override
  State<NarrativeSelectionScreen> createState() =>
      _NarrativeSelectionScreenState();
}

class _NarrativeSelectionScreenState extends State<NarrativeSelectionScreen> {
  NarrativeCategory _category = NarrativeCategory.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final catalog = widget.catalog;
    final strings = catalog.strings;
    final results = searchNarratives(catalog, _category, _query);
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
        title: Text(strings.selectTitle),
      ),
      body: Column(
        children: [
          Material(
            color:
                Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SelectionSearchField(
                    hintText: strings.searchHint,
                    query: _query,
                    onChanged: (value) => setState(() => _query = value),
                    onClear: () => setState(() => _query = ''),
                  ),
                ),
                HorizontalTagScroller(
                  onAccentBar: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  children: [
                    for (final category in NarrativeCategory.values)
                      AccentBarChoiceChip(
                        label: strings.categoryLabel(category),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: searching
                ? _NarrativeSearchResultList(
                    catalog: catalog,
                    results: results,
                    currentValue: widget.currentValue,
                    onSelected: widget.onSelected,
                  )
                : _NarrativeFlatList(
                    catalog: catalog,
                    entries: results.byTitle,
                    currentValue: widget.currentValue,
                    onSelected: widget.onSelected,
                  ),
          ),
        ],
      ),
    );
  }
}

class _NarrativeFlatList extends StatelessWidget {
  const _NarrativeFlatList({
    required this.catalog,
    required this.entries,
    required this.currentValue,
    required this.onSelected,
  });

  final NarrativeCatalog catalog;
  final List<NarrativeEntry> entries;
  final Object? currentValue;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _NoNarrativeCard(
            label: catalog.strings.noDialogue,
            selected: currentValue == null,
            onTap: () => onSelected(null),
          );
        }
        final entry = entries[index - 1];
        return _NarrativeCard(
          catalog: catalog,
          entry: entry,
          selected: currentValue?.toString() == entry.valueKey,
          onSelected: onSelected,
        );
      },
    );
  }
}

class _NarrativeSearchResultList extends StatelessWidget {
  const _NarrativeSearchResultList({
    required this.catalog,
    required this.results,
    required this.currentValue,
    required this.onSelected,
  });

  final NarrativeCatalog catalog;
  final NarrativeSearchResults results;
  final Object? currentValue;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            catalog.strings.noResults,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _NarrativeSearchGroup(
          label: catalog.strings.searchGroupLabel(
            'searchByTitle',
            results.byTitle.length,
          ),
          entries: results.byTitle,
          catalog: catalog,
          currentValue: currentValue,
          onSelected: onSelected,
        ),
        _NarrativeSearchGroup(
          label: catalog.strings.searchGroupLabel(
            'searchByContent',
            results.byContent.length,
          ),
          entries: results.byContent,
          catalog: catalog,
          currentValue: currentValue,
          onSelected: onSelected,
        ),
        _NarrativeSearchGroup(
          label: catalog.strings.searchGroupLabel(
            'searchBySpeaker',
            results.bySpeaker.length,
          ),
          entries: results.bySpeaker,
          catalog: catalog,
          currentValue: currentValue,
          onSelected: onSelected,
        ),
      ],
    );
  }
}

class _NarrativeSearchGroup extends StatelessWidget {
  const _NarrativeSearchGroup({
    required this.label,
    required this.entries,
    required this.catalog,
    required this.currentValue,
    required this.onSelected,
  });

  final String label;
  final List<NarrativeEntry> entries;
  final NarrativeCatalog catalog;
  final Object? currentValue;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      key: PageStorageKey('narrative-search-$label'),
      initiallyExpanded: true,
      controlAffinity: ListTileControlAffinity.leading,
      tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      childrenPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      children: [
        for (final entry in entries)
          _NarrativeCard(
            catalog: catalog,
            entry: entry,
            selected: currentValue?.toString() == entry.valueKey,
            onSelected: onSelected,
          ),
      ],
    );
  }
}

class _NoNarrativeCard extends StatelessWidget {
  const _NoNarrativeCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: _cardShape(theme, selected),
      color: selected
          ? theme.colorScheme.primary.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.block),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({
    required this.catalog,
    required this.entry,
    required this.selected,
    required this.onSelected,
  });

  final NarrativeCatalog catalog;
  final NarrativeEntry entry;
  final bool selected;
  final ValueChanged<Object?> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: entry.selectable ? 1 : 0.6,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: _cardShape(theme, selected),
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : null,
        child: InkWell(
          onTap: entry.selectable ? () => onSelected(entry.value) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AssetImageWidget(
                    assetPath: entry.iconAsset,
                    altCandidates: imageAltCandidates(entry.iconAsset),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        entry.id,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!entry.selectable)
                  Tooltip(
                    message: catalog.strings.unavailableDialogue,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: catalog.strings.detailsTitle,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (previewContext) => NarrativePreviewScreen(
                        catalog: catalog,
                        dialogue: entry,
                        onSelect: entry.selectable
                            ? () {
                                Navigator.of(previewContext).pop();
                                onSelected(entry.value);
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ShapeBorder _cardShape(ThemeData theme, bool selected) {
  return RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: selected
          ? theme.colorScheme.primary
          : theme.dividerColor.withValues(alpha: 0.3),
      width: selected ? 2 : 1,
    ),
  );
}
