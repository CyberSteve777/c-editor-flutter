import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

class ZombossAutoModule {
  const ZombossAutoModule({
    required this.objclass,
    required this.alias,
    required this.source,
    this.objdata,
  });

  final String objclass;
  final String alias;
  final String source;
  final Map<String, dynamic>? objdata;

  factory ZombossAutoModule.fromJson(Map<String, dynamic> json) {
    return ZombossAutoModule(
      objclass: json['objclass'] as String,
      alias: json['alias'] as String,
      source: json['source'] as String,
      objdata: json['objdata'] is Map
          ? Map<String, dynamic>.from(json['objdata'] as Map)
          : null,
    );
  }

  String get rtid => RtidParser.build(alias, source);
}

class ZombossBattleInfo {
  const ZombossBattleInfo({
    required this.id,
    required this.icon,
    required this.variations,
    required this.resourceGroups,
    this.modules = const [],
  });

  final String id;
  final String icon;
  final List<String> variations;
  final List<String> resourceGroups;
  final List<ZombossAutoModule> modules;
}

class ZombossBattleRepository {
  static const String _resourcePath = 'assets/resources/Zombosses.json';
  static final List<ZombossBattleInfo> allZombosses = [];
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await loadJsonString(_resourcePath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      allZombosses
        ..clear()
        ..addAll(
          jsonList.map((raw) {
            final item = raw as Map<String, dynamic>;
            return ZombossBattleInfo(
              id: item['id'] as String,
              icon: item['icon'] as String,
              variations: (item['variations'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              resourceGroups: (item['resourceGroups'] as List<dynamic>)
                  .map((e) => e.toString())
                  .toList(),
              modules: (item['modules'] as List<dynamic>?)
                      ?.map(
                        (entry) => ZombossAutoModule.fromJson(
                          Map<String, dynamic>.from(entry as Map),
                        ),
                      )
                      .toList() ??
                  const [],
            );
          }),
        );
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading zomboss battle data: $e');
    }
  }

  static ZombossBattleInfo? getBase(String baseId) {
    return allZombosses.where((e) => e.id == baseId).firstOrNull;
  }

  static ZombossBattleInfo? findBaseForVariation(String variation) {
    return allZombosses
        .where((b) => b.variations.contains(variation))
        .firstOrNull;
  }

  static String resolveBaseId(String? preferredBaseId, String variation) {
    if (preferredBaseId != null) {
      final base = getBase(preferredBaseId);
      if (base != null && base.variations.contains(variation)) {
        return preferredBaseId;
      }
    }
    return findBaseForVariation(variation)?.id ??
        allZombosses.firstOrNull?.id ??
        '';
  }

  static void ensureAutoModules({
    required PvzLevelFile levelFile,
    required LevelDefinitionData levelDef,
    required String baseId,
  }) {
    final base = getBase(baseId);
    if (base == null || base.modules.isEmpty) {
      return;
    }
    for (final module in base.modules) {
      _addAutoModule(
        levelFile,
        levelDef,
        module,
        overwriteExistingObject: false,
      );
    }
    _persistLevelDefinition(levelFile, levelDef);
  }

  static void syncAutoModules({
    required PvzLevelFile levelFile,
    required LevelDefinitionData levelDef,
    required String? previousBaseId,
    required String newBaseId,
  }) {
    if (previousBaseId != null && previousBaseId != newBaseId) {
      final previous = getBase(previousBaseId);
      if (previous != null) {
        for (final module in previous.modules) {
          _removeAutoModule(levelFile, levelDef, module);
        }
      }
    }

    final next = getBase(newBaseId);
    if (next != null) {
      for (final module in next.modules) {
        _addAutoModule(levelFile, levelDef, module);
      }
    }

    _persistLevelDefinition(levelFile, levelDef);
  }

  static void _addAutoModule(
    PvzLevelFile levelFile,
    LevelDefinitionData levelDef,
    ZombossAutoModule module, {
    bool overwriteExistingObject = true,
  }) {
    final rtid = module.rtid;
    if (!levelDef.modules.contains(rtid)) {
      levelDef.modules.add(rtid);
    }

    if (module.source != 'CurrentLevel') {
      return;
    }

    final existing = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(module.alias) == true,
    );
    final objData = Map<String, dynamic>.from(module.objdata ?? {});
    if (existing == null) {
      levelFile.objects.add(
        PvzObject(
          aliases: [module.alias],
          objClass: module.objclass,
          objData: objData,
        ),
      );
    } else if (overwriteExistingObject) {
      existing.objData = objData;
    }
  }

  static void _removeAutoModule(
    PvzLevelFile levelFile,
    LevelDefinitionData levelDef,
    ZombossAutoModule module,
  ) {
    levelDef.modules.remove(module.rtid);
    if (module.source == 'CurrentLevel') {
      levelFile.objects.removeWhere(
        (o) => o.aliases?.contains(module.alias) == true,
      );
    }
  }

  static void _persistLevelDefinition(
    PvzLevelFile levelFile,
    LevelDefinitionData levelDef,
  ) {
    final levelDefObj = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelDefinition',
    );
    if (levelDefObj != null) {
      levelDefObj.objData = levelDef.toJson();
    }
  }
}
