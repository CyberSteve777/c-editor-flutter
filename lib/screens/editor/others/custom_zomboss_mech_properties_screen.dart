import 'package:flutter/material.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models.dart';
import 'package:z_editor/data/repository/zomboss_mech_repository.dart';
import 'package:z_editor/data/zomboss_mech_action_utils.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/l10n/resource_names.dart';
import 'package:z_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:z_editor/screens/editor/others/zomboss_mech_action_selection_screen.dart';
import 'package:z_editor/widgets/editor_components.dart';
import 'package:z_editor/widgets/zomboss_mech_editor_widgets.dart';

/// Edits level-local zombossmech property sheet (`editableInstancePropsName`).
class CustomZombossMechPropertiesScreen extends StatefulWidget {
  const CustomZombossMechPropertiesScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.introData,
    this.onStageCountChanged,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final ZombossMechBattleIntroData? introData;
  final ValueChanged<int>? onStageCountChanged;

  @override
  State<CustomZombossMechPropertiesScreen> createState() =>
      _CustomZombossMechPropertiesScreenState();
}

class _CustomZombossMechPropertiesScreenState
    extends State<CustomZombossMechPropertiesScreen> {
  static const _kDefaultRetreatRtid =
      'RTID(ZombossRetreatJump@ZombieActions)';

  PvzObject? _propsObj;
  late Map<String, dynamic> _propsData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _propsObj = ZombossMechRepository.ensureCustomPropertiesInLevel(
      catalog: widget.catalog,
      levelFile: widget.levelFile,
    );
    final raw = _propsObj!.objData;
    if (raw is Map<String, dynamic>) {
      _propsData = Map<String, dynamic>.from(raw);
    } else {
      _propsData = widget.catalog.templatePropsData();
    }
    _ensureStages();
    _ensureRetreatActions();
  }

  void _ensureStages() {
    final stages = _stages;
    if (stages.isNotEmpty) return;
    final template = widget.catalog.templatePropsData();
    final templateStages = template['Stages'];
    if (templateStages is List && templateStages.isNotEmpty) {
      _propsData['Stages'] = _deepClone(templateStages);
    } else {
      _propsData['Stages'] = [
        for (var i = 0; i < widget.catalog.defaultPhaseCount; i++)
          {
            'Actions': <String>[],
            'HitPoints': 10000,
            if (widget.catalog.supportsRetreatInStages)
              'RetreatAction': _kDefaultRetreatRtid,
          },
      ];
    }
  }

  void _ensureRetreatActions() {
    if (!_supportsRetreat) return;
    var changed = false;
    for (final stage in _stages) {
      final raw = stage['RetreatAction'];
      if (raw is! String || raw.isEmpty) {
        stage['RetreatAction'] = _kDefaultRetreatRtid;
        changed = true;
      }
    }
    if (changed) {
      _propsData['Stages'] = _stages;
      _propsObj!.objData = _propsData;
    }
  }

  List<Map<String, dynamic>> get _stages {
    final raw = _propsData['Stages'];
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  bool get _supportsRetreat => widget.catalog.supportsRetreatInStages;

  void _sync() {
    _propsObj!.objData = _propsData;
    final count = _stages.length;
    widget.onStageCountChanged?.call(count);
    widget.introData?.zombossPhaseCount = count;
    widget.onChanged();
    setState(() {});
  }

  dynamic _deepClone(dynamic value) {
    return switch (value) {
      Map() => Map<String, dynamic>.fromEntries(
          value.entries.map(
            (e) => MapEntry(e.key.toString(), _deepClone(e.value)),
          ),
        ),
      List() => value.map(_deepClone).toList(),
      _ => value,
    };
  }

  String _displayName(BuildContext context, String key) {
    final name = ResourceNames.lookup(context, key);
    return name == key ? key : name;
  }

  List<String> _stageActions(Map<String, dynamic> stage) {
    final raw = stage['Actions'];
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).toList();
  }

  void _setStageActions(int index, List<String> rtids) {
    final stages = _stages;
    if (index < 0 || index >= stages.length) return;
    stages[index]['Actions'] = rtids;
    _propsData['Stages'] = stages;
    _sync();
  }

  void _setStageRetreat(int index, String? rtid) {
    final stages = _stages;
    if (index < 0 || index >= stages.length) return;
    if (rtid == null || rtid.isEmpty) {
      stages[index].remove('RetreatAction');
    } else {
      stages[index]['RetreatAction'] = rtid;
    }
    _propsData['Stages'] = stages;
    _sync();
  }

  String _retreatRtid(Map<String, dynamic> stage) {
    final raw = stage['RetreatAction'];
    if (raw is String && raw.isNotEmpty) return raw;
    return _kDefaultRetreatRtid;
  }

  void _updateScalar(String key, dynamic value) {
    _propsData[key] = value;
    _sync();
  }

  int _readInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Future<void> _confirmDeletePhase(int index) async {
    final l10n = AppLocalizations.of(context);
    final phaseNum = index + 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.zombossMechDeletePhaseTitle(phaseNum) ??
              'Delete phase $phaseNum?',
        ),
        content: Text(
          l10n?.zombossMechDeletePhaseMessage ??
              'This removes the phase and its action list. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final next = List<Map<String, dynamic>>.from(_stages)..removeAt(index);
    _propsData['Stages'] = next;
    _sync();
  }

  void _addPhase() {
    final next = List<Map<String, dynamic>>.from(_stages);
    final last = next.isNotEmpty ? next.last : null;
    next.add({
      'Actions': <String>[
        if (last != null) ..._stageActions(last),
      ],
      'HitPoints': _readInt(last?['HitPoints'], 10000),
      if (_supportsRetreat)
        'RetreatAction': _retreatRtid(last ?? {}),
    });
    _propsData['Stages'] = next;
    _sync();
  }

  Future<void> _pickAction({
    required int stageIndex,
    required bool retreat,
  }) async {
    final rtid = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionSelectionScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          retreatOnly: retreat,
        ),
      ),
    );
    if (rtid == null || !mounted) return;
    if (retreat) {
      _setStageRetreat(stageIndex, rtid);
    } else {
      final actions = List<String>.from(_stageActions(_stages[stageIndex]))
        ..add(rtid);
      _setStageActions(stageIndex, actions);
    }
  }

  Future<void> _editCustomAction(String rtid) async {
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomZombossMechActionEditorScreen(
          catalog: widget.catalog,
          levelFile: widget.levelFile,
          existingRtid: rtid,
          propsData: _propsData,
          onPropsSync: _sync,
        ),
      ),
    );
    if (mounted) _sync();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stages = _stages;
    final accent = zombossMechAccent(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(
            l10n?.customZombossMechProperties ?? 'Custom ZombossMech properties',
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: l10n?.tooltipAboutModule ?? 'Help',
              onPressed: () {
                showEditorHelpDialog(
                  context,
                  title: l10n?.customZombossMechProperties ??
                      'Custom ZombossMech properties',
                  sections: [
                    HelpSectionData(
                      title: l10n?.overview ?? 'Overview',
                      body: l10n?.customZombossMechEditHint ??
                          'Edit level-local property sheet for the memo (custom) mech variation.',
                    ),
                    HelpSectionData(
                      title: l10n?.customZombossMechStages ?? 'Battle phases',
                      body: l10n?.zombossMechPhasesHelp ??
                          'Each phase has hit points, an ordered action list, and optionally a retreat action.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: accent.withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: accent.withValues(alpha: 0.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName(context, widget.catalog.id),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n?.zombossMechPropertiesLabel ?? 'Properties'}: ${widget.catalog.editableInstancePropsName}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n?.zombossMechAliasLabel ?? 'Alias'}: ${widget.catalog.editableInstance}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.customZombossMechScalars ?? 'General',
              style: theme.textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _ScalarStepper(
              label: l10n?.zombossMechMinColumn ?? 'Min column',
              value: _readInt(_propsData['MinColumn'], 1),
              min: 0,
              max: 9,
              onChanged: (v) => _updateScalar('MinColumn', v),
            ),
            _ScalarStepper(
              label: l10n?.zombossMechMaxColumn ?? 'Max column',
              value: _readInt(_propsData['MaxColumn'], 7),
              min: 0,
              max: 9,
              onChanged: (v) => _updateScalar('MaxColumn', v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.customZombossMechStages ?? 'Battle phases',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n?.zombossMechAddPhase ?? 'Add phase',
                  onPressed: _addPhase,
                  icon: Icon(Icons.add_circle_outline, color: accent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < stages.length; i++)
              _StageCard(
                index: i,
                catalog: widget.catalog,
                levelFile: widget.levelFile,
                accentColor: accent,
                stage: stages[i],
                canDelete: stages.length > 1,
                selectedActions: _stageActions(stages[i]),
                retreatRtid: _retreatRtid(stages[i]),
                supportsRetreat: _supportsRetreat,
                onDelete: () => _confirmDeletePhase(i),
                onHitPointsChanged: (hp) {
                  stages[i]['HitPoints'] = hp;
                  _propsData['Stages'] = stages;
                  _sync();
                },
                onActionsChanged: (rtids) => _setStageActions(i, rtids),
                onAddAction: () => _pickAction(stageIndex: i, retreat: false),
                onPickRetreat: () => _pickAction(stageIndex: i, retreat: true),
                onEditCustomAction: _editCustomAction,
                phaseLabel: l10n?.zombossMechPhaseNumber(i + 1) ??
                    'Phase ${i + 1}',
                hitPointsLabel: l10n?.zombossMechHitPoints ?? 'Hit points',
                actionsLabel: l10n?.zombossMechActions ?? 'Actions',
                retreatLabel:
                    l10n?.zombossMechRetreatAction ?? 'Retreat action',
                deleteTooltip: l10n?.zombossMechDeletePhase ?? 'Delete phase',
                addActionTooltip:
                    l10n?.zombossMechAddAction ?? 'Add action',
              ),
          ],
        ),
      ),
    );
  }
}

class _ScalarStepper extends StatelessWidget {
  const _ScalarStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
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

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.index,
    required this.catalog,
    required this.levelFile,
    required this.accentColor,
    required this.stage,
    required this.canDelete,
    required this.selectedActions,
    required this.retreatRtid,
    required this.supportsRetreat,
    required this.onDelete,
    required this.onHitPointsChanged,
    required this.onActionsChanged,
    required this.onAddAction,
    required this.onPickRetreat,
    required this.onEditCustomAction,
    required this.phaseLabel,
    required this.hitPointsLabel,
    required this.actionsLabel,
    required this.retreatLabel,
    required this.deleteTooltip,
    required this.addActionTooltip,
  });

  final int index;
  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final Color accentColor;
  final Map<String, dynamic> stage;
  final bool canDelete;
  final List<String> selectedActions;
  final String retreatRtid;
  final bool supportsRetreat;
  final VoidCallback onDelete;
  final ValueChanged<int> onHitPointsChanged;
  final ValueChanged<List<String>> onActionsChanged;
  final VoidCallback onAddAction;
  final VoidCallback onPickRetreat;
  final ValueChanged<String> onEditCustomAction;
  final String phaseLabel;
  final String hitPointsLabel;
  final String actionsLabel;
  final String retreatLabel;
  final String deleteTooltip;
  final String addActionTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hp = _hitPoints;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    phaseLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
                if (canDelete)
                  IconButton(
                    tooltip: deleteTooltip,
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, color: accentColor),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _HitPointsField(
              label: hitPointsLabel,
              value: hp,
              onChanged: onHitPointsChanged,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(
                color: zombossMechActionTagColor('spawn', context)
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          actionsLabel,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: addActionTooltip,
                        onPressed: onAddAction,
                        icon: Icon(Icons.add_circle_outline, color: accentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (selectedActions.isEmpty)
                    Text(
                      l10n?.zombossMechNoStageActions ?? 'No actions yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    SizedBox(
                      height: selectedActions.length * kZombossMechActionRowHeight,
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: selectedActions.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          final next = List<String>.from(selectedActions);
                          final item = next.removeAt(oldIndex);
                          next.insert(newIndex, item);
                          onActionsChanged(next);
                        },
                        itemBuilder: (context, actionIndex) {
                          final rtid = selectedActions[actionIndex];
                          final isCustom =
                              ZombossMechActionUtils.isCustomRtid(rtid);
                          final resolved = ZombossMechActionUtils.resolveAction(
                            rtid: rtid,
                            catalog: catalog,
                            levelFile: levelFile,
                          );
                          final tag = resolved?.tag ?? '';

                          return ZombossMechActionListTile(
                            key: ValueKey('$index-$actionIndex-$rtid'),
                            rtid: rtid,
                            tag: tag,
                            reorderIndex: actionIndex,
                            onEdit: isCustom
                                ? () => onEditCustomAction(rtid)
                                : null,
                            onRemove: () {
                              final next = List<String>.from(selectedActions)
                                ..removeAt(actionIndex);
                              onActionsChanged(next);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (supportsRetreat) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: zombossMechActionTagColor('retreat', context)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      retreatLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ZombossMechRetreatActionTile(
                      rtid: retreatRtid,
                      tag: ZombossMechActionUtils.resolveAction(
                            rtid: retreatRtid,
                            catalog: catalog,
                            levelFile: levelFile,
                          )?.tag ??
                          'retreat',
                      onSwap: onPickRetreat,
                      onEdit: ZombossMechActionUtils.isCustomRtid(retreatRtid)
                          ? () => onEditCustomAction(retreatRtid)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int get _hitPoints {
    final hp = stage['HitPoints'];
    if (hp is int) return hp;
    if (hp is num) return hp.toInt();
    if (hp is String) return int.tryParse(hp) ?? 10000;
    return 10000;
  }
}

class _HitPointsField extends StatefulWidget {
  const _HitPointsField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_HitPointsField> createState() => _HitPointsFieldState();
}

class _HitPointsFieldState extends State<_HitPointsField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
    _focusNode = FocusNode()..addListener(() {
      final f = _focusNode.hasFocus;
      if (_focused != f) setState(() => _focused = f);
    });
  }

  @override
  void didUpdateWidget(covariant _HitPointsField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.value != widget.value) {
      _controller.text = '${widget.value}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: editorInputDecoration(
        context,
        labelText: widget.label,
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null && parsed > 0) widget.onChanged(parsed);
      },
    );
  }
}
