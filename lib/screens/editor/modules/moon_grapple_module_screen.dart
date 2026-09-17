import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class MoonGrappleModuleScreen extends StatefulWidget {
  const MoonGrappleModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
    this.referenceData,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final Map<String, dynamic>? referenceData;

  @override
  State<MoonGrappleModuleScreen> createState() =>
      _MoonGrappleModuleScreenState();
}

class _MoonGrappleModuleScreenState extends State<MoonGrappleModuleScreen> {
  static const _objClass = 'MoonGrappleModuleProperties';

  late MoonGrappleModulePropertiesData _data;
  late String _alias;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    final object = widget.levelFile.objects.firstWhereOrNull(
      (candidate) => candidate.aliases?.contains(_alias) == true,
    );
    final raw = object?.objData is Map
        ? Map<String, dynamic>.from(object!.objData as Map)
        : widget.referenceData;
    _data = raw == null
        ? MoonGrappleModulePropertiesData.createDefault()
        : MoonGrappleModulePropertiesData.fromJson(raw);
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

  void _sync() {
    final object = widget.levelFile.objects.firstWhereOrNull(
      (candidate) => candidate.aliases?.contains(_alias) == true,
    );
    if (object != null) object.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _updateDouble(String value, void Function(double) update) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    update(parsed);
    _sync();
  }

  void _updateInt(String value, void Function(int) update) {
    final parsed = int.tryParse(value);
    if (parsed == null) return;
    update(parsed);
    _sync();
  }

  Widget _numberField(
    String label,
    double value,
    void Function(String) onChanged, {
    bool integer = false,
  }) {
    return EditorResponsiveInputField(
      label: label,
      builder: (context, decoration) => TextFormField(
        initialValue: integer ? value.toInt().toString() : value.toString(),
        keyboardType: TextInputType.numberWithOptions(decimal: !integer),
        decoration: decoration,
        onChanged: onChanged,
      ),
    );
  }

