import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/wave_generator_level_utils.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/data/zombie_display_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart' show isDesktopPlatform;
import 'package:c_editor/widgets/grid_override_preview_dialog.dart';
import 'package:c_editor/widgets/initial_kongfu_grid_items_card.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';

/// Waves tab for levels using [WaveGeneratorProperties] (embedded wave data).
class WaveGeneratorTab extends StatefulWidget {
  const WaveGeneratorTab({
    super.key,
    required this.levelFile,
    required this.parsed,
    required this.onChanged,
    this.onOpenModule,
    this.onEditWaveGeneratorSettings,
    required this.onEditWave,
  });

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final VoidCallback onChanged;
  final OpenModuleCallback? onOpenModule;
  final VoidCallback? onEditWaveGeneratorSettings;
  final void Function(int waveIndex) onEditWave;

  @override
  State<WaveGeneratorTab> createState() => _WaveGeneratorTabState();
}

class _WaveGeneratorTabState extends State<WaveGeneratorTab> {
  WaveGeneratorPropertiesData? _data;
  PvzObject? _obj;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant WaveGeneratorTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.levelFile != widget.levelFile ||
        oldWidget.parsed != widget.parsed) {
      _reload();
    }
  }

  void _reload() {
    _obj = WaveGeneratorLevelUtils.findObject(widget.levelFile);
    if (_obj != null) {
      _data = WaveGeneratorLevelUtils.parseObject(_obj!);
    } else {
      _data = null;
    }
  }

  void _sync() {
    if (_obj == null || _data == null) return;
    _data!.syncWaveCount();
    _obj!.objData = _data!.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addWave() {
    if (_data == null) return;
    _data!.waves = [..._data!.waves, WaveGeneratorWaveData()];
    _sync();
  }

  void _deleteWave(int index) {
    if (_data == null || index < 0 || index >= _data!.waves.length) return;
    final waves = List<WaveGeneratorWaveData>.from(_data!.waves)
      ..removeAt(index);
    _data!.waves = waves;
    _sync();
  }

  String? _getModuleRtid(String objClass) {
    final def = widget.parsed.levelDef;
    if (def == null) return null;
    for (final rtid in def.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null || info.source != 'CurrentLevel') continue;
      final obj = widget.parsed.objectMap[info.alias];
      if (obj?.objClass == objClass) return rtid;
    }
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == objClass,
    );
    if (obj?.aliases?.isNotEmpty == true) {
      return RtidParser.build(obj!.aliases!.first, 'CurrentLevel');
    }
    return null;
  }

  DropShipPropertiesData? _getDropShipModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'DropShipProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return DropShipPropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  ArmrackPropertiesData? _getArmrackModuleData() {
    return readArmrackModuleData(widget.levelFile);
  }

  EnergyGridPropertiesData? _getEnergyGridModuleData() {
    return readEnergyGridModuleData(widget.levelFile);
  }

  HeianWindModulePropertiesData? _getHeianWindModuleData() {
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'HeianWindModuleProperties',
    );
    if (obj?.objData is Map<String, dynamic>) {
      try {
        return HeianWindModulePropertiesData.fromJson(
          obj!.objData as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return null;
  }

  bool _waveHasDropShipActivity(int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return false;
    return dropShip.appearWaves.any((w) => w.wave + 1 == waveIndex);
  }

  bool _waveHasArmrackActivity(int waveIndex) {
    return waveGeneratorWaveHasArmrackActivity(
      waveGeneratorWaveIndex: waveIndex,
      data: _getArmrackModuleData(),
    );
  }

  bool _waveHasEnergyGridActivity(int waveIndex) {
    return waveGeneratorWaveHasEnergyGridActivity(
      waveGeneratorWaveIndex: waveIndex,
      data: _getEnergyGridModuleData(),
    );
  }

  bool _waveHasHeianWindActivity(int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return false;
    return heianWind.waveWindInfos
        .any((w) => w.waveNumber + 1 == waveIndex);
  }

  String _zombieDisplayName(String rtid) {
    return ZombieDisplayUtils.localizedName(
      context,
      typeOrRtid: rtid,
      levelFile: widget.levelFile,
    );
  }

  String _zombieCodename(String rtid) {
    return ZombieDisplayUtils.codename(rtid);
  }

  String? _zombieIcon(String rtid) {
    return ZombieDisplayUtils.iconPath(rtid, levelFile: widget.levelFile);
  }

  Future<void> _confirmDeleteWave(int index) async {
    if (_data == null || index < 0 || index >= _data!.waves.length) return;
    final l10n = AppLocalizations.of(context);
    final waveIndex = index + 1;
    final wave = _data!.waves[index];
    final zombieCount = wave.zombies.length;
    var confirm = false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            (l10n?.deleteWave != null && l10n?.waveLabel != null)
                ? '${l10n?.deleteWave} ${l10n?.waveLabel} $waveIndex?'
                : 'Delete Wave $waveIndex?',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.deleteWaveConfirm(zombieCount) ??
                    'This will remove this wave and its $zombieCount scripted zombies.',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: confirm,
                onChanged: (v) => setDialogState(() => confirm = v ?? false),
                title: Text(
                  l10n?.deleteWaveConfirmCheckbox ??
                      'I confirm permanent deletion of this wave',
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: confirm ? () => Navigator.pop(ctx, true) : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n?.delete ?? 'Delete'),
            ),
          ],
        ),
      ),
    );
    if (ok == true) _deleteWave(index);
  }

  void _openWaveEditor(int index) {
    widget.onEditWave(index + 1);
  }

  void _showExpectationDialog(int waveIndex, bool isFlagWave) {
    if (_data == null) return;
    showWaveGeneratorExpectationDialog(
      context,
      data: _data!,
      waveIndex: waveIndex,
      isFlagWave: isFlagWave,
    );
  }

  void _openModule(String moduleClass, {ModuleOpenHint? hint}) {
    if (widget.onOpenModule == null) return;
    final rtid = _getModuleRtid(moduleClass);
    if (rtid == null) return;
    widget.onOpenModule!(rtid, hint: hint);
  }

  void _showHeianWindInfoDialog(BuildContext context, int waveIndex) {
    final heianWind = _getHeianWindModuleData();
    if (heianWind == null) return;
    final waves = heianWind.waveWindInfos
        .where((w) => w.waveNumber + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showHeianWindWavePreviewDialog(
      context,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
                'HeianWindModuleProperties',
                hint: ModuleOpenHint(heianWindWaveNumber: waveIndex - 1),
              ),
    );
  }

  void _showDropShipInfoDialog(BuildContext context, int waveIndex) {
    final dropShip = _getDropShipModuleData();
    if (dropShip == null) return;
    final waves = dropShip.appearWaves
        .where((w) => w.wave + 1 == waveIndex)
        .toList();
    if (waves.isEmpty) return;
    showDropShipWavePreviewDialog(
      context,
      levelFile: widget.levelFile,
      waveIndex: waveIndex,
      waves: waves,
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
                'DropShipProperties',
                hint: ModuleOpenHint(dropShipWave: waves.first.wave),
              ),
    );
  }

  void _showArmrackInfoDialog(BuildContext context, int waveIndex) {
    final l10n = AppLocalizations.of(context);
    final data = _getArmrackModuleData();
    if (data == null) return;
    final moduleWave = moduleWaveForWaveGeneratorWave(waveIndex);
    final items = armrackItemsForModuleWave(data, moduleWave);
    if (items.isEmpty) return;
    final label = l10n?.armrackModuleExpectationLabel ?? 'Weapon stands';
    showArmrackGridPreviewDialog(
      context,
      levelFile: widget.levelFile,
      items: items,
      title: l10n?.waveGeneratorGridOverrideWavePreviewTitle(waveIndex, label) ??
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex — $label',
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
                'ArmrackProperties',
                hint: ModuleOpenHint(gridOverrideModuleWave: moduleWave),
              ),
    );
  }

  void _showEnergyGridInfoDialog(BuildContext context, int waveIndex) {
    final l10n = AppLocalizations.of(context);
    final data = _getEnergyGridModuleData();
    if (data == null) return;
    final moduleWave = moduleWaveForWaveGeneratorWave(waveIndex);
    final items = energyGridItemsForModuleWave(data, moduleWave);
    if (items.isEmpty) return;
    final label = l10n?.energyGridModuleExpectationLabel ?? 'Taiji tiles';
    showEnergyGridPreviewDialog(
      context,
      levelFile: widget.levelFile,
      items: items,
      title: l10n?.waveGeneratorGridOverrideWavePreviewTitle(waveIndex, label) ??
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex — $label',
      onOpenModuleSettings: widget.onOpenModule == null
          ? null
          : () => _openModule(
                'EnergyGridProperties',
                hint: ModuleOpenHint(gridOverrideModuleWave: moduleWave),
              ),
    );
  }

  void _showBlackHoleInfoDialog(BuildContext context, int waveIndex, int cols) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.eventTitle_BlackHoleWaveActionProps ?? 'Black Hole'}',
        ),
        content: Text(
          l10n?.waveGeneratorBlackHoleWaveHint(cols) ??
              'Built-in black hole on this wave (ColNumPlantIsDragged: $cols).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveGeneratorSettingsCard(
    BuildContext context,
    WaveGeneratorPropertiesData data,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.tune),
            title: Text(
              l10n?.waveGeneratorGlobalParams ?? 'Wave Generator Parameters',
            ),
            subtitle: Text(
              l10n?.waveGeneratorTabSummary(
                    data.flagWaveInterval,
                    data.waveSpendingPoints,
                    data.waveSpendingPointIncrement,
                  ) ??
                  'Flag interval: ${data.flagWaveInterval}, Spending: ${data.waveSpendingPoints} + ${data.waveSpendingPointIncrement}/wave',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: widget.onEditWaveGeneratorSettings,
          ),
        ),
        if (!data.spendingPointsValid) ...[
          const SizedBox(height: 8),
          Text(
            l10n?.waveGeneratorSpendingPointsWarning ??
                'WaveSpendingPoints must be ≤ WaveSpendingPointIncrement.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _reload();
    final l10n = AppLocalizations.of(context);
    final data = _data;

    if (data == null) {
      return Center(
        child: Text(
          l10n?.waveGeneratorTabMissingModule ??
              'Add Wave Generator module to edit waves.',
        ),
      );
    }

    final interval = data.flagWaveInterval <= 0 ? 10 : data.flagWaveInterval;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWaveGeneratorSettingsCard(context, data),
          InitialKongfuGridItemsCard(
            levelFile: widget.levelFile,
            onOpenModule: widget.onOpenModule,
          ),
          const SizedBox(height: 16),
          if (data.waves.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(l10n?.waveGeneratorNoWaves ?? 'No waves defined.'),
                ),
              ),
            )
          else
            ...List.generate(data.waves.length, (index) {
              final waveIndex = index + 1;
              final wave = data.waves[index];
              final isFlagWave =
                  waveIndex % interval == 0 || waveIndex == data.waves.length;
              final actionButtons = <({String label, VoidCallback onTap})>[];
              if (WaveGeneratorPointAnalysis.showExpectationForWave(
                data,
                waveIndex,
              )) {
                final points = WaveGeneratorPointAnalysis.pointsAtWave(
                  data,
                  waveIndex,
                  isFlagWave: isFlagWave,
                );
                actionButtons.add((
                  label: l10n?.wavePointsShort(points) ?? '$points pts.',
                  onTap: () => _showExpectationDialog(waveIndex, isFlagWave),
                ));
              }
              if (wave.colNumPlantIsDragged != null) {
                actionButtons.add((
                  label: l10n?.eventTitle_BlackHoleWaveActionProps ??
                      'Black Hole',
                  onTap: () => _showBlackHoleInfoDialog(
                    context,
                    waveIndex,
                    wave.colNumPlantIsDragged!,
                  ),
                ));
              }
              if (_waveHasDropShipActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.airDropShipModuleExpectationLabel ?? 'Imp drops',
                  onTap: () => _showDropShipInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasArmrackActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.armrackModuleExpectationLabel ?? 'Weapon stands',
                  onTap: () => _showArmrackInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasEnergyGridActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.energyGridModuleExpectationLabel ?? 'Taiji tiles',
                  onTap: () => _showEnergyGridInfoDialog(context, waveIndex),
                ));
              }
              if (_waveHasHeianWindActivity(waveIndex)) {
                actionButtons.add((
                  label: l10n?.heianWindModuleExpectationLabel ?? 'Divine Wind',
                  onTap: () => _showHeianWindInfoDialog(context, waveIndex),
                ));
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _WaveRowCard(
                  waveIndex: waveIndex,
                  isFlagWave: isFlagWave,
                  wave: wave,
                  globalPool: data.addToZombiePool,
                  wavePoolEntries: [
                    for (var w = 0; w < waveIndex; w++)
                      ...data.waves[w].addToZombiePool,
                  ],
                  actionButtons: actionButtons,
                  zombieDisplayName: _zombieDisplayName,
                  zombieCodename: _zombieCodename,
                  zombieIcon: _zombieIcon,
                  onTap: () => _openWaveEditor(index),
                  onDelete: () => _confirmDeleteWave(index),
                  l10n: l10n,
                ),
              );
            }),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.icon(
              onPressed: _addWave,
              icon: const Icon(Icons.add),
              label: Text(l10n?.addWave ?? 'Add wave'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveRowCard extends StatelessWidget {
  const _WaveRowCard({
    required this.waveIndex,
    required this.isFlagWave,
    required this.wave,
    required this.globalPool,
    required this.wavePoolEntries,
    required this.actionButtons,
    required this.zombieDisplayName,
    required this.zombieCodename,
    required this.zombieIcon,
    required this.onTap,
    required this.onDelete,
    required this.l10n,
  });

  final int waveIndex;
  final bool isFlagWave;
  final WaveGeneratorWaveData wave;
  final List<WaveGeneratorPoolEntryData> globalPool;
  final List<WaveGeneratorPoolEntryData> wavePoolEntries;
  final List<({String label, VoidCallback onTap})> actionButtons;
  final String Function(String rtid) zombieDisplayName;
  final String Function(String rtid) zombieCodename;
  final String? Function(String rtid) zombieIcon;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = isDesktopPlatform(context);
    final actionColumnWidth = isDesktop ? 220.0 : 188.0;
    final showRandomPool = !wave.disableRandomSpawns;
    final hasRandomPool =
        showRandomPool && (globalPool.isNotEmpty || wavePoolEntries.isNotEmpty);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 14 : 12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: isDesktop ? 52 : 44,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$waveIndex',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 18 : 16,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (isFlagWave)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Icon(
                              Icons.flag,
                              size: isDesktop ? 14 : 12,
                              color: theme.colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (wave.zombies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n?.waveGeneratorEmptyWaveRow ??
                              'No scripted zombies (tap to edit)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final z in wave.zombies)
                            WaveGeneratorZombieIconChip(
                              localizedName: zombieDisplayName(z.type),
                              codename: zombieCodename(z.type),
                              iconPath: zombieIcon(z.type),
                              rowLabel: waveGeneratorRowDisplay(z.row),
                            ),
                        ],
                      ),
                    if (hasRandomPool) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n?.waveGeneratorRandomZombiesLabel ??
                            'Random zombies:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final entry in globalPool)
                            WaveGeneratorZombieIconChip(
                              sourceBadge: 'G',
                              localizedName: zombieDisplayName(entry.type),
                              codename: zombieCodename(entry.type),
                              iconPath: zombieIcon(entry.type),
                            ),
                          for (final entry in wavePoolEntries)
                            WaveGeneratorZombieIconChip(
                              sourceBadge: 'W',
                              localizedName: zombieDisplayName(entry.type),
                              codename: zombieCodename(entry.type),
                              iconPath: zombieIcon(entry.type),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                width: actionColumnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (final b in actionButtons)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ActionChip(
                              label: Text(
                                b.label,
                                style: TextStyle(
                                  fontSize: isDesktop ? 12 : 11,
                                ),
                                softWrap: true,
                              ),
                              onPressed: b.onTap,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(
                        l10n?.deleteWave ?? 'Delete wave',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
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
