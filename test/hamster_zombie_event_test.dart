import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/events/hamster_zombie_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
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
        find.text(
          'Behavior (Behavior): 2 = changes lane after hitting a plant',
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Switch properties'));
      expect(find.text('Switch properties'), findsOneWidget);
    },
  );

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
    expect(zh.singleHandedTutorialHelpPromptsTitle, '教程提示');
    expect(zh.singleHandedTutorialHelpWaveTitle, '导弹出现波次');
    expect(zh.hamsterballBehaviorDetailUniform, '保持匀速运动');
    expect(zh.hamsterballBehaviorDetailSlowdown, '初始快，碰到植物后变慢');
    expect(zh.hamsterballBehaviorDetailChangeLane, '碰到植物会换行');
    expect(zh.hamsterballHelpOverviewBody, contains('在十二周年秘境中引入中文版的突袭事件'));
    expect(zh.singleHandedTutorialHelpWaveBody, contains('必须要搭配「单枪匹马」模块才会生效'));
  });
}
