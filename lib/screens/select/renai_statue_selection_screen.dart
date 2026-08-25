import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Dedicated statue selection for Renai module. Shows all Renai statue types.
class RenaiStatueSelectionScreen extends StatefulWidget {
  const RenaiStatueSelectionScreen({
    super.key,
    required this.onStatueSelected,
    required this.onBack,
    this.stateBucketId,
  });

  final void Function(String typeName) onStatueSelected;
  final VoidCallback onBack;
  final String? stateBucketId;

  @override
  State<RenaiStatueSelectionScreen> createState() =>
      _RenaiStatueSelectionScreenState();
}

class _RenaiStatueSelectionScreenState
    extends State<RenaiStatueSelectionScreen> {
  String _searchQuery = '';
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final bucket = widget.stateBucketId?.isNotEmpty == true
        ? widget.stateBucketId!
        : 'global';
    _memory = SelectionViewMemoryStore.forKey('$bucket:renai-statue');
    _searchQuery = _memory.query;
    _scrollController = ScrollController(
      initialScrollOffset: _memory.scrollOffset,
    )..addListener(_rememberScrollOffset);
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _scrollController.dispose();
    super.dispose();
  }

  void _rememberScrollOffset() {
    if (_scrollController.hasClients) {
      _memory.scrollOffset = _scrollController.offset;
    }
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _memory
      ..query = query
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  List<GridItemInfo> get _displayList {
    return GridItemRepository.getRenaiStatueItems().where((item) {
      final nameKey = 'griditem_${item.typeName}';
      return matchesSelectionSearch(_searchQuery, [
        item.typeName,
        nameKey,
        ResourceNames.lookup(context, nameKey),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeColor = isDark ? pvzBrownDark : pvzBrownLight;
    final displayList = _displayList;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          title: AppBarSearchField(
            hintText: l10n?.searchStatues ?? 'Search statues',
            query: _searchQuery,
            onChanged: _setSearchQuery,
            onClear: () => _setSearchQuery(''),
          ),
        ),
        body: displayList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.view_module,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.noItems ?? 'No items',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      RenaiStatueCardLayout.selectionCrossAxisCount(
                        constraints.maxWidth,
                      );
                  const spacing = 12.0;
                  const padding = 16.0;
                  final cellWidth =
                      (constraints.maxWidth -
                          padding * 2 -
                          spacing * (crossAxisCount - 1)) /
                      crossAxisCount;
                  final iconSize = RenaiStatueCardLayout.selectionIconSize(
                    cellWidth,
                  );

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(padding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio:
                          RenaiStatueCardLayout.selectionChildAspectRatio(
                            constraints.maxWidth,
                          ),
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final displayName = ResourceNames.lookup(
                        context,
                        'griditem_${item.typeName}',
                      );
                      final name = displayName != 'griditem_${item.typeName}'
                          ? displayName
                          : item.typeName;
                      return _RenaiStatueCard(
                        item: item,
                        name: name,
                        iconSize: iconSize,
                        theme: theme,
                        onTap: () => widget.onStatueSelected(item.typeName),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _RenaiStatueCard extends StatelessWidget {
  const _RenaiStatueCard({
    required this.item,
    required this.name,
    required this.iconSize,
    required this.theme,
    required this.onTap,
  });

  final GridItemInfo item;
  final String name;
  final double iconSize;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: GridItemIcon(
                    typeName: item.typeName,
                    size: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.typeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
