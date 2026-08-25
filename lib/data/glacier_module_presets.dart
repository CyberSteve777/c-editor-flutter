import 'package:collection/collection.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

class GlacierModulePreset {
  const GlacierModulePreset({
    required this.id,
    required this.variation,
    required this.createData,
    this.isBlank = false,
  });

  final String id;
  final String variation;
  final GlacierModulePropertiesData Function() createData;
  final bool isBlank;
}

/// Official Ice Chunk Module configurations used by Frostbite Caves Zomboss
/// variations. Empty zombie type entries are intentional: they represent the
/// chance that an Ice Chunk releases no zombie.
abstract class GlacierModulePresets {
  GlacierModulePresets._();

  static const iceAgeBaseId = 'ZombieZombossMech_IceAge';
  static const defaultVariation = 'zombossmech_iceage';
  static const plantPuzzleVariation = 'zombossmech_iceage_eliminate';
  static const customVariation = 'zombossmech_iceage_memo';
  static const customBlankId = 'custom_blank';

  static final List<GlacierModulePreset> all = [
    GlacierModulePreset(
      id: defaultVariation,
      variation: defaultVariation,
      createData: _standardData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_modern_iceage',
      variation: 'zombossmech_modern_iceage',
      createData: _standardData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_rift',
      variation: 'zombossmech_iceage_rift',
      createData: _riftData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_vacation',
      variation: 'zombossmech_iceage_vacation',
      createData: _vacationData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_TimeTravel_easy',
      variation: 'zombossmech_iceage_TimeTravel_easy',
      createData: _standardData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_TimeTravel_normal',
      variation: 'zombossmech_iceage_TimeTravel_normal',
      createData: _standardData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_TimeTravel_hard',
      variation: 'zombossmech_iceage_TimeTravel_hard',
      createData: _standardData,
    ),
    GlacierModulePreset(
      id: 'zombossmech_iceage_12th',
      variation: 'zombossmech_iceage_12th',
      createData: _anniversaryData,
    ),
    GlacierModulePreset(
      id: customBlankId,
      variation: customVariation,
      createData: GlacierModulePropertiesData.createDefault,
      isBlank: true,
    ),
  ];

  static GlacierModulePreset get defaultPreset => all.first;

  static GlacierModulePreset? byId(String? id) =>
      all.firstWhereOrNull((preset) => preset.id == id);

  static bool isPlantPuzzleVariation(String? variation) =>
      variation == plantPuzzleVariation;

  static GlacierModulePreset? forVariation(String? variation) {
    if (variation == null || isPlantPuzzleVariation(variation)) return null;
    return all.firstWhereOrNull((preset) => preset.variation == variation);
  }

  static GlacierModulePreset? matchingPreset(GlacierModulePropertiesData data) {
    return all.firstWhereOrNull((preset) => matches(data, preset));
  }

  static bool matches(
    GlacierModulePropertiesData data,
    GlacierModulePreset preset,
  ) => const DeepCollectionEquality().equals(
    data.toJson(),
    preset.createData().toJson(),
  );

  /// Applies [preset] to the first level-local Ice Chunk Module, creating and
  /// registering that module when it does not exist.
  static PvzObject applyToLevel(
    PvzLevelFile levelFile,
    GlacierModulePreset preset,
  ) {
    var module = levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'GlacierModuleProperties',
    );

    if (module == null) {
      var alias = 'GlacierModule';
      var suffix = 0;
      while (levelFile.objects.any(
        (object) => object.aliases?.contains(alias) == true,
      )) {
        suffix++;
        alias = 'GlacierModule_$suffix';
      }
      module = PvzObject(
        aliases: [alias],
        objClass: 'GlacierModuleProperties',
        objData: preset.createData().toJson(),
      );
      levelFile.objects.add(module);
    } else {
      module.objData = preset.createData().toJson();
    }

