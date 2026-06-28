import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Pirate plank properties editor. Ported from Z-Editor-master PiratePlankPropertiesEP.kt
class PiratePlankPropertiesScreen extends StatefulWidget {
  const PiratePlankPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<PiratePlankPropertiesScreen> createState() =>
      _PiratePlankPropertiesScreenState();
}

class _PiratePlankPropertiesScreenState
    extends State<PiratePlankPropertiesScreen> {
  static const _objClass = 'PiratePlankProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PiratePlankPropertiesData _data;
  bool _isPirateStage = false;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

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
        objClass: 'PiratePlankProperties',
        objData: PiratePlankPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PiratePlankPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PiratePlankPropertiesData();
    }
    final stageInfo = RtidParser.parse(widget.levelDef.stageModule);
    final stageObjClass = stageInfo?.alias != null
        ? ReferenceRepository.instance.getObjClass(stageInfo!.alias)
        : null;
    _isPirateStage = stageObjClass == 'PirateStageProperties';
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasPlank(int row) => _data.plankRows.contains(row);

  void _setPlank(int row, bool value) {
    final rows = List<int>.from(_data.plankRows);
    if (value) {
      if (!rows.contains(row)) {
        rows.add(row);
        rows.sort();
      }
    } else {
      rows.remove(row);
    }
    _data = PiratePlankPropertiesData(plankRows: rows);
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
      ),
      body: SingleChildScrollView(
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
            if (!_isPirateStage) ...[
              Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        editorErrorIcon,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.stageMismatch ?? 'Stage mismatch',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.currentStageNotPirate ??
                                  'Current stage is not Pirate. This module may not work correctly.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              _gridRows == 5
                  ? (l10n?.plankRows ?? 'Plank rows (0–4)')
                  : (l10n?.plankRowsDeepSea ?? 'Plank rows (0–5)'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: List.generate(_gridRows, (row) {
                  final hasDivider = row < _gridRows - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n?.rowN(row + 1) ?? 'Row ${row + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    l10n?.indexN(row) ?? 'Index: $row',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _hasPlank(row),
                              onChanged: (v) => _setPlank(row, v),
                            ),
                          ],
                        ),
                      ),
                      if (hasDivider)
                        Divider(
                          height: 1,
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                    ],
                  );
                }),
              ),
            ),
            if (_data.plankRows.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.selectedRowsLabel ?? 'Selected rows:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _data.plankRows
                            .map((r) => l10n?.rowN(r + 1) ?? 'Row ${r + 1}')
                            .join(', '),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
