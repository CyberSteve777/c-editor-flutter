import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/zomboss_battle_base_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

class ZombossBattleTab extends StatefulWidget {
  const ZombossBattleTab({
    super.key,
    required this.levelFile,
    required this.onChanged,
  });

  final PvzLevelFile levelFile;
  final VoidCallback onChanged;

  @override
  State<ZombossBattleTab> createState() => _ZombossBattleTabState();
}

class _ZombossBattleTabState extends State<ZombossBattleTab> {
  PvzObject? _moduleObj;
  LevelDefinitionData? _levelDef;
  late ZombossLastStandMinigameData _data;
  String _selectedBaseId = '';
  late TextEditingController _startingSunController;
  late FocusNode _startingSunFocus;

  (int maxRow, int maxCol) get _gridMaxIndices {
    final (rows, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return (rows - 1, cols - 1);
  }

  @override
  void initState() {
    super.initState();
    _startingSunController = TextEditingController();
    _startingSunFocus = FocusNode()..addListener(() => setState(() {}));
    _loadData();
    _startingSunController.text = '${_data.startingSun}';
  }

  @override
  void dispose() {
    _startingSunController.dispose();
    _startingSunFocus.dispose();
    super.dispose();
  }

  void _loadData() {
    _moduleObj = widget.levelFile.objects
        .where((o) => o.objClass == 'ZombossLastStandMinigameProperties')
        .firstOrNull;

    if (_moduleObj != null && _moduleObj!.objData is Map) {
      _data = ZombossLastStandMinigameData.fromJson(
        Map<String, dynamic>.from(_moduleObj!.objData as Map),
      );
    } else {
      _data = ZombossLastStandMinigameData();
    }

    _levelDef = LevelParser.parseLevel(widget.levelFile).levelDef;

    _data.zombossStartStageIndex = 0;
    if (_data.reservedColumnCount == 0) {
      _data.reservedColumnCount = 3;
    }

    _clampSpawnToGrid();

    _selectedBaseId = ZombossBattleRepository.resolveBaseId(
      null,
      _data.zombossTypeName,
    );
    if (_selectedBaseId.isEmpty &&
        ZombossBattleRepository.allZombosses.isNotEmpty) {
      _selectedBaseId = ZombossBattleRepository.allZombosses.first.id;
    }
    final base = ZombossBattleRepository.getBase(_selectedBaseId);
    if (base != null) {
      _data.resourceGroupNames = List<String>.from(base.resourceGroups);
      if (!base.variations.contains(_data.zombossTypeName) &&
          base.variations.isNotEmpty) {
        _data.zombossTypeName = base.variations.first;
      }
    }

    if (_levelDef != null && _selectedBaseId.isNotEmpty) {
      ZombossBattleRepository.ensureAutoModules(
        levelFile: widget.levelFile,
        levelDef: _levelDef!,
        baseId: _selectedBaseId,
      );
    }
  }

  void _clampSpawnToGrid() {
    final (maxRow, maxCol) = _gridMaxIndices;
    if (_data.zombossInitialGridCol > maxCol) {
      _data.zombossInitialGridCol = maxCol;
    }
    if (_data.zombossInitialGridRow > maxRow) {
      _data.zombossInitialGridRow = maxRow;
    }
  }

  void _saveData() {
    if (_moduleObj != null) {
      _data.zombossStartStageIndex = 0;
      _moduleObj!.objData = _data.toJson();
      widget.onChanged();
    }
  }

  void _sync({VoidCallback? extra}) {
    extra?.call();
    _saveData();
    setState(() {});
  }

  Future<void> _openBaseSelection() async {
    final baseId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossBattleBaseSelectionScreen(
          selectedBaseId: _selectedBaseId,
        ),
      ),
    );
    if (baseId != null && mounted) {
      _onBaseChanged(baseId);
    }
  }

  void _onBaseChanged(String baseId) {
    if (baseId == _selectedBaseId) return;
    final base = ZombossBattleRepository.getBase(baseId);
    if (base == null) return;
    final previousBaseId = _selectedBaseId;
    _sync(extra: () {
      _selectedBaseId = baseId;
      _data.resourceGroupNames = List<String>.from(base.resourceGroups);
      if (!base.variations.contains(_data.zombossTypeName)) {
        _data.zombossTypeName = base.variations.first;
      }
      if (_levelDef != null) {
        ZombossBattleRepository.syncAutoModules(
          levelFile: widget.levelFile,
          levelDef: _levelDef!,
          previousBaseId: previousBaseId,
          newBaseId: baseId,
        );
      }
    });
  }

  void _onVariationChanged(String? variation) {
    if (variation == null || variation == _data.zombossTypeName) return;
    _sync(extra: () => _data.zombossTypeName = variation);
  }

  String _displayName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (maxRow, maxCol) = _gridMaxIndices;

    if (_moduleObj == null) {
      return Center(
        child: Text(
          l10n?.missingZombossBattleModule ??
              'Missing ZombossLastStandMinigameProperties',
        ),
      );
    }

    final bases = ZombossBattleRepository.allZombosses;
    final currentBase = ZombossBattleRepository.getBase(_selectedBaseId);
    final variations = currentBase?.variations ?? <String>[];

    if (bases.isEmpty) {
      return Center(
        child: Text(l10n?.noZombossBattleFound ?? 'No zomboss found'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n?.zombossBattleSelection ?? 'Zomboss selection',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (currentBase != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ZombossMechBaseCard(
              baseId: currentBase.id,
              icon: currentBase.icon,
              compact: true,
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: l10n?.zombossBattleChangeBase ?? 'Change base Zomboss',
                onPressed: _openBaseSelection,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Tooltip(
          message: l10n?.zombossBattleVariationHint ?? '',
          child: DropdownButtonFormField<String>(
            value: variations.contains(_data.zombossTypeName)
                ? _data.zombossTypeName
                : (variations.isNotEmpty ? variations.first : null),
            decoration: editorInputDecoration(
              context,
              labelText:
                  l10n?.zombossBattleVariationLabel ?? 'Zomboss variation',
            ),
            items: variations
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(_displayName(context, v)),
                  ),
                )
                .toList(),
            onChanged: variations.isEmpty ? null : _onVariationChanged,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n?.parameters ?? 'Parameters',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Tooltip(
          message: l10n?.zombossBattleStartingSunHint ?? '',
          child: TextField(
            controller: _startingSunController,
            focusNode: _startingSunFocus,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: editorInputDecoration(
              context,
              labelText: l10n?.zombossBattleStartingSunLabel ?? 'Starting sun',
              isFocused: _startingSunFocus.hasFocus,
            ),
            onChanged: (text) {
              final value = int.tryParse(text.trim());
              if (value != null && value >= 0 && value <= 9990) {
                _data.startingSun = value;
                _saveData();
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        _StepperControl(
          label: l10n?.zombossBattleStartingPlantfoodLabel ?? 'Starting plant food',
          tooltip: l10n?.zombossBattleStartingPlantfoodHint ?? '',
          value: _data.startingPlantfood,
          onChanged: (val) => _sync(extra: () => _data.startingPlantfood = val),
          min: 0,
          max: 5,
        ),
        _StepperControl(
          label: l10n?.zombossBattleInitialGridColLabel ?? 'Initial grid column',
          tooltip: l10n?.zombossBattleInitialGridColHint ?? '',
          value: _data.zombossInitialGridCol,
          onChanged: (val) =>
              _sync(extra: () => _data.zombossInitialGridCol = val),
          min: 0,
          max: maxCol,
        ),
        _StepperControl(
          label: l10n?.zombossBattleInitialGridRowLabel ?? 'Initial grid row',
          tooltip: l10n?.zombossBattleInitialGridRowHint ?? '',
          value: _data.zombossInitialGridRow,
          onChanged: (val) =>
              _sync(extra: () => _data.zombossInitialGridRow = val),
          min: 0,
          max: maxRow,
        ),
        _StepperControl(
          label: l10n?.reservedColumnCount ?? 'Reserved column count',
          tooltip: l10n?.reservedColumnCountHint ?? '',
          value: _data.reservedColumnCount,
          onChanged: (val) => _sync(extra: () => _data.reservedColumnCount = val),
          min: 0,
          max: 9,
        ),
        Tooltip(
          message: l10n?.zombossBattleSkipPlantingHint ?? '',
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n?.zombossBattleSkipPlantingLabel ?? 'Skip planting phase',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              Switch(
                value: _data.skipPlanting,
                onChanged: (v) => _sync(extra: () => _data.skipPlanting = v),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.label,
    required this.value,
    required this.onChanged,
    this.tooltip = '',
    this.min = 0,
    this.max = 100,
  });

  final String label;
  final String tooltip;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip.isNotEmpty ? tooltip : label,
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
