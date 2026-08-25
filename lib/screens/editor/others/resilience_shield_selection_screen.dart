import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

import 'package:c_editor/data/pvz_models.dart';

import 'package:c_editor/data/resilience_weak_type.dart';

import 'package:c_editor/data/resilience_shield_utils.dart';

import 'package:c_editor/l10n/app_localizations.dart';

import 'package:c_editor/screens/editor/others/custom_resilience_shield_editor_screen.dart';

import 'package:c_editor/widgets/animated_extended_fab.dart';

import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';

import 'package:c_editor/widgets/editor_components.dart';

import 'package:c_editor/widgets/resilience_shield_widgets.dart';

enum _FilterAxis { bySource, byType }

/// Sentinel values for type-axis sub-filters.
const _typeAll = -1;

class _ResilienceSelectionViewState {
  _ResilienceSelectionViewState({
    required this.axis,
    required this.sourceChoice,
    required this.typeChoice,
    required this.query,
    required this.scrollOffset,
  });

  _FilterAxis axis;
  String sourceChoice;
  int typeChoice;
  String query;
  double scrollOffset;
}

final Map<String, _ResilienceSelectionViewState>
_resilienceSelectionViewStates = {};

/// Picks a preset or level-local resilience shield; returns RTID string.

class ResilienceShieldSelectionScreen extends StatefulWidget {
  const ResilienceShieldSelectionScreen({
    super.key,

    required this.levelFile,

    this.currentRtid,

    this.onChanged,
  });

  final PvzLevelFile levelFile;

  final String? currentRtid;

  final VoidCallback? onChanged;

  @override
  State<ResilienceShieldSelectionScreen> createState() =>
      _ResilienceShieldSelectionScreenState();
}

