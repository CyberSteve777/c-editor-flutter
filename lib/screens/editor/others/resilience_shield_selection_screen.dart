import 'package:collection/collection.dart';

import 'package:flutter/material.dart';

import 'package:c_editor/data/pvz_models.dart';

import 'package:c_editor/data/resilience_shield_utils.dart';

import 'package:c_editor/l10n/app_localizations.dart';

import 'package:c_editor/screens/editor/others/custom_resilience_shield_editor_screen.dart';

import 'package:c_editor/widgets/animated_extended_fab.dart';

import 'package:c_editor/widgets/editor_components.dart';

import 'package:c_editor/widgets/resilience_shield_widgets.dart';



enum _FilterAxis { bySource, byType }



/// Sentinel values for type-axis sub-filters.
const _typeAll = -1;



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

  final ScrollController _listScrollController = ScrollController();

  bool _listScrollAtTop = true;



  bool get _showCreateFab =>
      _axis == _FilterAxis.bySource &&
      _sourceChoice == ResilienceShieldUtils.customSource;



  @override

  void initState() {

    super.initState();

    _listScrollController.addListener(_onListScroll);

    final current = widget.currentRtid;

    if (current != null) {

      final info = ResilienceShieldUtils.listItems(widget.levelFile)

          .where((e) => e.rtid == current)

          .firstOrNull;

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

  }



  @override

  void dispose() {

    _listScrollController.removeListener(_onListScroll);

    _listScrollController.dispose();

    super.dispose();

  }



  void _onListScroll() {

    if (!_listScrollController.hasClients) return;

    final atTop = _listScrollController.offset <= 0;

    if (atTop != _listScrollAtTop && mounted) {

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

    if (ResilienceShieldUtils.countReferences(widget.levelFile, item.rtid) > 0) {

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

          l10n?.resilienceShieldDeleteTitle ?? 'Delete custom resilience shield?',

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

        title: Text(l10n?.resilienceSelectShield ?? 'Select resilience shield'),

      ),

      body: Stack(

        children: [

          Column(

            children: [

              SingleChildScrollView(

                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),

                child: Row(

                  children: [

                    Padding(

                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(

                        label: Text(

                          l10n?.selectionFilterBySource ?? 'By source',

                        ),

                        selected: _axis == _FilterAxis.bySource,

                        onSelected: (_) => setState(() {

                          _axis = _FilterAxis.bySource;

                          _sourceChoice = ResilienceShieldUtils.catalogSource;

                        }),

                      ),

                    ),

                    Padding(

                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(

                        label: Text(l10n?.selectionFilterByType ?? 'By type'),

                        selected: _axis == _FilterAxis.byType,

                        onSelected: (_) => setState(() {

                          _axis = _FilterAxis.byType;

                          _typeChoice = _typeAll;

                        }),

                      ),

                    ),

                  ],

                ),

              ),

              SingleChildScrollView(
                key: ValueKey(_axis),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    if (_axis == _FilterAxis.bySource) ...[

                      Padding(

                        padding: const EdgeInsets.only(right: 8),

                        child: ChoiceChip(

                          label: Text(l10n?.selectionPreMade ?? 'Pre-made'),

                          selected:

                              _sourceChoice == ResilienceShieldUtils.catalogSource,

                          onSelected: (_) => setState(

                            () => _sourceChoice =

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

                          onSelected: (_) => setState(

                            () => _sourceChoice =

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

                          onSelected: (_) =>

                              setState(() => _typeChoice = _typeAll),

                        ),

                      ),

                      for (var wt = 1; wt <= 6; wt++)

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

                            onSelected: (_) => setState(() => _typeChoice = wt),

                          ),

                        ),

                    ],

                  ],

                ),

              ),

              Padding(

                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),

                child: SelectionSearchField(

                  hintText: l10n?.search ?? 'Search',

                  query: _query,

                  useOutlineBorder: true,

                  onChanged: (v) => setState(() => _query = v),

                  onClear: () => setState(() => _query = ''),

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

                            title: Text(item.alias),

                            subtitle: Text(

                              item.displayRtid,

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

