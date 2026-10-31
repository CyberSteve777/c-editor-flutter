import 'package:flutter/material.dart';
import 'package:c_editor/data/halloween_content.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class HalloweenPlacementScreen extends StatefulWidget {
  const HalloweenPlacementScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.cauldron,
    required this.onChanged,
    required this.onBack,
  });
  final String rtid;
  final PvzLevelFile levelFile;
  final bool cauldron;
  final VoidCallback onChanged, onBack;
  @override
  State<HalloweenPlacementScreen> createState() => _HalloweenPlacementState();
}

class _HalloweenPlacementState extends State<HalloweenPlacementScreen> {
  late PvzObject object;
  late Map<String, dynamic> data;
  late String alias;
  int selected = 0;
  String get listKey =>
      widget.cauldron ? 'InitialGridItemWizardCrucibles' : 'SpawnPositionsPool';
  List<dynamic> get positions => data[listKey] as List;
  @override
  void initState() {
    super.initState();
    alias = aliasFromRtid(widget.rtid);
    object = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
    );
    data = Map<String, dynamic>.from(object.objData as Map);
    data.putIfAbsent(listKey, () => <dynamic>[]);
    data[listKey] = [
      for (final item in positions) Map<String, dynamic>.from(item as Map),
    ];
    if (!widget.cauldron) {
      data.putIfAbsent('Hitpoints', () => 4000);
      data.putIfAbsent('Level', () => 0);
      data.putIfAbsent(
        'PumpkinScarecrowPool',
        () => [
          {'Count': 1, 'Type': 'RTID(pumpkin_scarecrow@GridItemTypes)'},
        ],
      );
    }
  }

  void sync() {
    object.objData = data;
    widget.onChanged();
    setState(() {});
  }

  Widget number(Map target, String key, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      key: ValueKey('${identityHashCode(target)}_$key'),
      initialValue: '${target[key] ?? 0}',
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (text) {
        final value = num.tryParse(text);
        if (value == null || !value.isFinite || value < 0) return;
        if ((key == 'Level' || key == 'Count') && value != value.truncate()) {
          return;
        }
        target[key] = key == 'Level' || key == 'Count' ? value.toInt() : value;
        sync();
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = widget.cauldron
        ? l.moduleTitle_InitialGridItemWizardCrucibleProps
        : l.eventTitle_SpawnPumpkinScarecrowWaveActionProps;
    final dimensions = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    final rows = dimensions.$1, cols = dimensions.$2;
    final xKey = widget.cauldron ? 'GridX' : 'mX',
        yKey = widget.cauldron ? 'GridY' : 'mY';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(title),
                scrollable: true,
                content: Text(
                  widget.cauldron
                      ? l.wizardCauldronHelpOverview
                      : l.pumpkinScarecrowHelpOverview,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l.ok),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EditorAliasInputField(
                alias: alias,
                levelFile: widget.levelFile,
                onAliasChanged: (value) {
                  renameLevelObjectAlias(
                    levelFile: widget.levelFile,
                    oldAlias: alias,
                    newAlias: value,
                    onChanged: widget.onChanged,
                  );
                  setState(() => alias = value);
                },
              ),
              const SizedBox(height: 16),
              Text(
                widget.cauldron
                    ? l.wizardCauldronPositions
                    : l.pumpkinScarecrowPositions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: cols / rows,
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: cols,
                  children: List.generate(rows * cols, (i) {
                    final x = i % cols, y = i ~/ cols;
                    final index = positions.indexWhere(
                      (p) => p[xKey] == x && p[yKey] == y,
                    );
                    return InkWell(
                      onTap: () {
                        if (index < 0) {
                          positions.add(
                            widget.cauldron
                                ? newCauldron(x, y)
                                : {'mX': x, 'mY': y},
                          );
                          selected = positions.length - 1;
                        } else {
                          selected = index;
                        }
                        sync();
                      },
                      onLongPress: () {
                        if (index >= 0) {
                          positions.removeAt(index);
                          selected = 0;
                          sync();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          color: index >= 0
                              ? Colors.orange.withValues(alpha: .35)
                              : null,
                        ),
                        child: index < 0
                            ? null
                            : Icon(
                                widget.cauldron
                                    ? Icons.soup_kitchen
                                    : Icons.cruelty_free,
                              ),
                      ),
                    );
                  }),
                ),
              ),
              if (!widget.cauldron) ...[
                number(data, 'Hitpoints', l.pumpkinScarecrowHitpoints),
                number(data, 'Level', l.pumpkinScarecrowCrowLevel),
                for (final pool in data['PumpkinScarecrowPool'] as List)
                  number(pool, 'Count', l.pumpkinScarecrowSpawnCount),
              ],
              if (positions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '${positions[selected][xKey] + 1}, ${positions[selected][yKey] + 1}',
                ),
                if (widget.cauldron) ...[
                  number(
                    positions[selected],
                    'CrucibleHitpoints',
                    l.wizardCauldronHitpoints,
                  ),
                  number(
                    positions[selected],
                    'BoilingDuration',
                    l.wizardCauldronBoilingDuration,
                  ),
                  number(
                    positions[selected],
                    'ExplodeDamageAmount',
                    l.wizardCauldronExplosionDamage,
                  ),
                  number(
                    positions[selected],
                    'VenomDamageAmountPerSecond',
                    l.wizardCauldronVenomDamagePerSecond,
                  ),
                  number(
                    positions[selected],
                    'VenomExistDuration',
                    l.wizardCauldronVenomDuration,
                  ),
                ],
                OutlinedButton.icon(
                  onPressed: () {
                    positions.removeAt(selected);
                    selected = 0;
                    sync();
                  },
                  icon: const Icon(Icons.delete),
                  label: Text(l.delete),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
