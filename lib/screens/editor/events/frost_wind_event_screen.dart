import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Frost wind event editor. Ported from Z-Editor-master FrostWindEventEP.kt
class FrostWindEventScreen extends StatefulWidget {
  const FrostWindEventScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<FrostWindEventScreen> createState() => _FrostWindEventScreenState();
}

class _FrostWindEventScreenState extends State<FrostWindEventScreen> {
  static const _objClass = 'FrostWindWaveActionProps';

  late PvzObject _moduleObj;
  late FrostWindWaveActionPropsData _data;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;

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
        objData: FrostWindWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = FrostWindWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = FrostWindWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addWind() {
    _data = FrostWindWaveActionPropsData(
      winds: [
        ..._data.winds,
        FrostWindData(row: 2, direction: 'right'),
      ],
    );
    _sync();
  }

  void _updateWind(int index, FrostWindData wind) {
    final winds = List<FrostWindData>.from(_data.winds);
    winds[index] = wind;
    _data = FrostWindWaveActionPropsData(winds: winds);
    _sync();
  }

  void _removeWind(int index) {
    final winds = List<FrostWindData>.from(_data.winds)..removeAt(index);
    _data = FrostWindWaveActionPropsData(winds: winds);
    _sync();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.eventFrostWind ?? 'Frost wind event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpFrostWindBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.direction ?? 'Direction',
                  body: l10n?.eventHelpFrostWindDirection ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorAliasInputField(
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              ..._data.winds.asMap().entries.map((e) {
                final idx = e.key;
                final wind = e.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.ac_unit,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.windN(idx + 1) ?? 'Wind #${idx + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeWind(idx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              l10n?.rowNShort(wind.row + 1) ??
                                  'Row: ${wind.row + 1}',
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                ChoiceChip(
                                  label: Text(l10n?.left ?? 'Left'),
                                  selected: wind.direction == 'left',
                                  onSelected: (_) => _updateWind(
                                    idx,
                                    FrostWindData(
                                      row: wind.row,
                                      direction: 'left',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: Text(l10n?.right ?? 'Right'),
                                  selected:
                                      wind.direction == 'right' ||
                                      wind.direction.isEmpty,
                                  onSelected: (_) => _updateWind(
                                    idx,
                                    FrostWindData(
                                      row: wind.row,
                                      direction: 'right',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: wind.row > 0
                                  ? () => _updateWind(
                                      idx,
                                      FrostWindData(
                                        row: wind.row - 1,
                                        direction: wind.direction,
                                      ),
                                    )
                                  : null,
                            ),
                            Text(
                              l10n?.rowNShort(wind.row + 1) ??
                                  'Row ${wind.row + 1}',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: wind.row < _maxRowIndex
                                  ? () => _updateWind(
                                      idx,
                                      FrostWindData(
                                        row: wind.row + 1,
                                        direction: wind.direction,
                                      ),
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              FilledButton.icon(
                onPressed: _addWind,
                icon: const Icon(Icons.add),
                label: Text(l10n?.addWind ?? 'Add wind'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
