import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:z_editor/data/rtid_parser.dart';
import 'package:z_editor/data/zomboss_mech_action_utils.dart';
import 'package:z_editor/data/zomboss_mech_l10n.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';

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
  static const _categories = ['all', 'movement', 'attack', 'special'];
  String _category = 'all';
  String _query = '';

  List<_ActionListItem> get _items {
    final items = <_ActionListItem>[];
    if (widget.retreatOnly) {
      for (final action in widget.catalog.retreatCatalogActions) {
        items.add(
          _ActionListItem.catalog(
            catalog: widget.catalog,
            levelFile: widget.levelFile,
            action: action,
            rtid: RtidParser.build(
              action.alias,
              ZombossMechActionUtils.catalogSource,
            ),
          ),
        );
      }
    } else {
      final tag = _category == 'all' ? null : _category;
      for (final action in widget.catalog.actionsByTag(tag)) {
        items.add(
          _ActionListItem.catalog(
            catalog: widget.catalog,
            levelFile: widget.levelFile,
            action: action,
            rtid: RtidParser.build(
              action.alias,
              ZombossMechActionUtils.catalogSource,
            ),
          ),
        );
      }
    }
    for (final obj in widget.levelFile.objects) {
      final alias = obj.aliases?.firstOrNull;
      if (alias == null) continue;
      final group = widget.catalog.actions
          .where((g) => g.objclass == obj.objClass)
          .firstOrNull;
      if (group == null) continue;
      if (widget.retreatOnly && group.tag != 'retreat') continue;
      if (!widget.retreatOnly && group.tag == 'retreat') continue;
      if (!widget.retreatOnly &&
          _category != 'all' &&
          group.tag != _category) {
        continue;
      }
      items.add(
        _ActionListItem.custom(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          alias: alias,
          objclass: obj.objClass,
          tag: group.tag,
          rtid: RtidParser.build(alias, ZombossMechActionUtils.customSource),
        ),
      );
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items
        .where((e) => e.label(context).toLowerCase().contains(q))
        .toList();
  }

  String _categoryLabel(BuildContext context, String key) {
    if (key == 'all') {
      return AppLocalizations.of(context)?.zombossMechActionCategoryAll ??
          'All';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = _items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.retreatOnly
              ? (l10n?.zombossMechSelectRetreatAction ?? 'Select retreat action')
              : (l10n?.zombossMechSelectAction ?? 'Select action'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCustom,
        icon: const Icon(Icons.add),
        label: Text(l10n?.zombossMechCreateCustomAction ?? 'New custom action'),
      ),
      body: Column(
        children: [
          if (!widget.retreatOnly)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (final cat in _categories)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_categoryLabel(context, cat)),
                        selected: _category == cat,
                        onSelected: (_) => setState(() => _category = cat),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                labelText: l10n?.search ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
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
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.label(context)),
                        subtitle: item.isCustom
                            ? Text(
                                l10n?.zombossMechCustomActionLabel ??
                                    'Custom (CurrentLevel)',
                              )
                            : Text(
                                '${item.alias}@${ZombossMechActionUtils.catalogSource}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                        trailing: item.isCustom
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
                            : null,
                        onTap: () => Navigator.pop(context, item.rtid),
                      );
                    },
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
    required this.levelFile,
    required ZombossMechCatalogAction action,
    required this.rtid,
  })  : isCustom = false,
        catalogAction = action,
        alias = action.alias,
        objclass = action.objclass,
        tag = action.tag;

  _ActionListItem.custom({
    required this.catalog,
    required this.levelFile,
    required this.alias,
    required this.objclass,
    required this.tag,
    required this.rtid,
  })  : isCustom = true,
        catalogAction = null;

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final ZombossMechCatalogAction? catalogAction;
  final String rtid;
  final bool isCustom;
  final String alias;
  final String objclass;
  final String tag;

  String label(BuildContext context) {
    if (isCustom) {
      return ZombossMechL10n.labelForStageRtid(
        context: context,
        mechId: catalog.id,
        catalog: catalog,
        levelFile: levelFile,
        rtid: rtid,
      );
    }
    return ZombossMechL10n.actionRtidLabel(
      context,
      catalog.id,
      rtid,
      objclass: objclass,
      implementationAlias: alias,
    );
  }
}
