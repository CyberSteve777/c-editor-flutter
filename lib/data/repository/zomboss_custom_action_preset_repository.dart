import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/rtid_parser.dart';

abstract final class ZombossCustomActionPresetRepository {
  static const String _resourcePath =
      'assets/resources/ZombossMechCustomActionPresets.json';
  static const String currentLevelSource = 'CurrentLevel';

  static final List<ZombossCustomActionPreset> _presets = [];
  static final Expando<_PresetMarker> _runtimeMarkers = Expando<_PresetMarker>(
    'zombossPresetOrigin',
  );
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await loadJsonString(_resourcePath);
      final raw = json.decode(jsonString);
      if (raw is! List<dynamic>) {
        throw FormatException('Expected array in $_resourcePath');
      }
      _presets
        ..clear()
        ..addAll(
          raw.map(
            (entry) => ZombossCustomActionPreset.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          ),
        )
        ..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading zomboss custom action presets: $e');
    }
  }

  static void resetForTest() {
    _presets.clear();
    _isLoaded = false;
  }

  static List<ZombossCustomActionPreset> get presets =>
      List.unmodifiable(_presets);

  static List<ZombossCustomActionPreset> presetsForMech(String mechType) {
    return _presets
        .where((preset) => preset.applicableMechs.contains(mechType))
        .toList(growable: false);
  }

  static ZombossCustomActionPreset? presetById(String id) {
    return _presets.firstWhereOrNull((preset) => preset.id == id);
  }

  static ZombossCustomActionPreset? presetForObject(PvzObject object) {
    final runtimePreset = presetById(_runtimeMarkers[object]?.presetId ?? '');
    if (runtimePreset != null) return runtimePreset;
    final alias = object.aliases?.firstOrNull;
    if (alias == null) return null;
    return _presets.firstWhereOrNull(
      (preset) =>
          object.objClass == preset.objclass &&
          _matchesSuggestedAlias(alias, preset.sourceAlias),
    );
  }

  static ZombossCustomActionPreset? presetForRtid(
    PvzLevelFile levelFile,
    String rtid,
  ) {
    final object = _findObjectByRtid(levelFile, rtid);
    if (object == null) return null;
    return presetForObject(object);
  }

  static ZombossCustomActionOrigin originForObject(PvzObject object) {
    final runtime = _runtimeMarkers[object];
    if (runtime != null) return runtime.origin;
    final preset = presetForObject(object);
    if (preset == null) return ZombossCustomActionOrigin.userCreated;
    return _matchesPresetMainData(object, preset)
        ? ZombossCustomActionOrigin.presetTemplate
        : ZombossCustomActionOrigin.presetDerived;
  }

  static void markUserCreated(PvzObject object) {
    _runtimeMarkers[object] = const _PresetMarker(
      '',
      ZombossCustomActionOrigin.userCreated,
    );
  }

  static ZombossCustomActionOrigin originForRtid(
    PvzLevelFile levelFile,
    String rtid,
  ) {
    final object = _findObjectByRtid(levelFile, rtid);
    if (object == null) return ZombossCustomActionOrigin.userCreated;
    final runtime = _runtimeMarkers[object];
    if (runtime != null) return runtime.origin;
    final preset = presetForObject(object);
    if (preset == null) return ZombossCustomActionOrigin.userCreated;
    return _matchesPresetData(levelFile, object, preset)
        ? ZombossCustomActionOrigin.presetTemplate
        : ZombossCustomActionOrigin.presetDerived;
  }

  static bool isMetadataAlias(String alias) {
    return PvzObject.isEditorMetadataAlias(alias);
  }

  static List<String> aliasesWithPrimaryAlias(
    String primaryAlias,
    Iterable<String>? existingAliases,
  ) {
    return [primaryAlias];
  }

  static List<ZombossMechObjclassGroup> actionGroupsForMech(String mechType) {
    final byObjclass = <String, List<ZombossCustomActionPreset>>{};
    for (final preset in presetsForMech(mechType)) {
      byObjclass.putIfAbsent(preset.objclass, () => []).add(preset);
    }
    return [
      for (final entry in byObjclass.entries)
        ZombossMechObjclassGroup(
          objclass: entry.key,
          tag: 'spawn',
          fields: entry.value.first.fields,
          implementations: {
            for (final preset in entry.value)
              preset.sourceAlias: _cloneMap(preset.objdata),
          },
        ),
    ];
  }

  static ZombossMechObjclassGroup? groupForObjclass(
    String mechType,
    String objclass,
  ) {
    return actionGroupsForMech(
      mechType,
    ).firstWhereOrNull((group) => group.objclass == objclass);
  }

  static ZombossPresetActionCreation instantiatePreset(
    PvzLevelFile levelFile,
    ZombossCustomActionPreset preset,
  ) {
    final dependencyAliases = <String, String>{};
    final createdAliases = <String>[];
    final createdObjects = <PvzObject>[];
    for (final dependency in preset.dependencies) {
      final alias = _uniqueAlias(levelFile, dependency.alias);
      createdAliases.add(alias);
      dependencyAliases[dependency.id] = alias;
      final object = PvzObject(
        aliases: [alias],
        objClass: dependency.objclass,
        objData: _cloneMap(dependency.objdata),
      );
      levelFile.objects.add(object);
      createdObjects.add(object);
    }

    final data = _cloneMap(preset.objdata);
    for (final entry in preset.dependencyRtidFields.entries) {
      final dependencyAlias = dependencyAliases[entry.value];
      if (dependencyAlias == null) continue;
      data[entry.key] = RtidParser.build(dependencyAlias, currentLevelSource);
    }

    final alias = _uniqueAlias(levelFile, preset.sourceAlias);
    createdAliases.add(alias);
    final object = PvzObject(
      aliases: [alias],
      objClass: preset.objclass,
      objData: data,
    );
    _runtimeMarkers[object] = _PresetMarker(
      preset.id,
      ZombossCustomActionOrigin.presetTemplate,
    );
    levelFile.objects.add(object);
    createdObjects.add(object);

    return ZombossPresetActionCreation(
      rtid: RtidParser.build(alias, currentLevelSource),
      createdAliases: createdAliases,
      createdObjects: createdObjects,
    );
  }

  static ZombossPresetActionCreation? deriveFromPresetInstance(
    PvzLevelFile levelFile,
    String rtid,
  ) {
    final object = _findObjectByRtid(levelFile, rtid);
    if (object == null) return null;
    if (originForRtid(levelFile, rtid) !=
        ZombossCustomActionOrigin.presetTemplate) {
      return null;
    }
    final preset = presetForObject(object);
    if (preset == null) return null;

    final data = _cloneMap(_mapData(object.objData));
    final createdAliases = <String>[];
    final createdObjects = <PvzObject>[];
    for (final entry in preset.dependencyRtidFields.entries) {
      final dependency = preset.dependencies.firstWhereOrNull(
        (item) => item.id == entry.value,
      );
      if (dependency == null) continue;

      final oldRtid = data[entry.key]?.toString() ?? '';
      final oldDependency = _findObjectByRtid(levelFile, oldRtid);
      final alias = _uniqueAlias(
        levelFile,
        dependency.alias.isNotEmpty ? dependency.alias : entry.value,
      );
      createdAliases.add(alias);
      final dependencyObject = PvzObject(
        aliases: [alias],
        objClass: oldDependency?.objClass ?? dependency.objclass,
        objData: _normalizedDependencyDataForPreset(
          preset,
          oldDependency == null
              ? dependency.objdata
              : _mapData(oldDependency.objData),
        ),
      );
      levelFile.objects.add(dependencyObject);
      createdObjects.add(dependencyObject);
      data[entry.key] = RtidParser.build(alias, currentLevelSource);
    }

    final alias = _uniqueAlias(levelFile, preset.sourceAlias);
    createdAliases.add(alias);
    final derivedObject = PvzObject(
      aliases: [alias],
      objClass: object.objClass,
      objData: data,
    );
    _runtimeMarkers[derivedObject] = _PresetMarker(
      preset.id,
      ZombossCustomActionOrigin.presetDerived,
    );
    levelFile.objects.add(derivedObject);
    createdObjects.add(derivedObject);

    return ZombossPresetActionCreation(
      rtid: RtidParser.build(alias, currentLevelSource),
      createdAliases: createdAliases,
      createdObjects: createdObjects,
    );
  }

  static void removeCreatedObjects(
    PvzLevelFile levelFile,
    ZombossPresetActionCreation creation,
  ) {
    final created = creation.createdObjects.toSet();
    if (created.isNotEmpty) {
      levelFile.objects.removeWhere(created.contains);
      return;
    }
    removeObjectsByAliases(levelFile, creation.createdAliases);
  }

  static void removeObjectsByAliases(
    PvzLevelFile levelFile,
    Iterable<String> aliases,
  ) {
    final aliasSet = aliases.toSet();
    levelFile.objects.removeWhere(
      (object) => object.aliases?.any(aliasSet.contains) == true,
    );
  }

  static void deleteActionObjectAndUnusedPresetDependencies(
    PvzLevelFile levelFile,
    String rtid,
  ) {
    final object = _findObjectByRtid(levelFile, rtid);
    if (object == null) return;
    final preset = presetForObject(object);
    final dependencies =
        <({String rtid, ZombossCustomActionPresetDependency spec})>[];
    if (preset != null) {
      for (final entry in preset.dependencyRtidFields.entries) {
        final dependencyRtid = _mapData(object.objData)[entry.key]?.toString();
        final spec = preset.dependencies.firstWhereOrNull(
          (dependency) => dependency.id == entry.value,
        );
        if (dependencyRtid != null &&
            dependencyRtid.isNotEmpty &&
            spec != null) {
          dependencies.add((rtid: dependencyRtid, spec: spec));
        }
      }
    }

    final info = RtidParser.parse(rtid);
    if (info == null) return;
    levelFile.objects.removeWhere(
      (candidate) => candidate.aliases?.contains(info.alias) == true,
    );

    for (final entry in dependencies) {
      if (_countRtidReferences(levelFile, entry.rtid) > 0) continue;
      final dependency = _findObjectByRtid(levelFile, entry.rtid);
      if (dependency == null || dependency.objClass != entry.spec.objclass) {
        continue;
      }
      final depInfo = RtidParser.parse(entry.rtid);
      if (depInfo == null) continue;
      if (!_matchesSuggestedAlias(depInfo.alias, entry.spec.alias)) continue;
      levelFile.objects.removeWhere(
        (candidate) => candidate.aliases?.contains(depInfo.alias) == true,
      );
    }
  }

  static String presetDisplayNameWithAlias(
    ZombossCustomActionPreset preset,
    String localizedName,
  ) {
    return '$localizedName (${preset.sourceAlias})';
  }

  static ZombossCustomActionPresetDependency? dependencySpecForField(
    PvzObject action,
    String fieldName,
  ) {
    final preset = presetForObject(action);
    if (preset == null) return null;
    final dependencyId = preset.dependencyRtidFields[fieldName];
    if (dependencyId == null) return null;
    return preset.dependencies.firstWhereOrNull(
      (dependency) => dependency.id == dependencyId,
    );
  }

  static PvzObject? dependencyObjectForField(
    PvzLevelFile levelFile,
    PvzObject action,
    String fieldName,
  ) {
    final rtid = _mapData(action.objData)[fieldName]?.toString() ?? '';
    return _findObjectByRtid(levelFile, rtid);
  }

  static bool isValidDependencyObject(
    PvzObject? object,
    ZombossCustomActionPresetDependency spec,
  ) {
    if (object == null || object.objClass != spec.objclass) return false;
    final data = object.objData;
    if (data is! Map) return false;
    if (spec.objclass != 'ZombieDropProps') return true;
    final hordes = data['ZombieHordes'];
    final collectables = data['Collectables'];
    if (hordes is! List || collectables is! List) return false;
    if (collectables.any((item) => item is! String)) return false;
    for (final horde in hordes) {
      if (horde is! Map) return false;
      final type = horde['Type'];
      if (type is! String || type.isEmpty) return false;
    }
    return true;
  }

  static ({PvzObject object, String rtid}) createDependencyForField({
    required PvzLevelFile levelFile,
    required ZombossCustomActionPresetDependency spec,
  }) {
    final alias = _uniqueAlias(levelFile, spec.alias);
    final object = PvzObject(
      aliases: [alias],
      objClass: spec.objclass,
      objData: _cloneMap(spec.objdata),
    );
    levelFile.objects.add(object);
    return (object: object, rtid: RtidParser.build(alias, currentLevelSource));
  }

  static Map<String, dynamic> cloneDependencyData(Map<String, dynamic> data) =>
      _cloneMap(data);

  static PvzObject? _findObjectByRtid(PvzLevelFile levelFile, String rtid) {
    final info = RtidParser.parse(rtid);
    if (info == null || info.source != currentLevelSource) return null;
    return levelFile.objects.firstWhereOrNull(
      (object) => object.aliases?.contains(info.alias) == true,
    );
  }

  static String _uniqueAlias(PvzLevelFile levelFile, String baseAlias) {
    if (!_containsAlias(levelFile, baseAlias)) return baseAlias;
    var i = 2;
    while (_containsAlias(levelFile, '${baseAlias}_$i')) {
      i++;
    }
    return '${baseAlias}_$i';
  }

  static bool _containsAlias(PvzLevelFile levelFile, String alias) {
    return levelFile.objects.any(
      (object) => object.aliases?.contains(alias) == true,
    );
  }

  static bool _matchesSuggestedAlias(String alias, String sourceAlias) {
    if (alias == sourceAlias) return true;
    if (!alias.startsWith('${sourceAlias}_')) return false;
    final suffix = alias.substring(sourceAlias.length + 1);
    final number = int.tryParse(suffix);
    return number != null && number >= 2;
  }

  static bool _matchesPresetData(
    PvzLevelFile levelFile,
    PvzObject object,
    ZombossCustomActionPreset preset,
  ) {
    if (!_matchesPresetMainData(object, preset)) return false;
    for (final entry in preset.dependencyRtidFields.entries) {
      final dependencySpec = preset.dependencies.firstWhereOrNull(
        (dependency) => dependency.id == entry.value,
      );
      if (dependencySpec == null) return false;
      final dependencyRtid = _mapData(object.objData)[entry.key]?.toString();
      final dependency = dependencyRtid == null
          ? null
          : _findObjectByRtid(levelFile, dependencyRtid);
      if (dependency == null ||
          dependency.objClass != dependencySpec.objclass) {
        return false;
      }
      if (!const DeepCollectionEquality().equals(
        _normalizedDependencyDataForPreset(
          preset,
          _mapData(dependency.objData),
        ),
        dependencySpec.objdata,
      )) {
        return false;
      }
    }
    return true;
  }

  static bool _matchesPresetMainData(
    PvzObject object,
    ZombossCustomActionPreset preset,
  ) {
    if (object.objClass != preset.objclass) return false;
    final actual = _cloneMap(_mapData(object.objData));
    final expected = _cloneMap(preset.objdata);
    for (final field in preset.dependencyRtidFields.keys) {
      final actualRtid = RtidParser.parse(actual[field]?.toString() ?? '');
      if (actualRtid?.source != currentLevelSource) return false;
      actual[field] = expected[field];
    }
    return const DeepCollectionEquality().equals(actual, expected);
  }

  static Map<String, dynamic> _mapData(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static Map<String, dynamic> _cloneMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(_deepClone(source) as Map);
  }

  static Map<String, dynamic> _normalizedDependencyDataForPreset(
    ZombossCustomActionPreset preset,
    Map<String, dynamic> source,
  ) {
    final data = _cloneMap(source);
    if (preset.id == 'sport_tank_spawn') {
      final collectables = data['Collectables'];
      if (collectables is List &&
          collectables.length == 1 &&
          collectables.single == 'spacetime_plantfood') {
        data['Collectables'] = <String>['plantfood'];
      }
    }
    return data;
  }

  static dynamic _deepClone(dynamic value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _deepClone(entry.value),
      };
    }
    if (value is List) {
      return [for (final item in value) _deepClone(item)];
    }
    return value;
  }

  static int _countRtidReferences(PvzLevelFile levelFile, String rtid) {
    var count = 0;
    for (final object in levelFile.objects) {
      count += _countRtidInValue(object.objData, rtid);
    }
    return count;
  }

  static int _countRtidInValue(dynamic value, String rtid) {
    if (value == rtid) return 1;
    if (value is List) {
      return value.fold<int>(
        0,
        (sum, item) => sum + _countRtidInValue(item, rtid),
      );
    }
    if (value is Map) {
      return value.values.fold<int>(
        0,
        (sum, item) => sum + _countRtidInValue(item, rtid),
      );
    }
    return 0;
  }
}

class _PresetMarker {
  const _PresetMarker(this.presetId, this.origin);

  final String presetId;
  final ZombossCustomActionOrigin origin;
}
