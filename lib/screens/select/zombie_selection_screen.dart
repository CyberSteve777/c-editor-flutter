import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/kongfu_rocket_flick_prompt.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart'
    show
        AccentBarFilterTabRow,
        AccentBarTabBarStyle,
        ScrollableWithMouseDrag,
        SelectionSearchField;

/// Placeholder when a zombie has no icon or icon fails to load.
const String _kUnknownIconPath = 'assets/images/others/unknown.webp';
const String _kStayTunedZombieId = 'stay_tuned';

enum _ZombieBlockedReason {
  stayTunedMoon,
  stayTunedTaleZCorp,
  stayTunedFallback,
}

/// Zombie selection. Ported from Z-Editor-master ZombieSelectionScreen.kt
class ZombieSelectionScreen extends StatefulWidget {
  const ZombieSelectionScreen({
    super.key,
    this.multiSelect = false,
    required this.onZombieSelected,
    this.onMultiZombieSelected,
    required this.onBack,
    this.editorCubit,
    this.excludeIds = const [],
    this.initialSelectedIds = const [],
    this.allowDuplicateSelection = false,
  });

  final bool multiSelect;
  final void Function(String) onZombieSelected;
  final void Function(List<String>)? onMultiZombieSelected;
  final VoidCallback onBack;

  /// When set (e.g. from the level editor), enables Kongfu rocket → flick module prompt.
  final EditorCubit? editorCubit;

  /// IDs hidden from the grid (e.g. entries in a conflicting list).
  final List<String> excludeIds;

  /// When unique multi-select is used, these IDs start selected (already in the parent list).
  final List<String> initialSelectedIds;

  /// When true, each tap adds another entry (batch append mode).
  final bool allowDuplicateSelection;

  @override
  State<ZombieSelectionScreen> createState() => _ZombieSelectionScreenState();
}

