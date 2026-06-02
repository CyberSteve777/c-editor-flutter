import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:z_editor/data/asset_loader.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models/PvzObject.dart';
import 'package:z_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:z_editor/data/pvz_models/LocationData.dart';

/// Dropdown value for the custom (memo) zombossmech variation in the battle tab.
const kZombossMechCustomVariationValue = '__z_editor_custom__';

class ZombossMechInfo {
  const ZombossMechInfo({
    required this.id,
    required this.icon,
    required this.defaultPhaseCount,
    required this.variations,
    required this.editableInstance,
    required this.editableInstancePropsName,
  });

  final String id;
  final String icon;
  final int defaultPhaseCount;
  final List<String> variations;
  final String editableInstance;
  final String editableInstancePropsName;

  bool get hasCustomInstance =>
      editableInstance.isNotEmpty &&
      editableInstance != 'none' &&
      editableInstancePropsName.isNotEmpty;
}

class ZombossMechRepository {
  static const String _resourcePath = 'assets/resources/ZombossMechs.json';
  static final List<ZombossMechInfo> allZombossMechs = [];
  static final Map<String, ZombossMechCatalogEntry> _catalogById = {};
  static bool _isLoaded = false;
  static String? loadError;

  /// Clears cached data (tests only).
  @visibleForTesting
  static void resetForTest() {
    _isLoaded = false;
    loadError = null;
    allZombossMechs.clear();
    _catalogById.clear();
  }

  static Future<void> init() async {
    if (_isLoaded) return;
    await _load();
  }

  /// Ensures data is loaded; safe to call from tabs after app start.
  static Future<void> ensureLoaded() async {
    if (_isLoaded && allZombossMechs.isNotEmpty) return;
    await _load();
  }

  static Future<void> _load() async {
    try {
      final jsonString = await loadJsonString(_resourcePath);
      final decoded = json.decode(jsonString);
      if (decoded is! List<dynamic>) {
        throw FormatException(
          'Expected a JSON array in $_resourcePath, got ${decoded.runtimeType}',
        );
      }
      allZombossMechs.clear();
      _catalogById.clear();
      for (final raw in decoded) {
        final item = Map<String, dynamic>.from(raw as Map);
        final variations = item['variations'];
        if (variations is! List || variations.isEmpty) {
          throw FormatException(
            'ZombossMech group ${item['id']} has no variations',
          );
        }
        final entry = ZombossMechCatalogEntry.fromJson(item);
        _catalogById[entry.id] = entry;
        allZombossMechs.add(
          ZombossMechInfo(
            id: entry.id,
            icon: entry.icon,
            defaultPhaseCount: entry.defaultPhaseCount,
            variations: entry.variations,
            editableInstance: entry.editableInstance,
            editableInstancePropsName: entry.editableInstancePropsName,
          ),
        );
      }
      loadError = null;
      _isLoaded = true;
      debugPrint('Loaded ${allZombossMechs.length} ZombossMech groups');
    } catch (e, st) {
      loadError = e.toString();
      _isLoaded = false;
      allZombossMechs.clear();
      _catalogById.clear();
      debugPrint('Error loading zomboss mechs: $e\n$st');
    }
  }

  static ZombossMechCatalogEntry? getCatalog(String baseId) => _catalogById[baseId];

  static ZombossMechInfo? getBase(String baseId) {
    return allZombossMechs.where((e) => e.id == baseId).firstOrNull;
  }

  static ZombossMechInfo? findBaseForVariation(String variation) {
    return allZombossMechs
        .where((b) => b.variations.contains(variation))
        .firstOrNull;
  }

  static ZombossMechCatalogEntry? findCatalogForVariation(String variation) {
    final base = findBaseForVariation(variation);
    if (base == null) return null;
    return getCatalog(base.id);
  }

  /// Whether [mechType] is an Ice Age zomboss mech variation (incl. `zombossmech_modern_iceage`).
  static bool isIceAgeMechVariation(String? mechType) {
    if (mechType == null || mechType.isEmpty) return false;
    if (mechType.startsWith('zombossmech_iceage')) return true;
    return findBaseForVariation(mechType)?.id == 'ZombieZombossMech_IceAge';
  }

  static String resolveBaseId(String? preferredBaseId, String variation) {
    if (preferredBaseId != null) {
      final base = getBase(preferredBaseId);
      if (base != null && base.variations.contains(variation)) {
        return preferredBaseId;
      }
    }
    return findBaseForVariation(variation)?.id ??
        allZombossMechs.firstOrNull?.id ??
        '';
  }

  static bool isCustomVariation(String? mechType, ZombossMechCatalogEntry? catalog) {
    if (catalog == null || !catalog.hasCustomInstance) return false;
    return mechType == catalog.editableInstance;
  }

  /// Ensures a level-local property object exists for the custom (memo) mech.
  static PvzObject ensureCustomPropertiesInLevel({
    required ZombossMechCatalogEntry catalog,
    required PvzLevelFile levelFile,
  }) {
    final alias = catalog.editableInstancePropsName;
    final existing = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      return existing;
    }
    final obj = PvzObject(
      aliases: [alias],
      objClass: catalog.propsObjclass,
      objData: catalog.templatePropsData(),
    );
    levelFile.objects.add(obj);
    return obj;
  }

  static PvzObject? findCustomPropertiesInLevel({
    required ZombossMechCatalogEntry catalog,
    required PvzLevelFile levelFile,
  }) {
    final alias = catalog.editableInstancePropsName;
    return levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
  }

  /// Spawn grid position for [variation], or `null` when the mech omits spawn data.
  static LocationData? spawnPositionForVariation(String variation) {
    const noSpawnPos = {
      'zombossmech_pvz1_robot_hard',
      'zombossmech_pvz1_robot_normal',
      'zombossmech_pvz1_robot_1',
      'zombossmech_pvz1_robot_2',
      'zombossmech_pvz1_robot_3',
      'zombossmech_pvz1_robot_4',
      'zombossmech_pvz1_robot_5',
      'zombossmech_pvz1_robot_6',
      'zombossmech_pvz1_robot_7',
      'zombossmech_pvz1_robot_8',
      'zombossmech_pvz1_robot_9',
    };
    const specificSpawnPos = {
      'zombossmech_iceage',
      'zombossmech_eighties',
      'zombossmech_renai',
      'zombossmech_modern_iceage',
      'zombossmech_modern_eighties',
      'zombossmech_iceage_vacation',
      'zombossmech_eighties_vacation',
      'zombossmech_iceage_12th',
      'zombossmech_eighties_12th',
      'zombossmech_renai_12th',
    };

    if (noSpawnPos.contains(variation)) {
      return LocationData(x: 0, y: 0);
    }
    if (specificSpawnPos.contains(variation)) {
      return LocationData(x: 6, y: 4);
    }
    return LocationData(x: 6, y: 3);
  }

  static bool omitsSpawnPosition(String variation) {
    const noSpawnPos = {
      'zombossmech_pvz1_robot_hard',
      'zombossmech_pvz1_robot_normal',
      'zombossmech_pvz1_robot_1',
      'zombossmech_pvz1_robot_2',
      'zombossmech_pvz1_robot_3',
      'zombossmech_pvz1_robot_4',
      'zombossmech_pvz1_robot_5',
      'zombossmech_pvz1_robot_6',
      'zombossmech_pvz1_robot_7',
      'zombossmech_pvz1_robot_8',
      'zombossmech_pvz1_robot_9',
    };
    return noSpawnPos.contains(variation);
  }
}
