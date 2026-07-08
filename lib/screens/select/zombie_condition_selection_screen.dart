import 'package:flutter/material.dart';
import 'package:c_editor/data/condition_l10n.dart';
import 'package:c_editor/data/zombie_conditions.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Multi-select zombie conditions with checkboxes (for star challenges).
class ZombieConditionSelectionScreen extends StatefulWidget {
  const ZombieConditionSelectionScreen({
    super.key,
    required this.initialSelected,
    required this.onDone,
    required this.onBack,
  });

  final List<String> initialSelected;
  final void Function(List<String> selected) onDone;
  final VoidCallback onBack;

  @override
  State<ZombieConditionSelectionScreen> createState() =>
      _ZombieConditionSelectionScreenState();
}

class _ZombieConditionSelectionScreenState
    extends State<ZombieConditionSelectionScreen> {
  late final Set<String> _selected;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initialSelected};
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
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
          ),
          Expanded(
            child: ListView.builder(
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
