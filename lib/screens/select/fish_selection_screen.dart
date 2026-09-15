import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzFishDark, pvzFishLight;
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Fish selection for ZombieFishWaveEvent. Selects creature types (fish).
///
/// Only fish listed in [FishInfo.iconAssetByAlias] (`fish_type_repository.dart`) appear
/// here — each has `assets/images/fishes/icon_*.webp`. Others (e.g. smalljellyfish) are omitted
/// so levels cannot reference creatures without bundled icons (can crash the game).
class FishSelectionScreen extends StatefulWidget {
  const FishSelectionScreen({
    super.key,
    required this.onFishSelected,
    required this.onBack,
    this.stateBucketId,
  });

  final void Function(String fishAlias) onFishSelected;
  final VoidCallback onBack;
  final String? stateBucketId;

  @override
  State<FishSelectionScreen> createState() => _FishSelectionScreenState();
}

class _FishSelectionScreenState extends State<FishSelectionScreen> {
  String _searchQuery = '';
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final bucket = widget.stateBucketId?.isNotEmpty == true
        ? widget.stateBucketId!
        : 'global';
    _memory = SelectionViewMemoryStore.forKey('$bucket:fish-selection');
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

  List<FishInfo> get _displayList {
    final repo = FishTypeRepository();
    if (!repo.isLoaded) return [];
    final order = FishInfo.iconAssetByAlias.keys.toList();
    var list = repo.allFishes
        .where((f) => FishInfo.hasEditorIcon(f.alias))
        .toList();
    list.sort(
      (a, b) => order
          .indexOf(FishInfo.normalizeFishAlias(a.alias))
          .compareTo(order.indexOf(FishInfo.normalizeFishAlias(b.alias))),
    );
    list = list.where((f) {
      final nameKey = 'creature_${f.typeName}';
      return matchesSelectionSearch(_searchQuery, [
        f.typeName,
        f.alias,
        f.creatureClass,
        nameKey,
        ResourceNames.lookup(context, nameKey),
      ]);
    }).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeColor = isDark ? pvzFishDark : pvzFishLight;
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
            hintText: l10n?.searchFish ?? 'Search fish',
            query: _searchQuery,
            onChanged: _setSearchQuery,
            onClear: () => _setSearchQuery(''),
          ),
        ),
        body: displayList.isEmpty
            ? Center(
                child: Text(
                  l10n?.noFishFound ?? 'No fish found',
                  style: theme.textTheme.bodyLarge,
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: displayList.length,
                itemBuilder: (_, i) {
                  final fish = displayList[i];
                  final nameKey = 'creature_${fish.typeName}';
                  final name = ResourceNames.lookup(context, nameKey) != nameKey
                      ? ResourceNames.lookup(context, nameKey)
                      : fish.typeName;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AssetImageWidget(
                          assetPath: fish.iconAssetPath,
                          altCandidates: imageAltCandidates(fish.iconAssetPath),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(fish.creatureClass),
                      onTap: () => widget.onFishSelected(fish.alias),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