class _ResilienceShieldSelectionScreenState
    extends State<ResilienceShieldSelectionScreen> {
  _FilterAxis _axis = _FilterAxis.bySource;

  String _sourceChoice = ResilienceShieldUtils.catalogSource;

  int _typeChoice = _typeAll;

  String _query = '';

  late final ScrollController _listScrollController;

  late bool _listScrollAtTop;

  String get _viewStateKey =>
      'level:${identityHashCode(widget.levelFile)}:resilience';

  bool get _showCreateFab =>
      _axis == _FilterAxis.bySource &&
      _sourceChoice == ResilienceShieldUtils.customSource;

  @override
  void initState() {
    super.initState();

    final remembered = _resilienceSelectionViewStates[_viewStateKey];

    if (remembered != null) {
      _axis = remembered.axis;
      _sourceChoice = remembered.sourceChoice;
      _typeChoice = remembered.typeChoice;
      _query = remembered.query;
    }

    final current = widget.currentRtid;

    if (remembered == null && current != null) {
      final info = ResilienceShieldUtils.listItems(
        widget.levelFile,
      ).where((e) => e.rtid == current).firstOrNull;

      if (info != null) {
        if (info.isCustom) {
          _axis = _FilterAxis.bySource;

          _sourceChoice = ResilienceShieldUtils.customSource;
        } else {
          _axis = _FilterAxis.bySource;

          _sourceChoice = ResilienceShieldUtils.catalogSource;
        }
      }
    }

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

  void _setAxis(_FilterAxis axis) {
    if (_axis == axis) return;
    setState(() {
      _axis = axis;
      if (axis == _FilterAxis.bySource) {
        _sourceChoice = ResilienceShieldUtils.catalogSource;
      } else {
        _typeChoice = _typeAll;
      }
      _listScrollAtTop = true;
    });
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0);
  }

  void _setSourceChoice(String source) {
    if (_sourceChoice == source) return;
    setState(() {
      _sourceChoice = source;
      _listScrollAtTop = true;
    });
    _resetRememberedScrollOffset();
    _rememberViewState(scrollOffset: 0);
  }

  void _setTypeChoice(int type) {
    if (_typeChoice == type) return;
    setState(() {
      _typeChoice = type;
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
    _resetRememberedScrollOffset();
  }

  void _rememberViewState({double? scrollOffset}) {
    final state = _resilienceSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _ResilienceSelectionViewState(
        axis: _axis,
        sourceChoice: _sourceChoice,
        typeChoice: _typeChoice,
        query: _query,
        scrollOffset: 0,
      ),
    );
    state.axis = _axis;
    state.sourceChoice = _sourceChoice;
    state.typeChoice = _typeChoice;
    state.query = _query;
    if (scrollOffset != null) state.scrollOffset = scrollOffset;
  }

  void _rememberScrollOffset() {
    if (!_listScrollController.hasClients) return;
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
        _resilienceSelectionViewStates[_viewStateKey]?.scrollOffset ?? 0;
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

  List<ResilienceShieldListItem> get _items {
    final q = _query.trim().toLowerCase();

    return ResilienceShieldUtils.listItems(widget.levelFile).where((item) {
      if (_axis == _FilterAxis.bySource) {
        if (item.source != _sourceChoice) return false;
      } else if (_typeChoice != _typeAll && item.weakType != _typeChoice) {
        return false;
      }

      if (q.isEmpty) return true;

      return item.alias.toLowerCase().contains(q) ||
          item.displayRtid.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _openCreateCustom() async {
    final rtid = await Navigator.push<String>(
      context,

      MaterialPageRoute(
        builder: (context) => CustomResilienceShieldEditorScreen(
          levelFile: widget.levelFile,

          onChanged: widget.onChanged,
        ),
      ),
    );

    if (rtid != null && mounted) {
      setState(() {});

      Navigator.pop(context, rtid);
    }
  }

  Future<void> _openEditCustom(ResilienceShieldListItem item) async {
    final rtid = await Navigator.push<String>(
      context,

      MaterialPageRoute(
        builder: (context) => CustomResilienceShieldEditorScreen(
          levelFile: widget.levelFile,

          existingRtid: item.rtid,

          onChanged: widget.onChanged,
        ),
      ),
    );

    if (!mounted) return;

    if (rtid != null) {
      setState(() {});

      Navigator.pop(context, rtid);
    } else {
      setState(() {});
    }
  }

  Future<void> _confirmDeleteCustom(ResilienceShieldListItem item) async {
    final l10n = AppLocalizations.of(context);

    if (ResilienceShieldUtils.countReferences(widget.levelFile, item.rtid) >
        0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.resilienceShieldInUseCannotDelete ??
                'Cannot delete — this shield is used by zombies in this level.',
          ),
        ),
      );

      return;
    }

    final ok = await showDialog<bool>(
      context: context,

      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.resilienceShieldDeleteTitle ??
              'Delete custom resilience shield?',
        ),

        content: Text(
          l10n?.resilienceShieldDeleteMessage(item.alias) ??
              'Delete "${item.alias}" from this level?',
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),

            child: Text(l10n?.cancel ?? 'Cancel'),
          ),

          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,

              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),

            onPressed: () => Navigator.pop(ctx, true),

            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      ResilienceShieldUtils.deleteCustomShield(widget.levelFile, item.rtid);

      widget.onChanged?.call();

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final theme = Theme.of(context);

    final items = _items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.resilienceSelectShield ?? 'Select resilience shield',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              HorizontalTagScroller(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),

                    child: ChoiceChip(
                      label: Text(l10n?.selectionFilterBySource ?? 'By source'),

                      selected: _axis == _FilterAxis.bySource,

                      onSelected: (_) => _setAxis(_FilterAxis.bySource),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 8),

                    child: ChoiceChip(
                      label: Text(l10n?.selectionFilterByType ?? 'By type'),

                      selected: _axis == _FilterAxis.byType,

                      onSelected: (_) => _setAxis(_FilterAxis.byType),
                    ),
                  ),
                ],
              ),

              HorizontalTagScroller(
                key: ValueKey(_axis),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  if (_axis == _FilterAxis.bySource) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(
                        label: Text(l10n?.selectionPreMade ?? 'Pre-made'),

                        selected:
                            _sourceChoice ==
                            ResilienceShieldUtils.catalogSource,

                        onSelected: (_) => _setSourceChoice(
                          ResilienceShieldUtils.catalogSource,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(
                        label: Text(
                          l10n?.selectionDefinedByUser ?? 'Defined by user',
                        ),

                        selected:
                            _sourceChoice == ResilienceShieldUtils.customSource,

                        onSelected: (_) => _setSourceChoice(
                          ResilienceShieldUtils.customSource,
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(
                        label: Text(l10n?.resilienceTypeAll ?? 'All types'),

                        selected: _typeChoice == _typeAll,

                        onSelected: (_) => _setTypeChoice(_typeAll),
                      ),
                    ),

                    for (final wt in resilienceWeakTypeJsonValues)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),

                        child: ChoiceChip(
                          label: ResilienceWeakTypeLabelRow(
                            weakType: wt,
                            label: resilienceWeakTypeLabel(l10n, wt),
                            iconSize: 18,
                            compact: true,
                          ),

                          selected: _typeChoice == wt,

                          onSelected: (_) => _setTypeChoice(wt),
                        ),
                      ),
                  ],
                ],
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
                          l10n?.resilienceNoShieldsFound ??
                              'No resilience shields found',

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

                          final selected = item.rtid == widget.currentRtid;

                          return ListTile(
                            selected: selected,

                            leading: ResilienceWeakTypeIcon(
                              weakType: item.weakType,

                              size: 28,
                            ),

                            title: Row(
                              children: [
                                if (item.isCustom) ...[
                                  CustomResourceBadge(
                                    color: userCustomResourceBadgeColor(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    item.alias,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            subtitle: Text(
                              item.displayRtid,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),

                            trailing: item.isCustom
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,

                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined),

                                        tooltip: l10n?.edit ?? 'Edit',

                                        onPressed: () => _openEditCustom(item),
                                      ),

                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,

                                          color: theme.colorScheme.error,
                                        ),

                                        tooltip: l10n?.delete ?? 'Delete',

                                        onPressed: () =>
                                            _confirmDeleteCustom(item),
                                      ),
                                    ],
                                  )
                                : null,

                            onTap: () => Navigator.pop(context, item.rtid),
                          );
                        },
                      ),
              ),
            ],
          ),

          if (_showCreateFab)
            Positioned(
              right: 16,

              bottom: 16,

              child: AnimatedExtendedFab(
                visible: _listScrollAtTop,

                heroTag: 'resilienceCreateCustomShield',

                onPressed: _openCreateCustom,

                icon: Icons.add,

                label: l10n?.resilienceCreateCustom ?? 'New custom shield',
              ),
            ),
        ],
      ),
    );
  }
}
