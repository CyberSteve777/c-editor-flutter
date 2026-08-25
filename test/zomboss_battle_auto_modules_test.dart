import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_battle_tab.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ZombossBattleRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('new non-mech Zomboss battles default to Qigong Master', () {
    final data = ZombossLastStandMinigameData();

    expect(data.zombossTypeName, 'kongfu_zomboss_qigong');
    expect(data.resourceGroupNames, [
      'ZombieKongFuZombossQigongGroup',
      'ZombossQigongAudio',
    ]);
  });

  test('Underground Palace auto modules are immediately recognizable', () {
    final fixture = _levelFixture();

    final changed = ZombossBattleRepository.ensureAutoModules(
      levelFile: fixture.levelFile,
      levelDef: fixture.levelDef,
      baseId: 'ZombieZombossQinShiHuang',
    );

    expect(changed, isTrue);
    expect(
      fixture.levelDef.modules,
      containsAll([
        'RTID(FinalStageTimeLimitedChallenge@LevelModules)',
        'RTID(TunnelDefend@CurrentLevel)',
      ]),
    );
    final parsed = LevelParser.parseLevel(fixture.levelFile);
    final tunnel = parsed.objectMap['TunnelDefend'];
    expect(tunnel?.objClass, 'TunnelDefendModuleProperties');
    expect(
      ModuleRegistry.getMetadataForAlias(
        'TunnelDefend',
        tunnel!.objClass,
      ).routeId,
      'TunnelDefendModule',
    );
  });

  test('switching Underground Palace variants only changes tile style', () {
    final fixture = _levelFixture();
    ZombossBattleRepository.ensureAutoModules(
      levelFile: fixture.levelFile,
      levelDef: fixture.levelDef,
      baseId: 'ZombieZombossQinShiHuang',
    );
    final tunnel = _tunnelObject(fixture.levelFile);
    final tunnelData = tunnel.objData as Map<String, dynamic>;
    tunnelData['Roads'] = [
      {'GridX': 3, 'GridY': 2, 'Length': 4},
    ];
    tunnelData['TunnelSequenceInterval'] = 0.75;

    final changed = ZombossBattleRepository.syncAutoModules(
      levelFile: fixture.levelFile,
      levelDef: fixture.levelDef,
      previousBaseId: 'ZombieZombossQinShiHuang',
      newBaseId: 'ZombieZombossQinShiHuangGhost',
    );

    expect(changed, isTrue);
    final updated = _tunnelObject(fixture.levelFile).objData as Map;
    expect(updated['BrickMapIndex'], 2);
    expect(updated['TunnelSequenceInterval'], 0.75);
    expect(updated['Roads'], [
      {'GridX': 3, 'GridY': 2, 'Length': 4},
    ]);
    expect(
      fixture.levelDef.modules
          .where((rtid) => rtid == 'RTID(TunnelDefend@CurrentLevel)')
          .length,
      1,
    );
  });

  test(
    'leaving Underground Palace always removes timer and can keep tunnels',
    () {
      final fixture = _levelFixture();
      ZombossBattleRepository.ensureAutoModules(
        levelFile: fixture.levelFile,
        levelDef: fixture.levelDef,
        baseId: 'ZombieZombossQinShiHuangGhost',
      );
      (_tunnelObject(fixture.levelFile).objData as Map)['Roads'] = [
        {'GridX': 1},
      ];

      ZombossBattleRepository.syncAutoModules(
        levelFile: fixture.levelFile,
        levelDef: fixture.levelDef,
        previousBaseId: 'ZombieZombossQinShiHuangGhost',
        newBaseId: 'ZombieZombossQigong',
        removePreviousTunnelDefend: false,
      );

      expect(
        fixture.levelDef.modules,
        isNot(contains('RTID(FinalStageTimeLimitedChallenge@LevelModules)')),
      );
      expect(
        fixture.levelDef.modules,
        contains('RTID(TunnelDefend@CurrentLevel)'),
      );
      expect((_tunnelObject(fixture.levelFile).objData as Map)['Roads'], [
        {'GridX': 1},
      ]);
    },
  );

  test('leaving Underground Palace can remove tunnels together with timer', () {
    final fixture = _levelFixture();
    ZombossBattleRepository.ensureAutoModules(
      levelFile: fixture.levelFile,
      levelDef: fixture.levelDef,
      baseId: 'ZombieZombossQinShiHuang',
    );

    ZombossBattleRepository.syncAutoModules(
      levelFile: fixture.levelFile,
      levelDef: fixture.levelDef,
      previousBaseId: 'ZombieZombossQinShiHuang',
      newBaseId: 'ZombieZombossQigong',
    );

    expect(
      fixture.levelDef.modules,
      isNot(contains('RTID(FinalStageTimeLimitedChallenge@LevelModules)')),
    );
    expect(
      fixture.levelDef.modules,
      isNot(contains('RTID(TunnelDefend@CurrentLevel)')),
    );
    expect(
      fixture.levelFile.objects.any(
        (object) => object.aliases?.contains('TunnelDefend') == true,
      ),
      isFalse,
    );
  });

  testWidgets('non-mech Zomboss and death drop do not conflict', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final conflicts = ConflictRegistry.getActiveConflicts(context, {
              'ZombossLastStandMinigameProperties',
              'ZombiesDeadWinConProperties',
            });
            return Text('${conflicts.length}');
          },
        ),
      ),
    );

    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('cancelling an Underground Palace switch stays clean', (
    tester,
  ) async {
    final data = ZombossLastStandMinigameData(
      zombossTypeName: 'zomboss_qinshihuang',
    );
    final levelDef = LevelDefinitionData(
      modules: <String>['RTID(ZombossLastStand@CurrentLevel)'],
    );
    final levelFile = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDef.toJson(),
        ),
        PvzObject(
          aliases: const ['ZombossLastStand'],
          objClass: 'ZombossLastStandMinigameProperties',
          objData: data.toJson(),
        ),
      ],
    );
    var dirtyChanges = 0;
    var parsedRefreshes = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ZombossBattleTab(
            levelFile: levelFile,
            moduleRtid: 'RTID(ZombossLastStand@CurrentLevel)',
            onChanged: () => dirtyChanges++,
            onAutoModulesEnsured: () => parsedRefreshes++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(parsedRefreshes, 1);
    expect(dirtyChanges, 0);
    await tester.tap(find.byType(ZombossMechBaseCard));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Qigong Master'));
    await tester.pumpAndSettle();
    expect(find.text('Switch base Zomboss'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(dirtyChanges, 0);
  });
}

({PvzLevelFile levelFile, LevelDefinitionData levelDef}) _levelFixture() {
  final levelDef = LevelDefinitionData(modules: <String>[]);
  final levelFile = PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: levelDef.toJson(),
      ),
    ],
  );
  return (levelFile: levelFile, levelDef: levelDef);
}

PvzObject _tunnelObject(PvzLevelFile levelFile) => levelFile.objects
    .singleWhere((object) => object.aliases?.contains('TunnelDefend') == true);
