import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/level_escalation_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  test('LevelEscalationModuleData round-trips the reference payload', () {
    const json = <String, dynamic>{
      'FlagCount': 3,
      'PlantfoodToSpawnCount': 4,
      'PointIncrementPerWave': 75,
      'StartingPoints': 100,
      'WaveManagerProps': 'RTID(WaveManagerProps@CurrentLevel)',
      'WavesPerFlag': 4,
      'ZombiePool': [
        'RTID(pirate@ZombieTypes)',
        'RTID(pirate_armor2@ZombieTypes)',
        'RTID(pirate_armor1@ZombieTypes)',
        'RTID(barrelroller@ZombieTypes)',
      ],
    };

    final data = LevelEscalationModuleData.fromJson(json);
    expect(data.flagCount, 3);
    expect(data.wavesPerFlag, 4);
    expect(data.startingPoints, 100);
    expect(data.pointIncrementPerWave, 75);
    expect(data.plantfoodToSpawnCount, 4);
    expect(data.waveManagerProps, 'RTID(WaveManagerProps@CurrentLevel)');
    expect(data.zombiePool, hasLength(4));
    expect(data.totalWaves, 12);
    expect(data.toJson(), json);
  });

  group('LevelEscalationModuleScreen', () {
    Widget wrap(PvzLevelFile level) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelEscalationModuleScreen(
          rtid: 'RTID(LevelEscalation@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      );
    }

    PvzLevelFile buildLevel({
      String? propsAlias = 'WaveManagerProps',
      String? moduleRef = 'RTID(WaveManagerProps@CurrentLevel)',
    }) {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: moduleRef,
          zombiePool: const ['RTID(pirate@ZombieTypes)'],
        ).toJson(),
      );
      final objects = <PvzObject>[module];
      if (propsAlias != null) {
        objects.add(
          PvzObject(
            aliases: [propsAlias],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        );
      }
      return PvzLevelFile(objects: objects);
    }

    testWidgets('editing flag count writes objdata', (tester) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final flagField = find.widgetWithText(TextField, '3');
      await tester.enterText(flagField, '5');
      await tester.pumpAndSettle();

      final obj = level.objects.first;
      final data = Map<String, dynamic>.from(obj.objData as Map);
      expect(data['FlagCount'], 5);
      expect(data['WavesPerFlag'], 4);
      expect(data['ZombiePool'], ['RTID(pirate@ZombieTypes)']);
      expect(find.text('Total escalation waves: 20'), findsOneWidget);
    });

    testWidgets('dangling WaveManagerProps shows repair button', (
      tester,
    ) async {
      final level = buildLevel(
        propsAlias: 'WaveManagerPropsWeek1',
        moduleRef: 'RTID(WaveManagerPropsOld@CurrentLevel)',
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final fixFinder = find.byKey(
        const ValueKey('levelEscalationPropsFixButton'),
      );
      expect(fixFinder, findsOneWidget);

      await tester.tap(fixFinder);
      await tester.pumpAndSettle();

      final obj = level.objects.first;
      final repaired = LevelEscalationModuleData.fromJson(
        Map<String, dynamic>.from(obj.objData as Map),
      );
      expect(
        repaired.waveManagerProps,
        'RTID(WaveManagerPropsWeek1@CurrentLevel)',
      );
      expect(fixFinder, findsNothing);
    });

    testWidgets('renders zombie pool entries', (tester) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('levelEscalationZombie-0')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict button opens the point prediction dialog', (
      tester,
    ) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      expect(button, findsOneWidget);

      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Point prediction'),
        ),
        findsOneWidget,
      );
      // Defaults to the last wave (12), which is a flag wave.
      expect(find.textContaining('Wave 12'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('levelEscalationPredictWave-1')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('levelEscalationPredictWave-1')),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Wave 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict dialog lists flag carriers and hides no-data '
        'zombies', (tester) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
          zombiePool: const [
            'RTID(pirate@ZombieTypes)',
            'RTID(pirate_flag@ZombieTypes)',
            'RTID(my_custom@CurrentLevel)',
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          module,
          PvzObject(
            aliases: const ['WaveManagerProps'],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        ],
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      // The Weight = 0 flag carrier is a normal prediction row; only the
      // custom zombie without point cost data is reported and hidden.
      expect(find.text('pirate_flag'), findsOneWidget);
      expect(find.text('my_custom'), findsNothing);
      expect(find.textContaining('not counted'), findsOneWidget);
      expect(find.textContaining('my_custom'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('predict dialog hides rows that are 0.00 for the wave', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
          // One wave, 75 points after the flag multiplier: a cost-100 pirate
          // never fits, so its row must be hidden.
          flagCount: 1,
          wavesPerFlag: 1,
          startingPoints: 30,
          pointIncrementPerWave: 0,
          zombiePool: const ['RTID(pirate@ZombieTypes)'],
        ).toJson(),
      );
      final level = PvzLevelFile(
        objects: [
          module,
          PvzObject(
            aliases: const ['WaveManagerProps'],
            objClass: 'WaveManagerProperties',
            objData: <String, dynamic>{},
          ),
        ],
      );
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey('levelEscalationPredictButton'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(find.text('pirate'), findsNothing);
      expect(
        find.text(
          "None of this wave's pool zombies can be bought with its points.",
        ),
        findsOneWidget,
      );
      expect(find.text('No dynamic zombies'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('add wave timeline creates missing wave manager objects', (
      tester,
    ) async {
      final module = PvzObject(
        aliases: const ['LevelEscalation'],
        objClass: 'LevelEscalationModuleProperties',
        objData: LevelEscalationModuleData(
          waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
        ).toJson(),
      );
      final levelDef = PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          modules: const ['RTID(LevelEscalation@CurrentLevel)'],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [levelDef, module]);
      var structureChanged = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LevelEscalationModuleScreen(
            rtid: 'RTID(LevelEscalation@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onStructureChanged: () => structureChanged = true,
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byKey(
        const ValueKey('levelEscalationAddWaveTimelineButton'),
      );
      expect(button, findsOneWidget);
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      final props = level.objects
          .where((o) => o.objClass == 'WaveManagerProperties')
          .toList();
      expect(props, hasLength(1));
      expect(props.single.aliases, ['WaveManagerProps']);

      final wmm = level.objects
          .where((o) => o.objClass == 'WaveManagerModuleProperties')
          .toList();
      expect(wmm, hasLength(1));
      expect(wmm.single.aliases, ['NewWaves']);

      final wmmData = WaveManagerModuleData.fromJson(
        Map<String, dynamic>.from(wmm.single.objData as Map),
      );
      expect(wmmData.waveManagerProps, 'RTID(WaveManagerProps@CurrentLevel)');

      final def = LevelDefinitionData.fromJson(
        Map<String, dynamic>.from(levelDef.objData as Map),
      );
      expect(
        def.modules,
        containsAll(<String>[
          'RTID(LevelEscalation@CurrentLevel)',
          'RTID(NewWaves@CurrentLevel)',
        ]),
      );

      final repaired = LevelEscalationModuleData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      );
      expect(repaired.waveManagerProps, 'RTID(WaveManagerProps@CurrentLevel)');
      expect(structureChanged, isTrue);
      // Card is valid now, so the add button is gone.
      expect(button, findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('help dialog states that zombies always spawn at level 1', (
      tester,
    ) async {
      final level = buildLevel();
      await tester.pumpWidget(wrap(level));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.help_outline));
      await tester.pumpAndSettle();

      expect(find.text('• Zombie levels'), findsOneWidget);
      expect(find.textContaining('always spawns at level 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
