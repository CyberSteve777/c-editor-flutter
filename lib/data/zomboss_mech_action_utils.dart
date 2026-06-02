import 'package:collection/collection.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models/PvzObject.dart';
import 'package:z_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:z_editor/data/rtid_parser.dart';

/// Binding for a spawn-related zombie type field on an action.
class ZombossZombieListBinding {
  const ZombossZombieListBinding({
    required this.fieldName,
    required this.isList,
    required this.zombieIds,
  });

  final String fieldName;
  final bool isList;
  final List<String> zombieIds;
}

/// Action data resolved from catalog or a level-local object.
class ZombossResolvedAction {
  const ZombossResolvedAction({
    required this.rtid,
    required this.alias,
    required this.tag,
    required this.fields,
    required this.data,
    required this.editable,
    required this.levelObject,
  });

  final String rtid;
  final String alias;
  final String tag;
  final List<ZombossMechFieldSpec> fields;
  final Map<String, dynamic> data;
  final bool editable;
  final PvzObject? levelObject;

  List<ZombossZombieListBinding> get zombieLists =>
      ZombossMechActionUtils.zombieListBindings(fields, data);

  bool get hasZombieLists => zombieLists.any((b) => b.zombieIds.isNotEmpty);
}

/// Helpers for zomboss mech stage actions (catalog + level-local custom).
abstract class ZombossMechActionUtils {
  static const catalogSource = 'ZombieActions';
  static const customSource = 'CurrentLevel';

  static String displayLabel(String rtid) {
    final info = RtidParser.parse(rtid);
    if (info == null) return rtid;
    return '${info.alias}@${info.source}';
  }

  static bool isCustomRtid(String rtid) =>
      RtidParser.parse(rtid)?.source == customSource;