  Widget _vectorField(
    String label,
    MoonGrappleVectorData vector,
    void Function(double x, double y) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: _numberField(
            '$label X',
            vector.x,
            (value) =>
                _updateDouble(value, (next) => onChanged(next, vector.y)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _numberField(
            '$label Y',
            vector.y,
            (value) =>
                _updateDouble(value, (next) => onChanged(vector.x, next)),
          ),
        ),
      ],
    );
  }

  Widget _section(String title, List<Widget> children, {Widget? trailing}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _roundEditor(int index, MoonGrappleRoundData round) {
    final l10n = AppLocalizations.of(context);
    return _section(
      l10n?.moonGrappleRound(index + 1) ?? 'Round ${index + 1}',
      [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: _numberField(
                l10n?.moonGrappleTargetScore ?? 'Target score',
                round.targetScore.toDouble(),
                (value) =>
                    _updateInt(value, (next) => round.targetScore = next),
                integer: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: _numberField(
                l10n?.moonGrappleSpawnThreshold ?? 'Spawn threshold',
                round.spawnThreshold.toDouble(),
                (value) =>
                    _updateInt(value, (next) => round.spawnThreshold = next),
                integer: true,
              ),
            ),
            SizedBox(
              width: 180,
              child: _numberField(
                l10n?.moonGrappleSpawnInterval ?? 'Spawn interval',
                round.spawnInterval,
                (value) =>
                    _updateDouble(value, (next) => round.spawnInterval = next),
              ),
            ),
            SizedBox(
              width: 180,
              child: _numberField(
                l10n?.moonGrappleMinimumSpeed ?? 'Minimum speed',
                round.minimumSpeed,
                (value) =>
                    _updateDouble(value, (next) => round.minimumSpeed = next),
              ),
            ),
            SizedBox(
              width: 180,
              child: _numberField(
                l10n?.moonGrappleMaximumSpeed ?? 'Maximum speed',
                round.maximumSpeed,
                (value) =>
                    _updateDouble(value, (next) => round.maximumSpeed = next),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...round.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(item.type),
              subtitle: Text(
                l10n?.moonGrappleRenderingFixed ??
                    'Rendering definition is fixed',
              ),
              trailing: IconButton(
                tooltip:
                    l10n?.moonGrappleRemoveSpawnObject ?? 'Remove spawn object',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  round.items.remove(item);
                  _sync();
                },
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: _numberField(
                        l10n?.moonGrappleSpawnWeight ?? 'Spawn weight',
                        item.spawnWeight,
                        (value) => _updateDouble(
                          value,
                          (next) => item.spawnWeight = next,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: _numberField(
                        l10n?.moonGrappleReturnSpeedFactor ??
                            'Return speed factor',
                        item.returnSpeedFactor,
                        (value) => _updateDouble(
                          value,
                          (next) => item.returnSpeedFactor = next,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: _numberField(
                        l10n?.moonGrappleScore ?? 'Score',
                        item.score.toDouble(),
                        (value) =>
                            _updateInt(value, (next) => item.score = next),
                        integer: true,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: _numberField(
                        l10n?.moonGrappleExperience ?? 'Experience',
                        item.experience.toDouble(),
                        (value) =>
                            _updateInt(value, (next) => item.experience = next),
                        integer: true,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: _numberField(
                        l10n?.moonGrappleCollisionRadius ?? 'Collision radius',
                        item.collisionRadius,
                        (value) => _updateDouble(
                          value,
                          (next) => item.collisionRadius = next,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Align(alignment: Alignment.centerLeft, child: _itemAddMenu(round)),
      ],
      trailing: IconButton(
        tooltip: l10n?.moonGrappleRemoveRound ?? 'Remove round',
        icon: const Icon(Icons.delete_outline),
        onPressed: _data.rounds.length > 1
            ? () {
                _data.rounds.removeAt(index);
                _sync();
              }
            : null,
      ),
    );
  }

  void _addRound() {
    final defaults = MoonGrappleModulePropertiesData.createDefault();
    _data.rounds.add(
      MoonGrappleRoundData.fromJson(
        defaults.rounds.last.toJson(),
        firstRound: false,
      ),
    );
    _sync();
  }

  void _addItem(MoonGrappleRoundData round, String type) {
    if (round.items.any((item) => item.type == type)) return;
    round.items.add(MoonGrappleItemData(type: type));
    _sync();
  }

  Widget _itemAddMenu(MoonGrappleRoundData round) {
    final available = MoonGrappleItemData.supportedTypes
        .where((type) => !round.items.any((item) => item.type == type))
        .toList();
    return PopupMenuButton<String>(
      tooltip:
          AppLocalizations.of(context)?.moonGrappleAddSpawnObject ??
          'Add spawn object',
      icon: const Icon(Icons.add_circle_outline),
      enabled: available.isNotEmpty,
      onSelected: (type) => _addItem(round, type),
      itemBuilder: (context) => available
          .map((type) => PopupMenuItem(value: type, child: Text(type)))
          .toList(),
    );
  }

  Widget _backgroundObjectsEditor() {
    final l10n = AppLocalizations.of(context);
    return _section(
      l10n?.moonGrappleBackgroundObjects ?? 'Background objects',
      [
        ..._data.backgroundObjects.map(
          (object) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  tooltip:
                      l10n?.moonGrappleRemoveBackgroundObject ??
                      'Remove background object',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _data.backgroundObjects.remove(object);
                    _sync();
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(object.popAnimName),
                      Text(
                        l10n?.moonGrappleAnimationArtCenterFixed ??
                            'Animation and art center are fixed',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 220,
                  child: _numberField(
                    l10n?.moonGrappleSpeed ?? 'Speed',
                    object.speed,
                    (value) =>
                        _updateDouble(value, (next) => object.speed = next),
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip:
              l10n?.moonGrappleAddBackgroundObject ?? 'Add background object',
          icon: const Icon(Icons.add_circle_outline),
          onSelected: (name) {
            _data.backgroundObjects.add(
              MoonGrappleBackgroundObjectData(popAnimName: name),
            );
            _sync();
          },
          itemBuilder: (context) {
            final existing = _data.backgroundObjects
                .map((object) => object.popAnimName)
                .toSet();
            return MoonGrappleBackgroundObjectData.supportedPopAnimNames
                .where((name) => !existing.contains(name))
                .map((name) => PopupMenuItem(value: name, child: Text(name)))
                .toList();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ModuleAliasInputField(
            rtid: widget.rtid,
            alias: _alias,
            levelFile: widget.levelFile,
            onAliasChanged: _handleAliasChanged,
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: 12),
          _section(l10n?.moonGrappleHookGameplay ?? 'Hook gameplay', [
            _vectorField(
              l10n?.moonGrappleShipPosition ?? 'Ship position',
              _data.shipPosition,
              (x, y) {
                _data.shipPosition.x = x;
                _data.shipPosition.y = y;
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleMinimumHookDistance ??
                        'Minimum hook distance',
                    _data.minimumHookDistance,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.minimumHookDistance = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleMaximumHookDistance ??
                        'Maximum hook distance',
                    _data.maximumHookDistance,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.maximumHookDistance = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleFiringArcDegrees ?? 'Firing arc degrees',
                    _data.firingArcDegrees,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.firingArcDegrees = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleLaunchSpeed ?? 'Launch speed',
                    _data.launchSpeed,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.launchSpeed = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleEmptyReturnSpeed ?? 'Empty return speed',
                    _data.emptyReturnSpeed,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.emptyReturnSpeed = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleLoadedReturnSpeed ?? 'Loaded return speed',
                    _data.loadedReturnSpeed,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.loadedReturnSpeed = next,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _numberField(
                    l10n?.moonGrappleHookCollisionRadius ??
                        'Hook collision radius',
                    _data.hookCollisionRadius,
                    (value) => _updateDouble(
                      value,
                      (next) => _data.hookCollisionRadius = next,
                    ),
                  ),
                ),
              ],
            ),
          ]),
          const SizedBox(height: 12),
          _section(l10n?.moonGrappleSpawnLayout ?? 'Spawn layout', [
            _numberField(
              l10n?.moonGrappleFormationSpacing ?? 'Formation spacing',
              _data.formationSpacing,
              (value) =>
                  _updateDouble(value, (next) => _data.formationSpacing = next),
            ),
            const SizedBox(height: 12),
            _numberField(
              l10n?.moonGrappleFormationYOffset ?? 'Formation Y offset',
              _data.formationYOffset,
              (value) =>
                  _updateDouble(value, (next) => _data.formationYOffset = next),
            ),
          ]),
          const SizedBox(height: 12),
          _backgroundObjectsEditor(),
          const SizedBox(height: 12),
          ..._data.rounds.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _roundEditor(entry.key, entry.value),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _addRound,
              icon: const Icon(Icons.add),
              label: Text(l10n?.moonGrappleAddRound ?? 'Add round'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.moduleDesc_MoonGrappleModuleProperties ??
                'Configure the Moon BaseZ grappling game.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
