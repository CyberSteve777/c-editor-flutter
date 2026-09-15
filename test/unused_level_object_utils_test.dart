import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/unused_level_object_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
  });

  test('keeps custom Zomboss properties selected by ZombossMechType', () async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: {
            'Modules': ['RTID(ZombossBattle@CurrentLevel)'],
          },
        ),
        PvzObject(
          aliases: ['ZombossBattle'],
          objClass: 'ZombossMechBattleModuleProperties',
          objData: {'ZombossMechType': 'zombossmech_egypt_memo'},
        ),
        PvzObject(
          aliases: ['ZombieZombossMechEgyptMemo'],
          objClass: 'ZombieZombossMechEgyptProperties',
          objData: {
            'Stages': [
              {
                'Actions': ['RTID(CustomBossAction@CurrentLevel)'],
              },
            ],
          },
        ),
        PvzObject(
          aliases: ['CustomBossAction'],
          objClass: 'ZombossActionDefinition',
          objData: {'Weight': 10},
        ),
        PvzObject(
          aliases: ['UnusedObject'],
          objClass: 'UnusedProperties',
          objData: const <String, dynamic>{},
        ),
      ],
    );

    final unused = await UnusedLevelObjectUtils.findUnusedObjects(level);

    expect(unused.map((object) => object.aliases?.first), ['UnusedObject']);
  });

  test('keeps objects referenced by a bare CurrentLevel alias', () async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: const <String, dynamic>{},
        ),
        PvzObject(
          aliases: ['SpawnAction'],
          objClass: 'SpawnActionProps',
          objData: {'ZombieTypeName': 'CustomZombie'},
        ),
        PvzObject(
          aliases: ['CustomZombie'],
          objClass: 'ZombieType',
          objData: {
            'TypeName': 'basic',
            'Properties': 'RTID(CustomZombieProps@CurrentLevel)',
          },
        ),
        PvzObject(
          aliases: ['CustomZombieProps'],
          objClass: 'ZombiePropertySheet',
          objData: {'Hitpoints': 100},
        ),
      ],
    );

    final unused = await UnusedLevelObjectUtils.findUnusedObjects(level);

    expect(unused.map((object) => object.aliases?.first), ['SpawnAction']);
  });

  test('keeps a used memo portal and anonymous top-level objects', () async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: const <String, dynamic>{},
        ),
        PvzObject(
          aliases: ['PortalEvent'],
          objClass: 'SpawnModernPortalsWaveActionProps',
          objData: {'PortalType': 'memo'},
        ),
        PvzObject(
          aliases: ['GridItemZombiePortalMemo'],
          objClass: 'GridItemZombiePortalProps',
          objData: PortalRepository.blankPropertiesData(),
        ),
        PvzObject(objClass: 'AnonymousLevelData', objData: {'Value': 1}),
      ],
    );

    final unused = await UnusedLevelObjectUtils.findUnusedObjects(level);

    expect(unused.map((object) => object.aliases?.first), ['PortalEvent']);
  });
}