class _ZombieSelectionScreenState extends State<ZombieSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  final List<String> _selectedIdsWithDuplicates = [];
  bool _isLoaded = false;
  ZombieCategory _selectedCategory = ZombieCategory.main;
  ZombieTag _selectedTag = ZombieTag.all;

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect &&
        !widget.allowDuplicateSelection &&
        widget.initialSelectedIds.isNotEmpty) {
      _selectedIds.addAll(widget.initialSelectedIds);
    }
    ZombieRepository().init().then((_) {
      if (mounted) {
        setState(() {
          _removeBlockedSelections();
          _isLoaded = true;
        });
      }
    });
  }

  int get _selectedCount => widget.allowDuplicateSelection
      ? _selectedIdsWithDuplicates.length
      : _selectedIds.length;

  List<ZombieTag> _visibleTagsFor(ZombieCategory category) {
    if (category == ZombieCategory.collection) return [];
    if (category == ZombieCategory.other) {
      return const [
        ZombieTag.all,
        ZombieTag.evildave,
        ZombieTag.custom,
        ZombieTag.expedition,
        ZombieTag.chinese,
        ZombieTag.international,
      ];
    }
    return [
      ZombieTag.all,
      ...ZombieTag.values.where(
        (t) => t != ZombieTag.all && t.category == category,
      ),
    ];
  }

  void _setCategory(ZombieCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      final tags = _visibleTagsFor(category);
      _selectedTag = tags.isNotEmpty ? tags.first : ZombieTag.all;
    });
  }

  void _toggleFavorite(BuildContext context, String id) async {
    await ZombieRepository().toggleFavorite(id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final isFav = ZombieRepository().isFavorite(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFav
              ? (l10n?.addedToFavorites ?? 'Added to favorites')
              : (l10n?.removedFromFavorites ?? 'Removed from favorites'),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
    setState(() {});
  }

  _ZombieBlockedReason? _zombieBlockedReason(ZombieInfo zombie) {
    if (zombie.id != _kStayTunedZombieId) return null;
    final hasMoon = zombie.tags.contains(ZombieTag.moon);
    final hasTaleZCorp = zombie.tags.contains(ZombieTag.taleZCorp);
    // The shared stay_tuned entry uses generic copy on the all-zombies tab.
    if (hasMoon && _selectedTag == ZombieTag.moon) {
      return _ZombieBlockedReason.stayTunedMoon;
    }
    if (hasTaleZCorp && _selectedTag == ZombieTag.taleZCorp) {
      return _ZombieBlockedReason.stayTunedTaleZCorp;
    }
    return _ZombieBlockedReason.stayTunedFallback;
  }

  _ZombieBlockedReason? _zombieBlockedReasonForId(String id) {
    if (id != _kStayTunedZombieId) return null;
    final zombie = ZombieRepository().getZombieById(id);
    if (zombie == null) return _ZombieBlockedReason.stayTunedFallback;
    return _zombieBlockedReason(zombie);
  }

  void _removeBlockedSelections() {
    bool isBlocked(String id) => _zombieBlockedReasonForId(id) != null;
    _selectedIds.removeWhere(isBlocked);
    _selectedIdsWithDuplicates.removeWhere(isBlocked);
  }

  List<String> _filterSelectableZombieIds(List<String> ids) {
    return ids.where((id) => _zombieBlockedReasonForId(id) == null).toList();
  }

  Future<void> _showZombieBlockedDialog(
    BuildContext context,
    _ZombieBlockedReason reason,
  ) async {
    final l10n = AppLocalizations.of(context);
    final (title, message) = switch (reason) {
      _ZombieBlockedReason.stayTunedMoon => (
        l10n?.stayTunedMoonZombieBlockedTitle ?? 'A Message from Space',
        l10n?.stayTunedMoonZombieBlockedMessage ??
            'The brand-new world, Moon Base, is coming in the '
                'not-too-distant future. Stay tuned!',
      ),
      _ZombieBlockedReason.stayTunedTaleZCorp => (
        l10n?.stayTunedTaleZCorpZombieBlockedTitle ?? 'To be continued',
        l10n?.stayTunedTaleZCorpZombieBlockedMessage ??
            'ZCorp Chapter Two is coming soon. Stay tuned!',
      ),
      _ZombieBlockedReason.stayTunedFallback => (
        l10n?.stayTunedZombieBlockedTitle ?? 'To be continued',
        l10n?.stayTunedZombieBlockedMessage ??
            'This content is not officially available yet. Stay tuned for '
                'future updates!',
      ),
    };
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  List<ZombieInfo> _categoryFilteredZombies(ZombieRepository repo) {
    if (!repo.isLoaded) return [];
    if (_selectedCategory == ZombieCategory.collection) {
      return repo.allZombies
          .where((z) => repo.favoriteIds.contains(z.id))
          .toList();
    }
    if (_selectedTag != ZombieTag.all) {
      return repo.allZombies
          .where((z) => z.tags.contains(_selectedTag))
          .toList();
    }
    return repo.allZombies;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final repositoryZombies = repo.search(
      _searchQuery,
      _selectedCategory == ZombieCategory.collection ? null : _selectedTag,
      _selectedCategory,
    );
    final allZombies = _searchQuery.trim().isEmpty
        ? repositoryZombies
        : mergeUniqueSelectionResults(
            repositoryZombies,
            _categoryFilteredZombies(repo).where(
              (zombie) => matchesSelectionSearch(_searchQuery, [
                ResourceNames.lookup(context, zombie.name),
              ]),
            ),
            (zombie) => zombie.id,
          );
    final excludeSet = widget.excludeIds.toSet();
    final zombies = excludeSet.isEmpty
        ? allZombies
        : allZombies.where((z) => !excludeSet.contains(z.id)).toList();
    final visibleTags = _visibleTagsFor(_selectedCategory);
    final tagIndex = visibleTags.indexOf(_selectedTag);
    final safeTagIndex = tagIndex < 0 ? 0 : tagIndex;
    if (_selectedCategory != ZombieCategory.collection &&
        !visibleTags.contains(_selectedTag)) {
      _selectedTag = visibleTags.first;
    }
    final themeColor = theme.brightness == Brightness.dark
        ? pvzPurpleDark
        : pvzPurpleLight;
    final filterMaxHeight = MediaQuery.sizeOf(context).height * 0.42;
    final tabColors = AccentBarTabBarStyle.colors(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.selectZombie ?? 'Select zombie'),
      ),
      floatingActionButton: widget.multiSelect
          ? FloatingActionButton(
              backgroundColor: themeColor,
              foregroundColor: theme.colorScheme.surface,
              onPressed: _isLoaded
                  ? () async {
                      final ids = _filterSelectableZombieIds(
                        widget.allowDuplicateSelection
                            ? List<String>.from(_selectedIdsWithDuplicates)
                            : _selectedIds.toList(),
                      );
                      await maybeShowKongfuRocketFlickPrompt(
                        context,
                        ids,
                        editorCubit: widget.editorCubit,
                      );
                      if (!context.mounted) return;
                      widget.onMultiZombieSelected?.call(ids);
                    }
                  : null,
              child: const Icon(Icons.check),
            )
          : null,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: themeColor,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: filterMaxHeight),
              child: ScrollableWithMouseDrag(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: SelectionSearchField(
                          hintText: widget.multiSelect
                              ? (l10n?.selectedCountTapToSearch(
                                      _selectedCount,
                                    ) ??
                                    'Selected $_selectedCount, tap to search')
                              : (l10n?.searchZombie ?? 'Search zombie'),
                          query: _searchQuery,
                          fillColor: theme.colorScheme.surface,
                          onChanged: (v) => setState(() => _searchQuery = v),
                          onClear: () => setState(() => _searchQuery = ''),
                        ),
                      ),
                      DefaultTabController(
                        key: ValueKey(_selectedCategory),
                        length: ZombieCategory.values.length,
                        initialIndex: ZombieCategory.values.indexOf(
                          _selectedCategory,
                        ),
                        child: TabBar(
                          isScrollable: true,
                          indicatorColor: tabColors.indicator,
                          labelColor: tabColors.label,
                          unselectedLabelColor: tabColors.unselectedLabel,
                          onTap: (index) =>
                              _setCategory(ZombieCategory.values[index]),
                          tabs: ZombieCategory.values.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Tab(
                              child: Row(
                                children: [
                                  if (category ==
                                      ZombieCategory.collection) ...[
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: isSelected
                                          ? tabColors.label
                                          : tabColors.unselectedLabel,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    category.getLabel(context),
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      if (_selectedCategory != ZombieCategory.collection)
                        AccentBarFilterTabRow(
                          key: ValueKey('${_selectedCategory.name}_tags'),
                          selectedIndex: safeTagIndex,
                          onSelected: (index) =>
                              setState(() => _selectedTag = visibleTags[index]),
                          tabs: visibleTags.map((tag) {
                            final iconPath = tag.iconAssetPath;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (iconPath != null) ...[
                                  AssetImageWidget(
                                    assetPath: iconPath,
                                    width: 18,
                                    height: 18,
                                    altCandidates: imageAltCandidates(iconPath),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(tag.getLabel(context)),
                              ],
                            );
                          }).toList(),
                        )
                      else
                        const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: !_isLoaded
                ? const Center(child: CircularProgressIndicator())
                : zombies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == ZombieCategory.collection
                              ? (l10n?.noFavoritesLongPress ??
                                    'No favorites. Long-press to favorite.')
                              : (l10n?.noZombieFound ?? 'No zombie found'),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 72,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: zombies.length,
                    itemBuilder: (_, i) {
                      final zombie = zombies[i];
                      final selectionCount = widget.allowDuplicateSelection
                          ? _selectedIdsWithDuplicates
                                .where((id) => id == zombie.id)
                                .length
                          : (_selectedIds.contains(zombie.id) ? 1 : 0);
                      final isSelected = selectionCount > 0;
                      final isFavorite = repo.isFavorite(zombie.id);
                      final blockedReason = _zombieBlockedReason(zombie);
                      final isEnabled = blockedReason == null;
                      return _ZombieGridItem(
                        zombie: zombie,
                        isSelected: isSelected,
                        isFavorite: isFavorite,
                        isEnabled: isEnabled,
                        selectionColor: widget.multiSelect ? themeColor : null,
                        onTap: () async {
                          if (blockedReason != null) {
                            await _showZombieBlockedDialog(
                              context,
                              blockedReason,
                            );
                            return;
                          }
                          if (widget.multiSelect) {
                            setState(() {
                              if (widget.allowDuplicateSelection) {
                                _selectedIdsWithDuplicates.add(zombie.id);
                              } else if (isSelected) {
                                _selectedIds.remove(zombie.id);
                              } else {
                                _selectedIds.add(zombie.id);
                              }
                            });
                          } else {
                            await maybeShowKongfuRocketFlickPrompt(context, [
                              zombie.id,
                            ], editorCubit: widget.editorCubit);
                            if (!context.mounted) return;
                            widget.onZombieSelected(zombie.id);
                          }
                        },
                        onLongPress: () => _toggleFavorite(context, zombie.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ZombieGridItem extends StatelessWidget {
  const _ZombieGridItem({
    required this.zombie,
    required this.isSelected,
    required this.isFavorite,
    required this.isEnabled,
    required this.onTap,
    required this.onLongPress,
    this.selectionColor,
  });

  final ZombieInfo zombie;
  final bool isSelected;
  final bool isFavorite;
  final bool isEnabled;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = zombie.iconAssetPath;
    final hasIcon = iconPath != null && iconPath.isNotEmpty;

    final accent = selectionColor ?? theme.colorScheme.primary;
    final borderColor = isSelected ? accent : Colors.transparent;
    final bgColor = isSelected
        ? accent.withValues(alpha: 0.08)
        : Colors.transparent;
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: isSelected ? 2 : 0),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: hasIcon
                            ? AssetImageWidget(
                                assetPath: iconPath,
                                altCandidates: imageAltCandidates(iconPath),
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorWidget: Image.asset(
                                  _kUnknownIconPath,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                _kUnknownIconPath,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (isFavorite)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFC107),
                              width: 0.5,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  ResourceNames.lookup(context, zombie.name),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  zombie.id,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 8,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
