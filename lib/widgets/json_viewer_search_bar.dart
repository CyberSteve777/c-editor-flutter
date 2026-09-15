import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Android Studio–style search (and optional replace) bar for the JSON viewer.
class JsonViewerSearchBar extends StatelessWidget {
  const JsonViewerSearchBar({
    super.key,
    required this.searchController,
    required this.replaceController,
    required this.showReplace,
    required this.matchCase,
    required this.wholeWords,
    required this.useRegex,
    required this.searchHistory,
    required this.replaceHistory,
    required this.matchCount,
    required this.currentMatchIndex,
    required this.regexError,
    required this.onSearchChanged,
    required this.onReplaceChanged,
    required this.onMatchCaseChanged,
    required this.onWholeWordsChanged,
    required this.onRegexChanged,
    required this.onPreviousMatch,
    required this.onNextMatch,
    required this.onReplaceOne,
    required this.onReplaceAll,
    required this.onHistorySelected,
    required this.onReplaceHistorySelected,
    required this.onSearchSubmitted,
  });

  final TextEditingController searchController;
  final TextEditingController replaceController;
  final bool showReplace;
  final bool matchCase;
  final bool wholeWords;
  final bool useRegex;
  final List<String> searchHistory;
  final List<String> replaceHistory;
  final int matchCount;
  final int currentMatchIndex;
  final bool regexError;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onReplaceChanged;
  final ValueChanged<bool> onMatchCaseChanged;
  final ValueChanged<bool> onWholeWordsChanged;
  final ValueChanged<bool> onRegexChanged;
  final VoidCallback onPreviousMatch;
  final VoidCallback onNextMatch;
  final VoidCallback onReplaceOne;
  final VoidCallback onReplaceAll;
  final ValueChanged<String> onHistorySelected;
  final ValueChanged<String> onReplaceHistorySelected;
  final VoidCallback onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SearchRow(
              controller: searchController,
              history: searchHistory,
              matchCase: matchCase,
              wholeWords: wholeWords,
              useRegex: useRegex,
              regexError: regexError,
              matchCount: matchCount,
              currentMatchIndex: currentMatchIndex,
              onChanged: onSearchChanged,
              onHistorySelected: onHistorySelected,
              onMatchCaseChanged: onMatchCaseChanged,
              onWholeWordsChanged: onWholeWordsChanged,
              onRegexChanged: onRegexChanged,
              onPreviousMatch: onPreviousMatch,
              onNextMatch: onNextMatch,
              onSearchSubmitted: onSearchSubmitted,
              hintText: l10n?.jsonViewerSearchHint ?? 'Search',
              historyTooltip:
                  l10n?.jsonViewerSearchHistory ?? 'Recent searches',
            ),
            if (showReplace) ...[
              const SizedBox(height: 6),
              _ReplaceRow(
                controller: replaceController,
                history: replaceHistory,
                onChanged: onReplaceChanged,
                onReplaceHistorySelected: onReplaceHistorySelected,
                onReplaceOne: onReplaceOne,
                onReplaceAll: onReplaceAll,
                hintText: l10n?.jsonViewerReplaceHint ?? 'Replace',
                historyTooltip:
                    l10n?.jsonViewerReplaceHistory ?? 'Recent replacements',
                replaceOneTooltip: l10n?.jsonViewerReplaceOne ?? 'Replace',
                replaceAllTooltip: l10n?.jsonViewerReplaceAll ?? 'Replace all',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.history,
    required this.matchCase,
    required this.wholeWords,
    required this.useRegex,
    required this.regexError,
    required this.matchCount,
    required this.currentMatchIndex,
    required this.onChanged,
    required this.onHistorySelected,
    required this.onMatchCaseChanged,
    required this.onWholeWordsChanged,
    required this.onRegexChanged,
    required this.onPreviousMatch,
    required this.onNextMatch,
    required this.onSearchSubmitted,
    required this.hintText,
    required this.historyTooltip,
  });

  final TextEditingController controller;
  final List<String> history;
  final bool matchCase;
  final bool wholeWords;
  final bool useRegex;
  final bool regexError;
  final int matchCount;
  final int currentMatchIndex;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onHistorySelected;
  final ValueChanged<bool> onMatchCaseChanged;
  final ValueChanged<bool> onWholeWordsChanged;
  final ValueChanged<bool> onRegexChanged;
  final VoidCallback onPreviousMatch;
  final VoidCallback onNextMatch;
  final VoidCallback onSearchSubmitted;
  final String hintText;
  final String historyTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final borderColor = regexError
        ? theme.colorScheme.error
        : theme.dividerColor;