    var alias = module.aliases?.firstOrNull;
    if (alias == null || alias.isEmpty) {
      alias = 'GlacierModule';
      module.aliases = [alias];
    }
    final moduleRtid = RtidParser.build(alias, 'CurrentLevel');
    final levelDefinition = levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'LevelDefinition',
    );
    if (levelDefinition?.objData is Map) {
      final data = Map<String, dynamic>.from(levelDefinition!.objData as Map);
      final modules =
          (data['Modules'] as List?)
              ?.map((entry) => entry.toString())
              .toList() ??
          <String>[];
      if (!modules.contains(moduleRtid)) modules.add(moduleRtid);
      data['Modules'] = modules;
      levelDefinition.objData = data;
    }
    return module;
  }

  static GlacierColumnSpawnData _column(
    List<({String typeName, num weight})> entries,
  ) => GlacierColumnSpawnData(
    entries: entries
        .map(
          (entry) => GlacierSpawnEntryData(
            typeName: entry.typeName,
            weight: entry.weight,
          ),
        )
        .toList(),
  );

  static GlacierModulePropertiesData _standardData() {
    return GlacierModulePropertiesData(
      zombieSpawnData: [
        _column([(typeName: '', weight: 3)]),
        _column([
          (typeName: '', weight: 2),
          (typeName: 'iceage_weasel', weight: 3),
          (typeName: 'iceage_imp', weight: 5),
          (typeName: 'iceage', weight: 1),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_imp', weight: 3),
          (typeName: 'iceage', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_imp', weight: 2),
          (typeName: 'iceage', weight: 5),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage_imp', weight: 0),
          (typeName: 'iceage', weight: 1),
          (typeName: 'iceage_armor3', weight: 3),
          (typeName: 'iceage_hunter', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage', weight: 0),
          (typeName: 'iceage_armor3', weight: 4),
          (typeName: 'iceage_hunter', weight: 3),
          (typeName: 'iceage_dodo', weight: 1),
        ]),
      ],
    );
  }

  static GlacierModulePropertiesData _riftData() {
    return GlacierModulePropertiesData(
      zombieSpawnData: [
        _column([(typeName: '', weight: 3)]),
        _column([
          (typeName: '', weight: 0.5),
          (typeName: 'iceage_weaselhoarder', weight: 3),
          (typeName: 'iceage_imp', weight: 5),
          (typeName: 'iceage', weight: 1),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_imp', weight: 3),
          (typeName: 'iceage', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_imp', weight: 2),
          (typeName: 'iceage', weight: 5),
        ]),
        _column([
          (typeName: 'iceage', weight: 0.5),
          (typeName: 'iceage_armor3', weight: 3),
          (typeName: 'iceage_hunter', weight: 2),
          (typeName: 'iceage_weaselhoarder', weight: 3),
        ]),
        _column([
          (typeName: 'iceage_armor3', weight: 4),
          (typeName: 'iceage_hunter', weight: 1),
          (typeName: 'iceage_dodo', weight: 3),
        ]),
      ],
    );
  }

  static GlacierModulePropertiesData _vacationData() {
    return GlacierModulePropertiesData(
      zombieSpawnData: [
        _column([(typeName: '', weight: 3)]),
        _column([
          (typeName: '', weight: 2),
          (typeName: 'iceage_weaselhoarder', weight: 3),
          (typeName: 'iceage_imp', weight: 5),
          (typeName: 'iceage', weight: 1),
        ]),
        _column([
          (typeName: 'iceage_armor1', weight: 2),
          (typeName: 'iceage_weaselhoarder', weight: 3),
          (typeName: 'iceage', weight: 3),
        ]),
        _column([
          (typeName: 'iceage_armor2', weight: 3),
          (typeName: 'iceage_imp', weight: 2),
          (typeName: 'iceage', weight: 5),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage_imp', weight: 1),
          (typeName: 'iceage_chief', weight: 2),
          (typeName: 'iceage_armor3', weight: 3),
          (typeName: 'iceage_hunter', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage_gargantuar', weight: 2),
          (typeName: 'iceage_armor3', weight: 4),
          (typeName: 'iceage_hunter', weight: 3),
          (typeName: 'iceage_dodo', weight: 3),
        ]),
      ],
    );
  }

  static GlacierModulePropertiesData _anniversaryData() {
    return GlacierModulePropertiesData(
      zombieSpawnData: [
        _column([(typeName: '', weight: 3)]),
        _column([
          (typeName: '', weight: 2),
          (typeName: 'iceage_weasel', weight: 3),
          (typeName: 'iceage_dodo', weight: 5),
          (typeName: 'iceage', weight: 1),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_dodo', weight: 3),
          (typeName: 'iceage', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 1),
          (typeName: 'iceage_dodo', weight: 2),
          (typeName: 'iceage', weight: 5),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage_dodo', weight: 0),
          (typeName: 'iceage', weight: 1),
          (typeName: 'iceage_armor3', weight: 3),
          (typeName: 'iceage_hunter', weight: 3),
        ]),
        _column([
          (typeName: '', weight: 0),
          (typeName: 'iceage', weight: 0),
          (typeName: 'iceage_armor3', weight: 4),
          (typeName: 'iceage_hunter', weight: 3),
          (typeName: 'iceage_dodo', weight: 1),
        ]),
      ],
    );
  }
}
