import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_ordering.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_detail_screen.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/animated_extended_fab.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_components.dart';

class _ZombossActionSelectionViewState {
  _ZombossActionSelectionViewState({
    required this.category,
    required this.scrollOffset,
  });

  String category;
  double scrollOffset;
}

final Map<String, _ZombossActionSelectionViewState>
_zombossActionSelectionViewStates = {};

/// Picks a catalog or level-local zomboss action; returns RTID string.
class ZombossMechActionSelectionScreen extends StatefulWidget {
  const ZombossMechActionSelectionScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    this.retreatOnly = false,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final bool retreatOnly;

  @override
  State<ZombossMechActionSelectionScreen> createState() =>
      _ZombossMechActionSelectionScreenState();
}

class _ZombossMechActionSelectionScreenState
    extends State<ZombossMechActionSelectionScreen> {
  static const _categories = [
    ZombossMechActionOrdering.allFilter,
    'movement',
    ZombossMechActionOrdering.summonFilter,
    'attack',
    'special',
    ZombossMechActionOrdering.customFilter,
  ];
  late String _category;
  String _query = '';
  late final ScrollController _listScrollController;
  late bool _listScrollAtTop;

  String get _viewStateKey =>
      'level:${identityHashCode(widget.levelFile)}:'
      '${widget.catalog.id}:${widget.retreatOnly}';

  bool get _canRememberScroll => _query.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final remembered = _zombossActionSelectionViewStates[_viewStateKey];
    _category =
        !widget.retreatOnly &&
            remembered != null &&
            _categories.contains(remembered.category)
        ? remembered.category
        : ZombossMechActionOrdering.allFilter;
    final initialOffset = remembered?.scrollOffset ?? 0;
    _listScrollAtTop = initialOffset <= 0;
    _listScrollController = ScrollController(initialScrollOffset: initialOffset)
      ..addListener(_onListScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreRememberedScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberScrollOffset();
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
    super.dispose();
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    _rememberScrollOffset();
    final atTop = _listScrollController.offset <= 0;
    if (atTop != _listScrollAtTop && mounted) {
      setState(() => _listScrollAtTop = atTop);
    }
  }

  void _setCategory(String category) {
    if (_category == category) return;
    setState(() {
      _category = category;
      _listScrollAtTop = true;
    });
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0);
  }

  void _setQuery(String query) {
    if (_query == query) return;
    setState(() {
      _query = query;
      _listScrollAtTop = true;
    });
    _resetRememberedScrollOffset(persist: query.trim().isEmpty);
  }

  void _rememberViewState({double? scrollOffset}) {
    final state = _zombossActionSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _ZombossActionSelectionViewState(
        category: _category,
        scrollOffset: 0,
      ),
    );
    state.category = _category;
    if (scrollOffset != null) state.scrollOffset = scrollOffset;
  }

  void _rememberScrollOffset() {
    if (!_canRememberScroll || !_listScrollController.hasClients) return;
    _rememberViewState(scrollOffset: _listScrollController.offset);
  }

  void _resetRememberedScrollOffset({bool persist = true}) {
    if (persist) _rememberViewState(scrollOffset: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listScrollController.hasClients) return;
      _listScrollController.jumpTo(0);
    });
  }

  void _restoreRememberedScrollOffset() {
    if (!mounted || !_listScrollController.hasClients) return;
    final offset =
        _zombossActionSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
    final position = _listScrollController.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (_listScrollController.offset != target) {
      _listScrollController.jumpTo(target);
    }
    final atTop = target <= 0;
    if (_listScrollAtTop != atTop) {
      setState(() => _listScrollAtTop = atTop);
    }
  }

  List<_ActionListItem> get _items {
    final items = <_ActionListItem>[];
    if (widget.retreatOnly) {
      for (final action in widget.catalog.retreatCatalogActions) {
        final category = ZombossMechActionOrdering.categoryForCatalogAction(
          action,
        );
        items.add(
          _ActionListItem.catalog(
            catalog: widget.catalog,
            action: action,
            category: category,
            rtid: RtidParser.build(
              action.alias,
              ZombossMechActionUtils.catalogSource,
            ),
          ),
        );
      }
    } else {
      for (final action in ZombossMechActionOrdering.sortedCatalogActions(
        widget.catalog,
      )) {
        final category = ZombossMechActionOrdering.categoryForCatalogAction(
          action,
        );
        if (!_matchesCategory(isCustom: false, category: category)) {
          continue;
        }
        items.add(
          _ActionListItem.catalog(
            catalog: widget.catalog,
            action: action,
            category: category,
            rtid: RtidParser.build(
              action.alias,
              ZombossMechActionUtils.catalogSource,
            ),
          ),
        );
      }

      for (final preset in ZombossCustomActionPresetRepository.presetsForMech(
        widget.catalog.editableInstance,
      )) {
        final group =
            ZombossCustomActionPresetRepository.groupForObjclass(
              widget.catalog.editableInstance,
              preset.objclass,
            ) ??
            ZombossMechObjclassGroup(
              objclass: preset.objclass,
              tag: 'spawn',
              fields: preset.fields,
              implementations: const {},
            );
        final category = ZombossMechActionOrdering.categoryForGroup(
          group,
          alias: preset.sourceAlias,
        );
        if (!_matchesCategory(isCustom: true, category: category)) {
          continue;
        }
        items.add(
          _ActionListItem.presetTemplate(
            catalog: widget.catalog,
            template: preset,
            category: category,
          ),
        );
      }
    }

    final derivedItems = <_ActionListItem>[];
    final userItems = <_ActionListItem>[];
    for (final obj in widget.levelFile.objects) {
      final alias = obj.aliases?.firstOrNull;
      if (alias == null) continue;
      final group =
          widget.catalog.actions
              .where((g) => g.objclass == obj.objClass)
              .firstOrNull ??
          ZombossCustomActionPresetRepository.groupForObjclass(
            widget.catalog.editableInstance,
            obj.objClass,
          );
      if (group == null) continue;
      if (widget.retreatOnly && group.tag != 'retreat') continue;
      if (!widget.retreatOnly && group.tag == 'retreat') continue;
      final actionRtid = RtidParser.build(
        alias,
        ZombossMechActionUtils.customSource,
      );
      final origin = ZombossCustomActionPresetRepository.originForRtid(
        widget.levelFile,
        actionRtid,
      );
      if (origin == ZombossCustomActionOrigin.presetTemplate) continue;
      final category = ZombossMechActionOrdering.categoryForGroup(
        group,
        alias: alias,
      );
      if (!widget.retreatOnly &&
          !_matchesCategory(isCustom: true, category: category)) {
        continue;
      }
      final item = _ActionListItem.custom(
        catalog: widget.catalog,
        alias: alias,
        objclass: obj.objClass,
        tag: group.tag,
        category: category,
        baseAliases: group.implementations.keys.toList(),
        baseAlias: ZombossMechActionUtils.inferBaseCatalogAction(
          catalog: widget.catalog,
          customAlias: alias,
          objclass: obj.objClass,
          data: obj.objData is Map
              ? Map<String, dynamic>.from(obj.objData as Map)
              : const {},
          retreatOnly: widget.retreatOnly,
        )?.alias,
        rtid: actionRtid,
        origin: origin,
        preset: ZombossCustomActionPresetRepository.presetForObject(obj),
      );
      if (origin == ZombossCustomActionOrigin.presetDerived) {
        derivedItems.add(item);
      } else {
        userItems.add(item);
      }
    }
    items
      ..addAll(derivedItems)
      ..addAll(userItems);

    return _filterBySearch(items);
  }

  bool _matchesCategory({
    required bool isCustom,
    required ZombossMechActionMainCategory category,
  }) {
    return ZombossMechActionOrdering.matchesFilter(
      filter: _category,
      isCustom: isCustom,
      category: category,
    );
  }

  List<_ActionListItem> _filterBySearch(List<_ActionListItem> items) {
    final q = _query.trim();
    if (q.isEmpty) return items;
    return items
        .where((e) => matchesSelectionSearch(q, e.searchTerms(context)))
        .toList();
  }

  String _categoryLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    if (key == ZombossMechActionOrdering.allFilter) {
      return AppLocalizations.of(context)?.zombossMechActionCategoryAll ??
          'All';
    }
    if (key == ZombossMechActionOrdering.customFilter) {
      return l10n?.zombossMechActionCategoryCustom ?? 'Custom';
    }
    return ZombossMechL10n.tagLabel(context, key);
  }

  Future<void> _openCreateCustom() async {
    final rtid = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombossMechActionEditorScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          retreatOnly: widget.retreatOnly,
        ),
      ),
    );
    if (rtid != null && mounted) Navigator.pop(context, rtid);
  }

  Future<void> _openActionDetails(String rtid) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionDetailScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          rtid: rtid,
        ),
      ),
    );
  }

  void _selectItem(_ActionListItem item) {
    if (item.presetTemplate != null) {
      final creation = ZombossCustomActionPresetRepository.instantiatePreset(
        widget.levelFile,
        item.presetTemplate!,
      );
      Navigator.pop(context, creation.rtid);
      return;
    }
    Navigator.pop(context, item.rtid);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = _items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.retreatOnly
              ? (l10n?.zombossMechSelectRetreatAction ??
                    'Select retreat action')
              : (l10n?.zombossMechSelectAction ?? 'Select action'),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!widget.retreatOnly)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      for (final cat in _categories)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_categoryLabel(context, cat)),
                            selected: _category == cat,
                            onSelected: (_) => _setCategory(cat),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SelectionSearchField(
                  hintText: l10n?.search ?? 'Search',
                  query: _query,
                  useOutlineBorder: true,
                  onChanged: _setQuery,
                  onClear: () => _setQuery(''),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          l10n?.zombossMechNoActionsFound ?? 'No actions found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _listScrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: item.customBadge(context),
                            title: Text(item.primaryLabel(context)),
                            subtitle: Text(
                              item.secondaryLabel(context),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: item.presetTemplate != null
                                ? null
                                : item.canEditExisting
                                ? IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: l10n?.edit ?? 'Edit',
                                    onPressed: () async {
                                      final rtid = await Navigator.push<String>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CustomZombossMechActionEditorScreen(
                                                catalog: widget.catalog,
                                                levelFile: widget.levelFile,
                                                existingRtid: item.rtid,
                                                retreatOnly: widget.retreatOnly,
                                              ),
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      if (rtid != null) {
                                        Navigator.pop(context, rtid);
                                      }
                                    },
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    tooltip:
                                        l10n?.zombossMechActionDetails ??
                                        'Action Details',
                                    onPressed: () =>
                                        _openActionDetails(item.rtid),
                                  ),
                            onTap: () => _selectItem(item),
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: AnimatedExtendedFab(
              visible: _listScrollAtTop,
              heroTag: 'zombossMechCreateCustomAction',
              onPressed: _openCreateCustom,
              icon: Icons.add,
              label: l10n?.zombossMechCreateCustomAction ?? 'New custom action',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionListItem {
  _ActionListItem.catalog({
    required this.catalog,
    required ZombossMechCatalogAction action,
    required this.category,
    required this.rtid,
  }) : origin = null,
       preset = null,
       presetTemplate = null,
       catalogAction = action,
       alias = action.alias,
       objclass = action.objclass,
       tag = action.tag,
       baseAliases = const [],
       baseAlias = null;

  _ActionListItem.presetTemplate({
    required this.catalog,
    required ZombossCustomActionPreset template,
    required this.category,
  }) : origin = ZombossCustomActionOrigin.presetTemplate,
       preset = template,
       presetTemplate = template,
       catalogAction = null,
       rtid = RtidParser.build(
         template.sourceAlias,
         ZombossMechActionUtils.customSource,
       ),
       alias = template.sourceAlias,
       objclass = template.objclass,
       tag = 'spawn',
       baseAliases = const [],
       baseAlias = null;

  _ActionListItem.custom({
    required this.catalog,
    required this.alias,
    required this.objclass,
    required this.tag,
    required this.category,
    required this.baseAliases,
    required this.baseAlias,
    required this.rtid,
    required this.origin,
    required this.preset,
  }) : presetTemplate = null,
       catalogAction = null;

  final ZombossMechCatalogEntry catalog;
  final ZombossMechCatalogAction? catalogAction;
  final ZombossCustomActionOrigin? origin;
  final ZombossCustomActionPreset? preset;
  final ZombossCustomActionPreset? presetTemplate;
  final String rtid;
  final String alias;
  final String objclass;
  final String tag;
  final ZombossMechActionMainCategory category;
  final List<String> baseAliases;
  final String? baseAlias;

  bool get isCustom => origin != null;
  bool get canEditExisting =>
      origin == ZombossCustomActionOrigin.presetDerived ||
      origin == ZombossCustomActionOrigin.userCreated;

  Widget? customBadge(BuildContext context) {
    final itemOrigin = origin;
    if (itemOrigin == null) return null;
    final color = switch (itemOrigin) {
      ZombossCustomActionOrigin.presetTemplate =>
        presetCustomResourceBadgeColor(context),
      ZombossCustomActionOrigin.presetDerived => customStageBadgeColor(context),
      ZombossCustomActionOrigin.userCreated => userCustomResourceBadgeColor(
        context,
      ),
    };
    return CustomResourceBadge(color: color);
  }

  String primaryLabel(BuildContext context) {
    if (presetTemplate != null) {
      return _resourceName(context, presetTemplate!.nameKey);
    }
    if (isCustom) {
      return _rtidLabel();
    }
    return ZombossMechL10n.implementationLabel(context, catalog.id, alias);
  }

  String secondaryLabel(BuildContext context) {
    if (presetTemplate != null) {
      return _resourceName(context, presetTemplate!.sourceKey);
    }
    if (origin == ZombossCustomActionOrigin.presetDerived && preset != null) {
      final l10n = AppLocalizations.of(context);
      final action =
          ZombossCustomActionPresetRepository.presetDisplayNameWithAlias(
            preset!,
            _resourceName(context, preset!.nameKey),
          );
      return l10n?.zombossPresetDerivedBaseAction(action) ??
          'Based on Preset Custom Action: $action';
    }
    if (isCustom) {
      final baseAction = baseActionDisplayName(context);
      final l10n = AppLocalizations.of(context);
      return l10n?.zombossCustomActionBaseAction(baseAction) ??
          'Base Action: $baseAction';
    }
    return _rtidLabel();
  }

  String baseActionDisplayName(BuildContext context) {
    final implementationAlias = baseAlias;
    if (implementationAlias != null && implementationAlias.isNotEmpty) {
      return ZombossMechL10n.implementationDisplayLabel(
        context,
        catalog.id,
        implementationAlias,
      );
    }
    return ZombossMechL10n.actionLabel(
      context,
      catalog.id,
      objclass,
      fallback: alias,
    );
  }

  String _rtidLabel() {
    final info = RtidParser.parse(rtid);
    if (info != null) {
      return '${info.alias}@${info.source}';
    }
    return rtid;
  }

  String _resourceName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  Iterable<String> searchTerms(BuildContext context) sync* {
    yield primaryLabel(context);
    yield secondaryLabel(context);
    yield alias;
    yield objclass;
    yield tag;
    yield category.filterKey;
    yield rtid;
    yield ZombossMechL10n.actionKey(catalog.id, objclass);
    yield ZombossMechL10n.actionImplementationKey(catalog.id, alias);
    if (presetTemplate != null) {
      yield presetTemplate!.nameKey;
      yield presetTemplate!.sourceKey;
      yield presetTemplate!.sourceAlias;
      yield _resourceName(context, presetTemplate!.nameKey);
      yield _resourceName(context, presetTemplate!.sourceKey);
    }
    if (preset != null) {
      yield preset!.nameKey;
      yield preset!.sourceAlias;
      yield _resourceName(context, preset!.nameKey);
      yield ZombossCustomActionPresetRepository.presetDisplayNameWithAlias(
        preset!,
        _resourceName(context, preset!.nameKey),
      );
    }
    if (isCustom) {
      yield baseActionDisplayName(context);
      for (final baseAlias in baseAliases) {
        yield baseAlias;
        yield ZombossMechL10n.implementationLabel(
          context,
          catalog.id,
          baseAlias,
        );
        yield ZombossMechL10n.actionImplementationKey(catalog.id, baseAlias);
      }
    }
  }
}
