import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Ice Age glacier-block zombie weights (`GlacierModuleProperties`).
class GlacierModuleScreen extends StatefulWidget {
  const GlacierModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<GlacierModuleScreen> createState() => _GlacierModuleScreenState();
}

class _GlacierModuleScreenState extends State<GlacierModuleScreen> {
  static const _defaultAlias = 'GlacierModule';
  static const _objClass = 'GlacierModuleProperties';
  late String _alias;
  static const _levelMin = 0;
  static const _levelMax = 10;

  late PvzObject _moduleObj;
  late GlacierModulePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: GlacierModulePropertiesData.createDefault().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = GlacierModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = GlacierModulePropertiesData.createDefault();
    }
  }

  void _sync() {
    _data = GlacierModulePropertiesData(
      zombieSpawnData: GlacierModulePropertiesData.normalizeColumns(
        _data.zombieSpawnData,
      ),
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _updateColumn(int columnIndex, GlacierColumnSpawnData column) {
    final cols = List<GlacierColumnSpawnData>.from(_data.zombieSpawnData);
    cols[columnIndex] = column;
    _data = GlacierModulePropertiesData(zombieSpawnData: cols);
    _sync();
  }

  void _addEntry(int columnIndex) {
    widget.onRequestZombieSelection((id) {
      if (!mounted) return;
      final column = _data.zombieSpawnData[columnIndex];
      _updateColumn(
        columnIndex,
        GlacierColumnSpawnData(
          entries: [
            ...column.entries,
            GlacierSpawnEntryData(typeName: id),
          ],
        ),
      );
    });
  }

  void _removeEntry(int columnIndex, int entryIndex) {
    final column = _data.zombieSpawnData[columnIndex];
    final entries = List<GlacierSpawnEntryData>.from(column.entries)
      ..removeAt(entryIndex);
    _updateColumn(columnIndex, GlacierColumnSpawnData(entries: entries));
  }

  void _updateEntry(
    int columnIndex,
    int entryIndex,
    GlacierSpawnEntryData entry,
  ) {
    final column = _data.zombieSpawnData[columnIndex];
    final entries = List<GlacierSpawnEntryData>.from(column.entries);
    entries[entryIndex] = entry;
    _updateColumn(columnIndex, GlacierColumnSpawnData(entries: entries));
  }

  void _pickZombie(int columnIndex, int entryIndex) {
    widget.onRequestZombieSelection((id) {
      if (!mounted) return;
      final entry = _data.zombieSpawnData[columnIndex].entries[entryIndex];
      _updateEntry(
        columnIndex,
        entryIndex,
        GlacierSpawnEntryData(
          typeName: id,
          weight: entry.weight,
          level: entry.level,
        ),
      );
    });
  }


  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.glacierModuleTitle ?? 'Glacier module';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.glacierModuleHelpTitle ?? title,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.glacierModuleHelpOverviewBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.glacierModuleHelpColumnsTitle ?? 'Columns',
                  body: l10n?.glacierModuleHelpColumnsBody ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.glacierModuleHelpRequirementsTitle ??
                      'Requirements',
                  body: l10n?.glacierModuleHelpRequirementsBody ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
EditorAliasInputField(
          alias: _alias,
          levelFile: widget.levelFile,
          onAliasChanged: _handleAliasChanged,
          onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
          ...List.generate(GlacierModulePropertiesData.columnCount, (col) {
            return _ColumnCard(
              columnIndex: col,
              column: _data.zombieSpawnData[col],
              l10n: l10n,
              onAddEntry: () => _addEntry(col),
              onRemoveEntry: (ei) => _removeEntry(col, ei),
              onUpdateEntry: (ei, entry) => _updateEntry(col, ei, entry),
              onPickZombie: (ei) => _pickZombie(col, ei),
            );
          }),
        ],
      ),
    );
  }
}

class _ColumnCard extends StatelessWidget {
  const _ColumnCard({
    required this.columnIndex,
    required this.column,
    required this.l10n,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onUpdateEntry,
    required this.onPickZombie,
  });

