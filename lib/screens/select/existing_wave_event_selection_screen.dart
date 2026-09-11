import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

/// One reusable wave-event object already present in the level.
class ExistingWaveEventEntry {
  const ExistingWaveEventEntry({
    required this.rtid,
    required this.alias,
    required this.objClass,
    required this.waveIndexes,
  });

  final String rtid;
  final String alias;
  final String objClass;
  final List<int> waveIndexes;
}

/// Lists existing wave-event objects so a wave can reuse (reference) one.
class ExistingWaveEventSelectionScreen extends StatefulWidget {
  const ExistingWaveEventSelectionScreen({
    super.key,
    required this.waveIndex,
    required this.levelFile,
    required this.waveManager,
    required this.onEventSelected,
    required this.onBack,
  });

  final int waveIndex;
  final PvzLevelFile levelFile;
  final WaveManagerData waveManager;
  final void Function(String rtid) onEventSelected;
  final VoidCallback onBack;

  static List<ExistingWaveEventEntry> collectEntries({
    required PvzLevelFile levelFile,
    required WaveManagerData waveManager,
  }) {
    final waveIndexesByRtid = <String, List<int>>{};
    for (var i = 0; i < waveManager.waves.length; i++) {
      for (final rtid in waveManager.waves[i]) {
        waveIndexesByRtid.putIfAbsent(rtid, () => <int>[]).add(i + 1);
      }
    }

    final entries = <ExistingWaveEventEntry>[];
    for (final obj in levelFile.objects) {
      final meta = EventRegistry.getByObjClass(obj.objClass);
      if (meta == null) continue;
      final alias = obj.aliases?.firstOrNull;
      if (alias == null || alias.isEmpty) continue;
      final rtid = RtidParser.build(alias, 'CurrentLevel');
      entries.add(
        ExistingWaveEventEntry(
          rtid: rtid,
          alias: alias,
          objClass: obj.objClass,
          waveIndexes: List<int>.from(waveIndexesByRtid[rtid] ?? const <int>[]),
        ),
      );
    }
    entries.sort((a, b) => a.alias.toLowerCase().compareTo(b.alias.toLowerCase()));
    return entries;
  }

  @override
  State<ExistingWaveEventSelectionScreen> createState() =>
      _ExistingWaveEventSelectionScreenState();
}

class _ExistingWaveEventSelectionScreenState
    extends State<ExistingWaveEventSelectionScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final all = ExistingWaveEventSelectionScreen.collectEntries(
      levelFile: widget.levelFile,
      waveManager: widget.waveManager,
    );
    final filtered = all.where((entry) {
      if (_query.trim().isEmpty) return true;
      final meta = EventRegistry.getByObjClass(entry.objClass);
      final title = EventSelectionScreen.resolveEventTitle(context, meta, l10n);
      return matchesSelectionSearch(_query, [
        entry.alias,
        entry.objClass,
        title,
      ]);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.reuseExistingEventForWave(widget.waveIndex) ??
              'Reuse event for wave ${widget.waveIndex}',
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n?.search ?? 'Search',
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      all.isEmpty
                          ? (l10n?.reuseExistingEventEmpty ??
                                'No events in this level yet')
                          : (l10n?.noResultsFor(_query) ??
                                'No results for "$_query"'),
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = filtered[index];
                      final meta = EventRegistry.getByObjClass(entry.objClass);
                      final title = EventSelectionScreen.resolveEventTitle(
                        context,
                        meta,
                        l10n,
                      );
                      final wavesLabel = entry.waveIndexes.isEmpty
                          ? (l10n?.reuseExistingEventUnused ?? 'Not used in any wave')
                          : (l10n?.reuseExistingEventUsedInWaves(
                                  entry.waveIndexes.join(', ')) ??
                                'Waves: ${entry.waveIndexes.join(', ')}');
                      final color = meta?.color ?? theme.colorScheme.primary;
                      return Card(
                        child: ListTile(
                          leading: meta?.assetIconPath == null
                              ? Icon(meta?.icon ?? Icons.event, color: color)
                              : SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: AssetImageWidget(
                                    assetPath: meta!.assetIconPath!,
                                    fit: BoxFit.contain,
                                    altCandidates: imageAltCandidates(
                                      meta.assetIconPath!,
                                    ),
                                  ),
                                ),
                          title: Text(entry.alias),
                          subtitle: Text(
                            [
                              if (title.isNotEmpty) title,
                              wavesLabel,
                            ].join('\n'),
                          ),
                          isThreeLine: true,
                          onTap: () => widget.onEventSelected(entry.rtid),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
