import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';

class ZombossCustomActionPreset {
  const ZombossCustomActionPreset({
    required this.id,
    required this.nameKey,
    required this.sourceKey,
    required this.applicableMechs,
    required this.sourceAlias,
    required this.objclass,
    required this.sortIndex,
    required this.fields,
    required this.objdata,
    required this.dependencies,
    required this.dependencyRtidFields,
  });

  final String id;
  final String nameKey;
  final String sourceKey;
  final List<String> applicableMechs;
  final String sourceAlias;
  final String objclass;
  final int sortIndex;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, dynamic> objdata;
  final List<ZombossCustomActionPresetDependency> dependencies;
  final Map<String, String> dependencyRtidFields;

  factory ZombossCustomActionPreset.fromJson(Map<String, dynamic> json) {
    final rawObjdata = json['objdata'];
    final rawFields = json['fields'];
    final rawDependencies = json['dependencies'];
    final rawRtidFields = json['dependencyRtidFields'];
    return ZombossCustomActionPreset(
      id: json['id'] as String? ?? '',
      nameKey: json['nameKey'] as String? ?? '',
      sourceKey: json['sourceKey'] as String? ?? '',
      applicableMechs: (json['applicableMechs'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      sourceAlias: json['sourceAlias'] as String? ?? '',
      objclass: json['objclass'] as String? ?? '',
      sortIndex: json['sortIndex'] as int? ?? 0,
      fields: rawFields is List
          ? rawFields
                .whereType<Map>()
                .map(
                  (e) => ZombossMechFieldSpec.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      objdata: rawObjdata is Map
          ? Map<String, dynamic>.from(rawObjdata)
          : const {},
      dependencies: rawDependencies is List
          ? rawDependencies
                .whereType<Map>()
                .map(
                  (e) => ZombossCustomActionPresetDependency.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
      dependencyRtidFields: rawRtidFields is Map
          ? rawRtidFields.map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : const {},
    );
  }
}

class ZombossCustomActionPresetDependency {
  const ZombossCustomActionPresetDependency({
    required this.id,
    required this.alias,
    required this.objclass,
    required this.objdata,
  });

  final String id;
  final String alias;
  final String objclass;
  final Map<String, dynamic> objdata;

  factory ZombossCustomActionPresetDependency.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawObjdata = json['objdata'];
    return ZombossCustomActionPresetDependency(
      id: json['id'] as String? ?? '',
      alias: json['alias'] as String? ?? '',
      objclass: json['objclass'] as String? ?? '',
      objdata: rawObjdata is Map
          ? Map<String, dynamic>.from(rawObjdata)
          : const {},
    );
  }
}

enum ZombossCustomActionOrigin { presetTemplate, presetDerived, userCreated }

class ZombossPresetActionCreation {
  const ZombossPresetActionCreation({
    required this.rtid,
    required this.createdAliases,
    required this.createdObjects,
  });

  final String rtid;
  final List<String> createdAliases;
  final List<PvzObject> createdObjects;
}
