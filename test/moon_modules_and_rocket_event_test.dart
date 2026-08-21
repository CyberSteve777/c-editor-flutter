import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/registry/object_order_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/l10n/app_localizations_ru.dart';
import 'package:c_editor/l10n/app_localizations_zh.dart';
import 'package:c_editor/screens/editor/modules/moon_life_support_system_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Moon Base module models', () {
    test('reads the LevelModules life support definition', () {
      final data = MoonLifeSupportSystemPropertiesData.fromJson({
        'InitialCapacity': 10,
        'BufferOverloadRatio': 2.0,
        'PenaltyCountdown': 5.0,
        'PlantImmunityList': {
          'List': ['cosmoss', 'doomshroom'],
          'ListType': 'blacklist',
        },
        'ResourceGroupNames': ['ZombieArchmageGroup', 'LunarLifeSupport'],
      });

      expect(data.initialCapacity, 10);
      expect(data.bufferOverloadRatio, 2.0);
      expect(data.penaltyCountdown, 5.0);
      expect(data.plantImmunityList.plants, ['cosmoss', 'doomshroom']);
      expect(data.plantImmunityList.listType, 'blacklist');
      expect(data.toJson()['PlantImmunityList'], {
        'List': ['cosmoss', 'doomshroom'],
        'ListType': 'blacklist',
      });

      final defaults = MoonLifeSupportSystemPropertiesData();
      expect(
        () => defaults.plantImmunityList.plants.remove('cosmoss'),
        returnsNormally,
      );
    });

    test('round-trips the sample Lunar Terminal and vein data', () {
      final terminal = LunarTerminalModulePropertiesData.fromJson({
        'CollectorCooldown': 20,
      });
      final veins = LunarMineVeinModulePropertiesData.fromJson({
        'VeinPlacements': [
          {'GridX': 4, 'GridY': 2, 'EmergenceWave': 4},
          {'GridX': 6, 'GridY': 3, 'EmergenceWave': 12},
        ],
      });

      expect(terminal.collectorCooldown, 20);
      expect(terminal.toJson()['CollectorCooldown'], 20.0);
      expect(veins.placements, hasLength(2));
      expect(veins.placements.first.emergenceWave, 4);
      expect(veins.toJson()['VeinPlacements'], [
        {'GridX': 4, 'GridY': 2, 'EmergenceWave': 4},
        {'GridX': 6, 'GridY': 3, 'EmergenceWave': 12},
      ]);
    });

    test('round-trips the sample radioactive meteor schedule', () {
      final data = RadiationMeteorModulePropertiesData.fromJson({
        'ResourceGroupNames': ['Radiation_meteorite_group'],
        'WarningDuration': 5,
        'PollutionInterval': 5,
        'MiningDurationRequired': 5,
        'PowerRewardOnDestroy': 4,
        'SpawnSchedule': [
          {'Wave': 5, 'GridX': 8, 'GridY': 2},
          {'Wave': 10, 'GridX': 7, 'GridY': 3},
          {'Wave': 14, 'GridX': 5, 'GridY': 2},
        ],
      });

      expect(data.spawnSchedule.map((entry) => entry.wave), [5, 10, 14]);
      expect(data.powerRewardOnDestroy, 4);
      expect((data.toJson()['SpawnSchedule'] as List).last, {
        'Wave': 14,
        'GridX': 5,
        'GridY': 2,
      });
    });
  });

  group('Rocket landing event', () {
    test('round-trips the sample Wave 5 event', () {
      final data = SpawnRocketLandingWaveActionPropsData.fromJson({
        'RocketPool': [
          {'Type': 'RTID(rocket_landing@GridItemTypes)', 'Count': 1},
        ],
        'SpawnPositionsPool': [
          {'mX': 8, 'mY': 0},
          {'mX': 8, 'mY': 4},
        ],
        'SpawnCount': 1,
        'SpawnInterval': 3,
        'DisplacePlants': false,
        'IgnoreGraveStone': true,
      });

      expect(data.rocketPool.single.type, 'RTID(rocket_landing@GridItemTypes)');
      expect(data.spawnPositionsPool, hasLength(2));
      expect(data.spawnPositionsPool.last.mx, 8);
      expect(data.spawnPositionsPool.last.my, 4);
      expect(data.ignoreGraveStone, isTrue);
      expect(data.toJson()['SpawnPositionsPool'], [
        {'mX': 8, 'mY': 0},
        {'mX': 8, 'mY': 4},
      ]);
    });
  });

  group('Moon Base registries and assets', () {
    test('registers all four modules with the expected aliases', () {
      expect(
        ModuleRegistry.getMetadata(
          'MoonLifeSupportSystemProperties',
        ).defaultAlias,
        'MoonLifeSupportSystemModule',
      );
      expect(
        ModuleRegistry.getMetadata(
          'MoonLifeSupportSystemProperties',
        ).defaultSource,
        'LevelModules',
      );
      expect(
        ModuleRegistry.getMetadata(
          'LunarTerminalModuleProperties',
        ).defaultAlias,
        'LunarTerminalModule',
      );
      expect(
        ModuleRegistry.getMetadata(
          'LunarMineVeinModuleProperties',
        ).defaultAlias,
        'ExampleLunarMineVeins',
      );
      expect(
        ModuleRegistry.getMetadata(
          'RadiationMeteorModuleProperties',
        ).defaultAlias,
        'RadiationMeteorModule',
      );
    });

    test('keeps the requested module categories and ordering', () {
      final moduleKeys = ModuleRegistry.registry.keys.toList();
      final renai = moduleKeys.indexOf('RenaiModuleProperties');
      final veins = moduleKeys.indexOf('LunarMineVeinModuleProperties');
      final heian = moduleKeys.indexOf('HeianWindModuleProperties');
      final life = moduleKeys.indexOf('MoonLifeSupportSystemProperties');
      final terminal = moduleKeys.indexOf('LunarTerminalModuleProperties');
      final meteor = moduleKeys.indexOf('RadiationMeteorModuleProperties');

      expect(
        ModuleRegistry.getMetadata('LunarMineVeinModuleProperties').category,
        ModuleCategory.scene,
      );
      for (final objClass in [
        'MoonLifeSupportSystemProperties',
        'LunarTerminalModuleProperties',
        'RadiationMeteorModuleProperties',
      ]) {
        expect(
          ModuleRegistry.getMetadata(objClass).category,
          ModuleCategory.gimmick,
          reason: objClass,
        );
      }
      expect(veins, renai + 1);
      expect(life, heian + 1);
      expect(terminal, life + 1);
      expect(meteor, terminal + 1);

      expect(
        ObjectOrderRegistry.getPriority('LunarMineVeinModuleProperties'),
        ObjectOrderRegistry.getPriority('RenaiModuleProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('MoonLifeSupportSystemProperties'),
        ObjectOrderRegistry.getPriority('HeianWindModuleProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('LunarTerminalModuleProperties'),
        ObjectOrderRegistry.getPriority('MoonLifeSupportSystemProperties') + 1,
      );
      expect(
        ObjectOrderRegistry.getPriority('RadiationMeteorModuleProperties'),
        ObjectOrderRegistry.getPriority('LunarTerminalModuleProperties') + 1,
      );
    });

    test('registers the rocket event and required grid icons exist', () {
      final event = EventRegistry.getByObjClass(
        'SpawnRocketLandingWaveActionProps',
      );
      expect(event, isNotNull);
      expect(event!.defaultAlias, 'Rocket');
      expect(event.category, EventCategory.gridItemSpawn);
      expect(
        event.assetIconPath,
        'assets/images/griditems/rocket_landing.webp',
      );

      for (final path in [
        'assets/images/griditems/lunar_mine_vein.webp',
        'assets/images/griditems/radiation_meteor_ore.webp',
        'assets/images/griditems/rocket_landing.webp',
      ]) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }

      final events = EventRegistry.getAll();
      final shellIndex = events.indexWhere(
        (entry) => entry.defaultObjClass == 'ZombieAtlantisShellActionProps',
      );
      final rocketIndex = events.indexWhere(
        (entry) => entry.defaultObjClass == 'SpawnRocketLandingWaveActionProps',
      );
      expect(rocketIndex, shellIndex + 1);
      expect(
        ObjectOrderRegistry.getPriority('SpawnRocketLandingWaveActionProps'),
        ObjectOrderRegistry.getPriority('ZombieAtlantisShellActionProps') + 1,
      );
    });

    test('keeps the requested CollectorCooldown Chinese label', () {
      expect(
        AppLocalizationsZh().lunarTerminalCollectorCooldown,
        '机器人部署冷却 (CollectorCooldown，单位：秒)',
      );
      expect(
        AppLocalizationsZh().rocketDisplacePlantsSubtitle,
        '开启后，火箭会将落点格上的植物弹至周围空地',
      );
      expect(
        AppLocalizationsZh().positionPoolSpawnPositions,
        '候选位置池 (SpawnPositionsPool)',
      );
    });

    test('keeps English and Russian rocket switch subtitles localized', () {
      expect(
        AppLocalizationsEn().rocketDisplacePlantsSubtitle,
        'When enabled, the rocket moves plants on its landing tile to nearby '
        'empty tiles',
      );
      expect(
        AppLocalizationsRu().rocketDisplacePlantsSubtitle,
        'Если включено, ракета перемещает растения из клетки падения на '
        'соседние свободные клетки',
      );
      expect(
        AppLocalizationsEn().positionPoolSpawnPositions,
        'Position pool (SpawnPositionsPool)',
      );
      expect(
        AppLocalizationsRu().positionPoolSpawnPositions,
        'Пул позиций (SpawnPositionsPool)',
      );
    });
  });

  testWidgets('life support custom switch creates a CurrentLevel copy', (
    tester,
  ) async {
    final levelDef = LevelDefinitionData(
      modules: ['RTID(MoonLifeSupportSystemModule@LevelModules)'],
    );
    final levelFile = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDef.toJson(),
        ),
      ],
    );
    String? toggledRtid;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MoonLifeSupportSystemScreen(
          rtid: 'RTID(MoonLifeSupportSystemModule@LevelModules)',
          levelFile: levelFile,
          levelDef: levelDef,
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection: (_, _) {},
          onModeToggled: (rtid) => toggledRtid = rtid,
        ),
      ),
    );

    expect(find.byType(Switch), findsOneWidget);
    expect(find.textContaining('InitialCapacity'), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(toggledRtid, 'RTID(MoonLifeSupportSystemModule@CurrentLevel)');
    expect(levelDef.modules, [
      'RTID(MoonLifeSupportSystemModule@CurrentLevel)',
    ]);
    final copy = levelFile.objects.singleWhere(
      (object) => object.objClass == 'MoonLifeSupportSystemProperties',
    );
    expect(copy.objData['InitialCapacity'], 10);
    expect(copy.objData['PlantImmunityList']['List'], contains('cosmoss'));
  });
}
