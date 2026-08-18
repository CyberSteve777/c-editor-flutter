import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_mech_battle_tab.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
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

GlacierModulePropertiesData _glacierData(PvzLevelFile level) {
  final object = level.objects.singleWhere(
    (entry) => entry.objClass == 'GlacierModuleProperties',
  );
  return GlacierModulePropertiesData.fromJson(
    Map<String, dynamic>.from(object.objData as Map),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
    await ResourceNames.ensureLoaded();
  });

  test('official presets preserve empty outcomes and fractional weights', () {
    final rift = GlacierModulePresets.forVariation('zombossmech_iceage_rift')!;
    final data = rift.createData();

    expect(data.zombieSpawnData, hasLength(6));
    expect(data.zombieSpawnData[1].entries.first.typeName, isEmpty);
    expect(data.zombieSpawnData[1].entries.first.weight, 0.5);
    expect(data.zombieSpawnData[4].entries.first.weight, 0.5);

    final reopened = GlacierModulePropertiesData.fromJson(data.toJson());
    expect(reopened.zombieSpawnData[1].entries.first.typeName, isEmpty);
    expect(reopened.zombieSpawnData[1].entries.first.weight, 0.5);
    expect(
      GlacierModulePresets.forVariation(
        GlacierModulePresets.plantPuzzleVariation,
      ),
      isNull,
    );
    expect(
      GlacierModulePresets.forVariation(
        GlacierModulePresets.customVariation,
      )?.isBlank,
      isTrue,
    );

    final anniversary = GlacierModulePresets.forVariation(
      'zombossmech_iceage_12th',
    )!.createData();
    expect(
      anniversary.zombieSpawnData[1].entries
          .map((entry) => entry.typeName)
          .toList(),
      ['', 'iceage_weasel', 'iceage_dodo', 'iceage'],
    );
    expect(anniversary.zombieSpawnData[4].entries[1].typeName, 'iceage_dodo');
    expect(
      GlacierModulePresets.matches(
        anniversary,
        GlacierModulePresets.defaultPreset,
      ),
      isFalse,
    );
  });

  test('applying a preset creates and registers one Ice Chunk Module', () {
    final levelDefinition = _levelDefinition();
    final level = PvzLevelFile(objects: [levelDefinition]);

    GlacierModulePresets.applyToLevel(
      level,
      GlacierModulePresets.defaultPreset,
    );
    expect(
      level.objects.where(
        (entry) => entry.objClass == 'GlacierModuleProperties',
      ),
      hasLength(1),
    );
    expect(
      GlacierModulePresets.matches(
        _glacierData(level),
        GlacierModulePresets.defaultPreset,
      ),
      isTrue,
    );
    expect(
      LevelDefinitionData.fromJson(
        Map<String, dynamic>.from(levelDefinition.objData as Map),
      ).modules,
      contains('RTID(GlacierModule@CurrentLevel)'),
    );

    final rift = GlacierModulePresets.forVariation('zombossmech_iceage_rift')!;
    GlacierModulePresets.applyToLevel(level, rift);
    expect(
      level.objects.where(
        (entry) => entry.objClass == 'GlacierModuleProperties',
      ),
      hasLength(1),
    );
    expect(GlacierModulePresets.matches(_glacierData(level), rift), isTrue);
  });

  testWidgets(
    'Ice Chunk preset selector stays folded and confirms replacement',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final module = PvzObject(
        aliases: const ['GlacierModule'],
        objClass: 'GlacierModuleProperties',
        objData: GlacierModulePropertiesData.createDefault().toJson(),
      );
      final level = PvzLevelFile(objects: [module]);

      await tester.pumpWidget(
        _localizedApp(
          GlacierModuleScreen(
            rtid: 'RTID(GlacierModule@CurrentLevel)',
            levelFile: level,
            onChanged: () {},
            onBack: () {},
            onRequestZombieSelection: (_) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('冰河世界-第25天'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('glacierPresetSelector')));
      await tester.pumpAndSettle();
      expect(find.text('冰河世界-第25天'), findsOneWidget);

      await tester.tap(find.text('冰河世界-第25天'));
      await tester.pumpAndSettle();
      expect(find.text('切换冰堆预设'), findsOneWidget);
      expect(find.textContaining('当前6组冰堆配置将被替换'), findsOneWidget);

      await tester.tap(find.text('切换'));
      await tester.pumpAndSettle();
      expect(
        GlacierModulePresets.matches(
          _glacierData(level),
          GlacierModulePresets.defaultPreset,
        ),
        isTrue,
      );
    },
  );

  testWidgets('selecting the Ice Age base creates the Day 25 preset', (
    tester,
  ) async {
    final battle = _battle('zombossmech_egypt');
    final level = PvzLevelFile(objects: [_levelDefinition(), battle, _intro()]);

    await tester.pumpWidget(
      _localizedApp(ZombossMechBattleTab(levelFile: level, onChanged: () {})),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ZombossMechBaseCard));
    await tester.pumpAndSettle();

    final iceAgeCard = find.byWidgetPredicate(
      (widget) =>
          widget is ZombossMechBaseCard &&
          widget.baseId == GlacierModulePresets.iceAgeBaseId,
    );
    expect(iceAgeCard, findsOneWidget);
    await tester.ensureVisible(iceAgeCard);
    await tester.tap(iceAgeCard);
    await tester.pumpAndSettle();

    final battleData = ZombossMechBattleModuleData.fromJson(
      Map<String, dynamic>.from(battle.objData as Map),
    );
    expect(battleData.zombossMechType, GlacierModulePresets.defaultVariation);
    expect(
      GlacierModulePresets.matches(
        _glacierData(level),
        GlacierModulePresets.defaultPreset,
      ),
      isTrue,
    );
  });

  testWidgets('variation prompt applies Rift preset and shows custom codename', (
    tester,
  ) async {
    final battle = _battle(GlacierModulePresets.defaultVariation);
    final level = PvzLevelFile(objects: [_levelDefinition(), battle, _intro()]);
    GlacierModulePresets.applyToLevel(
      level,
      GlacierModulePresets.defaultPreset,
    );

    await tester.pumpWidget(
      _localizedApp(ZombossMechBattleTab(levelFile: level, onChanged: () {})),
    );
    await tester.pumpAndSettle();

    final picker = tester.widget<SeparatedOptionPickerField<String>>(
      find.byType(SeparatedOptionPickerField<String>),
    );
    expect(
      picker.items
          .singleWhere((item) => item.value == kZombossMechCustomVariationValue)
          .subtitle,
      GlacierModulePresets.customVariation,
    );
    await tester.tap(find.text('冰河世界-第25天'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('zombossmech_iceage_rift'),
      180,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('zombossmech_iceage_rift'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '冰河世界僵王通过灌注冰堆召唤僵尸，冰堆中出现的僵尸由专门的「冰堆模块」进行配置。您即将切换至冰河世界僵王的另一变体，是否要同时启用该变体在游戏原有关卡中使用的「冰堆模块」预设配置？',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('同时启用预设'));
    await tester.pumpAndSettle();
    final rift = GlacierModulePresets.forVariation('zombossmech_iceage_rift')!;
    expect(
      ZombossMechBattleModuleData.fromJson(
        Map<String, dynamic>.from(battle.objData as Map),
      ).zombossMechType,
      'zombossmech_iceage_rift',
    );
    expect(GlacierModulePresets.matches(_glacierData(level), rift), isTrue);
  });

  testWidgets(
    'Beplanted hides Ice Chunk shortcut and leaves warning to settings',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          _levelDefinition(),
          _battle(GlacierModulePresets.plantPuzzleVariation),
          _intro(),
        ],
      );

      await tester.pumpWidget(
        _localizedApp(
          ZombossMechBattleTab(
            levelFile: level,
            onChanged: () {},
            onOpenGlacierModule: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('iceAgePlantPuzzleWarning')),
        findsNothing,
      );
      expect(find.text('前往设置冰堆模块'), findsNothing);
    },
  );
}
