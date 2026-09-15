import 'package:collection/collection.dart';
import 'package:c_editor/data/pvz_models/GlacierColumnSpawnData.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';

/// `GlacierModuleProperties` — glacier-block zombie spawn weights (6 columns).
class GlacierModulePropertiesData extends PvzModel {
  static const int columnCount = 6;

  GlacierModulePropertiesData({List<GlacierColumnSpawnData>? zombieSpawnData})
    : zombieSpawnData = normalizeColumns(zombieSpawnData);

  List<GlacierColumnSpawnData> zombieSpawnData;

  factory GlacierModulePropertiesData.createDefault() {
    return GlacierModulePropertiesData(
      zombieSpawnData: List.generate(
        columnCount,
        (_) => GlacierColumnSpawnData(),
      ),
    );
  }

  /// True when the level uses this module but lacks a compatible zomboss battle setup.
  static bool shouldShowCompatibilityWarning({
    required PvzLevelFile levelFile,
    required Set<String> moduleObjClasses,
  }) {
    final hasGlacier =
        moduleObjClasses.contains('GlacierModuleProperties') ||
        levelFile.objects.any((o) => o.objClass == 'GlacierModuleProperties');
    if (!hasGlacier) return false;

    final hasBattle =
        moduleObjClasses.contains('ZombossBattleModuleProperties') ||
        levelFile.objects.any(
          (o) => o.objClass == 'ZombossBattleModuleProperties',
        );
    if (!hasBattle) return true;

    final battle = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ZombossBattleModuleProperties',
    );
    if (battle?.objData is! Map) return true;
    final mechType = (battle!.objData as Map)['ZombossMechType'] as String?;
    return !ZombossMechRepository.isIceAgeMechVariation(mechType);
  }

  static List<GlacierColumnSpawnData> normalizeColumns(
    List<GlacierColumnSpawnData>? raw,
  ) {
    final cols = List<GlacierColumnSpawnData>.from(raw ?? []);
    while (cols.length < columnCount) {
      cols.add(GlacierColumnSpawnData());
    }
    if (cols.length > columnCount) {
      cols.removeRange(columnCount, cols.length);
    }
    return cols;
  }

  factory GlacierModulePropertiesData.fromJson(Map<String, dynamic> json) {
    final raw = json['ZombieSpawnData'];
    final list = <GlacierColumnSpawnData>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(GlacierColumnSpawnData.fromJson(e));
        } else if (e is Map) {
          list.add(
            GlacierColumnSpawnData.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return GlacierModulePropertiesData(zombieSpawnData: list);
  }

  @override
  Map<String, dynamic> toJson() => {
    'ZombieSpawnData': zombieSpawnData
        .map((column) => column.toJson())
        .toList(),
  };
}
