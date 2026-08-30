import 'dart:typed_data';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_dialog.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzLevelFile _level({
  required bool includeMain,
  required bool includeTutorial,
}) {
  final modules = <String>[];
  final objects = <PvzObject>[];

  if (includeMain) {
    modules.add('RTID(SingleHanded@CurrentLevel)');
    objects.add(
      PvzObject(
        aliases: const ['SingleHanded'],
        objClass: 'SingleHandedProperties',
        objData: SingleHandedPropertiesData(
          missileCount: 2,
          dropWeaponDatas: [
            SingleHandedDropWeaponData(weaponName: 'repeater', killCount: 20),
            SingleHandedDropWeaponData(
              weaponName: 'threepeater',
              killCount: 40,
            ),
          ],
          specialWaveDatas: [
            SingleHandedSpecialWaveData(
              wave: 5,
              zombiesWalkSpeed: 1.5,
              zombiesHitpointsPercent: 2,
              showHealthBar: true,
            ),
          ],
        ).toJson(),
      ),
    );
  }

  if (includeTutorial) {
    modules.add('RTID(SingleHandedTutorial@CurrentLevel)');
    objects.add(
      PvzObject(
        aliases: const ['SingleHandedTutorial'],
        objClass: 'IntroSingleHandedProperties',
        objData: IntroSingleHandedPropertiesData(
          waveForStartRocket: 7,
        ).toJson(),
      ),
    );
  }

  return PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(modules: modules).toJson(),
      ),
      ...objects,
    ],
  );
}

Widget _preview(PvzLevelFile level) {
  final host = PluginHostImpl(
    pluginId: 'team.international2c.level_preview',
    assets: MemoryCPluginAssets(const <String, Uint8List>{}),
    registry: PluginScreenRegistry(),
  );
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LevelPreviewDialog(
      host: host,
      levelFile: level,
      parsed: LevelParser.parseLevel(level),
      fileName: 'single_handed.json',
      onBack: () {},
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);
  });

  testWidgets(
    'level overview shows Single Handed upgrade path and tutorial details',
    (tester) async {
      final level = _level(includeMain: true, includeTutorial: true);
      await tester.pumpWidget(_preview(level));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('singleHandedOverviewCard')),
        findsOneWidget,
      );
      final card = find.byKey(const ValueKey('singleHandedOverviewCard'));
      expect(
        find.byKey(const ValueKey('singleHandedPlantUpgradePath')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('singleHandedPlantStage_peashooter_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('singleHandedPlantStage_repeater_1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('singleHandedPlantStage_threepeater_2')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('singleHandedUpgradeArrow_0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('singleHandedUpgradeArrow_1')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('All by Oneself')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Plant Configuration')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text('Missiles per launch: 2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('Special Waves')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text('All by Oneself Tutorial'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: card,
          matching: find.text('Missiles start from wave: 7'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('tutorial-only level still has a Single Handed overview card', (
    tester,
  ) async {
    final level = _level(includeMain: false, includeTutorial: true);
    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('singleHandedOverviewCard')),
      findsOneWidget,
    );
    final card = find.byKey(const ValueKey('singleHandedOverviewCard'));
    expect(
      find.descendant(of: card, matching: find.text('All by Oneself Tutorial')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card,
        matching: find.text('Missiles start from wave: 7'),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('singleHandedPlantUpgradePath')),
      findsNothing,
    );
  });
}
