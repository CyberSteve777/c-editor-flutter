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
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _copy =
    <String, ({String plants, String zombies, String conveyor, String lawn})>{
      'en': (
        plants: 'Preset plants',
        zombies: 'Preset zombies',
        conveyor: 'Conveyor plants',
        lawn: 'Lawn',
      ),
      'zh': (plants: '预选植物', zombies: '预选僵尸', conveyor: '传送带植物', lawn: '草坪'),
      'ru': (
        plants: 'Предустановленные растения',
        zombies: 'Предустановленные зомби',
        conveyor: 'Растения конвейера',
        lawn: 'Поле',
      ),
    };

PvzLevelFile _level({required bool zombieMode}) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID(EgyptStage@LevelModules)',
        modules: const [
          'RTID(SeedBank@CurrentLevel)',
          'RTID(Conveyor@CurrentLevel)',
          'RTID(SeedRain@CurrentLevel)',
        ],
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['SeedBank'],
      objClass: 'SeedBankProperties',
      objData: {
        'SelectionMethod': 'preset',
        'ZombieMode': zombieMode,
        'PresetPlantList': [zombieMode ? 'tutorial' : 'peashooter'],
      },
    ),
    PvzObject(
      aliases: const ['Conveyor'],
      objClass: 'ConveyorSeedBankProperties',
      objData: {
        'Plants': [
          {'PlantType': 'sunflower'},
        ],
      },
    ),
    PvzObject(
      aliases: const ['SeedRain'],
      objClass: 'SeedRainProperties',
      objData: SeedRainPropertiesData(
        seedRains: [SeedRainItem(plantTypeName: 'wallnut')],
      ).toJson(),
    ),
  ],
);

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

  test('overview labels are distinct from technical editor field copy', () {
    const editorDescriptions = {
      'en': 'Plants pre-selected at the start',
      'zh': '开局自带的植物',
      'ru': 'Растения в начале',
    };
    for (final entry in _copy.entries) {
      final l10n = lookupAppLocalizations(Locale(entry.key));
      final copy = entry.value;
      expect(l10n.overviewPresetPlants, copy.plants);
      expect(l10n.overviewPresetZombies, copy.zombies);
      expect(l10n.overviewConveyorPlants, copy.conveyor);
      expect(l10n.overviewLawn, copy.lawn);
      expect(l10n.presetPlants, contains('(PresetPlantList)'));
      expect(l10n.plantsAvailableAtStart, editorDescriptions[entry.key]);
    }
  });

  for (final entry in _copy.entries) {
    for (final zombieMode in [false, true]) {
      testWidgets(
        '${entry.key} overview distinguishes ${zombieMode ? 'zombie' : 'plant'} '
        'seed slots, conveyor and seed rain',
        (tester) async {
          tester.view.physicalSize = const Size(900, 800);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final locale = Locale(entry.key);
          final level = _level(zombieMode: zombieMode);
          await tester.pumpWidget(
            MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: ThemeData(platform: TargetPlatform.iOS),
              home: LevelOverviewDialog(
                levelFile: level,
                parsed: LevelParser.parseLevel(level),
                fileName: 'overview-copy.json',
                onClose: () {},
              ),
            ),
          );
          await tester.pumpAndSettle();

          final copy = entry.value;
          expect(
            find.text(zombieMode ? copy.zombies : copy.plants),
            findsOneWidget,
          );
          expect(
            find.text(zombieMode ? copy.plants : copy.zombies),
            findsNothing,
          );
          expect(find.text(copy.conveyor), findsOneWidget);
          expect(
            find.text(lookupAppLocalizations(locale).rainContent),
            findsOneWidget,
          );
          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Text &&
                  (widget.data?.startsWith('${copy.lawn}: ') ?? false),
            ),
            findsOneWidget,
          );
          expect(find.textContaining('PresetPlantList'), findsNothing);
          expect(
            find.text(lookupAppLocalizations(locale).plantsAvailableAtStart),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
