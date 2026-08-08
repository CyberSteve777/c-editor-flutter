import 'package:collection/collection.dart';
import 'package:c_editor/data/level_rtid_utils.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

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

  /// Legacy helper; prefer [ZombossMechL10n.labelForStageRtid] when context is available.
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

  static Map<String, dynamic> dataFromCatalogAction(
    ZombossMechCatalogAction action,
  ) {
    if (action.defaultData.isNotEmpty) {
      return Map<String, dynamic>.from(_deepClone(action.defaultData) as Map);
    }
    return defaultsFromFields(action.fields);
  }

  /// Finds the catalog implementation a user-created action was based on.
  ///
  /// Custom actions intentionally carry no editor metadata in level JSON, so
  /// the nearest original implementation is recovered from its data. The
  /// custom alias is only used as a stable tie-breaker.
  static ZombossMechCatalogAction? inferBaseCatalogAction({
    required ZombossMechCatalogEntry catalog,
    required String customAlias,
    required String objclass,
    required Map<String, dynamic> data,
    bool retreatOnly = false,
  }) {
    final candidates = catalog.catalogActions.where((action) {
      if (action.objclass != objclass) return false;
      return retreatOnly ? action.tag == 'retreat' : action.tag != 'retreat';
    }).toList();
    if (candidates.isEmpty) return null;

    const equality = DeepCollectionEquality();
    for (final candidate in candidates) {
      if (equality.equals(candidate.defaultData, data)) return candidate;
    }

    ZombossMechCatalogAction? best;
    var bestScore = -0x7fffffff;
    for (final candidate in candidates) {
      var score = 0;
      for (final entry in candidate.defaultData.entries) {
        if (!data.containsKey(entry.key)) {
          score -= 1;
        } else if (equality.equals(data[entry.key], entry.value)) {
          score += 3;
        } else {
          score -= 1;
        }
      }
      if (customAlias == candidate.alias ||
          customAlias.startsWith('${candidate.alias}_') ||
          customAlias.startsWith('${candidate.alias}Custom')) {
        score += 1;
      }
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return best;
  }

  static Map<String, dynamic> defaultsFromFields(
    List<ZombossMechFieldSpec> fields,
  ) {
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

  static bool isZombieTypeListField(ZombossMechFieldSpec field) =>
      field.type == 'List<zombieType>';

  static bool isSingleZombieTypeField(ZombossMechFieldSpec field) {
    if (field.type == 'zombieType') return true;
    if (field.type != 'string') return false;
    const names = {
      'ZombieName',
      'ZombieType',
      'ZombieTypeName',
      'SpawnZombieName',
      'SpiderZombieName',
    };
    return names.contains(field.name);
  }

  static bool isZombieTypeField(ZombossMechFieldSpec field) =>
      isZombieTypeListField(field) || isSingleZombieTypeField(field);

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
      final group =
          catalog.actions
              .where((g) => g.objclass == obj.objClass)
              .firstOrNull ??
          ZombossCustomActionPresetRepository.groupForObjclass(
            catalog.editableInstance,
            obj.objClass,
          );
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
      data: dataFromCatalogAction(action),
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
      if (isZombieTypeListField(field)) {
        bindings.add(
          ZombossZombieListBinding(
            fieldName: field.name,
            isList: true,
            zombieIds: parseZombieTypeList(data[field.name]),
          ),
        );
      } else if (isSingleZombieTypeField(field)) {
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

  static bool usesSecondsUnit(ZombossMechFieldSpec field) {
    final name = field.name.toLowerCase();
    if (name.endsWith('times')) return false;
    return name.contains('time') ||
        name.contains('duration') ||
        name.contains('delay') ||
        name.contains('interval') ||
        name.contains('cooldown');
  }

  static bool usesDecimalInput(ZombossMechFieldSpec field) {
    if (field.type == 'float') return true;
    if (field.type != 'int') return false;
    if (usesSecondsUnit(field)) return true;
    return const {
      'EffectOffsetX',
      'EffectOffsetY',
      'SpawnGridZDelta',
    }.contains(field.name);
  }

  static String uniqueCustomAlias(
    PvzLevelFile levelFile,
    String baseAlias, {
    PvzObject? except,
  }) {
    if (!levelFile.objects.any(
      (o) => o != except && o.aliases?.contains(baseAlias) == true,
    )) {
      return baseAlias;
    }
    var i = 2;
    while (levelFile.objects.any(
      (o) => o != except && o.aliases?.contains('${baseAlias}_$i') == true,
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
    ZombossCustomActionPresetRepository.markUserCreated(obj);
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
    propsData['Stages'] = LevelRtidUtils.replaceInValue(
      propsData['Stages'],
      oldRtid,
      newRtid,
    );
  }

  static bool isAliasAvailable(
    PvzLevelFile levelFile,
    String alias, {
    PvzObject? except,
  }) {
    return !levelFile.objects.any(
      (o) => o != except && o.aliases?.contains(alias) == true,
    );
  }

  static void renameCustomActionInLevel({
    required PvzLevelFile levelFile,
    required String oldAlias,
    required String newAlias,
    PvzObject? obj,
  }) {
    if (oldAlias == newAlias) return;
    final oldRtid = RtidParser.build(oldAlias, customSource);
    final newRtid = RtidParser.build(newAlias, customSource);
    LevelRtidUtils.replaceReferences(levelFile, oldRtid, newRtid);
    if (obj != null) {
      obj.aliases = ZombossCustomActionPresetRepository.aliasesWithPrimaryAlias(
        newAlias,
        obj.aliases,
      );
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

  static int countReferences(PvzLevelFile levelFile, String rtid) {
    var count = 0;
    for (final obj in levelFile.objects) {
      count += _countRtidInValue(obj.objData, rtid);
    }
    return count;
  }

  static void deleteCustomActionObject(PvzLevelFile levelFile, String rtid) {
    final info = RtidParser.parse(rtid);
    if (info?.source != customSource) return;
    levelFile.objects.removeWhere(
      (o) => o.aliases?.contains(info!.alias) == true,
    );
  }

  static int _countRtidInValue(dynamic value, String rtid) {
    if (value == rtid) return 1;
    if (value is List) {
      var sum = 0;
      for (final item in value) {
        sum += _countRtidInValue(item, rtid);
      }
      return sum;
    }
    if (value is Map) {
      var sum = 0;
      for (final entry in value.entries) {
        sum += _countRtidInValue(entry.value, rtid);
      }
      return sum;
    }
    return 0;
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
