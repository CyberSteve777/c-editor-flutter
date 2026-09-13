import 'dart:convert';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_module_resource_names.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _translate(String key, String fallback, [Map<String, Object?>? args]) {
  var text = fallback;
  for (final entry in (args ?? const <String, Object?>{}).entries) {
    text = text.replaceAll('{${entry.key}}', '${entry.value}');
  }
  return text;
}

PvzLevelFile _level(String objClass, Map<String, dynamic> data) => PvzLevelFile(
  objects: [
    PvzObject(aliases: ['Module'], objClass: objClass, objData: data),
  ],
);

Future<BuildContext> _localizedContext(
  WidgetTester tester,
  String locale,
) async {
  late BuildContext result;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          result = context;
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
  return result;
}

List<Object?> _iconIdentity(PreviewModuleInfoPayload payload) => [
  payload.lawnRows,
  payload.lawnCols,
  for (final section in payload.sections)
    [
      section.title,
      for (final item in section.items)
        [item.id, item.assetPath, item.label, item.gridX, item.gridY],
    ],
];

typedef _Fixture = ({
  String objClass,
  Map<String, dynamic> data,
  List<String> resourceKeys,
});

List<_Fixture> _structuredFixtures() => [
  for (final objClass in [
    'InitialPlantProperties',
    'InitialPlantEntryProperties',
  ])
    (
      objClass: objClass,
      data: {
        'InitialPlantPlacements': [
          {
            'PlantTypeName': 'RTID(peashooter@PlantTypes)',
            'GridX': 1,
            'GridY': 2,
          },
          {
            'PlantTypes': ['cosmoss'],
            'GridX': 2,
            'GridY': 3,
          },
        ],
      },
      resourceKeys: ['plant_peashooter', 'plant_cosmoss'],
    ),
  (
    objClass: 'InitialZombieProperties',
    data: {
      'InitialZombiePlacements': [
        {
          'TypeName': 'RTID(mummy@ZombieTypes)',
          'GridX': 4,
          'GridY': 2,
          'Condition': 'frozen',
        },
      ],
    },
    resourceKeys: ['zombie_mummy'],
  ),
  (
    objClass: 'InitialGridItemProperties',
    data: {
      'InitialGridItemPlacements': [
        {'TypeName': 'cosmoss', 'GridX': 1, 'GridY': 3},
      ],
    },
    resourceKeys: ['griditem_cosmoss'],
  ),
  (
    objClass: 'ProtectThePlantChallengeProperties',
    data: ProtectThePlantChallengePropertiesData(
      mustProtectCount: 1,
      plants: [ProtectPlantData(plantType: 'peashooter', gridX: 1, gridY: 2)],
    ).toJson(),
    resourceKeys: ['plant_peashooter'],
  ),
  (
    objClass: 'ProtectTheGridItemChallengeProperties',
    data: ProtectTheGridItemChallengePropertiesData(
      mustProtectCount: 1,
      gridItems: [
        ProtectGridItemData(gridItemType: 'cosmoss', gridX: 2, gridY: 3),
      ],
    ).toJson(),
    resourceKeys: ['griditem_cosmoss'],
  ),
  (
    objClass: 'VaseBreakerPresetProperties',
    data: VaseBreakerPresetData(
      vases: [
        VaseDefinition(plantTypeName: 'peashooter', count: 2),
        VaseDefinition(zombieTypeName: 'mummy', count: 3),
        VaseDefinition(collectableTypeName: 'sun', count: 4),
      ],
    ).toJson(),
    resourceKeys: ['plant_peashooter', 'zombie_mummy', 'sun_large'],
  ),
  (
    objClass: 'SeedRainProperties',
    data: SeedRainPropertiesData(
      seedRains: [
        SeedRainItem(plantTypeName: 'peashooter', maxCount: 2, weight: 80),
        SeedRainItem(zombieTypeName: 'mummy', maxCount: 3, weight: 40),
        SeedRainItem(plantTypeName: 'tool_powertile_alpha', maxCount: 1),
      ],
    ).toJson(),
    resourceKeys: ['plant_peashooter', 'zombie_mummy', 'tool_powertile_alpha'],
  ),
  (
    objClass: 'BronzeProperties',
    data: BronzePropertiesData(
      data: [
        BronzeStatueBatchData(
          itemList: [
            for (final kind in BronzeStatueKind.values)
              BronzeStatueItemData(
                kind: kind,
                mX: kind.index,
                mY: 1,
                spawnTime: 20,
              ),
          ],
        ),
      ],
    ).toJson(),
    resourceKeys: [
      'zombie_kongfu_strong_bronze',
      'zombie_kongfu_magic_bronze',
      'zombie_kongfu_agile_bronze',
    ],
  ),
  (
    objClass: 'PowerTileProperties',
    data: PowerTilePropertiesData(
      linkedTiles: [
        LinkedTileData(
          group: 'alpha',
          location: TileLocationData(mx: 1, my: 2),
        ),
        LinkedTileData(group: 'beta', location: TileLocationData(mx: 3, my: 4)),
      ],
    ).toJson(),
    resourceKeys: ['tool_powertile_alpha', 'tool_powertile_beta'],
  ),
  (
    objClass: 'RenaiModuleProperties',
    data: RenaiModulePropertiesData(
      nightEnabled: true,
      nightStartWaveNum: 4,
      statueInfos: [
        RenaiStatueInfoData(
          typeName: 'renai_statue_zombie1',
          gridX: 1,
          gridY: 2,
        ),
      ],
      statueNightInfos: [
        RenaiStatueInfoData(
          typeName: 'renai_statue_zombie_armor1',
          gridX: 3,
          gridY: 4,
        ),
      ],
    ).toJson(),
    resourceKeys: [
      'griditem_renai_statue_zombie1',
      'griditem_renai_statue_zombie_armor1',
    ],
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await loadPreviewModuleResourceNames();
  });

  for (final locale in ['en', 'zh']) {
    testWidgets(
      '$locale module text labels use real localized resource names',
      (tester) async {
        final context = await _localizedContext(tester, locale);
        for (final fixture in _structuredFixtures()) {
          final level = _level(fixture.objClass, fixture.data);
          final original = jsonEncode(level.toJson());
          final unlocalized = previewModuleInfoBuild(
            levelFile: level,
            objClass: fixture.objClass,
            t: _translate,
          );
          final localized = previewModuleInfoBuild(
            levelFile: level,
            objClass: fixture.objClass,
            t: _translate,
            resourceName: (kind, id) =>
                previewModuleResourceName(context, level, kind, id),
          );
          for (final key in fixture.resourceKeys) {
            final expected = ResourceNames.lookupWithLocale(locale, key);
            expect(
              expected,
              isNot(key),
              reason: 'Missing fixture translation: $key',
            );
            expect(
              localized.textBody,
              contains(expected),
              reason: fixture.objClass,
            );
          }
          expect(
            _iconIdentity(localized),
            _iconIdentity(unlocalized),
            reason: fixture.objClass,
          );
          expect(
            jsonEncode(level.toJson()),
            original,
            reason: 'Display names must not change game data',
          );
        }
      },
    );

    testWidgets(
      '$locale resource resolution preserves categories, RTIDs and custom aliases',
      (tester) async {
        final context = await _localizedContext(tester, locale);
        final level = PvzLevelFile(
          objects: [
            PvzObject(
              aliases: ['CustomMummy'],
              objClass: 'ZombieType',
              objData: {'TypeName': 'mummy'},
            ),
            PvzObject(
              aliases: ['peashooter'],
              objClass: 'PlantType',
              objData: {'TypeName': 'sunflower'},
            ),
          ],
        );
        String resolve(PreviewModuleResourceKind kind, String id) =>
            previewModuleResourceName(context, level, kind, id);
        String name(String key) => ResourceNames.lookupWithLocale(locale, key);
        expect(
          resolve(PreviewModuleResourceKind.plant, 'cosmoss'),
          locale == 'zh' ? '宇宙苔藓' : 'Cosmoss',
        );
        expect(
          resolve(PreviewModuleResourceKind.gridItem, 'cosmoss'),
          locale == 'zh' ? '苔藓地块' : 'Moss Tile',
        );
        expect(
          resolve(
            PreviewModuleResourceKind.plant,
            'RTID(peashooter@PlantTypes)',
          ),
          name('plant_peashooter'),
        );
        expect(
          resolve(PreviewModuleResourceKind.zombie, 'RTID(mummy@ZombieTypes)'),
          name('zombie_mummy'),
        );
        expect(
          resolve(
            PreviewModuleResourceKind.zombie,
            'zombie_towerdefend_wolf_imp',
          ),
          name('zombie_zombie_towerdefend_wolf_imp'),
        );
        expect(
          resolve(
            PreviewModuleResourceKind.gridItem,
            'RTID(cosmoss@GridItemTypes)',
          ),
          name('griditem_cosmoss'),
        );
        for (final customId in [
          'CustomMummy',
          'RTID(CustomMummy@CurrentLevel)',
        ]) {
          expect(
            resolve(PreviewModuleResourceKind.zombie, customId),
            '${name('zombie_mummy')} (CustomMummy)',
          );
        }
        for (final toolId in ['tool_powertile_alpha', 'powertile_alpha']) {
          expect(
            resolve(PreviewModuleResourceKind.tool, toolId),
            name('tool_powertile_alpha'),
          );
        }
        expect(
          resolve(PreviewModuleResourceKind.collectable, 'sun'),
          name('sun_large'),
        );
        expect(
          resolve(PreviewModuleResourceKind.collectable, 'plantfood'),
          name('tool_plantfood'),
        );
        expect(
          resolve(
            PreviewModuleResourceKind.creature,
            'RTID(hermitcrab@CreatureTypes)',
          ),
          name('creature_hermitcrab'),
        );
        for (final kind in PreviewModuleResourceKind.values) {
          expect(
            resolve(kind, 'my_unregistered_resource'),
            'my_unregistered_resource',
          );
          expect(
            resolve(kind, 'RTID(my_unregistered_resource@CurrentLevel)'),
            'my_unregistered_resource',
          );
        }
      },
    );
  }

  test(
    'generic module text resolves typed resources without translating arbitrary values',
    () {
      final level = _level('PreviewUnknownModuleProperties', {
        'PlantTypeName': 'peashooter',
        'ZombieTypeName': 'mummy',
        'GridItemTypeName': 'cosmoss',
        'ToolType': 'powertile_alpha',
        'CollectableTypeName': 'sun',
        'CreatureType': 'hermitcrab',
        'Name': 'peashooter',
        'SomeReference': 'RTID(mummy@ZombieTypes)',
        'GridItems': [
          {'TypeName': 'cosmoss', 'GridX': 2, 'GridY': 3},
        ],
        'PlantWhiteList': ['sunflower'],
        'CustomNotes': ['peashooter'],
      });
      final calls = <(PreviewModuleResourceKind, String)>[];
      final payload = previewModuleInfoBuild(
        levelFile: level,
        objClass: 'PreviewUnknownModuleProperties',
        t: _translate,
        resourceName: (kind, id) {
          calls.add((kind, id));
          return 'localized-${kind.name}-$id';
        },
      );
      expect(
        calls,
        containsAll([
          (PreviewModuleResourceKind.plant, 'peashooter'),
          (PreviewModuleResourceKind.zombie, 'mummy'),
          (PreviewModuleResourceKind.gridItem, 'cosmoss'),
          (PreviewModuleResourceKind.tool, 'powertile_alpha'),
          (PreviewModuleResourceKind.collectable, 'sun'),
          (PreviewModuleResourceKind.creature, 'hermitcrab'),
          (PreviewModuleResourceKind.zombie, 'RTID(mummy@ZombieTypes)'),
          (PreviewModuleResourceKind.plant, 'sunflower'),
        ]),
      );
      expect(
        calls.where((call) => call.$1 == PreviewModuleResourceKind.gridItem),
        hasLength(2),
      );
      expect(calls.where((call) => call.$2 == 'peashooter'), hasLength(1));
      expect(payload.lines, contains('Name: peashooter'));
      expect(payload.lines, contains('  · peashooter'));
      expect(payload.textBody, contains('localized-gridItem-cosmoss (2,3)'));
    },
  );

  test(
    'legacy summaries forward resource localization and keep raw fallback',
    () {
      final level = _level('InitialPlantProperties', {
        'InitialPlantPlacements': ['RTID(peashooter@PlantTypes)'],
      });
      expect(
        previewModuleInfoTextSummary(
          levelFile: level,
          objClass: 'InitialPlantProperties',
          t: _translate,
        ),
        contains('peashooter (0,0)'),
      );
      final localized = previewModuleInfoTextSummary(
        levelFile: level,
        objClass: 'InitialPlantProperties',
        t: _translate,
        resourceName: (kind, id) => '豌豆射手',
      );
      expect(localized, contains('豌豆射手 (0,0)'));
      expect(localized, isNot(contains('peashooter')));
      final icons = previewModuleInfoSections(
        levelFile: level,
        objClass: 'InitialPlantProperties',
        t: _translate,
        resourceName: (kind, id) => '豌豆射手',
      )!;
      expect(icons.single.items.single.id, 'peashooter');
      expect(
        icons.single.items.single.assetPath,
        'assets/images/plants/icon_peashooter.webp',
      );
    },
  );
}
