import 'package:flutter/material.dart';
import 'package:c_editor/data/condition_l10n.dart';
import 'package:c_editor/data/zombie_conditions.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/utils/selection_view_memory.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Multi-select zombie conditions with checkboxes (for star challenges).
class ZombieConditionSelectionScreen extends StatefulWidget {
  const ZombieConditionSelectionScreen({
    super.key,
    required this.initialSelected,
    required this.onDone,
    required this.onBack,
    this.stateBucketId,
  });

  final List<String> initialSelected;
  final void Function(List<String> selected) onDone;
  final VoidCallback onBack;
  final String? stateBucketId;

  @override
  State<ZombieConditionSelectionScreen> createState() =>
      _ZombieConditionSelectionScreenState();
}

class _ZombieConditionSelectionScreenState
    extends State<ZombieConditionSelectionScreen> {
  late final Set<String> _selected;
  String _query = '';
  late final SelectionViewMemory _memory;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
    final bucket = widget.stateBucketId?.isNotEmpty == true
        ? widget.stateBucketId!
        : 'global';
    _memory = SelectionViewMemoryStore.forKey('$bucket:zombie-condition');
    _query = _memory.query;
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

  void _setQuery(String query) {
    if (_query == query) return;
    setState(() => _query = query);
    _memory
      ..query = query
      ..scrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  List<String> get _filteredIds {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return ZombieConditions.allIds;
    return ZombieConditions.allIds.where((id) {
      return matchesSelectionSearch(_query, [
        id,
        ConditionL10n.zombieKey(id),
        ConditionL10n.zombieLabel(context, id),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ids = _filteredIds;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.starChallengeSelectConditions ?? 'Select conditions'),
        actions: [
          TextButton(
            onPressed: () => widget.onDone(_selected.toList()..sort()),
            child: Text(l10n?.done ?? 'Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SelectionSearchField(
              hintText: l10n?.search ?? 'Search',
              query: _query,
              useOutlineBorder: true,
              onChanged: _setQuery,
              onClear: () => _setQuery(''),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: ids.length,
              itemBuilder: (context, index) {
                final id = ids[index];
                final label = ConditionL10n.zombieLabel(context, id);
                final checked = _selected.contains(id);
                return CheckboxListTile(
                  value: checked,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selected.add(id);
                      } else {
                        _selected.remove(id);
                      }
                    });
                  },
                  title: Text(label),
                  subtitle: Text(
                    id,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
