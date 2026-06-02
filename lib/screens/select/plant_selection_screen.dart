import 'package:flutter/material.dart';
import 'package:z_editor/data/level_parser.dart';
import 'package:z_editor/data/pvz_models.dart';
import 'package:z_editor/data/registry/module_registry.dart';
import 'package:z_editor/data/repository/plant_repository.dart';
import 'package:z_editor/data/rtid_parser.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/l10n/resource_names.dart';
import 'package:z_editor/screens/select/magic_hat_spawn_preview_screen.dart';
import 'package:z_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:z_editor/widgets/editor_components.dart'
    show ScrollableWithMouseDrag;

/// Placeholder when a plant has no icon or icon fails to load.
const String _kUnknownIconPath = 'assets/images/others/unknown.webp';

/// Internal tag → module objClass required to enable those plants.
const Map<String, String> _moduleGatedPlantTags = {
  '_internal_copycats': 'PVZ1CopycatsModuleProperties',
};

bool _isRealmExclusivePlant(PlantInfo plant) =>
    plant.hasInternalTag('_internal_no42') ||
    plant.hasInternalTag('_internal_mausoleum');

/// Plant selection. Ported from Z-Editor-master PlantSelectionScreen.kt
class PlantSelectionScreen extends StatefulWidget {
  const PlantSelectionScreen({
    super.key,
    this.isMultiSelect = false,
    required this.onPlantSelected,
    this.onMultiPlantSelected,
    required this.onBack,
    this.excludeIds = const [],
    this.levelFile,
    this.onAddModule,
    this.blockRealmExclusiveInChooser = false,
    this.allowDuplicateSelection = false,
  });

  final bool isMultiSelect;
  final void Function(String) onPlantSelected;
  final void Function(List<String>)? onMultiPlantSelected;
  final VoidCallback onBack;

  /// IDs to exclude from selection (e.g. plants already in the other list).
  final List<String> excludeIds;

  /// When set, parallel plants gated by modules are disabled until the corresponding module is in the level.
  final PvzLevelFile? levelFile;

  /// Called when user taps "Add" in the "module required" dialog. Must add the module to the level and sync.
  final void Function(String objClass)? onAddModule;

  /// When true, realm-exclusive plants cannot be picked (seed bank chooser white/black lists).
  final bool blockRealmExclusiveInChooser;

  /// When true, each tap in multi-select adds another entry (preset seed bank list).
  final bool allowDuplicateSelection;

  @override
  State<PlantSelectionScreen> createState() => _PlantSelectionScreenState();
}

