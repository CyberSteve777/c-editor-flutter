import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_detail_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

class ZombossMechPropertiesViewScreen extends StatelessWidget {
  const ZombossMechPropertiesViewScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    required this.mechType,
    required this.onBack,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String mechType;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = zombossMechAccent(context);
    final propsData =
        ZombossMechRepository.propertiesDataForVariation(
          mechType,
          catalog: catalog,
        ) ??
        <String, dynamic>{};
    final stages = _stages(propsData);
    final stageJamOrder = _stringOrder(propsData, 'StageJamOrder');
    final zombossAnimOrder = _stringOrder(propsData, 'ZombossAnimOrder');
    final showEightiesOrders =
        catalog.id == 'ZombieZombossMech_Eighties' &&
        (stageJamOrder.isNotEmpty || zombossAnimOrder.isNotEmpty);
    final propertiesLabel = ZombossMechRepository.propertiesDisplayLabel(
      mechType,
      catalog: catalog,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          title: Text(
            l10n?.zombossMechPropertiesViewTitle ?? 'ZombossMech Properties',
          ),
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
                      _variationLabel(context),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n?.zombossMechAliasLabel ?? 'Alias'}: $mechType',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (propertiesLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${l10n?.zombossMechPropertiesLabel ?? 'Properties'}: $propertiesLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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
            ..._generalEntries(context, propsData).map(
              (entry) => _ReadOnlyValueRow(label: entry.$1, value: entry.$2),
            ),
            ZombossMechReadOnlyBoolRow(
              key: const ValueKey('readOnlySquashZombies'),
              label: l10n?.zombossMechSquashZombies ?? 'Can squash zombies',
              value: ZombossMechRepository.boolPropertyWithTemplateFallback(
                data: propsData,
                catalog: catalog,
                key: 'SquashZombies',
              ),
            ),
            ZombossMechReadOnlyBoolRow(
              key: const ValueKey('readOnlySquashGridItems'),
              label:
                  l10n?.zombossMechSquashGridItems ?? 'Can squash grid items',
              value: ZombossMechRepository.boolPropertyWithTemplateFallback(
                data: propsData,
                catalog: catalog,
                key: 'SquashGridItems',
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.customZombossMechStages ?? 'Battle phases',
              style: theme.textTheme.titleMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (showEightiesOrders) ...[
              _ReadOnlyStageOrderCard(
                key: const ValueKey('readOnlyStageJamOrderCard'),
                title:
                    l10n?.zombossMechStageJamOrder ??
                    'Music playback order (StageJamOrder)',
                values: stageJamOrder,
                valueLabel: (value) => _stageJamLabel(l10n, value),
                accentColor: accent,
              ),
              const SizedBox(height: 4),
              _ReadOnlyStageOrderCard(
                key: const ValueKey('readOnlyZombossAnimOrderCard'),
                title:
                    l10n?.zombossMechZombossAnimOrder ??
                    'Zomboss animation order (ZombossAnimOrder)',
                values: zombossAnimOrder,
                valueLabel: (value) => _zombossAnimLabel(l10n, value),
                accentColor: accent,
              ),
              const SizedBox(height: 4),
            ],
            if (stages.isEmpty)
              Text(
                l10n?.zombossMechNoStageActions ?? 'No actions yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (var i = 0; i < stages.length; i++)
                _ReadOnlyStageCard(
                  index: i,
                  catalog: catalog,
                  levelFile: levelFile,
                  accentColor: accent,
                  stage: stages[i],
                  phaseLabel:
                      l10n?.zombossMechPhaseNumber(i + 1) ?? 'Phase ${i + 1}',
                  hitPointsLabel: l10n?.zombossMechHitPoints ?? 'Hit points',
                  actionsLabel: l10n?.zombossMechActions ?? 'Actions',
                  retreatLabel:
                      l10n?.zombossMechRetreatAction ?? 'Retreat action',
                  onInspectAction: (rtid) => _openActionDetails(context, rtid),
                ),
          ],
        ),
      ),
    );
  }

  String _variationLabel(BuildContext context) {
    return ZombossMechL10n.variationLabel(
      context,
      catalog.id,
      mechType,
      fallback: ResourceNames.lookup(context, mechType),
    );
  }

  List<Map<String, dynamic>> _stages(Map<String, dynamic> propsData) {
    final raw = propsData['Stages'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  List<String> _stringOrder(Map<String, dynamic> propsData, String key) {
    final raw = propsData[key];
    if (raw is! List) return const [];
    return raw.map((value) => value.toString()).toList();
  }

  String _stageJamLabel(AppLocalizations? l10n, String value) {
    return switch (value) {
      'jam_punk' => l10n?.jamPunk ?? 'Punk',
      'jam_pop' => l10n?.jamPop ?? 'Pop',
      'jam_rap' => l10n?.jamRap ?? 'Rap',
      'jam_8bit' => l10n?.jam8Bit ?? '8-Bit',
      'jam_metal' => l10n?.jamMetal ?? 'Metal',
      _ => value,
    };
  }

  String _zombossAnimLabel(AppLocalizations? l10n, String value) {
    return switch (value) {
      'idle_punk' => l10n?.jamPunk ?? 'Punk',
      'idle_newwave' => l10n?.zombossAnimNewWave ?? 'New Wave',
      'idle_hiphop' => l10n?.zombossAnimHipHop ?? 'Hip-Hop',
      'idle_8bit' => l10n?.jam8Bit ?? '8-Bit',
      'idle_metal' => l10n?.jamMetal ?? 'Metal',
      _ => value,
    };
  }

  List<(String, String)> _generalEntries(
    BuildContext context,
    Map<String, dynamic> propsData,
  ) {
    final l10n = AppLocalizations.of(context);
    final entries = <(String, String)>[];
    const keys = ['MinColumn', 'MaxColumn'];
    for (final key in keys) {
      final value = propsData[key];
      if (value == null) continue;
      entries.add((_propertyLabel(l10n, key), value.toString()));
    }
    return entries;
  }

  String _propertyLabel(AppLocalizations? l10n, String key) {
    return switch (key) {
      'MinColumn' => l10n?.zombossMechMinColumn ?? 'Min column',
      'MaxColumn' => l10n?.zombossMechMaxColumn ?? 'Max column',
      _ => key,
    };
  }

  Future<void> _openActionDetails(BuildContext context, String rtid) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => ZombossMechActionDetailScreen(
          catalog: catalog,
          levelFile: levelFile,
          rtid: rtid,
        ),
      ),
    );
  }
}

