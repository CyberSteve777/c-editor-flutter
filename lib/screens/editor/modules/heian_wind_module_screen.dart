import 'package:flutter/material.dart';
import 'package:z_editor/data/level_parser.dart';
import 'package:z_editor/data/pvz_models.dart';
import 'package:z_editor/data/rtid_parser.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/widgets/editor_components.dart';

/// Heian Wind module editor. Configures winds that affect zombies on waves.
class HeianWindModuleScreen extends StatefulWidget {
  const HeianWindModuleScreen({
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
  State<HeianWindModuleScreen> createState() => _HeianWindModuleScreenState();
}

class _HeianWindModuleScreenState extends State<HeianWindModuleScreen> {
  late PvzObject _moduleObj;
  late HeianWindModulePropertiesData _data;
  int _selectedWaveIndex = -1;
  HeianWindWaveWindInfoData? _waveToDelete;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'HeianWindModuleProperties',
        objData: HeianWindModulePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = HeianWindModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = HeianWindModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addWave() {
    final newWave = HeianWindWaveWindInfoData(
      waveNumber: _data.waveWindInfos.isEmpty
          ? 0
          : _data.waveWindInfos.last.waveNumber + 1,
      windDelay: 3,
      windInfos: [],
    );
    _data = HeianWindModulePropertiesData(
      waveWindInfos: [..._data.waveWindInfos, newWave],
    );
    _sync();
    setState(() => _selectedWaveIndex = _data.waveWindInfos.length - 1);
  }

  void _deleteWave(HeianWindWaveWindInfoData target) {
    _data = HeianWindModulePropertiesData(
      waveWindInfos: _data.waveWindInfos.where((e) => e != target).toList(),
    );
    _sync();
    if (_selectedWaveIndex >= _data.waveWindInfos.length) {
      _selectedWaveIndex = _data.waveWindInfos.isEmpty
          ? -1
          : _data.waveWindInfos.length - 1;
    }
  }

  void _updateWave(int index, HeianWindWaveWindInfoData updated) {
    if (index < 0 || index >= _data.waveWindInfos.length) return;
    final list = List<HeianWindWaveWindInfoData>.from(_data.waveWindInfos);
    list[index] = updated;
    _data = HeianWindModulePropertiesData(waveWindInfos: list);
    _sync();
  }

  void _addWind(int waveIndex) {
    if (waveIndex < 0 || waveIndex >= _data.waveWindInfos.length) return;
    final wave = _data.waveWindInfos[waveIndex];
    final winds = [...wave.windInfos, HeianWindInfoData()];
    _updateWave(
      waveIndex,
      HeianWindWaveWindInfoData(
        waveNumber: wave.waveNumber,
        windDelay: wave.windDelay,
        windInfos: winds,
      ),
    );
  }

  void _removeWind(int waveIndex, int windIndex) {
    if (waveIndex < 0 || waveIndex >= _data.waveWindInfos.length) return;
    final wave = _data.waveWindInfos[waveIndex];
    final winds = List<HeianWindInfoData>.from(wave.windInfos)
      ..removeAt(windIndex);
    _updateWave(
      waveIndex,
      HeianWindWaveWindInfoData(
        waveNumber: wave.waveNumber,
        windDelay: wave.windDelay,
        windInfos: winds,
      ),
    );
  }

  void _updateWind(int waveIndex, int windIndex, HeianWindInfoData updated) {
    if (waveIndex < 0 || waveIndex >= _data.waveWindInfos.length) return;
    final wave = _data.waveWindInfos[waveIndex];
    final winds = List<HeianWindInfoData>.from(wave.windInfos);
    if (windIndex < 0 || windIndex >= winds.length) return;
    winds[windIndex] = updated;
    _updateWave(
      waveIndex,
      HeianWindWaveWindInfoData(
        waveNumber: wave.waveNumber,
        windDelay: wave.windDelay,
        windInfos: winds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = l10n?.heianWindModuleTitle ?? 'Heian Wind';
    final helpTitle = l10n?.heianWindModuleHelpTitle ?? 'Heian Wind help';
    final selectedWave =
        _selectedWaveIndex >= 0 &&
            _selectedWaveIndex < _data.waveWindInfos.length
        ? _data.waveWindInfos[_selectedWaveIndex]
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
                  title: l10n?.heianWindModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.heianWindModuleHelpOverviewBody ??
                      'Configures winds on specific waves. Winds push zombies and can summon tornados on single rows that carry zombies forward and blow away plants.',
                ),
                HelpSectionData(
                  title: l10n?.heianWindModuleHelpDistance ?? 'Distance',
                  body:
                      l10n?.heianWindModuleHelpDistanceBody ??
                      'Distance of 50 equals one grid cell. Negative values move zombies to the left; positive values move them to the right.',
                ),
                HelpSectionData(
                  title: l10n?.heianWindModuleHelpRow ?? 'Row',
                  body:
                      l10n?.heianWindModuleHelpRowBody ??
                      'You can specify any row or all rows at once. Winds on single rows also summon a tornado that carries zombies forward and blows away a plant.',
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
                  l10n?.heianWindModuleWaves ?? 'Waves with wind',
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
                    ..._data.waveWindInfos.asMap().entries.map((e) {
                      final idx = e.key;
                      final w = e.value;
                      final isSelected = _selectedWaveIndex == idx;
                      return InkWell(
                        onTap: () => setState(() => _selectedWaveIndex = idx),
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
                                '${l10n?.waveLabel ?? "W"} ${w.waveNumber}',
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
                                    setState(() => _waveToDelete = w),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n?.waveLabel ?? "Wave"} ${selectedWave.waveNumber}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: '${selectedWave.windDelay}',
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.heianWindModuleWindDelay ??
                                        'Wind delay',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) {
                                    final n = int.tryParse(v);
                                    if (n != null && n >= 0) {
                                      _updateWave(
                                        _selectedWaveIndex,
                                        HeianWindWaveWindInfoData(
                                          waveNumber: selectedWave.waveNumber,
                                          windDelay: n,
                                          windInfos: selectedWave.windInfos,
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
                            l10n?.heianWindModuleWindEntries ?? 'Wind entries',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...selectedWave.windInfos.asMap().entries.map((e) {
                            final windIdx = e.key;
                            final wind = e.value;
                            return _buildWindEntry(
                              theme,
                              l10n,
                              wind,
                              (updated) => _updateWind(
                                _selectedWaveIndex,
                                windIdx,
                                updated,
                              ),
                              () => _removeWind(_selectedWaveIndex, windIdx),
                            );
                          }),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => _addWind(_selectedWaveIndex),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(
                              l10n?.heianWindModuleAddWind ?? 'Add wind',
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
          if (_waveToDelete != null) _buildDeleteDialog(),
        ],
      ),
    );
  }

  Widget _buildWindEntry(
    ThemeData theme,
    AppLocalizations? l10n,
    HeianWindInfoData wind,
    void Function(HeianWindInfoData) onUpdate,
    VoidCallback onRemove,
  ) {
    final dropdownValue = wind.row >= -1 && wind.row < _gridRows
        ? wind.row
        : -1;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: dropdownValue,
                    decoration: InputDecoration(
                      labelText: l10n?.heianWindModuleRow ?? 'Row',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: -1,
                        child: Text(l10n?.heianWindModuleAllRows ?? 'All rows'),
                      ),
                      ...List.generate(
                        _gridRows,
                        (i) => DropdownMenuItem(
                          value: i,
                          child: Text('${l10n?.row ?? "Row"} ${i + 1}'),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        onUpdate(
                          HeianWindInfoData(
                            row: v,
                            affectZombies: wind.affectZombies,
                            distance: wind.distance,
                            moveTime: wind.moveTime,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '${wind.affectZombies}',
                    decoration: InputDecoration(
                      labelText:
                          l10n?.heianWindModuleAffectZombies ??
                          'Affect zombies',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 0) {
                        onUpdate(
                          HeianWindInfoData(
                            row: wind.row,
                            affectZombies: n,
                            distance: wind.distance,
                            moveTime: wind.moveTime,
                          ),
                        );
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '${wind.distance}',
                    decoration: InputDecoration(
                      labelText: l10n?.heianWindModuleDistance ?? 'Distance',
                      hintText: '50 = 1 cell',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null) {
                        onUpdate(
                          HeianWindInfoData(
                            row: wind.row,
                            affectZombies: wind.affectZombies,
                            distance: n,
                            moveTime: wind.moveTime,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '${wind.moveTime}',
                    decoration: InputDecoration(
                      labelText: l10n?.heianWindModuleMoveTime ?? 'Move time',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) {
                      final n = double.tryParse(v);
                      if (n != null && n > 0) {
                        onUpdate(
                          HeianWindInfoData(
                            row: wind.row,
                            affectZombies: wind.affectZombies,
                            distance: wind.distance,
                            moveTime: n,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final wave = _waveToDelete!;
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        (l10n?.removeItemConfirm('${l10n.waveLabel} ${wave.waveNumber}')) ??
            'Remove wave ${wave.waveNumber}?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _waveToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _deleteWave(wave);
            setState(() => _waveToDelete = null);
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
