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
  static const String _mainMarkerPrefix = '__c_editor_zomboss_action_preset__';
  static const String _dependencyMarkerPrefix =
      '__c_editor_zomboss_action_preset_dependency__';

  static final List<ZombossCustomActionPreset> _presets = [];
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
    final marker = _mainMarkerForObject(object);
    if (marker == null) return null;
    return presetById(marker.presetId);
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
    final marker = _mainMarkerForObject(object);
    if (marker == null) return ZombossCustomActionOrigin.userCreated;
    return marker.origin;
  }

  static ZombossCustomActionOrigin originForRtid(
    PvzLevelFile levelFile,
    String rtid,
  ) {
    final object = _findObjectByRtid(levelFile, rtid);
    if (object == null) return ZombossCustomActionOrigin.userCreated;
    return originForObject(object);
  }

  static bool isMetadataAlias(String alias) {
    return alias.startsWith(_mainMarkerPrefix) ||
        alias.startsWith(_dependencyMarkerPrefix);
  }

  static List<String> aliasesWithPrimaryAlias(
    String primaryAlias,
    Iterable<String>? existingAliases,
  ) {
    return [primaryAlias, ...?existingAliases?.where(isMetadataAlias)];
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
        aliases: [alias, _dependencyMarker(preset.id, dependency.id)],
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
      aliases: [
        alias,
        _mainMarker(preset.id, ZombossCustomActionOrigin.presetTemplate),
      ],
      objClass: preset.objclass,
      objData: data,
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
    final marker = _mainMarkerForObject(object);
    if (marker == null ||
        marker.origin != ZombossCustomActionOrigin.presetTemplate) {
      return null;
    }
    final preset = presetById(marker.presetId);
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
        aliases: [alias, _dependencyMarker(preset.id, dependency.id)],
        objClass: oldDependency?.objClass ?? dependency.objclass,
        objData: _cloneMap(
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
      aliases: [
        alias,
        _mainMarker(preset.id, ZombossCustomActionOrigin.presetDerived),
      ],
      objClass: object.objClass,
      objData: data,
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
    final dependencyRtids = preset == null
        ? const <String>[]
        : preset.dependencyRtidFields.keys
              .map((field) => _mapData(object.objData)[field]?.toString())
              .whereType<String>()
              .where((value) => value.isNotEmpty)
              .toList();

    final info = RtidParser.parse(rtid);
    if (info == null) return;
    levelFile.objects.removeWhere(
      (candidate) => candidate.aliases?.contains(info.alias) == true,
    );

    for (final dependencyRtid in dependencyRtids) {
      if (_countRtidReferences(levelFile, dependencyRtid) > 0) continue;
      final dependency = _findObjectByRtid(levelFile, dependencyRtid);
      if (dependency == null || !_hasDependencyMarker(dependency)) continue;
      final depInfo = RtidParser.parse(dependencyRtid);
      if (depInfo == null) continue;
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

  static String _mainMarker(String presetId, ZombossCustomActionOrigin origin) {
    return '$_mainMarkerPrefix${origin.name}__$presetId';
  }

  static String _dependencyMarker(String presetId, String dependencyId) {
    return '$_dependencyMarkerPrefix${presetId}__$dependencyId';
  }

  static _PresetMarker? _mainMarkerForObject(PvzObject object) {
    for (final alias in object.aliases ?? const <String>[]) {
      if (!alias.startsWith(_mainMarkerPrefix)) continue;
      final body = alias.substring(_mainMarkerPrefix.length);
      final separator = body.indexOf('__');
      if (separator <= 0) continue;
      final originName = body.substring(0, separator);
      final presetId = body.substring(separator + 2);
      final origin = ZombossCustomActionOrigin.values.firstWhereOrNull(
        (value) => value.name == originName,
      );
      if (origin == null || presetId.isEmpty) continue;
      return _PresetMarker(presetId, origin);
    }
    return null;
  }

  static bool _hasDependencyMarker(PvzObject object) {
    return object.aliases?.any(
          (alias) => alias.startsWith(_dependencyMarkerPrefix),
        ) ==
        true;
  }

  static Map<String, dynamic> _mapData(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  static Map<String, dynamic> _cloneMap(Map<String, dynamic> source) {
    return Map<String, dynamic>.from(_deepClone(source) as Map);
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
