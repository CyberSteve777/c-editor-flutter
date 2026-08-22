import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';

class ZombieDiscovery {
  static const skyCityImp = 'skycity_ggtimp';

  static const bronzeGargMap = {
    'kongfu_strong_bronze': 'kongfu_strong_bronze',
    'kongfu_magic_bronze': 'kongfu_magic_bronze',
    'kongfu_agile_bronze': 'kongfu_agile_bronze',
  };

  static const renaissanceStatueMap = {
    'renai_statue_zombie1': 'renai_worker',
    'renai_statue_zombie1_half': 'renai_worker',
    'renai_statue_zombie_armor1': 'renai_armor1',
    'renai_statue_zombie_armor1_half': 'renai_armor1',
    'renai_statue_zombie_armor2': 'renai_armor2',
    'renai_statue_zombie_armor2_half': 'renai_armor2',
    'renai_statue_zombie_perfumer': 'renai_perfumer',
    'renai_statue_zombie_perfumer_half': 'renai_perfumer',
    'renai_zomboss_statue_zombie1_half': 'renai_worker',
  };

  static const ignoredIds = {
    'sandstorm',
    'snowstorm',
    'barrelmoster',
    'barrelempty',
    'barrelpowder',
    'schoolbus_normal',
    'schoolbus_special',
    'krill',
    'hermitcrab',
    'inkfish',
    'jellyfish',
    'pufferfish',
    'starfish',
    'swordfish',
    'cthulhusmalljelly',
    'smalljellyfish',
  };

  static Set<String> discoverZombies(
    PvzLevelFile levelFile,
    ParsedLevelData parsed,
  ) {
    final zombies = <String>{};

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'InitialZombieProperties') {
        final data = obj.objData;
        if (data is Map) {
          final list = data['InitialZombiePlacements'] ?? data['Zombies'];
          if (list is List) {
            for (final e in list) {
              if (e is Map) {
                final type = e['TypeName'] ?? e['ZombieType'];
                if (type is String) _addZombie(type, zombies);
              }
            }
          }
        }
      }
    }

    final wm = parsed.waveManager;
    if (wm is WaveManagerData) {
      for (final wave in wm.waves) {
        for (final rtid in wave) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = parsed.objectMap[alias];
          if (obj != null) {
            _extractFromWaveAction(obj, zombies);
          }
        }
      }
    }

    final wg = parsed.waveGenerator;
    if (wg != null) {
      for (final wave in wg.waves) {
        for (final z in wave.zombies) {
          if (z.type.isNotEmpty) _addZombie(z.type, zombies);
        }
        for (final pool in wave.addToZombiePool) {
          if (pool.type.isNotEmpty) _addZombie(pool.type, zombies);
        }
      }
      for (final pool in wg.addToZombiePool) {
        if (pool.type.isNotEmpty) _addZombie(pool.type, zombies);
      }
    }

    final wmm = parsed.waveModule;
    if (wmm != null) {
      for (final group in wmm.dynamicZombies) {
        for (final zId in group.zombiePool) {
          if (zId.isNotEmpty) _addZombie(zId, zombies);
        }
      }
    }

    final bronzeData = readBronzeModuleData(levelFile);
    if (bronzeData != null) {
      for (final batch in bronzeData.data) {
        for (final item in batch.itemList) {
          final id = switch (item.kind) {
            BronzeStatueKind.strength => 'kongfu_strong_bronze',
            BronzeStatueKind.mage => 'kongfu_magic_bronze',
            BronzeStatueKind.agile => 'kongfu_agile_bronze',
          };
          final garg = bronzeGargMap[id];
          if (garg != null) _addZombie(garg, zombies);
        }
      }
    }

    final renaiData = readRenaiModuleData(levelFile);
    if (renaiData != null) {
      final allStatues = [
        ...renaiData.statueInfos,
        ...renaiData.statueNightInfos,
      ];
      for (final s in allStatues) {
        final z = renaissanceStatueMap[_cleanId(s.typeName)];
        if (z != null) _addZombie(z, zombies);
      }
    }

    if (levelHasModule(levelFile, 'DropShipProperties')) {
      _addZombie(skyCityImp, zombies);
    }

    if (levelHasModule(levelFile, 'GlacierModuleProperties')) {
      for (final obj in levelFile.objects) {
        if (obj.objClass == 'GlacierModuleProperties') {
          final data = obj.objData;
          if (data is Map) {
            final colData = data['ZombieSpawnData'];
            if (colData is List) {
              for (final col in colData) {
                if (col is List) {
                  for (final zEntry in col) {
                    if (zEntry is Map) {
                      final type = zEntry['TypeName'];
                      if (type is String) _addZombie(type, zombies);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'ZombieType') {
        final aliases = obj.aliases;
        if (aliases != null && aliases.isNotEmpty) {
          _addZombie(aliases.first, zombies);
        }
      }
    }

    return zombies;
  }

  static bool hasWaves(ParsedLevelData parsed) {
    final wm = parsed.waveManager;
    if (wm is WaveManagerData && wm.waves.isNotEmpty) {
      for (final wave in wm.waves) {
        if (wave.isNotEmpty) return true;
      }
    }

    final wg = parsed.waveGenerator;
    if (wg != null && wg.waves.isNotEmpty) {
      return true;
    }

    return false;
  }

  static Set<String> discoverEvents(ParsedLevelData parsed) {
    final events = <String>{};
    final wm = parsed.waveManager;
    if (wm is WaveManagerData) {
      for (final wave in wm.waves) {
        for (final rtid in wave) {
          final alias = LevelParser.extractAlias(rtid);
          final obj = parsed.objectMap[alias];
          if (obj != null) {
            events.add(obj.objClass);
          }
        }
      }
    }
    return events;
  }

  static void _extractFromWaveAction(PvzObject obj, Set<String> out) {
    const skippedClasses = {
      'SpawnGravestonesWaveActionProps',
      'ModifyConveyorWaveActionProps',
      'ZombiePotionActionProps',
      'PumpkinHouseActionProps',
      'ThunderWaveActionProps',
      'ZombieAtlantisShellActionProps',
      'SpawnRocketLandingWaveActionProps',
    };

    if (skippedClasses.contains(obj.objClass)) {
      return;
    }

    if (obj.objClass == 'RaidingPartyZombieSpawnerProps') {
      _addZombie('swashbuckler', out);
    }

    final data = obj.objData;
    if (data is! Map) return;

    _scanForZombies(data, out);
  }

  static void _scanForZombies(dynamic d, Set<String> out) {
    if (d is Map) {
      final t =
          d['TypeName'] ??
          d['ZombieType'] ??
          d['Type'] ??
          d['ZombieName'] ??
          d['ZombieTypeName'] ??
          d['SpiderZombieName'];
      if (t is String && t.isNotEmpty) {
        _addZombie(t, out);
      }
      for (final v in d.values) {
        _scanForZombies(v, out);
      }
    } else if (d is List) {
      for (final e in d) {
        _scanForZombies(e, out);
      }
    }
  }

  static void _addZombie(String id, Set<String> out) {
    final clean = _cleanId(id);
    if (!ignoredIds.contains(clean) && !GridItemRepository.isValid(clean)) {
      out.add(clean);
    }
  }

  static String _cleanId(String id) {
    if (id.contains('(') && id.contains('@')) {
      return LevelParser.extractAlias(id);
    }
    return id;
  }
}
