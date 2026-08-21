import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';
import 'package:c_editor/widgets/grid_override_wave_groups_bar.dart';

class RadiationMeteorModuleScreen extends StatefulWidget {
  const RadiationMeteorModuleScreen({
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
  State<RadiationMeteorModuleScreen> createState() =>
      _RadiationMeteorModuleScreenState();
}

class _RadiationMeteorModuleScreenState
    extends State<RadiationMeteorModuleScreen> {
  static const _objClass = 'RadiationMeteorModuleProperties';
  static const _asset = 'assets/images/griditems/radiation_meteor_ore.webp';

  late String _alias;
  late PvzObject _moduleObject;
  late RadiationMeteorModulePropertiesData _data;
  late TextEditingController _warningCtrl;
  late TextEditingController _pollutionCtrl;
  late TextEditingController _miningCtrl;
  late TextEditingController _rewardCtrl;
  late List<int> _waveGroups;
  int _selectedGroupIndex = 0;
  int _selectedX = 0;
  int _selectedY = 0;

  int get _gridRows =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$1;
  int get _gridCols =>
      LevelParser.getGridDimensionsFromFile(widget.levelFile).$2;
  int? get _selectedWave =>
      _selectedGroupIndex >= 0 && _selectedGroupIndex < _waveGroups.length
      ? _waveGroups[_selectedGroupIndex]
      : null;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _moduleObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: RadiationMeteorModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = RadiationMeteorModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = RadiationMeteorModulePropertiesData();
    }
    _waveGroups =
        _data.spawnSchedule.map((entry) => entry.wave).toSet().toList()..sort();
    if (_waveGroups.isEmpty) _waveGroups.add(1);
    if (_data.spawnSchedule.isNotEmpty) {
      _selectedX = _data.spawnSchedule.first.gridX;
      _selectedY = _data.spawnSchedule.first.gridY;
    }
    _warningCtrl = TextEditingController(text: '${_data.warningDuration}');
    _pollutionCtrl = TextEditingController(text: '${_data.pollutionInterval}');
    _miningCtrl = TextEditingController(
      text: '${_data.miningDurationRequired}',
    );
    _rewardCtrl = TextEditingController(text: '${_data.powerRewardOnDestroy}');
  }

  @override
  void dispose() {
    _warningCtrl.dispose();
    _pollutionCtrl.dispose();
    _miningCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _hasAt(int col, int row) {
    final wave = _selectedWave;
    return wave != null &&
        _data.spawnSchedule.any(
          (entry) =>
              entry.wave == wave && entry.gridX == col && entry.gridY == row,
        );
  }

  void _tapCell(int col, int row) {
    setState(() {
      _selectedX = col;
      _selectedY = row;
    });
    if (_hasAt(col, row)) {
      return;
    }
    final wave = _selectedWave;
    if (wave == null) return;
    _data.spawnSchedule.add(
      RadiationMeteorSpawnData(wave: wave, gridX: col, gridY: row),
    );
    _sync();
  }

  void _removeAt(int col, int row) {
    final wave = _selectedWave;
    if (wave == null) return;
    _data.spawnSchedule.removeWhere(
      (entry) => entry.wave == wave && entry.gridX == col && entry.gridY == row,
    );
    _sync();
  }

  void _addWaveGroup() {
    final nextWave = _waveGroups.isEmpty ? 1 : _waveGroups.last + 1;
    setState(() {
      _waveGroups.add(nextWave);
      _selectedGroupIndex = _waveGroups.length - 1;
    });
  }

  void _updateSelectedWave(int wave) {
    final oldWave = _selectedWave;
    if (oldWave == null || wave < 1 || wave == oldWave) return;
    if (_waveGroups.contains(wave)) return;
    for (final entry in _data.spawnSchedule) {
      if (entry.wave == oldWave) entry.wave = wave;
    }
    _waveGroups[_selectedGroupIndex] = wave;
    _sync();
  }

  Future<void> _confirmDeleteWaveGroup(int index) async {
    if (index < 0 || index >= _waveGroups.length) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.removeItem ?? 'Remove item'),
        content: Text(
          l10n?.removeItemConfirm(l10n.groupN(index + 1)) ??
              'Remove group ${index + 1}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n?.remove ?? 'Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final wave = _waveGroups[index];
    _data.spawnSchedule.removeWhere((entry) => entry.wave == wave);
    _waveGroups.removeAt(index);
    if (_selectedGroupIndex >= _waveGroups.length) {
      _selectedGroupIndex = _waveGroups.length - 1;
    }
    _sync();
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedWave = _selectedWave;
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
              title: l10n?.radiationMeteorHelpTitle ?? 'Radioactive Meteorite',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.radiationMeteorHelpOverview ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.radiationMeteorHelpMiningTitle ??
                      'Mining to destroy',
                  body: l10n?.radiationMeteorHelpMining ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n?.radiationMeteorParameters ?? 'Meteor parameters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _numberField(
                      controller: _warningCtrl,
                      label:
                          l10n?.radiationMeteorWarningDuration ??
                          'Warning duration (WarningDuration, seconds)',
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.warningDuration = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _pollutionCtrl,
                      label:
                          l10n?.radiationMeteorPollutionInterval ??
                          'Pollution interval (PollutionInterval, seconds)',
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.pollutionInterval = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _miningCtrl,
                      label:
                          l10n?.radiationMeteorMiningDuration ??
                          'Mining duration (MiningDurationRequired, seconds)',
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.miningDurationRequired = parsed;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _numberField(
                      controller: _rewardCtrl,
                      decimal: false,
                      label:
                          l10n?.radiationMeteorPowerReward ??
                          'Power reward (PowerRewardOnDestroy)',
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed >= 0) {
                          _data.powerRewardOnDestroy = parsed;
                          _sync();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.radiationMeteorSpawnSchedule ??
                  'Landing schedule (SpawnSchedule)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            GridOverrideWaveGroupsBar(
              itemCount: _waveGroups.length,
              selectedIndex: _selectedGroupIndex,
              onSelected: (index) =>
                  setState(() => _selectedGroupIndex = index),
              onDeleteAt: _confirmDeleteWaveGroup,
              onAdd: _addWaveGroup,
              groupLabel: (index) =>
                  l10n?.groupN(index + 1) ?? 'Group ${index + 1}',
            ),
            if (selectedWave != null) ...[
              const SizedBox(height: 16),
              Card(
                key: ValueKey('radiationMeteorGroup-$_selectedGroupIndex'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n?.groupN(_selectedGroupIndex + 1) ??
                            'Group ${_selectedGroupIndex + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: ValueKey('meteor-wave-$selectedWave'),
                        initialValue: '$selectedWave',
                        decoration: InputDecoration(
                          labelText:
                              l10n?.radiationMeteorWave ??
                              'Wave (Wave, starts at 1)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) _updateSelectedWave(parsed);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.moonPlacementGestureHint ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${l10n?.selectedPosition ?? 'Selected position'}: '
                        'R${_selectedY + 1} : C${_selectedX + 1}',
                      ),
                      const SizedBox(height: 12),
                      GridOverridePlacementGrid(
                        gridRows: _gridRows,
                        gridCols: _gridCols,
                        selectedCol: _selectedX,
                        selectedRow: _selectedY,
                        onPrimaryTap: _tapCell,
                        onRemoveAt: _removeAt,
                        cellImageAt: (col, row) =>
                            _hasAt(col, row) ? _asset : null,
                        cellImageScaleAt: (_, _) => 0.92,
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

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
    bool decimal = true,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }
}
