import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';

class GridItemDiscovery {
  static Set<String> discoverGridItems(PvzLevelFile levelFile) {
    final items = <String>{};

    void scan(dynamic d) {
      if (d is Map) {
        final t =
            d['TypeName'] ??
            d['GridItemType'] ??
            d['GridItemTypeName'] ??
            d['ItemType'];
        if (t is String && t.isNotEmpty) {
          final clean = _cleanId(t);
          final displayTypeName = GridItemRepository.displayTypeNameForLevel(
            clean,
            levelFile,
          );
          if (clean != 'flowerpot' && displayTypeName != null) {
            items.add(displayTypeName);
          }
        }
        for (final v in d.values) {
          scan(v);
        }
      } else if (d is List) {
        for (final e in d) {
          scan(e);
        }
      }
    }

    final gridModules = {
      'InitialGridItemProperties',
      'SpawnGravestonesWaveActionProps',
    };

    for (final obj in levelFile.objects) {
      if (gridModules.contains(obj.objClass)) {
        scan(obj.objData);
      }
      if (obj.objClass == 'SpawnRocketLandingWaveActionProps' &&
          obj.objData is Map) {
        final rocketPool = (obj.objData as Map)['RocketPool'];
        if (rocketPool is List) {
          for (final entry in rocketPool.whereType<Map>()) {
            final type = entry['Type'];
            if (type is! String || type.isEmpty) continue;
            final clean = _cleanId(type);
            final displayTypeName = GridItemRepository.displayTypeNameForLevel(
              clean,
              levelFile,
            );
            if (displayTypeName != null) {
              items.add(displayTypeName);
            }
          }
        }
      }
    }

    final smokeData = readSmokePollutionData(levelFile);
    if (smokeData != null &&
        smokeData.smokeManholeList.isNotEmpty &&
        smokeData.gridItem.isNotEmpty) {
      items.add(_cleanId(smokeData.gridItem));
    }

    final pipeData = readManholePipelineData(levelFile);
    if (pipeData != null && pipeData.pipelineList.isNotEmpty) {
      items
        ..add('steam_down')
        ..add('steam_up');
    }

    final armrackData = readArmrackModuleData(levelFile);
    if (armrackData != null) {
      for (final override in armrackData.overrides) {
        for (final item in override.itemList) {
          if (item.type.isNotEmpty) items.add(_cleanId(item.type));
        }
      }
    }

    final lunarMineData = readLunarMineVeinModuleData(levelFile);
    if (lunarMineData != null && lunarMineData.placements.isNotEmpty) {
      items.add('lunar_mine_vein');
    }

    final radiationMeteorData = readRadiationMeteorModuleData(levelFile);
    if (radiationMeteorData != null &&
        radiationMeteorData.spawnSchedule.isNotEmpty) {
      items.add('radiation_meteor_ore');
    }

    final gulliverData = readGulliverTunnelData(levelFile);
    if (gulliverData != null && gulliverData.tunnelPlacements.isNotEmpty) {
      items.add('gulliver_tunnel');
    }

    final moldLayout = readMoldColonyLayoutData(levelFile);
    if (moldLayout != null &&
        moldLayout.values.any((row) => row.any((value) => value != 0))) {
      items.add('fake_mold');
    }

    final ptData = readPowerTileModuleData(levelFile);
    if (ptData != null) {
      for (final tile in ptData.linkedTiles) {
        items.add('tool_powertile_${tile.group}');
      }
    }

    final energyData = readEnergyGridModuleData(levelFile);
    if (energyData != null) {
      for (final over in energyData.overrides) {
        if (over.itemList.isNotEmpty) {
          items.add('energyGrid');
          break;
        }
      }
    }

    final renaiData = readRenaiModuleData(levelFile);
    if (renaiData != null) {
      for (final s in renaiData.statueInfos) {
        if (s.typeName.isNotEmpty) items.add(_cleanId(s.typeName));
      }
      for (final s in renaiData.statueNightInfos) {
        if (s.typeName.isNotEmpty) items.add(_cleanId(s.typeName));
      }
    }

    final potObj = findModuleObject(levelFile, 'ZombiePotionModuleProperties');
    if (potObj != null && potObj.objData is Map) {
      final potData = ZombiePotionModulePropertiesData.fromJson(
        Map<String, dynamic>.from(potObj.objData as Map),
      );
      for (final type in potData.potionTypes) {
        if (type.isNotEmpty) items.add(_cleanId(type));
      }
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass.contains('Dino')) {
        scan(obj.objData);
      }
      if (obj.objClass == 'ZombiePotionActionProps') {
        scan(obj.objData);
      }
      if (obj.objClass == 'ZombieAtlantisShellActionProps') {
        items.add('atlantis_shell');
      }
      if (obj.objClass == 'PumpkinHouseActionProps') {
        items.add('pumpkin_house');
      }
    }

    return items;
  }

  static String _cleanId(String id) {
    if (id.contains('(') && id.contains('@')) {
      return LevelParser.extractAlias(id);
    }
    return id;
  }
}
