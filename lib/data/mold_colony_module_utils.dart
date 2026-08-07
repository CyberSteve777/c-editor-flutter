import 'package:collection/collection.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

abstract final class MoldColonyModuleUtils {
  static const moduleObjClass = 'MoldColonyChallengeProps';
  static const layoutObjClass = 'BoardGridMapProps';
  static const defaultModuleAlias = 'DoNotPlantBeforeLine';
  static const defaultLayoutAlias = 'Mold';

  static PvzObject? findLayoutObject(PvzLevelFile levelFile, String locations) {
    final info = RtidParser.parse(locations);
    if (info == null) return null;
    return levelFile.objects.firstWhereOrNull(
      (object) =>
          object.objClass == layoutObjClass &&
          object.aliases?.contains(info.alias) == true,
    );
  }

  static bool hasValidLayoutLink(
    PvzLevelFile levelFile,
    MoldColonyChallengePropsData data,
  ) {
    final info = RtidParser.parse(data.locations);
    return info?.source == 'CurrentLevel' &&
        findLayoutObject(levelFile, data.locations) != null;
  }

  /// Repairs [Locations] and creates its current-level grid map when needed.
  /// A matching local map is reused even when the original RTID incorrectly
  /// points at LevelModules.
  static String ensureCurrentLevelLayout({
    required PvzLevelFile levelFile,
    required PvzObject moduleObject,
    int rows = 5,
    int columns = 9,
  }) {
    final moduleData = MoldColonyChallengePropsData.fromJson(
      Map<String, dynamic>.from(moduleObject.objData as Map? ?? const {}),
    );
    final info = RtidParser.parse(moduleData.locations);
    final requestedAlias = info?.alias.trim();
    final existingLayout = requestedAlias == null || requestedAlias.isEmpty
        ? null
        : levelFile.objects.firstWhereOrNull(
            (object) =>
                object.objClass == layoutObjClass &&
                object.aliases?.contains(requestedAlias) == true,
          );

    final String layoutAlias;
    if (existingLayout != null) {
      layoutAlias = requestedAlias!;
    } else {
      layoutAlias = PvzAliasUtils.uniqueAlias(levelFile, defaultLayoutAlias);
      levelFile.objects.add(
        PvzObject(
          aliases: [layoutAlias],
          objClass: layoutObjClass,
          objData: BoardGridMapPropsData.empty(
            rows: rows,
            columns: columns,
          ).toJson(),
        ),
      );
    }

    moduleData.locations = RtidParser.build(layoutAlias, 'CurrentLevel');
    moduleObject.objData = moduleData.toJson();
    return layoutAlias;
  }

  static void removeUnreferencedLayout({
    required PvzLevelFile levelFile,
    required String locations,
  }) {
    final info = RtidParser.parse(locations);
    if (info?.source != 'CurrentLevel') return;
    final target = RtidParser.build(info!.alias, 'CurrentLevel');
    final layout = findLayoutObject(levelFile, target);
    if (layout == null) return;
    final isStillReferenced = levelFile.objects.any(
      (object) =>
          !identical(object, layout) && _containsValue(object.objData, target),
    );
    if (!isStillReferenced) levelFile.objects.remove(layout);
  }

  static bool _containsValue(dynamic value, String target) {
    if (value == target) return true;
    if (value is Map) {
      return value.values.any((item) => _containsValue(item, target));
    }
    if (value is Iterable) {
      return value.any((item) => _containsValue(item, target));
    }
    return false;
  }
}
