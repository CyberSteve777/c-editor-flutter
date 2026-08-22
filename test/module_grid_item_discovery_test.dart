import 'package:c_editor/data/grid_item_discovery.dart';
import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GridItemRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('discovers module-spawned grid items with dedicated icons', () {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['Armrack'],
          objClass: 'ArmrackProperties',
          objData: const <String, dynamic>{
            'Overrides': [
              {
                'wave': 1,
                'itemList': [
                  {'mX': 1, 'mY': 1, 'type': 'ArmrackFlag'},
                  {'mX': 2, 'mY': 1, 'type': 'ArmrackBlade'},
                ],
              },
            ],
          },
        ),
        PvzObject(
          aliases: const ['ExampleLunarMineVeins'],
          objClass: 'LunarMineVeinModuleProperties',
          objData: const <String, dynamic>{
            'VeinPlacements': [
              {'GridX': 3, 'GridY': 2, 'EmergenceWave': 1},
            ],
          },
        ),
        PvzObject(
          aliases: const ['RadiationMeteorModule'],
          objClass: 'RadiationMeteorModuleProperties',
          objData: const <String, dynamic>{
            'SpawnSchedule': [
              {'Wave': 2, 'GridX': 4, 'GridY': 3},
            ],
          },
        ),
        PvzObject(
          aliases: const ['SmokePollution'],
          objClass: 'SmokePollutionModuleProperties',
          objData: const <String, dynamic>{
            'GridItem': 'SmokeManhole',
            'SmokeManholeList': [
              {'GridColumn': 5, 'GridRow': 2, 'StartTime': 3},
            ],
          },
        ),
        PvzObject(
          aliases: const ['ManholePipeline'],
          objClass: 'ManholePipelineModuleProperties',
          objData: const <String, dynamic>{
            'PipelineList': [
              {'StartX': 1, 'StartY': 1, 'EndX': 7, 'EndY': 4},
            ],
          },
        ),
        PvzObject(
          aliases: const ['GulliverTunnels'],
          objClass: 'InitialGridItemGulliverTunnelProperties',
          objData: const <String, dynamic>{
            'TunnelPlacements': [
              {'GridX': 6, 'GridY': 3},
            ],
          },
        ),
        PvzObject(
          aliases: const ['MoldColony'],
          objClass: MoldColonyModuleUtils.moduleObjClass,
          objData: const <String, dynamic>{
            'Locations': 'RTID(MoldLayout@CurrentLevel)',
          },
        ),
        PvzObject(
          aliases: const ['MoldLayout'],
          objClass: MoldColonyModuleUtils.layoutObjClass,
          objData: const <String, dynamic>{
            'Values': [
              [0, 1],
            ],
          },
        ),
      ],
    );

    final items = GridItemDiscovery.discoverGridItems(level);

    expect(
      items,
      containsAll(const {
        'ArmrackFlag',
        'ArmrackBlade',
        'lunar_mine_vein',
        'radiation_meteor_ore',
        'SmokeManhole',
        'steam_down',
        'steam_up',
        'gulliver_tunnel',
        'fake_mold',
      }),
    );
    for (final item in items) {
      expect(
        GridItemRepository.getIconPath(item),
        isNot('assets/images/others/unknown.webp'),
        reason: '$item should have a Level Overview icon',
      );
    }
  });

  test('does not offer Robot Vacuum as a rift theme', () {
    expect(RiftThemeRepository.themeIds, isNot(contains('cleaner')));
    expect(
      RiftThemeRepository.availableThemes(const []),
      isNot(contains('cleaner')),
    );
  });

  test('offers Heavy Balloon in the requested theme order', () {
    final themes = RiftThemeRepository.themeIds;
    final cold = themes.indexOf('cold_reduce');
    final balloon = themes.indexOf('heavy_ballon');
    final miner = themes.indexOf('miner_cheating');

    expect(balloon, cold + 1);
    expect(miner, balloon + 1);
    expect(
      ResourceNames.lookupWithLocale(
        'en',
        RiftThemeRepository.nameKey('heavy_ballon'),
      ),
      'Heavy Balloon',
    );
    expect(
      ResourceNames.lookupWithLocale(
        'zh',
        RiftThemeRepository.nameKey('heavy_ballon'),
      ),
      '沉重气球',
    );
  });

  test('offers KO immediately after Zombie with localized text', () {
    final themes = RiftThemeRepository.themeIds;
    final zombie = themes.indexOf('zombie');
    final ko = themes.indexOf('ko');

    expect(ko, zombie + 1);
    expect(
      ResourceNames.lookupWithLocale('en', RiftThemeRepository.nameKey('ko')),
      'Melee Plants Cannot Use Plant Food',
    );
    expect(
      ResourceNames.lookupWithLocale('zh', RiftThemeRepository.nameKey('ko')),
      '近战植物禁止用能量豆',
    );
  });

  test('maps pursuit and dedicated rift theme icons correctly', () {
    for (final id in const {
      'zombie',
      'exploder',
      'ko',
      'projectile',
      'nuke',
      'gravity',
      'rift',
    }) {
      expect(
        RiftThemeRepository.iconAssetPath(id),
        'assets/images/rift_themes/pursuit.webp',
      );
    }
    expect(
      RiftThemeRepository.iconAssetPath('plant_melee'),
      'assets/images/rift_themes/plant_melee.webp',
    );
  });

  test('uses the RIFT_THEMES target aliases for theme detail lists', () {
    expect(
      RiftThemeRepository.targetLists['zombie']?.ids,
      containsAll(['roman', 'renai_armor2']),
    );
    expect(
      RiftThemeRepository.targetLists['ko']?.ids,
      containsAll(['bonkchoy', 'pokra']),
    );
    expect(
      RiftThemeRepository.targetLists['nuke']?.ids,
      containsAll(['wallnut', 'waxgourd']),
    );
    expect(
      RiftThemeRepository.targetLists['gravity']?.ids,
      containsAll(['cabbagepult', 'elaeocarpus']),
    );
    expect(
      RiftThemeRepository.targetLists['sun_disabled']?.ids,
      containsAll(['sunflower', 'moonflower']),
    );
  });

  test('localizes the colossal Moon creatures', () {
    expect(
      ResourceNames.lookupWithLocale('en', 'zombie_giant_hermit_crab'),
      'Colossal Hermit Crab',
    );
    expect(
      ResourceNames.lookupWithLocale('zh', 'zombie_giant_hermit_crab'),
      '巨型寄居蟹',
    );
    expect(
      ResourceNames.lookupWithLocale('en', 'zombie_cthulhu_jelly_fish'),
      'Colossal Jellyfish',
    );
    expect(
      ResourceNames.lookupWithLocale('zh', 'zombie_cthulhu_jelly_fish'),
      '巨型水母',
    );
  });

  test('uses the detailed final-row rift theme descriptions', () {
    expect(
      ResourceNames.lookupWithLocale(
        'zh',
        RiftThemeRepository.descriptionKey('heavy_ballon'),
      ),
      '所有带飞行属性的僵尸不会再被吹飞，只会被击退到最后一格。',
    );
    expect(
      ResourceNames.lookupWithLocale(
        'zh',
        RiftThemeRepository.descriptionKey('miner_cheating'),
      ),
      '反向类僵尸入场后，直接进入挖掘/弹射状态，从大后方进攻。',
    );
    expect(
      ResourceNames.lookupWithLocale(
        'zh',
        RiftThemeRepository.descriptionKey('knight_cheating'),
      ),
      '冲刺类僵尸入场后，直接进入冲锋状态，停下来之前无视伤害和控制。',
    );
    expect(
      ResourceNames.lookupWithLocale(
        'zh',
        RiftThemeRepository.descriptionKey('mage_cheating'),
      ),
      '特殊技能僵尸进入场后不再移动，在原地以更高频率释放技能。',
    );

    final heavyBalloonEn = ResourceNames.lookupWithLocale(
      'en',
      RiftThemeRepository.descriptionKey('heavy_ballon'),
    );
    expect(heavyBalloonEn, contains('blown away'));
    expect(heavyBalloonEn, contains('knocked back'));
    expect(heavyBalloonEn.toLowerCase(), isNot(contains('knockback')));
  });
}