class _PlantSelectionScreenState extends State<PlantSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _selectedIds = {};
  final List<String> _selectedIdsWithDuplicates = [];
  bool _isLoaded = false;
  PlantCategory _selectedCategory = PlantCategory.quality;
  PlantTag _selectedTag = PlantTag.all;

  @override
  void initState() {
    super.initState();
    PlantRepository().init().then((_) {
      if (mounted) setState(() => _isLoaded = true);
    });
  }

  List<PlantTag> _visibleTagsFor(PlantCategory category) {
    if (category == PlantCategory.collection) return [];
    return [
      PlantTag.all,
      ...PlantTag.values.where(
        (t) => t != PlantTag.all && t.category == category,
      ),
    ];
  }

  void _setCategory(PlantCategory category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      final tags = _visibleTagsFor(category);
      _selectedTag = tags.isNotEmpty ? tags.first : PlantTag.all;
    });
  }

  void _toggleFavorite(BuildContext context, String id) async {
    await PlantRepository().toggleFavorite(id);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    final isFav = PlantRepository().isFavorite(id);
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

  Set<String> _levelModuleObjClasses() {
    final lf = widget.levelFile;
    if (lf == null) return {};
    final parsed = LevelParser.parseLevel(lf);
    final levelDef = parsed.levelDef;
    if (levelDef == null) return {};
    final objectMap = parsed.objectMap;
    final set = <String>{};
    for (final rtid in levelDef.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      if (info.source == 'CurrentLevel') {
        final obj = objectMap[info.alias];
        if (obj != null) set.add(obj.objClass);
      } else if (info.source == 'LevelModules') {
        set.add(info.alias);
      }
    }
    return set;
  }

  bool _isPlantEnabled(PlantInfo plant, Set<String> levelModules) {
    if (widget.blockRealmExclusiveInChooser && _isRealmExclusivePlant(plant)) {
      return false;
    }
    for (final entry in _moduleGatedPlantTags.entries) {
      if (plant.hasInternalTag(entry.key)) {
        if (!levelModules.contains(entry.value)) return false;
      }
    }
    return true;
  }

  String? _requiredModuleForPlant(PlantInfo plant) {
    for (final entry in _moduleGatedPlantTags.entries) {
      if (plant.hasInternalTag(entry.key)) return entry.value;
    }
    return null;
  }

  Future<void> _showRealmExclusiveChooserBlockedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.realmExclusivePlantChooserBlockedTitle ?? 'Cannot select plant',
        ),
        content: Text(
          l10n?.realmExclusivePlantChooserBlockedMessage ??
              'Realm-exclusive plants cannot be selected in Chooser Mode. '
                  'To use them, please refer to other methods such as Preset Mode, '
                  'Conveyor Belt, or Packet Drops.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onPlantTap(
    BuildContext context,
    PlantInfo plant,
    bool isEnabled,
    Set<String> levelModules,
  ) async {
    if (widget.blockRealmExclusiveInChooser && _isRealmExclusivePlant(plant)) {
      await _showRealmExclusiveChooserBlockedDialog(context);
      return;
    }
    if (isEnabled) {
      if (widget.isMultiSelect) {
        setState(() {
          if (widget.allowDuplicateSelection) {
            _selectedIdsWithDuplicates.add(plant.id);
          } else if (_selectedIds.contains(plant.id)) {
            _selectedIds.remove(plant.id);
          } else {
            _selectedIds.add(plant.id);
          }
        });
      } else {
        widget.onPlantSelected(plant.id);
      }
      return;
    }
    final requiredObjClass = _requiredModuleForPlant(plant);
    if (requiredObjClass == null || widget.onAddModule == null) return;
    final l10n = AppLocalizations.of(context)!;
    final meta = ModuleRegistry.getMetadata(requiredObjClass);
    final moduleName = meta.getTitle(context);
    final message = l10n.plantModuleRequiredMessage(moduleName);
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (added == true && mounted) {
      widget.onAddModule!(requiredObjClass);
      if (!widget.isMultiSelect &&
          requiredObjClass == 'PVZ1CopycatsModuleProperties') {
        widget.onPlantSelected(plant.id);
      }
      setState(() {});
    }
  }

  bool _isMagicHatPlant(PlantInfo plant) =>
      plant.id.startsWith('minigame_imitater');

  void _openMagicHatPreview(BuildContext context, String hatPlantId) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => MagicHatSpawnPreviewScreen(
          hatPlantId: hatPlantId,
          levelFile: widget.levelFile,
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final repo = PlantRepository();
    final levelModuleObjClasses = _levelModuleObjClasses();
    final allPlants = repo.search(
      _searchQuery,
      _selectedCategory == PlantCategory.collection ? null : _selectedTag,
      _selectedCategory,
    );
    final excludeSet = widget.excludeIds.toSet();
    final plants = excludeSet.isEmpty
        ? allPlants
        : allPlants.where((p) => !excludeSet.contains(p.id)).toList();
    final visibleTags = _visibleTagsFor(_selectedCategory);
    final tagIndex = visibleTags.indexOf(_selectedTag);
    final safeTagIndex = tagIndex < 0 ? 0 : tagIndex;
    if (_selectedCategory != PlantCategory.collection &&
        !visibleTags.contains(_selectedTag)) {
      _selectedTag = visibleTags.first;
    }
    final themeColor = theme.colorScheme.primary;
    final filterMaxHeight = MediaQuery.sizeOf(context).height * 0.42;

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
        title: Text(l10n?.selectPlant ?? 'Select plant'),
      ),
      floatingActionButton: widget.isMultiSelect
          ? FloatingActionButton(
              onPressed: () {
                final ids = widget.allowDuplicateSelection
                    ? List<String>.from(_selectedIdsWithDuplicates)
                    : _selectedIds.toList();
                widget.onMultiPlantSelected?.call(ids);
              },
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
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: widget.isMultiSelect
                              ? (l10n?.selectedCountTapToSearch(
                                    widget.allowDuplicateSelection
                                        ? _selectedIdsWithDuplicates.length
                                        : _selectedIds.length,
                                  ) ??
                                  'Selected ${widget.allowDuplicateSelection ? _selectedIdsWithDuplicates.length : _selectedIds.length}, tap to search')
                              : (l10n?.searchPlant ?? 'Search plant'),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _searchQuery = ''),
                                )
                              : null,
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    DefaultTabController(
                      key: ValueKey(_selectedCategory),
                      length: PlantCategory.values.length,
                      initialIndex: PlantCategory.values.indexOf(
                        _selectedCategory,
                      ),
                      child: TabBar(
                        isScrollable: true,
                        indicatorColor: theme.colorScheme.surface,
                        labelColor: theme.colorScheme.surface,
                        unselectedLabelColor: theme.colorScheme.surface
                            .withValues(alpha: 0.6),
                        onTap: (index) =>
                            _setCategory(PlantCategory.values[index]),
                        tabs: PlantCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return Tab(
                            child: Row(
                              children: [
                                if (category == PlantCategory.collection) ...[
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: isSelected
                                        ? theme.colorScheme.surface
                                        : theme.colorScheme.surface.withValues(
                                            alpha: 0.6,
                                          ),
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
                    if (_selectedCategory != PlantCategory.collection)
                      DefaultTabController(
                        key: ValueKey('${_selectedCategory.name}_tags'),
                        length: visibleTags.length,
                        initialIndex: safeTagIndex,
                        child: TabBar(
                          isScrollable: true,
                          indicatorColor: theme.colorScheme.surface.withValues(
                            alpha: 0.8,
                          ),
                          labelColor: theme.colorScheme.surface,
                          unselectedLabelColor: theme.colorScheme.surface
                              .withValues(alpha: 0.6),
                          onTap: (index) => setState(
                            () => _selectedTag = visibleTags[index],
                          ),
                          tabs: visibleTags.map((tag) {
                            final isSelected = _selectedTag == tag;
                            final iconName = tag.iconName;
                            return Tab(
                              child: Row(
                                children: [
                                  if (iconName != null) ...[
                                    AssetImageWidget(
                                      assetPath:
                                          'assets/images/tags/$iconName',
                                      width: 18,
                                      height: 18,
                                      altCandidates: imageAltCandidates(
                                        'assets/images/tags/$iconName',
                                      ),
                                      cacheWidth: 36,
                                      cacheHeight: 36,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    tag.getLabel(context),
                                    style: TextStyle(
                                      fontSize: 13,
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
                : plants.isEmpty
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
                              _selectedCategory == PlantCategory.collection
                                  ? (l10n?.noFavoritesLongPress ??
                                        'No favorites. Long-press to favorite.')
                                  : (l10n?.noPlantFound ?? 'No plant found'),
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
                        itemCount: plants.length,
                        itemBuilder: (_, i) {
                          final plant = plants[i];
                          final selectionCount = widget.allowDuplicateSelection
                              ? _selectedIdsWithDuplicates
                                  .where((id) => id == plant.id)
                                  .length
                              : (_selectedIds.contains(plant.id) ? 1 : 0);
                          final isSelected = selectionCount > 0;
                          final isFavorite = repo.isFavorite(plant.id);
                          final isEnabled = _isPlantEnabled(
                            plant,
                            levelModuleObjClasses,
                          );
                          final isHat = _isMagicHatPlant(plant);
                          return _PlantGridItem(
                            plant: plant,
                            isSelected: isSelected,
                            isFavorite: isFavorite,
                            isEnabled: isEnabled,
                            onTap: () => _onPlantTap(
                              context,
                              plant,
                              isEnabled,
                              levelModuleObjClasses,
                            ),
                            onSecondaryTap: isHat
                                ? () => _openMagicHatPreview(context, plant.id)
                                : null,
                            onLongPress: isHat
                                ? () => _openMagicHatPreview(context, plant.id)
                                : () => _toggleFavorite(context, plant.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PlantGridItem extends StatelessWidget {
  const _PlantGridItem({
    required this.plant,
    required this.isSelected,
    required this.isFavorite,
    required this.isEnabled,
    required this.onTap,
    this.onSecondaryTap,
    required this.onLongPress,
  });

  final PlantInfo plant;
  final bool isSelected;
  final bool isFavorite;
  final bool isEnabled;
  final VoidCallback onTap;
  final VoidCallback? onSecondaryTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = plant.iconAssetPath;
    final hasIcon = iconPath != null && iconPath.isNotEmpty;

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : Colors.transparent;
    final bgColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : Colors.transparent;
    final ink = Material(
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
                                cacheWidth: 88,
                                cacheHeight: 88,
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
                  ResourceNames.lookup(context, plant.name),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  plant.id,
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
    );
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: onSecondaryTap == null
          ? ink
          : GestureDetector(
              onSecondaryTap: onSecondaryTap,
              child: ink,
            ),
    );
  }
}