  static PvzObject? findLevelObject(PvzLevelFile levelFile, String rtid) {
    final info = RtidParser.parse(rtid);
    if (info == null || info.source != customSource) return null;
    return levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(info.alias) == true,
    );
  }

  static Map<String, dynamic> dataFromCatalogAction(ZombossMechCatalogAction action) {
    if (action.defaultData.isNotEmpty) {
      return Map<String, dynamic>.from(
        _deepClone(action.defaultData) as Map,
      );
    }
    return defaultsFromFields(action.fields);
  }

  static Map<String, dynamic> defaultsFromFields(List<ZombossMechFieldSpec> fields) {
    final data = <String, dynamic>{};
    for (final field in fields) {
      if (field.name.isEmpty || field.name.startsWith('#')) continue;
      if (field.type == 'object' && field.objectFields.isNotEmpty) {
        data[field.name] = defaultsFromFields(field.objectFields);
      } else if (field.defaultValue != null) {
        data[field.name] = _deepClone(field.defaultValue);
      }
    }
    return data;
  }

  static bool isZombieTypeField(ZombossMechFieldSpec field) =>
      field.type == 'List<zombieType>' || field.type == 'zombieType';

  static List<String> parseZombieTypeList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  /// Resolved action data for display/editing (catalog impl or level object).
  static ZombossResolvedAction? resolveAction({
    required String rtid,
    required ZombossMechCatalogEntry catalog,
    required PvzLevelFile levelFile,
  }) {
    final info = RtidParser.parse(rtid);
    if (info == null) return null;

    if (info.source == customSource) {
      final obj = findLevelObject(levelFile, rtid);
      if (obj == null) return null;
      final group = catalog.actions
          .where((g) => g.objclass == obj.objClass)
          .firstOrNull;
      final raw = obj.objData;
      final data = raw is Map<String, dynamic>
          ? Map<String, dynamic>.from(raw)
          : raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};
      return ZombossResolvedAction(
        rtid: rtid,
        alias: info.alias,
        tag: group?.tag ?? '',
        fields: group?.fields ?? const [],
        data: data,
        editable: true,
        levelObject: obj,
      );
    }

    final action = catalog.catalogActionForAlias(info.alias);
    if (action == null) return null;
    return ZombossResolvedAction(
      rtid: rtid,
      alias: info.alias,
      tag: action.tag,
      fields: action.fields,
      data: Map<String, dynamic>.from(action.defaultData),
      editable: false,
      levelObject: null,
    );
  }

  static List<ZombossZombieListBinding> zombieListBindings(
    List<ZombossMechFieldSpec> fields,
    Map<String, dynamic> data,
  ) {
    final bindings = <ZombossZombieListBinding>[];
    for (final field in fields) {
      if (field.type == 'List<zombieType>') {
        bindings.add(
          ZombossZombieListBinding(
            fieldName: field.name,
            isList: true,
            zombieIds: parseZombieTypeList(data[field.name]),
          ),
        );
      } else if (field.type == 'zombieType') {
        final raw = data[field.name];
        if (raw == null || raw.toString().isEmpty) continue;
        bindings.add(
          ZombossZombieListBinding(
            fieldName: field.name,
            isList: false,
            zombieIds: [raw.toString()],
          ),
        );
      }
    }
    return bindings;
  }

  static void writeZombieList(
    Map<String, dynamic> data,
    ZombossZombieListBinding binding,
    List<String> ids,
  ) {
    if (binding.isList) {
      data[binding.fieldName] = List<String>.from(ids);
    } else {
      data[binding.fieldName] = ids.isNotEmpty ? ids.first : '';
    }
  }

  static bool usesLabeledIntInput(ZombossMechFieldSpec field) {
    if (field.type != 'int') return false;
    final def = field.defaultValue;
    if (def is num && def > 10) return true;
    final name = field.name.toLowerCase();
    const keys = [
      'hp',
      'hitpoint',
      'damage',
      'weight',
      'count',
      'amount',
      'health',
      'column',
      'row',
      'num',
      'launch',
      'spawn',
    ];
    return keys.any(name.contains);
  }

  static String uniqueCustomAlias(
    PvzLevelFile levelFile,
    String baseAlias,
  ) {
    if (!levelFile.objects.any((o) => o.aliases?.contains(baseAlias) == true)) {
      return baseAlias;
    }
    var i = 2;
    while (levelFile.objects.any(
      (o) => o.aliases?.contains('${baseAlias}_$i') == true,
    )) {
      i++;
    }
    return '${baseAlias}_$i';
  }

  static PvzObject createCustomAction({
    required PvzLevelFile levelFile,
    required String objclass,
    required String alias,
    required Map<String, dynamic> data,
  }) {
    final obj = PvzObject(
      aliases: [alias],
      objClass: objclass,
      objData: _deepClone(data),
    );
    levelFile.objects.add(obj);
    return obj;
  }

  static void renameCustomActionReferences({
    required Map<String, dynamic> propsData,
    required String oldAlias,
    required String newAlias,
  }) {
    if (oldAlias == newAlias) return;
    final oldRtid = RtidParser.build(oldAlias, customSource);
    final newRtid = RtidParser.build(newAlias, customSource);
    final stages = propsData['Stages'];
    if (stages is! List) return;
    for (final stage in stages) {
      if (stage is! Map) continue;
      final actions = stage['Actions'];
      if (actions is List) {
        for (var i = 0; i < actions.length; i++) {
          if (actions[i] == oldRtid) actions[i] = newRtid;
        }
      }
      if (stage['RetreatAction'] == oldRtid) {
        stage['RetreatAction'] = newRtid;
      }
    }
  }

  static void removeCustomActionFromStages({
    required Map<String, dynamic> propsData,
    required String rtid,
  }) {
    final stages = propsData['Stages'];
    if (stages is! List) return;
    for (final stage in stages) {
      if (stage is! Map) continue;
      final actions = stage['Actions'];
      if (actions is List) {
        actions.removeWhere((e) => e == rtid);
      }
      if (stage['RetreatAction'] == rtid) {
        stage.remove('RetreatAction');
      }
    }
  }

  static Map<String, dynamic> cloneMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(_deepClone(source) as Map);
  }

  static dynamic _deepClone(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), _deepClone(e.value)),
        ),
      );
    }
    if (value is List) {
      return value.map(_deepClone).toList();
    }
    return value;
  }
}