    return Row(
      children: [
        _HistoryMenuButton(
          tooltip: historyTooltip,
          history: history,
          onSelected: (value) {
            controller.text = value;
            controller.selection = TextSelection.collapsed(
              offset: value.length,
            );
            onChanged(value);
            onHistorySelected(value);
          },
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            onSubmitted: (_) => onSearchSubmitted(),
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                  color: regexError
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InsertNewlineButton(
                  controller: controller,
                  onChanged: onChanged,
                  tooltip: l10n?.jsonViewerInsertNewline ?? 'Insert newline',
                ),
                _SearchToggleButton(
                  label: 'Aa',
                  tooltip: l10n?.jsonViewerMatchCase ?? 'Match case',
                  selected: matchCase,
                  onPressed: () => onMatchCaseChanged(!matchCase),
                ),
                _SearchToggleButton(
                  label: 'W',
                  tooltip: l10n?.jsonViewerWholeWords ?? 'Words',
                  selected: wholeWords,
                  onPressed: () => onWholeWordsChanged(!wholeWords),
                ),
                _SearchToggleButton(
                  label: '.*',
                  tooltip: l10n?.jsonViewerRegex ?? 'Regex',
                  selected: useRegex,
                  onPressed: () => onRegexChanged(!useRegex),
                ),
                if (matchCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      l10n?.jsonViewerMatchCounter(
                            currentMatchIndex + 1,
                            matchCount,
                          ) ??
                          '${currentMatchIndex + 1}/$matchCount',
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_up),
                  tooltip: l10n?.jsonViewerPreviousMatch ?? 'Previous match',
                  onPressed: matchCount > 0 ? onPreviousMatch : null,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down),
                  tooltip: l10n?.jsonViewerNextMatch ?? 'Next match',
                  onPressed: matchCount > 0 ? onNextMatch : null,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReplaceRow extends StatelessWidget {
  const _ReplaceRow({
    required this.controller,
    required this.history,
    required this.onChanged,
    required this.onReplaceHistorySelected,
    required this.onReplaceOne,
    required this.onReplaceAll,
    required this.hintText,
    required this.historyTooltip,
    required this.replaceOneTooltip,
    required this.replaceAllTooltip,
  });

  final TextEditingController controller;
  final List<String> history;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onReplaceHistorySelected;
  final VoidCallback onReplaceOne;
  final VoidCallback onReplaceAll;
  final String hintText;
  final String historyTooltip;
  final String replaceOneTooltip;
  final String replaceAllTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _HistoryMenuButton(
          tooltip: historyTooltip,
          history: history,
          onSelected: (value) {
            controller.text = value;
            controller.selection = TextSelection.collapsed(
              offset: value.length,
            );
            onChanged(value);
            onReplaceHistorySelected(value);
          },
        ),
        const SizedBox(width: 4),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InsertNewlineButton(
                  controller: controller,
                  onChanged: onChanged,
                  tooltip:
                      AppLocalizations.of(context)?.jsonViewerInsertNewline ??
                      'Insert newline',
                ),
                IconButton(
                  icon: const Icon(Icons.find_replace),
                  tooltip: replaceOneTooltip,
                  onPressed: onReplaceOne,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.layers),
                  tooltip: replaceAllTooltip,
                  onPressed: onReplaceAll,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryMenuButton extends StatelessWidget {
  const _HistoryMenuButton({
    required this.tooltip,
    required this.history,
    required this.onSelected,
  });

  final String tooltip;
  final List<String> history;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: tooltip,
      enabled: history.isNotEmpty,
      padding: EdgeInsets.zero,
      offset: const Offset(0, 36),
      itemBuilder: (context) {
        return history
            .map(
              (entry) => PopupMenuItem<String>(
                value: entry,
                child: Text(
                  entry.replaceAll('\n', '↵'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList();
      },
      onSelected: onSelected,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: history.isEmpty
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: history.isEmpty
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsertNewlineButton extends StatelessWidget {
  const _InsertNewlineButton({
    required this.controller,
    required this.onChanged,
    required this.tooltip,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.subdirectory_arrow_left),
      onPressed: () {
        final text = controller.text;
        final sel = controller.selection;
        final start = sel.start >= 0 ? sel.start : text.length;
        final end = sel.end >= 0 ? sel.end : text.length;
        final next = text.replaceRange(start, end, '\n');
        controller.text = next;
        controller.selection = TextSelection.collapsed(offset: start + 1);
        onChanged(next);
      },
    );
  }
}

class _SearchToggleButton extends StatelessWidget {
  const _SearchToggleButton({
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primaryContainer
        : Colors.transparent;
    final fg = selected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

/// Font size picker shown in the app bar (Tt + dropdown).
class JsonViewerFontSizeButton extends StatelessWidget {
  const JsonViewerFontSizeButton({
    super.key,
    required this.currentSize,
    required this.sizes,
    required this.onSelected,
    required this.tooltip,
  });

  final double currentSize;
  final List<int> sizes;
  final ValueChanged<double> onSelected;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeLabel = '${currentSize.round()}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Tt',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<double>(
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            offset: const Offset(0, 36),
            onSelected: onSelected,
            itemBuilder: (context) {
              return sizes
                  .map(
                    (size) => CheckedPopupMenuItem<double>(
                      value: size.toDouble(),
                      checked: currentSize.round() == size,
                      child: Text('$size', style: theme.textTheme.bodyMedium),
                    ),
                  )
                  .toList();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sizeLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
