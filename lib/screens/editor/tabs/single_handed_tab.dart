import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

class SingleHandedTab extends StatefulWidget {
  const SingleHandedTab({
    super.key,
    required this.levelFile,
    required this.onChanged,
    this.onAddModule,
    this.onOpenTutorialModule,
  });

  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final void Function(String objClass)? onAddModule;
  final VoidCallback? onOpenTutorialModule;

  @override
  State<SingleHandedTab> createState() => _SingleHandedTabState();
}

class _SingleHandedTabState extends State<SingleHandedTab> {
  PvzObject? _moduleObject;
  late SingleHandedPropertiesData _data;

  static final _integerFormatter = FilteringTextInputFormatter.digitsOnly;
  static final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*$'),
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _moduleObject = widget.levelFile.objects
        .where((object) => object.objClass == 'SingleHandedProperties')
        .firstOrNull;
    if (_moduleObject == null) {
      _data = SingleHandedPropertiesData();
      return;
    }
    try {
      _data = SingleHandedPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject!.objData as Map),
      );
    } catch (_) {
      _data = SingleHandedPropertiesData();
    }
  }

  void _save({bool rebuild = false}) {
    final object = _moduleObject;
    if (object == null) return;
    object.objData = _data.toJson();
    widget.onChanged();
    if (rebuild && mounted) setState(() {});
  }

  bool get _hasTutorialModule => widget.levelFile.objects.any(
    (object) => object.objClass == 'IntroSingleHandedProperties',
  );

  String _plantName(BuildContext context, String plantId) {
    return ResourceNames.lookup(context, PlantRepository().getName(plantId));
  }

  String _plantIcon(String plantId) {
    return PlantRepository().getPlantInfoById(plantId)?.iconAssetPath ??
        'assets/images/others/unknown.webp';
  }

  Future<String?> _pickPlant({List<String> excludeIds = const []}) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (selectionContext) => PlantSelectionScreen(
          onPlantSelected: (id) => Navigator.pop(selectionContext, id),
          onBack: () => Navigator.pop(selectionContext),
          excludeIds: excludeIds,
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
          stateBucketId: 'single-handed-plants',
        ),
      ),
    );
  }

  Future<void> _changeInitialPlant() async {
    final selected = await _pickPlant(
      excludeIds: _data.dropWeaponDatas
          .map((entry) => entry.weaponName)
          .toList(),
    );
    if (!mounted || selected == null) return;
    _data.initWeapon = selected;
    _save(rebuild: true);
  }

  Future<void> _addUpgradePlant() async {
    final selected = await _pickPlant(
      excludeIds: [
        _data.initWeapon,
        ..._data.dropWeaponDatas.map((entry) => entry.weaponName),
      ],
    );
    if (!mounted || selected == null) return;
    final entry = SingleHandedDropWeaponData(weaponName: selected);
    final accepted = await _showUpgradeDialog(entry);
    if (!mounted || !accepted) return;
    _data.dropWeaponDatas.add(entry);
    _save(rebuild: true);
  }

  Future<bool> _showUpgradeDialog(SingleHandedDropWeaponData entry) async {
    final l10n = AppLocalizations.of(context)!;
    final killController = TextEditingController(text: '${entry.killCount}');
    final intervalController = TextEditingController(
      text: _formatNumber(entry.launchTimePercent),
    );
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n.singleHandedEditUpgradePlant(
            _plantName(dialogContext, entry.weaponName),
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EditorResponsiveInputField(
                label: localizedPropertyLabel(
                  dialogContext,
                  l10n.singleHandedRequiredKills,
                  'killnum',
                ),
                builder: (context, decoration) => TextField(
                  key: const ValueKey('singleHandedUpgradeKillCount'),
                  controller: killController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_integerFormatter],
                  decoration: decoration,
                ),
              ),
              const SizedBox(height: 16),
              EditorResponsiveInputField(
                label: localizedPropertyLabel(
                  dialogContext,
                  l10n.singleHandedAttackInterval,
                  'launchtimepercent',
                ),
                builder: (context, decoration) => TextField(
                  key: const ValueKey('singleHandedUpgradeAttackInterval'),
                  controller: intervalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [_decimalFormatter],
                  decoration: decoration,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final kills = int.tryParse(killController.text);
              final interval = double.tryParse(intervalController.text);
              if (kills == null || interval == null) return;
              entry.killCount = kills;
              entry.launchTimePercent = interval;
              Navigator.pop(dialogContext, true);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    killController.dispose();
    intervalController.dispose();
    return accepted == true;
  }

  Future<void> _editUpgradePlant(SingleHandedDropWeaponData entry) async {
    final accepted = await _showUpgradeDialog(entry);
    if (!mounted || !accepted) return;
    _save(rebuild: true);
  }

  Future<void> _addSpecialWave() async {
    final lastWave = _data.specialWaveDatas
        .map((entry) => entry.wave)
        .fold<int>(0, (current, wave) => wave > current ? wave : current);
    final entry = SingleHandedSpecialWaveData(
      wave: lastWave == 0 ? 5 : lastWave + 5,
    );
    final accepted = await _showSpecialWaveDialog(entry);
    if (!mounted || !accepted) return;
    _data.specialWaveDatas.add(entry);
    _data.specialWaveDatas.sort((a, b) => a.wave.compareTo(b.wave));
    _save(rebuild: true);
  }

  Future<bool> _showSpecialWaveDialog(SingleHandedSpecialWaveData entry) async {
    final l10n = AppLocalizations.of(context)!;
    final waveController = TextEditingController(text: '${entry.wave}');
    final speedController = TextEditingController(
      text: _formatNumber(entry.zombiesWalkSpeed),
    );
    final healthController = TextEditingController(
      text: _formatNumber(entry.zombiesHitpointsPercent),
    );
    var showHealthBar = entry.showHealthBar;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.singleHandedSpecialWave),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogNumberField(
                  context: dialogContext,
                  key: const ValueKey('singleHandedSpecialWaveNumber'),
                  label: l10n.singleHandedWave,
                  propertyName: 'wave',
                  controller: waveController,
                  integer: true,
                ),
                const SizedBox(height: 16),
                EditorResponsiveFieldRow(
                  children: [
                    _dialogNumberField(
                      context: dialogContext,
                      key: const ValueKey('singleHandedSpecialWaveSpeed'),
                      label: l10n.singleHandedSpeedMultiplier,
                      propertyName: 'ZombiesWalkSpeed',
                      controller: speedController,
                    ),
                    _dialogNumberField(
                      context: dialogContext,
                      key: const ValueKey('singleHandedSpecialWaveHealth'),
                      label: l10n.singleHandedHealthMultiplier,
                      propertyName: 'ZombiesHitpointsPercent',
                      controller: healthController,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.singleHandedShowHealthBar),
                  value: showHealthBar,
                  onChanged: (value) =>
                      setDialogState(() => showHealthBar = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final wave = int.tryParse(waveController.text);
                final speed = double.tryParse(speedController.text);
                final health = double.tryParse(healthController.text);
                if (wave == null || speed == null || health == null) return;
                entry.wave = wave;
                entry.zombiesWalkSpeed = speed;
                entry.zombiesHitpointsPercent = health;
                entry.showHealthBar = showHealthBar;
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
    waveController.dispose();
    speedController.dispose();
    healthController.dispose();
    return accepted == true;
  }

  Future<void> _editSpecialWave(SingleHandedSpecialWaveData entry) async {
    final accepted = await _showSpecialWaveDialog(entry);
    if (!mounted || !accepted) return;
    _data.specialWaveDatas.sort((a, b) => a.wave.compareTo(b.wave));
    _save(rebuild: true);
  }

  Widget _dialogNumberField({
    required BuildContext context,
    required Key key,
    required String label,
    required String propertyName,
    required TextEditingController controller,
    bool integer = false,
  }) {
    return EditorResponsiveInputField(
      label: localizedPropertyLabel(context, label, propertyName),
      builder: (context, decoration) => TextField(
        key: key,
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [integer ? _integerFormatter : _decimalFormatter],
        decoration: decoration,
      ),
    );
  }

  String _formatNumber(num value) {
    final doubleValue = value.toDouble();
    return doubleValue == doubleValue.roundToDouble()
        ? doubleValue.toInt().toString()
        : doubleValue.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_moduleObject == null) {
      return Center(child: Text(l10n.noLevelDefinition));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBasicParametersCard(l10n),
              const SizedBox(height: 16),
              _buildPlantConfigurationCard(l10n),
              const SizedBox(height: 16),
              _buildSpecialWavesCard(l10n),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('singleHandedOpenTutorial'),
                onPressed: widget.onOpenTutorialModule,
                icon: const Icon(Icons.sledding),
                label: Text(
                  _hasTutorialModule
                      ? l10n.singleHandedConfigureTutorial
                      : l10n.singleHandedAddTutorial,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicParametersCard(AppLocalizations l10n) {
    return _sectionCard(
      icon: Icons.settings,
      title: l10n.singleHandedBasicParameters,
      children: [
        EditorResponsiveFieldRow(
          children: [
            _baseNumberField(
              key: const ValueKey('singleHandedMissileCount'),
              label: l10n.singleHandedMissileCount,
              propertyName: 'MissileCount',
              value: _data.missileCount,
              integer: true,
              onChanged: (value) => _data.missileCount = value.toInt(),
            ),
            _baseNumberField(
              key: const ValueKey('singleHandedMissileInterval'),
              label: l10n.singleHandedMissileInterval,
              propertyName: 'MissileInterval',
              value: _data.missileInterval,
              onChanged: (value) => _data.missileInterval = value,
            ),
          ],
        ),
        const SizedBox(height: 16),
        EditorResponsiveFieldRow(
          children: [
            _baseNumberField(
              key: const ValueKey('singleHandedRocketHitTime'),
              label: l10n.singleHandedWarningTime,
              propertyName: 'RocketHitTime',
              value: _data.rocketHitTime,
              onChanged: (value) => _data.rocketHitTime = value,
            ),
            _baseNumberField(
              key: const ValueKey('singleHandedRocketSpeed'),
              label: l10n.singleHandedRocketSpeed,
              propertyName: 'RocketSpeed',
              value: _data.rocketSpeed,
              onChanged: (value) => _data.rocketSpeed = value,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _baseNumberField(
          key: const ValueKey('singleHandedZombieSpeed'),
          label: l10n.singleHandedZombieSpeedMultiplier,
          propertyName: 'ZombiesWalkSpeed',
          value: _data.zombiesWalkSpeed,
          onChanged: (value) => _data.zombiesWalkSpeed = value,
        ),
        const SizedBox(height: 16),
        _baseNumberField(
          key: const ValueKey('singleHandedZombieHealth'),
          label: l10n.singleHandedZombieHealthMultiplier,
          propertyName: 'ZombiesHitpointsPercent',
          value: _data.zombiesHitpointsPercent,
          onChanged: (value) => _data.zombiesHitpointsPercent = value,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.singleHandedSpecialMultiplierHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _baseNumberField({
    required Key key,
    required String label,
    required String propertyName,
    required num value,
    required ValueChanged<double> onChanged,
    bool integer = false,
  }) {
    return EditorResponsiveInputField(
      label: localizedPropertyLabel(context, label, propertyName),
      builder: (context, decoration) => TextFormField(
        key: key,
        initialValue: _formatNumber(value),
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        inputFormatters: [integer ? _integerFormatter : _decimalFormatter],
        decoration: decoration,
        onChanged: (raw) {
          final parsed = double.tryParse(raw);
          if (parsed == null) return;
          onChanged(parsed);
          _save();
        },
      ),
    );
  }

  Widget _buildPlantConfigurationCard(AppLocalizations l10n) {
    return _sectionCard(
      icon: Icons.local_florist,
      title: l10n.singleHandedPlantConfiguration,
      children: [
        Text(l10n.singleHandedPlantConfigurationInfo),
        const SizedBox(height: 16),
        _plantTile(
          plantId: _data.initWeapon,
          subtitle: l10n.singleHandedInitialPlantSubtitle(
            _formatNumber(_data.initWeaponLaunchTimePercent),
          ),
          trailing: IconButton(
            tooltip: l10n.edit,
            onPressed: _changeInitialPlant,
            icon: const Icon(Icons.edit),
          ),
          onTap: _changeInitialPlant,
        ),
        const SizedBox(height: 16),
        _baseNumberField(
          key: const ValueKey('singleHandedInitialAttackInterval'),
          label: l10n.singleHandedAttackInterval,
          propertyName: 'InitWeaponLaunchTimePercent',
          value: _data.initWeaponLaunchTimePercent,
          onChanged: (value) => _data.initWeaponLaunchTimePercent = value,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.singleHandedAttackIntervalHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            key: const ValueKey('singleHandedAddUpgradePlant'),
            onPressed: _addUpgradePlant,
            icon: const Icon(Icons.add),
            label: Text(l10n.singleHandedAddUpgradePlant),
          ),
        ),
        const SizedBox(height: 12),
        if (_data.dropWeaponDatas.isEmpty)
          _emptyText(l10n.singleHandedNoUpgradePlants)
        else
          for (final entry in _data.dropWeaponDatas) ...[
            _plantTile(
              plantId: entry.weaponName,
              subtitle: l10n.singleHandedUpgradePlantSubtitle(
                entry.killCount,
                _formatNumber(entry.launchTimePercent),
              ),
              trailing: IconButton(
                tooltip: l10n.delete,
                onPressed: () {
                  _data.dropWeaponDatas.remove(entry);
                  _save(rebuild: true);
                },
                icon: const Icon(Icons.delete_outline),
              ),
              onTap: () => _editUpgradePlant(entry),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _buildSpecialWavesCard(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return _sectionCard(
      icon: Icons.star,
      title: l10n.singleHandedSpecialWaves,
      children: [
        Text(l10n.singleHandedSpecialWavesInfo),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonalIcon(
            key: const ValueKey('singleHandedAddSpecialWave'),
            onPressed: _addSpecialWave,
            icon: const Icon(Icons.add),
            label: Text(l10n.singleHandedAddSpecialWave),
          ),
        ),
        const SizedBox(height: 12),
        if (_data.specialWaveDatas.isEmpty)
          _emptyText(l10n.singleHandedNoSpecialWaves)
        else
          for (final entry in _data.specialWaveDatas) ...[
            Material(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _editSpecialWave(entry),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  l10n.singleHandedWaveNumber(entry.wave),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  entry.showHealthBar
                                      ? l10n.singleHandedHealthBarEnabled
                                      : l10n.singleHandedHealthBarDisabled,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              l10n.singleHandedSpecialWaveSubtitle(
                                _formatNumber(entry.zombiesWalkSpeed),
                                _formatNumber(entry.zombiesHitpointsPercent),
                              ),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        onPressed: () {
                          _data.specialWaveDatas.remove(entry);
                          _save(rebuild: true);
                        },
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _plantTile({
    required String plantId,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final iconPath = _plantIcon(plantId);

    Widget plantIcon() => SizedBox(
      key: ValueKey('singleHandedPlantIcon_$plantId'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AssetImageWidget(
          assetPath: iconPath,
          altCandidates: imageAltCandidates(iconPath),
          width: 56,
          height: 56,
          fit: BoxFit.cover,
        ),
      ),
    );

    Widget plantIdentity() => SizedBox(
      key: ValueKey('singleHandedPlantIdentity_$plantId'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _plantName(context, plantId),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    Widget plantAction() => SizedBox(
      key: ValueKey('singleHandedPlantAction_$plantId'),
      child: trailing,
    );

    return Material(
      key: ValueKey('singleHandedPlantTile_$plantId'),
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
              final compact = constraints.maxWidth < 420 || textScale > 1.3;
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [plantIcon(), const Spacer(), plantAction()],
                    ),
                    const SizedBox(height: 12),
                    plantIdentity(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  plantIcon(),
                  const SizedBox(width: 12),
                  Expanded(child: plantIdentity()),
                  const SizedBox(width: 8),
                  plantAction(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
