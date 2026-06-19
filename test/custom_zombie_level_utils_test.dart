import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/custom_zombie_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';

void main() {
  group('CustomZombieLevelUtils orphan checks', () {
    test('is prompt eligible when exactly one zombie uses the custom RTID', () {
      final levelFile = PvzLevelFile(
        objects: [
          _customZombieType('custom_basic_1'),
          PvzObject(
            aliases: ['SpawnOne'],
            objClass: 'SpawnZombiesJitteredWaveActionProps',
            objData: {
              'Zombies': [
                {'Type': 'RTID(custom_basic_1@CurrentLevel)'},
              ],
            },
          ),
        ],
      );

      expect(
        CustomZombieLevelUtils.countZombieUses(levelFile, 'custom_basic_1'),
        1,
      );
      expect(
        CustomZombieLevelUtils.willBeOrphanAfterRemove(
          levelFile,
          'custom_basic_1',
        ),
        true,
      );
    });

    test('is not prompt eligible while multiple zombies use the custom RTID', () {
      final levelFile = PvzLevelFile(
        objects: [
          _customZombieType('custom_basic_1'),
          PvzObject(
            aliases: ['SpawnTwo'],
            objClass: 'SpawnZombiesJitteredWaveActionProps',
            objData: {
              'Zombies': [
                {'Type': 'RTID(custom_basic_1@CurrentLevel)'},
                {'Type': 'RTID(custom_basic_1@CurrentLevel)'},
              ],
            },
          ),
        ],
      );

      expect(
        CustomZombieLevelUtils.countZombieUses(levelFile, 'custom_basic_1'),
        2,
      );
      expect(
        CustomZombieLevelUtils.willBeOrphanAfterRemove(
          levelFile,
          'custom_basic_1',
        ),
        false,
      );
    });

    test('counts legacy zombie TypeName aliases as zombie uses', () {
      final levelFile = PvzLevelFile(
        objects: [
          _customZombieType('custom_basic_1'),
          PvzObject(
            aliases: ['BarrelWave'],
            objClass: 'BarrelWaveActionProps',
            objData: {
              'Barrels': [
                {
                  'Params': {
                    'Zombies': [
                      {'TypeName': 'custom_basic_1'},
                    ],
                  },
                },
              ],
            },
          ),
        ],
      );

      expect(
        CustomZombieLevelUtils.countZombieUses(levelFile, 'custom_basic_1'),
        1,
      );
    });
  });
}

PvzObject _customZombieType(String alias) {
  return PvzObject(
    aliases: [alias],
    objClass: 'ZombieType',
    objData: {
      'TypeName': 'basic',
      'Properties': 'RTID(${alias}_props@CurrentLevel)',
    },
  );
}
