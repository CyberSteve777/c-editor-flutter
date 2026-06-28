import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/widgets/editor_components.dart'
    show
        editorInputDecoration,
        HelpSectionData,
        scaleTableForDesktop,
        showEditorHelpDialog;

/// Editor for PVZ1-style passage (portal) combat module properties.
class PVZ1PassageModuleScreen extends StatefulWidget {
  const PVZ1PassageModuleScreen({
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
  State<PVZ1PassageModuleScreen> createState() =>
      _PVZ1PassageModuleScreenState();
}

class _FieldSpec {
  const _FieldSpec({
    required this.label,
    required this.tooltip,
    required this.getter,
    required this.setter,
  });

  final String label;
  final String tooltip;
  final int Function(PVZ1PassageModulePropertiesData) getter;
  final void Function(PVZ1PassageModulePropertiesData, int) setter;
}

class _PVZ1PassageModuleScreenState extends State<PVZ1PassageModuleScreen> {
  static const _objClass = 'PVZ1PassageModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PVZ1PassageModulePropertiesData _data;
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  /// Highest valid column index for this lawn (0-based).
  int get _maxColIndex => _gridCols > 0 ? _gridCols - 1 : 0;

  bool _isPortalColumn(int col) {
    return col >= _data.gridXMin && col <= _data.gridXMax;
  }

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _focusNodes = List.generate(6, (_) => FocusNode());
    for (final n in _focusNodes) {
      n.addListener(() => setState(() {}));
    }
    _controllers = [
      TextEditingController(text: '${_data.groupAmount}'),
      TextEditingController(text: '${_data.passageAmount}'),
      TextEditingController(text: '${_data.gridXMin}'),
      TextEditingController(text: '${_data.gridXMax}'),
      TextEditingController(text: '${_data.transferCooldown}'),
      TextEditingController(text: '${_data.refreshTime}'),
    ];
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
        objClass: 'PVZ1PassageModuleProperties',
        objData: PVZ1PassageModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PVZ1PassageModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PVZ1PassageModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _focusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  List<_FieldSpec> _fieldSpecs(AppLocalizations? l10n, int maxColIndex) {
    final colRangeLabel =
        l10n?.pvz1PassageGridColumnRange(maxColIndex) ?? '0–$maxColIndex';
    return [
      _FieldSpec(
        label:
            l10n?.pvz1PassageFieldGroupAmount ?? 'Group amount (GroupAmount)',
        tooltip:
            l10n?.pvz1PassageHelpGroupAmount ??
            'Number of distinct portal group types.',
        getter: (d) => d.groupAmount,
        setter: (d, v) => d.groupAmount = v,
      ),
      _FieldSpec(
        label:
            l10n?.pvz1PassageFieldPassageAmount ??
            'Passages per group (PassageAmount)',
        tooltip:
            l10n?.pvz1PassageHelpPassageAmount ??
            'How many portals exist in each group.',
        getter: (d) => d.passageAmount,
        setter: (d, v) => d.passageAmount = v,
      ),
      _FieldSpec(
        label:
            '${l10n?.pvz1PassageFieldGridXMin ?? 'Minimum spawn column (GridXMin)'} '
            '($colRangeLabel)',
        tooltip:
            l10n?.pvz1PassageHelpGridXMin(maxColIndex) ??
            'Minimum lawn column where portals can spawn (0–$maxColIndex on this lawn).',
        getter: (d) => d.gridXMin,
        setter: (d, v) => d.gridXMin = v,
      ),
      _FieldSpec(
        label:
            '${l10n?.pvz1PassageFieldGridXMax ?? 'Maximum spawn column (GridXMax)'} '
            '($colRangeLabel)',
        tooltip:
            l10n?.pvz1PassageHelpGridXMax(maxColIndex) ??
            'Maximum lawn column where portals can spawn (0–$maxColIndex on this lawn).',
        getter: (d) => d.gridXMax,
        setter: (d, v) => d.gridXMax = v,
      ),
      _FieldSpec(
        label:
            l10n?.pvz1PassageFieldTransferCooldown ??
            'Per-zombie transfer cooldown (transferCooldown)',
        tooltip:
            l10n?.pvz1PassageHelpTransferCooldown ??
            'Minimum time between teleports for the same zombie.',
        getter: (d) => d.transferCooldown,
        setter: (d, v) => d.transferCooldown = v,
      ),
      _FieldSpec(
        label:
            l10n?.pvz1PassageFieldRefreshTime ??
            'Portal reposition interval (refreshTime)',
        tooltip:
            l10n?.pvz1PassageHelpRefreshTime ??
            'How often portal positions are regenerated.',
        getter: (d) => d.refreshTime,
        setter: (d, v) => d.refreshTime = v,
      ),
    ];
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
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzBrownDark : pvzBrownLight;
    final maxCol = _maxColIndex;
    final specs = _fieldSpecs(l10n, maxCol);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                title: l10n?.pvz1PassageModuleTitle ?? 'Portal combat',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.pvz1PassageHelpOverview ??
                        'PVZ1-style passage portals: configure how many portal groups appear, '
                            'how many portals per group, spawn columns on the lawn, and timing '
                            'for zombie teleports and portal repositioning.',
                  ),
                  HelpSectionData(
                    title: l10n?.pvz1PassageHelpFieldsTitle ?? 'Fields',
                    body: specs
                        .map((s) => '${s.label}\n${s.tooltip}')
                        .join('\n\n'),
                  ),
                  HelpSectionData(
                    title: l10n?.pvz1PassageHelpPreview ?? 'Preview',
                    body:
                        l10n?.pvz1PassageHelpPreviewBody(maxCol) ??
                        'Highlighted columns match GridXMin–GridXMax (inclusive). '
                            'On this lawn, valid column indices are 0–$maxCol.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
                Text(
                  l10n?.pvz1PassageSectionParams ?? 'Portal parameters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < specs.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  TextField(
                    focusNode: _focusNodes[i],
                    controller: _controllers[i],
                    keyboardType: TextInputType.number,
                    decoration: editorInputDecoration(
                      context,
                      labelText: specs[i].label,
                      focusColor: accentColor,
                      isFocused: _focusNodes[i].hasFocus,
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) {
                        specs[i].setter(_data, n);
                        _sync();
                      }
                    },
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n?.pvz1PassagePortalSpawnPreview ??
                      'Portal column preview',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 12),
                scaleTableForDesktop(
                  context: context,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: AspectRatio(
                      aspectRatio: _gridCols / _gridRows,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridCols,
                          childAspectRatio: 1,
                        ),
                        itemCount: _gridCols * _gridRows,
                        itemBuilder: (context, i) {
                          final col = i % _gridCols;
                          final inRange = _isPortalColumn(col);
                          return Container(
                            decoration: BoxDecoration(
                              color: inRange
                                  ? Colors.orange.withValues(alpha: 0.45)
                                  : theme.colorScheme.surfaceContainerHighest,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
