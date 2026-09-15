import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/custom_portal_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PortalRepository', () {
    test('excludes the buggy Hydra custom portal options', () {
      expect(
        PortalRepository.popAnimCodes,
        isNot(contains('POPANIM_EFFECTS_ZOMBOSS_HYDRA_MIRROR')),
      );
      expect(PortalRepository.spawnMethodCodes, isNot(contains('HydraRandom')));
    });

    test(
      'loads built-in portal templates and deep clones properties',
      () async {
        await PortalRepository.init();
        final template = PortalRepository.templateForType('egypt');
        expect(template, isNotNull);

        final first = PortalRepository.clonePropertiesData('egypt');
        final second = PortalRepository.clonePropertiesData('egypt');
        expect(first['Hitpoints'], 600);
        (first['ZombieTypesToSpawn'] as List).clear();
        expect(second['ZombieTypesToSpawn'], isNotEmpty);
      },
    );
  });

  group('CustomPortalLevelUtils', () {
    test('creates the official first memo slot without JSON metadata', () {
      final level = PvzLevelFile(objects: []);
      final portalType = CustomPortalLevelUtils.create(
        levelFile: level,
        propertiesData: PortalRepository.blankPropertiesData(),
      );

      expect(portalType, 'memo');
      expect(level.objects, hasLength(1));
      expect(level.objects.single.objClass, 'GridItemZombiePortalProps');
      expect(level.objects.single.aliases, ['GridItemZombiePortalMemo']);
      expect(
        level.objects.single.toJson().toString(),
        isNot(contains('__c_editor_')),
      );
      expect(CustomPortalLevelUtils.find(level, 'memo'), isNotNull);
    });

    test('reuses the only valid memo slot instead of creating memo2', () {
      final level = PvzLevelFile(objects: []);
      CustomPortalLevelUtils.create(
        levelFile: level,
        propertiesData: PortalRepository.blankPropertiesData(),
      );
      final replacement = PortalRepository.blankPropertiesData()
        ..['World'] = 'dark';
      final secondType = CustomPortalLevelUtils.create(
        levelFile: level,
        propertiesData: replacement,
      );

      expect(secondType, 'memo');
      expect(level.objects, hasLength(1));
      final second = CustomPortalLevelUtils.find(level, secondType);
      expect(second, isNotNull);
      expect(second!.properties.aliases, ['GridItemZombiePortalMemo']);
      expect((second.properties.objData as Map)['World'], 'dark');
      expect(CustomPortalLevelUtils.find(level, 'memo2'), isNull);
    });

    test('does not expose legacy numbered memo slots as valid portals', () {
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: ['GridItemZombiePortalMemo2'],
            objClass: 'GridItemZombiePortalProps',
            objData: PortalRepository.blankPropertiesData(),
          ),
          PvzObject(
            aliases: ['zombieportal_memo2'],
            objClass: 'GridItemType',
            objData: {
              'TypeName': 'zombieportal_memo2',
              'GridItemClass': 'GridItemZombiePortal',
              'Properties': 'RTID(GridItemZombiePortalMemo2@CurrentLevel)',
            },
          ),
        ],
      );

      expect(CustomPortalLevelUtils.list(level), isEmpty);
      expect(CustomPortalLevelUtils.find(level, 'memo2'), isNull);
    });

    test(
      'recognizes the property-only memo structure used by sample levels',
      () {
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: ['GridItemZombiePortalMemo'],
              objClass: 'GridItemZombiePortalProps',
              objData: {
                ...PortalRepository.blankPropertiesData(),
                'ZombieTypesToSpawn': [
                  {'ZombieTypeName': 'fairy_tale_witch', 'Weight': 50},
                ],
              },
            ),
          ],
        );

        final info = CustomPortalLevelUtils.find(level, 'memo');
        expect(info, isNotNull);
        expect(info!.gridItemType, isNull);
        expect(info.representativeZombies, ['fairy_tale_witch']);
      },
    );

    test('counts event and zomboss action PortalType uses before cleanup', () {
      final level = PvzLevelFile(objects: []);
      CustomPortalLevelUtils.create(
        levelFile: level,
        propertiesData: PortalRepository.blankPropertiesData(),
      );
      level.objects.addAll([
        PvzObject(
          aliases: ['PortalEvent'],
          objClass: 'SpawnModernPortalsWaveActionProps',
          objData: {'PortalType': 'memo', 'PortalColumn': 5, 'PortalRow': 2},
        ),
        PvzObject(
          aliases: ['ZombossPortalAction'],
          objClass: 'ZombossPortalsActionDefinition',
          objData: {'PortalType': 'memo'},
        ),
      ]);

      expect(CustomPortalLevelUtils.countUses(level, 'memo'), 2);
      expect(CustomPortalLevelUtils.removeIfUnused(level, 'memo'), isFalse);
      (level.objects.last.objData as Map)['PortalType'] = 'egypt';
      (level.objects[level.objects.length - 2].objData as Map)['PortalType'] =
          'pirate';
      expect(CustomPortalLevelUtils.removeIfUnused(level, 'memo'), isTrue);
      expect(CustomPortalLevelUtils.find(level, 'memo'), isNull);
    });
  });
}
