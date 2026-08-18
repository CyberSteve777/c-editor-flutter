import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/glacier_module_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_rain_properties_screen.dart';
import 'package:c_editor/screens/editor/tabs/vase_breaker_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('Ice Chunk adds a separately weighted no-zombie outcome', (
    tester,
  ) async {
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

    await tester.tap(find.text('添加内容').first);
    await tester.pumpAndSettle();

    expect(find.text('添加冰堆内容'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('editorChoiceOption_zombie')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('editorChoiceOption_empty')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('editorChoiceOption_empty')));
    await tester.pumpAndSettle();

    final saved = GlacierModulePropertiesData.fromJson(
      Map<String, dynamic>.from(module.objData as Map),
    );
    expect(saved.zombieSpawnData.first.entries, hasLength(1));
    expect(saved.zombieSpawnData.first.entries.single.typeName, isEmpty);
    expect(find.text('冰堆破碎后不出现僵尸'), findsOneWidget);
    expect(find.text('切换僵尸'), findsNothing);
    expect(find.byKey(const ValueKey('w__1')), findsOneWidget);
    expect(find.byKey(const ValueKey('lv__0')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Seed Rain keeps content choice cards compact', (tester) async {
    final module = PvzObject(
      aliases: const ['SeedRain'],
      objClass: 'SeedRainProperties',
      objData: SeedRainPropertiesData().toJson(),
    );
    final level = PvzLevelFile(objects: [module]);

    await tester.pumpWidget(
      _localizedApp(
        SeedRainPropertiesScreen(
          rtid: 'RTID(SeedRain@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('添加掉落物品'));
    await tester.pumpAndSettle();

    expect(find.text('添加种子雨内容'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('editorChoiceOption_plant')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('editorChoiceOption_zombie')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('editorChoiceOption_collectable')),
      findsOneWidget,
    );
    expect(find.textContaining('植物卡片'), findsNothing);
    expect(find.textContaining('僵尸卡片'), findsNothing);
    expect(find.textContaining('能量豆'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Vasebreaker keeps add-content cards compact and title icon-free',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final module = PvzObject(
        aliases: const ['VaseBreakerPreset'],
        objClass: 'VaseBreakerPresetProperties',
        objData: VaseBreakerPresetData().toJson(),
      );

      await tester.pumpWidget(
        _localizedApp(
          Scaffold(
            body: VaseBreakerTab(
              levelFile: PvzLevelFile(objects: [module]),
              onChanged: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('罐子列表'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      final titleRow = find.ancestor(
        of: find.text('罐子列表'),
        matching: find.byType(Row),
      );
      await tester.tap(
        find.descendant(of: titleRow, matching: find.byIcon(Icons.add)),
      );
      await tester.pumpAndSettle();

      expect(find.text('添加罐子'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('editorChoiceOption_plant')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('editorChoiceOption_zombie')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('editorChoiceOption_collectable')),
        findsOneWidget,
      );
      expect(find.textContaining('选择一种植物'), findsNothing);
      expect(find.textContaining('选择一种僵尸'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byIcon(Icons.inventory_2_outlined),
        ),
        findsNothing,
      );
      expect(
        tester
            .getSize(find.byKey(const ValueKey('editorChoiceOption_plant')))
            .width,
        greaterThan(240),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Vasebreaker stacks item actions below text on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final module = PvzObject(
      aliases: const ['VaseBreakerPreset'],
      objClass: 'VaseBreakerPresetProperties',
      objData: VaseBreakerPresetData(
        vases: [VaseDefinition(zombieTypeName: 'tutorial', count: 5)],
      ).toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        Scaffold(
          body: VaseBreakerTab(
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.byKey(const ValueKey('vaseListItemTitle_0'));
    await tester.scrollUntilVisible(
      title,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final actions = find.byKey(const ValueKey('vaseListItemActions_0'));
    expect(tester.getSize(title).width, greaterThan(100));
    expect(
      tester.getTopLeft(actions).dy,
      greaterThan(tester.getTopLeft(title).dy),
    );
    expect(tester.takeException(), isNull);
  });
}
