import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

class _ModuleSelectionViewState {
  _ModuleSelectionViewState({this.selectedCategory, this.scrollOffset = 0});

  ModuleCategory? selectedCategory;
  double scrollOffset;
}

final Map<String, _ModuleSelectionViewState> _moduleSelectionViewStates = {};

/// Module selection. Ported from Z-Editor-master ModuleSelectionScreen.kt
class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({
    super.key,
    required this.existingObjClasses,
    this.stateBucketId,
  });

  final Set<String> existingObjClasses;
  final String? stateBucketId;

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  String _searchQuery = '';
  ModuleCategory? _selectedCategory;
  late final ScrollController _listScrollController;

  String get _viewStateKey => widget.stateBucketId?.isNotEmpty == true
      ? widget.stateBucketId!
      : 'global';

  bool get _canRememberScroll => _searchQuery.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final remembered = _moduleSelectionViewStates[_viewStateKey];
    _selectedCategory = remembered?.selectedCategory;
    _listScrollController = ScrollController(
      initialScrollOffset: remembered?.scrollOffset ?? 0,
    )..addListener(_rememberViewState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberViewState();
    _listScrollController.removeListener(_rememberViewState);
    _listScrollController.dispose();
    super.dispose();
  }

  void _rememberViewState() {
    if (!_canRememberScroll || !_listScrollController.hasClients) return;
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = _selectedCategory
      ..scrollOffset = _listScrollController.offset;
  }

  void _restoreRememberedScrollOffset() {
    if (!mounted || !_listScrollController.hasClients) return;
    final remembered = _moduleSelectionViewStates[_viewStateKey];
    if (remembered == null) return;
    final position = _listScrollController.position;
    final target = remembered.scrollOffset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_listScrollController.offset != target) {
      _listScrollController.jumpTo(target);
    }
  }

  void _selectCategory(ModuleCategory? category) {
    if (_selectedCategory == category) return;
    setState(() => _selectedCategory = category);
    final state = _moduleSelectionViewStates.putIfAbsent(
      _viewStateKey,
      _ModuleSelectionViewState.new,
    );
    state
      ..selectedCategory = category
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allModules = ModuleRegistry.getAllModules();

    final filteredModules = allModules.where((meta) {
      final categoryMatch =
          _selectedCategory == null || meta.category == _selectedCategory;
      final searchMatch = matchesSelectionSearch(_searchQuery, [
        meta.getTitle(context),
        meta.getDescription(context),
        meta.defaultAlias,
        meta.objClass,
        meta.titleKey,
        meta.descriptionKey,
        meta.routeId,
      ]);
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n?.addNewModule ?? 'Add module'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SelectionSearchField(
                  hintText: l10n?.search ?? 'Search',
                  query: _searchQuery,
                  onChanged: _setSearchQuery,
                  onClear: () => _setSearchQuery(''),
                ),
              ),
              HorizontalTagScroller(
                onAccentBar: true,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                children: [
                  AccentBarChoiceChip(
                    key: const ValueKey('moduleCategory_all'),
                    label: l10n?.stageTypeAll ?? 'All',
                    selected: _selectedCategory == null,
                    onSelected: (_) => _selectCategory(null),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  ...ModuleCategory.values.map((cat) {
                    return AccentBarChoiceChip(
                      key: ValueKey('moduleCategory_${cat.name}'),
                      label: _categoryLabel(cat, l10n),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => _selectCategory(cat),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      body: filteredModules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? (l10n?.noResultsFor(_searchQuery) ??
                              'No results for "$_searchQuery"')
                        : (l10n?.noModulesInCategory ??
                              'No modules in this category'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              key: const ValueKey('moduleSelectionList'),
              controller: _listScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: filteredModules.length,
              itemBuilder: (context, index) {
                final meta = filteredModules[index];
                final isAlreadyAdded = widget.existingObjClasses.contains(
                  meta.selectionKey,
                );
                final isEnabled = !isAlreadyAdded || meta.allowMultiple;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ModuleSelectionCard(
                    meta: meta,
                    isAlreadyAdded: isAlreadyAdded,
                    isEnabled: isEnabled,
                    onTap: () {
                      if (isEnabled) Navigator.pop(context, meta);
                    },
                  ),
                );
              },
            ),
    );
  }

  String _categoryLabel(ModuleCategory cat, AppLocalizations? l10n) {
    if (l10n == null) {
      switch (cat) {
        case ModuleCategory.base:
          return 'Base';
        case ModuleCategory.mode:
          return 'Game Modes';
        case ModuleCategory.scene:
          return 'Scene';
        case ModuleCategory.gimmick:
          return 'Gimmick';
      }
    }
    switch (cat) {
      case ModuleCategory.base:
        return l10n.moduleCategoryBase;
      case ModuleCategory.mode:
        return l10n.moduleCategoryMode;
      case ModuleCategory.scene:
        return l10n.moduleCategoryScene;
      case ModuleCategory.gimmick:
        return l10n.moduleCategoryGimmick;
    }
  }
}

class _ModuleSelectionCard extends StatelessWidget {
  const _ModuleSelectionCard({
    required this.meta,
    required this.isAlreadyAdded,
    required this.isEnabled,
    required this.onTap,
  });

  final ModuleMetadata meta;
  final bool isAlreadyAdded;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: Card(
        color: isEnabled
            ? theme.colorScheme.surface
            : theme.colorScheme.surfaceContainerHighest,
        elevation: isEnabled ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        (isEnabled
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outline)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: meta.assetIconPath != null
                      ? Padding(
                          padding: const EdgeInsets.all(6),
                          child: AssetImageWidget(
                            assetPath: meta.assetIconPath!,
                            fit: BoxFit.contain,
                            altCandidates: imageAltCandidates(
                              meta.assetIconPath!,
                            ),
                          ),
                        )
                      : Icon(
                          meta.icon,
                          size: 28,
                          color: isEnabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.getTitle(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEnabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.getDescription(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isAlreadyAdded)
                  Icon(
                    meta.allowMultiple ? Icons.add_circle : Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
