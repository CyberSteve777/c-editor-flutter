import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Air Drop Ship (DropShip) module editor. Configures waves when imps are dropped.
class AirDropShipModuleScreen extends StatefulWidget {
  const AirDropShipModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.initialDropShipWave,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final int? initialDropShipWave;

  @override
  State<AirDropShipModuleScreen> createState() =>
      _AirDropShipModuleScreenState();
}

class _AirDropShipModuleScreenState extends State<AirDropShipModuleScreen> {
  late PvzObject _moduleObj;
  late DropShipPropertiesData _data;
  int _selectedIndex = -1;
  DropShipAppearWaveData? _itemToDelete;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  bool _isCellInDropRange(int col, int row, DropShipAppearWaveData wave) {
    return col >= wave.colRange.min &&
        col <= wave.colRange.max &&
        row >= wave.rowRange.min &&
        row <= wave.rowRange.max;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedIndex = _resolveInitialIndex();
  }

  int _resolveInitialIndex() {
    if (widget.initialDropShipWave != null) {
      final idx = _data.appearWaves.indexWhere(
        (w) => w.wave == widget.initialDropShipWave,
      );
      if (idx >= 0) return idx;
    }
    return _data.appearWaves.isEmpty ? -1 : 0;
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'DropShipProperties',
        objData: DropShipPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = DropShipPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = DropShipPropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addWave() {
    final newWave = DropShipAppearWaveData(
      wave: _data.appearWaves.isEmpty ? 0 : _data.appearWaves.last.wave + 1,
      imp: 0,
      impLv: 1,
      rowRange: MinMaxRange(min: 0, max: _gridRows - 1),
      colRange: MinMaxRange(min: 0, max: _gridCols - 1),
    );
    _data = DropShipPropertiesData(
      appearWaves: [..._data.appearWaves, newWave],
    );
    _sync();
    setState(() => _selectedIndex = _data.appearWaves.length - 1);
  }

  void _deleteWave(DropShipAppearWaveData target) {
    _data = DropShipPropertiesData(
      appearWaves: _data.appearWaves.where((e) => e != target).toList(),
    );
    _sync();
    if (_selectedIndex >= _data.appearWaves.length) {
      _selectedIndex = _data.appearWaves.isEmpty
          ? -1
          : _data.appearWaves.length - 1;
    }
  }

  void _updateWave(int index, DropShipAppearWaveData updated) {
    if (index < 0 || index >= _data.appearWaves.length) return;
    final list = List<DropShipAppearWaveData>.from(_data.appearWaves);
    list[index] = updated;
    _data = DropShipPropertiesData(appearWaves: list);
    _sync();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = l10n?.airDropShipModuleTitle ?? 'Air Drop Ship';
    final helpTitle = l10n?.airDropShipModuleHelpTitle ?? 'Air Drop Ship help';
    final selectedWave =
        _selectedIndex >= 0 && _selectedIndex < _data.appearWaves.length
        ? _data.appearWaves[_selectedIndex]
        : null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: helpTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.airDropShipModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.airDropShipModuleHelpOverviewBody ??
                      'Configures waves when imps are dropped from the air. Each entry defines wave, extra imp count, imp level, and drop area (row/column range).',
                ),
                HelpSectionData(
                  title: l10n?.airDropShipModuleHelpImps ?? 'Imps',
                  body:
                      l10n?.airDropShipModuleHelpImpsBody ??
                      'Extra imp count is the number of additional imps. At least one imp is always dropped.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.airDropShipModuleAppearances ?? 'Appearances',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._data.appearWaves.asMap().entries.map((e) {
                      final idx = e.key;
                      final w = e.value;
                      final isSelected = _selectedIndex == idx;
                      return InkWell(
                        onTap: () => setState(() => _selectedIndex = idx),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${l10n?.airDropShipGroupLabel ?? "Group"} ${idx + 1}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                ),
                                onPressed: () =>
                                    setState(() => _itemToDelete = w),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Material(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: _addWave,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.add, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedWave != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    key: ValueKey('dropship_panel_$_selectedIndex'),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.appearanceLabel ?? "Appearance"} ${_selectedIndex + 1} - ${l10n?.airDropShipModuleDropArea ?? "Drop area"}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: '${selectedWave.wave}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.moduleWaveFieldZeroBased ??
                                        'Wave (0 = wave 1, 1 = wave 2, ...)',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 0) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: n,
                                          imp: selectedWave.imp,
                                          impLv: selectedWave.impLv,
                                          rowRange: selectedWave.rowRange,
                                          colRange: selectedWave.colRange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: '${selectedWave.imp}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleExtraImpCount ??
                                        'Extra imp count',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 0) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: n,
                                          impLv: selectedWave.impLv,
                                          rowRange: selectedWave.rowRange,
                                          colRange: selectedWave.colRange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue: '${selectedWave.impLv}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleImpLevel ??
                                        'Imp level',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 0) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: selectedWave.imp,
                                          impLv: n,
                                          rowRange: selectedWave.rowRange,
                                          colRange: selectedWave.colRange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      '${selectedWave.rowRange.min + 1}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleRowMin ??
                                        'Minimal row',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 1) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: selectedWave.imp,
                                          impLv: selectedWave.impLv,
                                          rowRange: MinMaxRange(
                                            min: n - 1,
                                            max: selectedWave.rowRange.max,
                                          ),
                                          colRange: selectedWave.colRange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      '${selectedWave.rowRange.max + 1}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleRowMax ??
                                        'Maximal row',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 1) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: selectedWave.imp,
                                          impLv: selectedWave.impLv,
                                          rowRange: MinMaxRange(
                                            min: selectedWave.rowRange.min,
                                            max: n - 1,
                                          ),
                                          colRange: selectedWave.colRange,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      '${selectedWave.colRange.min + 1}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleColMin ??
                                        'Minimal column',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 1) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: selectedWave.imp,
                                          impLv: selectedWave.impLv,
                                          rowRange: selectedWave.rowRange,
                                          colRange: MinMaxRange(
                                            min: n - 1,
                                            max: selectedWave.colRange.max,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  initialValue:
                                      '${selectedWave.colRange.max + 1}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.airDropShipModuleColMax ??
                                        'Maximal column',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 1) {
                                      _updateWave(
                                        _selectedIndex,
                                        DropShipAppearWaveData(
                                          wave: selectedWave.wave,
                                          imp: selectedWave.imp,
                                          impLv: selectedWave.impLv,
                                          rowRange: selectedWave.rowRange,
                                          colRange: MinMaxRange(
                                            min: selectedWave.colRange.min,
                                            max: n - 1,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.airDropShipModuleDropAreaPreview ??
                                'Drop area preview',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
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
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: _gridCols,
                                        childAspectRatio: 1,
                                      ),
                                  itemCount: _gridCols * _gridRows,
                                  itemBuilder: (context, i) {
                                    final col = i % _gridCols;
                                    final row = i ~/ _gridCols;
                                    final inRange = _isCellInDropRange(
                                      col,
                                      row,
                                      selectedWave,
                                    );
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: inRange
                                            ? Colors.orange.withValues(
                                                alpha: 0.5,
                                              )
                                            : theme
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        border: Border.all(
                                          color:
                                              theme.colorScheme.outlineVariant,
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
                ],
              ],
            ),
          ),
          if (_itemToDelete != null) _buildDeleteDialog(),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final item = _itemToDelete!;
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm(
              '${l10n.airDropShipGroupLabel} ${_data.appearWaves.indexOf(item) + 1}',
            ) ??
            'Remove group ${_data.appearWaves.indexOf(item) + 1}?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _itemToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _deleteWave(item);
            setState(() => _itemToDelete = null);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n?.remove ?? 'Remove'),
        ),
      ],
    );
  }
}
