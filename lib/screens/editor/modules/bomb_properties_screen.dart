import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/widgets/explosive_barrels_preview_grid.dart';

/// Bomb properties (barrel/cherry bomb fuze) editor.
class BombPropertiesScreen extends StatefulWidget {
  const BombPropertiesScreen({
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
  State<BombPropertiesScreen> createState() => _BombPropertiesScreenState();
}

class _BombPropertiesScreenState extends State<BombPropertiesScreen> {
  static const _objClass = 'BombProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late BombPropertiesData _data;
  late BombPropertiesData _initialData;
  late Map<String, dynamic> _initialObjData;
  late TextEditingController _flameSpeedCtrl;

  static const _fuseLengthEquality = ListEquality<String>();

  Map<String, dynamic> _copyJsonMap(Map<String, dynamic> value) =>
      jsonDecode(jsonEncode(value)) as Map<String, dynamic>;

  void _normalizeFuseLengthsForGrid() {
    final dims = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    final expectedRows = dims.$1;
    final maxLength = dims.$2;
    final current = _data.fuseLengths;
    final adjusted = List<String>.generate(expectedRows, (index) {
      final raw = index < current.length ? current[index] : '8';
      final parsed = num.tryParse(raw)?.toInt() ?? 8;
      return parsed.clamp(0, maxLength).toInt().toString();
    });
    _data = BombPropertiesData(
      flameSpeed: _data.flameSpeed,
      fuseLengths: adjusted,
    );
  }

  bool get _matchesInitialData =>
      _data.flameSpeed == _initialData.flameSpeed &&
      _fuseLengthEquality.equals(_data.fuseLengths, _initialData.fuseLengths);

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  @override
  void dispose() {
    _flameSpeedCtrl.dispose();
    super.dispose();
  }

  void _loadData() {
    final alias = _alias;
    var addedModule = false;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'BombProperties',
        objData: BombPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
      addedModule = true;
    }
    final rawData = _moduleObj.objData is Map
        ? Map<String, dynamic>.from(_moduleObj.objData as Map)
        : <String, dynamic>{};
    _initialObjData = _copyJsonMap(rawData);
    try {
      _data = BombPropertiesData.fromJson(rawData);
    } catch (_) {
      _data = BombPropertiesData();
    }
    _normalizeFuseLengthsForGrid();
    _initialData = BombPropertiesData(
      flameSpeed: _data.flameSpeed,
      fuseLengths: List<String>.from(_data.fuseLengths),
    );
    if (addedModule) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged();
      });
    }
    _flameSpeedCtrl = TextEditingController(text: _data.flameSpeed.toString());
  }

  void _sync() {
    _moduleObj.objData = _matchesInitialData
        ? _copyJsonMap(_initialObjData)
        : _data.toJson();
    widget.onChanged();
    setState(() {});
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
    final theme = Theme.of(context);
    final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(
      widget.levelFile,
    );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.bombProperties ?? 'Bomb properties',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.bombPropertiesHelpBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.bombPropertiesHelpFuse ?? 'Fuse lengths',
                  body: l10n?.bombPropertiesHelpFuseBody ?? '',
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
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bombPropertiesFlameSpeed ??
                            'Flame speed (FlameSpeed)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('bombFlameSpeedField'),
                        controller: _flameSpeedCtrl,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final n = double.tryParse(v);
                          if (n != null) {
                            _data = BombPropertiesData(
                              flameSpeed: n,
                              fuseLengths: _data.fuseLengths,
                            );
                            _sync();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.bombPropertiesFuseLengths ??
                            'Fuse lengths (FuseLengths)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.bombPropertiesFuseLengthsHint ??
                            'One value per row (0–4 standard, 0–5 Deep Sea). Array size auto-adjusts on open.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_data.fuseLengths.length, (i) {
                        final parsed = int.tryParse(_data.fuseLengths[i]) ?? 8;
                        final fuseLength = parsed.clamp(0, gridCols).toInt();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            key: ValueKey('bombFuseLengthStepper-$i'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: EditorResponsiveStepperRow(
                              label: l10n?.rowN(i + 1) ?? 'Row ${i + 1}',
                              value: fuseLength,
                              min: 0,
                              max: gridCols,
                              decreaseIcon: Icons.remove,
                              increaseIcon: Icons.add,
                              decreaseKey: ValueKey(
                                'bombFuseLengthDecrease-$i',
                              ),
                              increaseKey: ValueKey(
                                'bombFuseLengthIncrease-$i',
                              ),
                              onChanged: (value) {
                                final lengths = List<String>.from(
                                  _data.fuseLengths,
                                );
                                lengths[i] = value.toString();
                                _data = BombPropertiesData(
                                  flameSpeed: _data.flameSpeed,
                                  fuseLengths: lengths,
                                );
                                _sync();
                              },
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      scaleTableForDesktop(
                        context: context,
                        child: ExplosiveBarrelsPreviewGrid(
                          key: const ValueKey('bombFuseLengthPreviewGrid'),
                          rows: gridRows,
                          cols: gridCols,
                          fuseLengths: _data.fuseLengths,
                          style: resolveGridStyle(
                            context,
                            GridPreviewModuleKind.explosiveBarrels,
                          ),
                          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
