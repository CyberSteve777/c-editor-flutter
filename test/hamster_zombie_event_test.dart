import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_widgets.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/hamster_zombie_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      GridItemRepository.init(),
      ZombieRepository().init(),
    ]);
  });

  test(
    'hamsterball data round-trips the reference schema and future fields',
    () {
      final source = <String, dynamic>{
        'ColumnStart': 0,
        'ColumnEnd': 8,
        'GroupSize': 2,
        'TimeBetweenGroups': 2,
        'TimeBeforeFullSpawn': 5,
        'FutureSpawnerField': 'kept',
        'Zombies': [
          {
            'Level': 1,
            'Behavior': 2,
            'HasPlantfood': true,
            'SpeedBeforeImpact': 0.3,
            'Type': 'RTID(hamster_ball@ZombieTypes)',
            'ZombieInsideBallType': 'RTID(birthday_pharaoh@ZombieTypes)',
            'FutureZombieField': 42,
          },
        ],
      };

      final data = HamsterZombieSpawnerPropsData.fromJson(source);
      expect(data.columnStart, 0);
      expect(data.columnEnd, 8);
      expect(data.zombies.single.behavior, 2);
      expect(data.toJson(), source);
    },
  );

  test(
    'hamsterball event is registered immediately after the ice cream van',
    () {
      final events = EventRegistry.getAll();
      final schoolBus = events.indexWhere(
        (event) => event.defaultObjClass == 'SchoolBusWaveActionProps',
      );
      expect(
        events[schoolBus + 1].defaultObjClass,
        'HamsterZombieSpawnerProps',
      );
      final hamster = EventRegistry.getByObjClass('HamsterZombieSpawnerProps')!;
      expect(hamster.category, EventCategory.zombieSpawn);
      expect(hamster.defaultAlias, 'HamsterBallEvent');
      expect(hamster.icon, Icons.pets);
      expect(
        hamster.initialDataFactory(),
        isA<HamsterZombieSpawnerPropsData>(),
      );
    },
  );

  test(
    'level overview includes hamsterball passengers but not containers or grid items',
    () {
      final event = PvzObject(
        aliases: const ['HamsterBallEvent'],
        objClass: 'HamsterZombieSpawnerProps',
        objData: const <String, dynamic>{
          'Zombies': [
            {
              'Type': 'RTID(hamster_ball@ZombieTypes)',
              'ZombieInsideBallType': 'RTID(birthday_pharaoh@ZombieTypes)',
            },
            {'Type': 'RTID(griditem_future_obstacle@GridItemTypes)'},
            {'ZombieType': 'RTID(future_zombie@ZombieTypes)'},
          ],
        },
      );
      final waveManager = PvzObject(
        aliases: const ['WaveManager'],
        objClass: 'WaveManagerProperties',
        objData: WaveManagerData(
          waves: const [
            ['RTID(HamsterBallEvent@CurrentLevel)'],
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [event, waveManager]);

      final zombies = ZombieDiscovery.discoverZombies(
        level,
        LevelParser.parseLevel(level),
      );

      expect(zombies, containsAll(['birthday_pharaoh', 'future_zombie']));
      expect(zombies, isNot(contains('hamster_ball')));
      expect(
        zombies.where((id) => id.toLowerCase().startsWith('griditem_')),
        isEmpty,
      );
    },
  );

  testWidgets('unknown overview resources keep their original code name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: UniversalIcon(id: 'future_zombie')),
      ),
    );
    await tester.pumpAndSettle();

    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'future_zombie');
    expect(tooltip.message, isNot(startsWith('griditem_')));
  });

  testWidgets(
    'hamsterball editor updates entry fields and reuses properties switch',
    (tester) async {
      final event = PvzObject(
        aliases: const ['HamsterBallEvent'],
        objClass: 'HamsterZombieSpawnerProps',
        objData: HamsterZombieSpawnerPropsData(
          zombies: [
            HamsterZombieData(
              zombieInsideBallType: 'RTID(mummy_armor4@ZombieTypes)',
            ),
          ],
        ).toJson(),
      );
      final level = PvzLevelFile(objects: [event]);
      await tester.pumpWidget(
        _localizedApp(
          HamsterZombieEventScreen(
            rtid: 'RTID(HamsterBallEvent@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
            onEditCustomZombie: (_) {},
            onInjectCustomZombie: (_) => null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Zombie Hamsterball'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('hamsterGroupSize')),
        '3',
      );
      expect((event.objData as Map)['GroupSize'], 3);

      await tester.ensureVisible(find.text('Change lane on impact'));
      await tester.tap(find.text('Change lane on impact'));
      await tester.pump();
      expect(((event.objData as Map)['Zombies'] as List).single['Behavior'], 2);
      expect(
        find.text('Behavior: 2 = changes lane after hitting a plant'),
        findsOneWidget,
      );
      expect(
        tester.getSize(find.text('Change lane on impact')).height,
        lessThan(30),
      );

      await tester.ensureVisible(find.text('Switch properties'));
      expect(find.text('Switch properties'), findsOneWidget);
    },
  );

  testWidgets(
    'hamsterball generation fields align mixed-height external labels',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final event = PvzObject(
        aliases: const ['HamsterBallEvent'],
        objClass: 'HamsterZombieSpawnerProps',
        objData: HamsterZombieSpawnerPropsData().toJson(),
      );
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) {
              final media = MediaQuery.of(context);
              return MediaQuery(
                data: media.copyWith(textScaler: const TextScaler.linear(1.4)),
                child: HamsterZombieEventScreen(
                  rtid: 'RTID(HamsterBallEvent@CurrentLevel)',
                  levelFile: PvzLevelFile(objects: [event]),
                  onChanged: () {},
                  onBack: () {},
                  onRequestZombieSelection: (_) {},
                ),
              );
            },
          ),
          locale: const Locale('ru'),
        ),
      );
      await tester.pumpAndSettle();

      final groupSize = find.byKey(const ValueKey('hamsterGroupSize'));
      final groupInterval = find.byKey(
        const ValueKey('hamsterTimeBetweenGroups'),
      );
      final fullSpawn = find.byKey(
        const ValueKey('hamsterTimeBeforeFullSpawn'),
      );
      expect(
        tester.getRect(groupSize).top,
        closeTo(tester.getRect(fullSpawn).top, 1),
      );
      expect(
        tester.getRect(groupInterval).top,
        closeTo(tester.getRect(fullSpawn).top, 1),
      );
      expect(
        tester.getRect(find.text('Размер группы')).center.dy,
        closeTo(
          tester
              .getRect(
                find.text('Время до полного появления (TimeBeforeFullSpawn)'),
              )
              .center
              .dy,
          1,
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('hamsterball heading and zombie card reflow on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final event = PvzObject(
      aliases: const ['HamsterBallEvent'],
      objClass: 'HamsterZombieSpawnerProps',
      objData: HamsterZombieSpawnerPropsData(
        zombies: [
          HamsterZombieData(
            zombieInsideBallType: 'RTID(birthday_pharaoh@ZombieTypes)',
          ),
        ],
      ).toJson(),
    );
    final level = PvzLevelFile(objects: [event]);
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
              child: HamsterZombieEventScreen(
                rtid: 'RTID(HamsterBallEvent@CurrentLevel)',
                levelFile: level,
                onChanged: () {},
                onBack: () {},
                onRequestZombieSelection: (_) {},
                onEditCustomZombie: (_) {},
                onInjectCustomZombie: (_) => null,
              ),
            );
          },
        ),
        locale: const Locale('ru'),
      ),
    );
    await tester.pumpAndSettle();

    final heading = find.byKey(const ValueKey('hamsterballZombiesHeading'));
    final addButton = find.byKey(const ValueKey('hamsterballAddZombieButton'));
    final identity = find.byKey(const ValueKey('hamsterZombieIdentity0'));
    final icon = find.byKey(const ValueKey('hamsterZombieIcon0'));
    final actions = find.byKey(const ValueKey('hamsterZombieActions0'));
    await tester.ensureVisible(identity);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(addButton).top,
      greaterThanOrEqualTo(tester.getRect(heading).bottom),
    );
    expect(
      tester.getRect(addButton).left,
      closeTo(tester.getRect(heading).left, 1),
    );
    expect(
      (tester.getRect(actions).center.dy - tester.getRect(icon).center.dy)
          .abs(),
      lessThan(1),
    );
    expect(
      tester.getRect(identity).top,
      greaterThanOrEqualTo(tester.getRect(icon).bottom),
    );
    final wrappingBehavior = tester.widget<Text>(
      find.text('Смена ряда при столкновении'),
    );
    expect(wrappingBehavior.maxLines, isNull);
    expect(wrappingBehavior.overflow, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tutorial intro conflict and help sections are localized', (
    tester,
  ) async {
    late List<Pair<String, String>> conflicts;
    late AppLocalizations zh;
    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) {
            zh = AppLocalizations.of(context)!;
            conflicts = ConflictRegistry.getActiveConflicts(context, const {
              'IntroSingleHandedProperties',
              'StandardLevelIntroProperties',
            });
            return const SizedBox.shrink();
          },
        ),
        locale: const Locale('zh'),
      ),
    );

    expect(conflicts, hasLength(1));
    expect(conflicts.single.second, '单枪匹马教程与转场模块存在冲突，同时使用会导致开局时的转场效果异常。');
    expect(zh.dinoTreadPreview, '可能践踏区域预览');
    expect(
      lookupAppLocalizations(const Locale('en')).dinoTreadPreview,
      'Possible stomp area preview',
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).dinoTreadPreview,
      'Предпросмотр возможной области удара',
    );
    expect(
      lookupAppLocalizations(
        const Locale('en'),
      ).hamsterballBehaviorSummary('2 = changes lane after hitting a plant'),
      'Behavior: 2 = changes lane after hitting a plant',
    );
    expect(zh.singleHandedTutorialHelpPromptsTitle, '教程提示');
    expect(zh.singleHandedTutorialHelpWaveTitle, '导弹出现波次');
    expect(zh.hamsterballBehaviorDetailUniform, '保持匀速运动');
    expect(zh.hamsterballBehaviorDetailSlowdown, '初始快，碰到植物后变慢');
    expect(zh.hamsterballBehaviorDetailChangeLane, '碰到植物会换行');
    expect(zh.hamsterballHelpOverviewBody, contains('在十二周年秘境中引入中文版的突袭事件'));
    expect(zh.singleHandedTutorialHelpWaveBody, contains('必须要搭配「单枪匹马」模块才会生效'));
  });
}
