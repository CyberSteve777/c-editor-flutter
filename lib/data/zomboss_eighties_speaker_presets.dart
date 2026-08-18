import 'package:collection/collection.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Official first-phase speaker placements used by the Eighties Zomboss.
abstract class ZombossEightiesSpeakerPresets {
  ZombossEightiesSpeakerPresets._();

  static const baseId = 'ZombieZombossMech_Eighties';
  static const moduleObjClass = 'InitialGridItemProperties';
  static const moduleDefaultAlias = 'GridItemPlacement';
  static const speakerTypeName = 'speaker_zomboss';

  // Both regular five-row lawns and six-row Underwater World lawns use the
  // first five rows of column 6. The sixth underwater row remains untouched.
  static const positions = <({int x, int y})>[
    (x: 6, y: 0),
    (x: 6, y: 1),
    (x: 6, y: 2),
    (x: 6, y: 3),
    (x: 6, y: 4),
  ];

  static PvzObject? findModule(PvzLevelFile levelFile) => levelFile.objects
      .firstWhereOrNull((object) => object.objClass == moduleObjClass);

  static PvzObject ensureModule(PvzLevelFile levelFile) {
    var module = findModule(levelFile);
    if (module == null) {
      var alias = moduleDefaultAlias;
      var suffix = 0;
      while (levelFile.objects.any(
        (object) => object.aliases?.contains(alias) == true,
      )) {
        suffix++;
        alias = '$moduleDefaultAlias$suffix';
      }
      module = PvzObject(
        aliases: [alias],
        objClass: moduleObjClass,
        objData: InitialGridItemEntryData().toJson(),
      );
      levelFile.objects.add(module);
    }

    var alias = module.aliases?.firstOrNull;
    if (alias == null || alias.isEmpty) {
      alias = moduleDefaultAlias;
      module.aliases = [alias];
    }
    _registerModule(levelFile, alias);
    return module;
  }

  static String moduleRtid(PvzObject module) => RtidParser.build(
    module.aliases?.firstOrNull ?? moduleDefaultAlias,
    'CurrentLevel',
  );

  /// Replaces every existing item in the official speaker cells, then adds
  /// one Zomboss speaker to each cell. Placements elsewhere are preserved.
  static PvzObject applyToLevel(PvzLevelFile levelFile) {
    final module = ensureModule(levelFile);
    final data = _readData(module);
    final placements = data.placements
        .where((placement) => !_isPresetPosition(placement))
        .toList();
    placements.addAll(
      positions.map(
        (position) => InitialGridItemData(
          gridX: position.x,
          gridY: position.y,
          typeName: speakerTypeName,
        ),
      ),
    );
    module.objData = InitialGridItemEntryData(
      placements: placements,
      fieldName: data.fieldName,
    ).toJson();
    return module;
  }

  static bool hasPresetSpeakers(PvzLevelFile levelFile) {
    final module = findModule(levelFile);
    if (module == null) return false;
    return _readData(module).placements.any(
      (placement) =>
          placement.typeName == speakerTypeName && _isPresetPosition(placement),
    );
  }

  /// Removes only speakers still occupying the official preset cells. Any
  /// user-edited replacement items and all placements elsewhere are kept.
  static int removeFromLevel(PvzLevelFile levelFile) {
    final module = findModule(levelFile);
    if (module == null) return 0;
    final data = _readData(module);
    final placements = data.placements
        .where(
          (placement) =>
              placement.typeName != speakerTypeName ||
              !_isPresetPosition(placement),
        )
        .toList();
    final removed = data.placements.length - placements.length;
    if (removed > 0) {
      module.objData = InitialGridItemEntryData(
        placements: placements,
        fieldName: data.fieldName,
      ).toJson();
    }
    return removed;
  }

  static InitialGridItemEntryData _readData(PvzObject module) {
    if (module.objData is Map) {
      try {
        return InitialGridItemEntryData.fromJson(
          Map<String, dynamic>.from(module.objData as Map),
        );
      } catch (_) {
        // Fall through to a clean module while retaining the standard field.
      }
    }
    return InitialGridItemEntryData();
  }

  static bool _isPresetPosition(InitialGridItemData placement) => positions.any(
    (position) =>
        placement.gridX == position.x && placement.gridY == position.y,
  );

  static void _registerModule(PvzLevelFile levelFile, String alias) {
    final levelDefinition = levelFile.objects.firstWhereOrNull(
      (object) => object.objClass == 'LevelDefinition',
    );
    if (levelDefinition?.objData is! Map) return;
    final data = Map<String, dynamic>.from(levelDefinition!.objData as Map);
    final modules =
        (data['Modules'] as List?)?.map((entry) => entry.toString()).toList() ??
        <String>[];
    final rtid = RtidParser.build(alias, 'CurrentLevel');
    if (!modules.contains(rtid)) modules.add(rtid);
    data['Modules'] = modules;
    levelDefinition.objData = data;
  }
}