class ZombossMechReadOnlyBoolRow extends StatelessWidget {
  const ZombossMechReadOnlyBoolRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Switch.adaptive(value: value, onChanged: null),
    );
  }
}

class _ReadOnlyStageOrderCard extends StatelessWidget {
  const _ReadOnlyStageOrderCard({
    super.key,
    required this.title,
    required this.values,
    required this.valueLabel,
    required this.accentColor,
  });

  final String title;
  final List<String> values;
  final String Function(String value) valueLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (var index = 0; index < values.length; index++)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: CircleAvatar(
                  radius: 15,
                  backgroundColor: accentColor.withValues(alpha: 0.14),
                  foregroundColor: accentColor,
                  child: Text('${index + 1}'),
                ),
                title: Text(valueLabel(values[index])),
                subtitle: Text(values[index]),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyStageCard extends StatelessWidget {
  const _ReadOnlyStageCard({
    required this.index,
    required this.catalog,
    required this.levelFile,
    required this.accentColor,
    required this.stage,
    required this.phaseLabel,
    required this.hitPointsLabel,
    required this.actionsLabel,
    required this.retreatLabel,
    required this.onInspectAction,
  });

  final int index;
  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final Color accentColor;
  final Map<String, dynamic> stage;
  final String phaseLabel;
  final String hitPointsLabel;
  final String actionsLabel;
  final String retreatLabel;
  final ValueChanged<String> onInspectAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final actions = _stageActions(stage);
    final retreat = stage['RetreatAction'];

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
            Text(
              phaseLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 12),
            _ReadOnlyValueRow(label: hitPointsLabel, value: '$_hitPoints'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
              decoration: BoxDecoration(
                color: zombossMechActionTagColor(
                  'spawn',
                  context,
                ).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actionsLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (actions.isEmpty)
                    Text(
                      l10n?.zombossMechNoStageActions ?? 'No actions yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    for (
                      var actionIndex = 0;
                      actionIndex < actions.length;
                      actionIndex++
                    )
                      ZombossMechActionListTile(
                        key: ValueKey(
                          '$index-$actionIndex-${actions[actionIndex]}',
                        ),
                        mechId: catalog.id,
                        catalog: catalog,
                        levelFile: levelFile,
                        rtid: actions[actionIndex],
                        tag:
                            ZombossMechActionUtils.resolveAction(
                              rtid: actions[actionIndex],
                              catalog: catalog,
                              levelFile: levelFile,
                            )?.tag ??
                            '',
                        onInspect:
                            ZombossMechActionUtils.isCustomRtid(
                              actions[actionIndex],
                            )
                            ? null
                            : () => onInspectAction(actions[actionIndex]),
                      ),
                ],
              ),
            ),
            if (retreat is String && retreat.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: zombossMechActionTagColor(
                    'retreat',
                    context,
                  ).withValues(alpha: 0.08),
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
                      mechId: catalog.id,
                      catalog: catalog,
                      levelFile: levelFile,
                      rtid: retreat,
                      tag:
                          ZombossMechActionUtils.resolveAction(
                            rtid: retreat,
                            catalog: catalog,
                            levelFile: levelFile,
                          )?.tag ??
                          'retreat',
                      onInspect: ZombossMechActionUtils.isCustomRtid(retreat)
                          ? null
                          : () => onInspectAction(retreat),
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

  List<String> _stageActions(Map<String, dynamic> stage) {
    final raw = stage['Actions'];
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  int get _hitPoints {
    final hp = stage['HitPoints'];
    if (hp is int) return hp;
    if (hp is num) return hp.toInt();
    if (hp is String) return int.tryParse(hp) ?? 0;
    return 0;
  }
}

class _ReadOnlyValueRow extends StatelessWidget {
  const _ReadOnlyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: EditorResponsiveLabelField(
        breakpoint: 600,
        labelWidth: 240,
        label: Text(label),
        field: SelectableText(value, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
