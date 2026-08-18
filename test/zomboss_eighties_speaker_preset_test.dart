import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_eighties_speaker_presets.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_mech_battle_tab.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: home),
  );
}

PvzObject _levelDefinition({List<String> modules = const []}) {
  return PvzObject(
    aliases: const ['LevelDefinition'],
    objClass: 'LevelDefinition',
    objData: LevelDefinitionData(modules: modules).toJson(),
  );
}

PvzObject _battle(String variation) {
  return PvzObject(
    aliases: const ['ZombossBattle'],
    objClass: 'ZombossBattleModuleProperties',
    objData: ZombossMechBattleModuleData(zombossMechType: variation).toJson(),
  );
}

PvzObject _intro() {
  return PvzObject(
    aliases: const ['ZombossIntro'],
    objClass: 'ZombossBattleIntroProperties',
    objData: ZombossMechBattleIntroData().toJson(),
  );
}

InitialGridItemEntryData _gridItems(PvzLevelFile level) {
  final object = level.objects.singleWhere(
    (entry) => entry.objClass == ZombossEightiesSpeakerPresets.moduleObjClass,
  );
  return InitialGridItemEntryData.fromJson(
    Map<String, dynamic>.from(object.objData as Map),
  );
}

Future<void> _selectBase(WidgetTester tester, String baseId) async {
  await tester.tap(find.byType(ZombossMechBaseCard));
  await tester.pumpAndSettle();
  final card = find.byWidgetPredicate(
    (widget) => widget is ZombossMechBaseCard && widget.baseId == baseId,
  );
  if (card.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      card,
      300,
      scrollable: find.byType(Scrollable).last,
    );
  }
  expect(card, findsOneWidget);
  await tester.ensureVisible(card);
  await tester.tap(card);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('speaker preset creates and registers the initial grid item module', () {
    final definition = _levelDefinition();
    final level = PvzLevelFile(objects: [definition]);

    final module = ZombossEightiesSpeakerPresets.applyToLevel(level);
    final placements = _gridItems(level).placements;

    expect(module.aliases, ['GridItemPlacement']);
    expect(placements, hasLength(5));
    expect(
      placements.map((item) => (item.gridX, item.gridY, item.typeName)).toSet(),
      {
        for (var row = 0; row < 5; row++)
          (6, row, ZombossEightiesSpeakerPresets.speakerTypeName),
      },
    );
    expect(
      LevelDefinitionData.fromJson(
        Map<String, dynamic>.from(definition.objData as Map),
      ).modules,
      contains('RTID(GridItemPlacement@CurrentLevel)'),
    );
  });

  test('speaker preset replaces its cells and preserves later user edits', () {
    final module = PvzObject(
      aliases: const ['ExistingGridItems'],
      objClass: ZombossEightiesSpeakerPresets.moduleObjClass,
      objData: InitialGridItemEntryData(
        fieldName: 'GridItems',
        placements: [
          InitialGridItemData(gridX: 6, gridY: 0, typeName: 'gravestone_dark'),
          InitialGridItemData(gridX: 2, gridY: 2, typeName: 'flowerpot'),
        ],
      ).toJson(),
    );
    final level = PvzLevelFile(objects: [_levelDefinition(), module]);

    ZombossEightiesSpeakerPresets.applyToLevel(level);
    var data = _gridItems(level);
    expect(data.fieldName, 'GridItems');
    expect(
      data.placements.where(
        (item) =>
            item.gridX == 6 &&
            item.gridY == 0 &&
            item.typeName == 'gravestone_dark',
      ),
      isEmpty,
    );
    expect(
      data.placements.any(
        (item) =>
            item.gridX == 2 && item.gridY == 2 && item.typeName == 'flowerpot',
      ),
      isTrue,
    );

    data.placements.removeWhere((item) => item.gridX == 6 && item.gridY == 1);
    data.placements.add(
      InitialGridItemData(gridX: 6, gridY: 1, typeName: 'flowerpot'),
    );
    data.placements.add(
      InitialGridItemData(
        gridX: 1,
        gridY: 1,
        typeName: ZombossEightiesSpeakerPresets.speakerTypeName,
      ),
    );
    module.objData = data.toJson();

    expect(ZombossEightiesSpeakerPresets.removeFromLevel(level), 4);
    data = _gridItems(level);
    expect(
      data.placements.any(
        (item) =>
            item.gridX == 6 && item.gridY == 1 && item.typeName == 'flowerpot',
      ),
      isTrue,
    );
    expect(
      data.placements.any(
        (item) =>
            item.gridX == 1 &&
            item.gridY == 1 &&
            item.typeName == ZombossEightiesSpeakerPresets.speakerTypeName,
      ),
      isTrue,
    );
  });

  testWidgets('selecting the Eighties base offers and applies speakers', (
    tester,
  ) async {
    final battle = _battle('zombossmech_egypt');
    final level = PvzLevelFile(objects: [_levelDefinition(), battle, _intro()]);

    await tester.pumpWidget(
      _localizedApp(ZombossMechBattleTab(levelFile: level, onChanged: () {})),
    );
    await tester.pumpAndSettle();
    await _selectBase(tester, ZombossEightiesSpeakerPresets.baseId);

    expect(
      find.text(
        '摇滚年代僵王的第一阶段通常需要场上的专属音响配合其技能，因此官方关卡会在地图指定位置预置音响。您即将切换至摇滚年代僵王，是否要按照官方关卡的位置一并预置这些音响？',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('applyEightiesSpeakerPreset')));
    await tester.pumpAndSettle();

    expect(
      ZombossMechBattleModuleData.fromJson(
        Map<String, dynamic>.from(battle.objData as Map),
      ).zombossMechType,
      'zombossmech_eighties',
    );
    expect(_gridItems(level).placements, hasLength(5));
  });

  testWidgets('leaving the Eighties base can remove only preset speakers', (
    tester,
  ) async {
    final battle = _battle('zombossmech_eighties');
    final level = PvzLevelFile(objects: [_levelDefinition(), battle, _intro()]);
    ZombossEightiesSpeakerPresets.applyToLevel(level);

    await tester.pumpWidget(
      _localizedApp(ZombossMechBattleTab(levelFile: level, onChanged: () {})),
    );
    await tester.pumpAndSettle();
    await _selectBase(tester, 'ZombieZombossMech_Egypt');

    expect(find.textContaining('是否删除此前在官方位置预置的专属音响'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('removeEightiesSpeakerPreset')));
    await tester.pumpAndSettle();

    expect(ZombossEightiesSpeakerPresets.hasPresetSpeakers(level), isFalse);
    expect(
      ZombossMechBattleModuleData.fromJson(
        Map<String, dynamic>.from(battle.objData as Map),
      ).zombossMechType,
      'zombossmech_egypt',
    );
  });

  testWidgets('Eighties base exposes the initial grid item shortcut', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    var opened = false;
    final level = PvzLevelFile(
      objects: [_levelDefinition(), _battle('zombossmech_eighties'), _intro()],
    );

    await tester.pumpWidget(
      _localizedApp(
        ZombossMechBattleTab(
          levelFile: level,
          onChanged: () {},
          onOpenInitialGridItems: () => opened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final shortcut = find.byKey(
      const ValueKey('openInitialGridItemsFromEighties'),
    );
    await tester.scrollUntilVisible(
      shortcut,
      100,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(shortcut);
    expect(opened, isTrue);
  });
}
