import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/grid_item_module_prompt.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Grid item selection. Ported from Z-Editor-master GridItemSelectionScreen.kt
class GridItemSelectionScreen extends StatefulWidget {
  const GridItemSelectionScreen({
    super.key,
    required this.onGridItemSelected,
    required this.onBack,
    required this.filterMode,
    this.levelFile,
    this.onAddModule,
  });

  final void Function(String id) onGridItemSelected;
  final VoidCallback onBack;
  final GridItemFilterMode filterMode;
  final PvzLevelFile? levelFile;
  final void Function(String objClass)? onAddModule;

  @override
  State<GridItemSelectionScreen> createState() =>
      _GridItemSelectionScreenState();
}

class _GridItemSelectionScreenState extends State<GridItemSelectionScreen> {
  String _searchQuery = '';
  GridItemCategory _selectedCategory = GridItemCategory.all;

  List<GridItemInfo> get _displayList {
    final baseList = switch (widget.filterMode) {
      GridItemFilterMode.renaiStatues =>
        GridItemRepository.getRenaiStatueItems(),
      _ =>
        _selectedCategory == GridItemCategory.all
            ? GridItemRepository.getAll()
            : GridItemRepository.getByCategory(_selectedCategory),
    };

    return baseList.where((item) {
      final isModeMatched = switch (widget.filterMode) {
        GridItemFilterMode.all => true,
        GridItemFilterMode.restricted => item.tag == GridItemTag.normal,
        GridItemFilterMode.renaiStatues => true,
      };
      final nameKey = 'griditem_${item.typeName}';
      final isSearchMatched = matchesSelectionSearch(_searchQuery, [
        item.typeName,
        nameKey,
        ResourceNames.lookup(context, nameKey),
      ]);
      return isModeMatched && isSearchMatched;
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
            hintText: l10n?.searchGridItems ?? 'Search grid items',
            query: _searchQuery,
            onChanged: (v) => setState(() => _searchQuery = v),
            onClear: () => setState(() => _searchQuery = ''),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: themeColor,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: GridItemCategory.values.map((cat) {
                    return AccentBarChoiceChip(
                      label: _categoryLabel(cat, l10n),
                      selected: _selectedCategory == cat,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = cat),
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: theme.colorScheme.surface,
                child: displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.view_module,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
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
                          final crossAxisCount = _selectionGridColumnCount(
                            constraints.maxWidth,
                          );

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final item = displayList[index];
                              final displayName = ResourceNames.lookup(
                                context,
                                'griditem_${item.typeName}',
                              );
                              final name =
                                  displayName != 'griditem_${item.typeName}'
                                  ? displayName
                                  : item.typeName;
                              return _GridItemCard(
                                item: item,
                                name: name,
                                theme: theme,
                                onTap: () => _handleItemTap(item.typeName),
                              );
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleItemTap(String typeName) async {
    final levelFile = widget.levelFile;
    if (levelFile != null) {
      final proceed = await confirmGridItemModuleRequirements(
        context,
        typeName: typeName,
        levelFile: levelFile,
        onAddModule: widget.onAddModule,
      );
      if (!proceed || !mounted) return;
    }
    widget.onGridItemSelected(typeName);
  }

  String _categoryLabel(GridItemCategory cat, AppLocalizations? l10n) {
    if (l10n == null) return cat.label;
    switch (cat) {
      case GridItemCategory.all:
        return l10n.gridItemCategoryAll;
      case GridItemCategory.scene:
        return l10n.gridItemCategoryScene;
      case GridItemCategory.trap:
        return l10n.gridItemCategoryTrap;
      case GridItemCategory.spawnableObjects:
        return l10n.gridItemCategorySpawnableObjects;
    }
  }
}

int _selectionGridColumnCount(double width) {
  final columns = (width / 180).floor();
  if (columns < 2) return 2;
  if (columns > 6) return 6;
  return columns;
}

class _GridItemCard extends StatelessWidget {
  const _GridItemCard({
    required this.item,
    required this.name,
    required this.theme,
    required this.onTap,
  });

  final GridItemInfo item;
  final String name;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GridItemIcon(
                      typeName: item.typeName,
                      size: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.typeName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