  final int columnIndex;
  final GlacierColumnSpawnData column;
  final AppLocalizations? l10n;
  final VoidCallback onAddEntry;
  final void Function(int entryIndex) onRemoveEntry;
  final void Function(int entryIndex, GlacierSpawnEntryData entry)
  onUpdateEntry;
  final void Function(int entryIndex) onPickZombie;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnLabel =
        l10n?.glacierModuleColumn(columnIndex + 1) ??
        'Column ${columnIndex + 1} (from left)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: columnIndex == 0,
        title: Text(
          columnLabel,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          l10n?.glacierModuleEntryCount(column.entries.length) ??
              '${column.entries.length} entries',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (column.entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n?.glacierModuleNoEntries ??
                          'No zombie entries for this column.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ...column.entries.asMap().entries.map((e) {
                  return _EntryRow(
                    key: ValueKey(
                      'col_${columnIndex}_entry_${e.key}_'
                      '${e.value.typeName}_${e.value.weight}_${e.value.level}',
                    ),
                    entry: e.value,
                    l10n: l10n,
                    onRemove: () => onRemoveEntry(e.key),
                    onUpdate: (entry) => onUpdateEntry(e.key, entry),
                    onPickZombie: () => onPickZombie(e.key),
                  );
                }),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onAddEntry,
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n?.glacierModuleAddEntry ?? 'Add zombie entry',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    super.key,
    required this.entry,
    required this.l10n,
    required this.onRemove,
    required this.onUpdate,
    required this.onPickZombie,
  });

  static const _iconSize = 54.0;
  static const _fieldPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 14,
  );
  static const _fieldMinHeight = 52.0;

  final GlacierSpawnEntryData entry;
  final AppLocalizations? l10n;
  final VoidCallback onRemove;
  final void Function(GlacierSpawnEntryData entry) onUpdate;
  final VoidCallback onPickZombie;

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
    contentPadding: _fieldPadding,
    constraints: const BoxConstraints(minHeight: _fieldMinHeight),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final typeName = entry.typeName;
    final zombie = typeName.isNotEmpty ? repo.getZombieById(typeName) : null;
    final displayName = typeName.isEmpty
        ? (l10n?.glacierModuleEmptyType ?? 'No zombie selected')
        : ResourceNames.lookup(context, repo.getName(typeName));
    final iconPath = zombie?.iconAssetPath;
    final switchLabel =
        l10n?.switchZombie ?? l10n?.switchCustomZombie ?? 'Switch zombie';
    final weightLabel = l10n?.glacierModuleWeight ?? 'Weight';
    final levelLabel = l10n?.glacierModuleLevel ?? 'Level (0–10)';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _iconSize,
              height: _iconSize,
              child: iconPath != null
                  ? AssetImageWidget(
                      assetPath: iconPath,
                      altCandidates: imageAltCandidates(iconPath),
                      width: _iconSize,
                      height: _iconSize,
                    )
                  : Icon(
                      Icons.pest_control_outlined,
                      size: _iconSize * 0.65,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 5,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (typeName.isNotEmpty)
                          Text(
                            typeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onPickZombie,
                    icon: const Icon(Icons.swap_horiz, size: 20),
                    label: Text(switchLabel, overflow: TextOverflow.ellipsis),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Tooltip(
                  message:
                      l10n?.glacierModuleWeightTooltip ??
                      'Spawn weight for this zombie in this column.',
                  child: TextFormField(
                    key: ValueKey('w_${entry.typeName}_${entry.weight}'),
                    initialValue: '${entry.weight}',
                    style: theme.textTheme.bodyLarge,
                    decoration: _fieldDecoration(weightLabel),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) {
                      final w = int.tryParse(v);
                      if (w != null && w > 0) {
                        onUpdate(
                          GlacierSpawnEntryData(
                            typeName: entry.typeName,
                            weight: w,
                            level: entry.level,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Tooltip(
                  message:
                      l10n?.glacierModuleLevelTooltip ?? 'Zombie level (0–10).',
                  child: DropdownButtonFormField<int>(
                    key: ValueKey('lv_${entry.typeName}_${entry.level}'),
                    initialValue: entry.level.clamp(
                      _GlacierModuleScreenState._levelMin,
                      _GlacierModuleScreenState._levelMax,
                    ),
                    isExpanded: true,
                    isDense: true,
                    padding: EdgeInsets.zero,
                    style: theme.textTheme.bodyLarge,
                    iconSize: 22,
                    items: List.generate(
                      _GlacierModuleScreenState._levelMax -
                          _GlacierModuleScreenState._levelMin +
                          1,
                      (i) {
                        final lv = i + _GlacierModuleScreenState._levelMin;
                        return DropdownMenuItem(value: lv, child: Text('$lv'));
                      },
                    ),
                    onChanged: (lv) {
                      if (lv != null) {
                        onUpdate(
                          GlacierSpawnEntryData(
                            typeName: entry.typeName,
                            weight: entry.weight,
                            level: lv,
                          ),
                        );
                      }
                    },
                    decoration: _fieldDecoration(levelLabel),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n?.delete ?? 'Delete',
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
