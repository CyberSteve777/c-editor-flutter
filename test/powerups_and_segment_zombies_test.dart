import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/level_powerup_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('segment zombies use the matching one-part metadata and ordering', () {
    final zombies =
        (jsonDecode(File('assets/resources/Zombies.json').readAsStringSync())
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
    final byId = {for (final zombie in zombies) zombie['id'] as String: zombie};
    final ids = zombies.map((zombie) => zombie['id'] as String).toList();

    for (final pair in const [
      ('camel_segment', 'camel_onehump'),
      ('lny_camel_segment', 'lny_camel_onehump'),
      ('christmas_camel_segment', 'christmas_camel_onehump'),
    ]) {
      expect(ids.indexOf(pair.$1), ids.indexOf(pair.$2) - 1);
      expect(byId[pair.$1]!['tags'], byId[pair.$2]!['tags']);
      expect(byId[pair.$1]!['icon'], byId[pair.$2]!['icon']);
    }

    expect(byId['roman_segment'], isNotNull);
    expect(byId['roman_shield_almanac'], isNotNull);
    expect(
      byId['roman_segment']!['tags'],
      byId['roman_shield_almanac']!['tags'],
    );
    expect(
      byId['roman_segment']!['icon'],
      byId['roman_shield_almanac']!['icon'],
    );
  });

  test('segment zombie names are localized as requested', () {
    final zh =
        jsonDecode(File('assets/l10n/resource_zh.json').readAsStringSync())
            as Map<String, dynamic>;
    final en =
        jsonDecode(File('assets/l10n/resource_en.json').readAsStringSync())
            as Map<String, dynamic>;

    expect(zh['zombie_camel_segment'], '图鉴骆驼牌僵尸');
    expect(en['zombie_camel_segment'], 'Camel Zombies (segment)');
    expect(zh['zombie_roman_segment'], '单牌罗马盾牌僵尸');
    expect(zh['zombie_roman_shield_almanac'], '图鉴罗马盾牌僵尸');
    expect(en['zombie_roman_shield_almanac'], 'Roman Shield Zombie (Almanac)');
  });

  test('Power Ups defaults and round-trip match the game schema', () {
    final data = LevelPowerupModulePropertiesData();
    expect(data.toJson(), {
      'Powerups': [
        {'TypeName': 'powerupflickzombie', 'FreeUseCount': 3},
        {'TypeName': 'powerupwizardfinger', 'FreeUseCount': 3},
        {'TypeName': 'poweruppinchzombie', 'FreeUseCount': 3},
      ],
    });

    final decoded = LevelPowerupModulePropertiesData.fromJson({
      'Powerups': [
        {'TypeName': 'powerupwizardfinger', 'FreeUseCount': 7},
      ],
    });
    expect(decoded.toJson(), {
      'Powerups': [
        {'TypeName': 'powerupwizardfinger', 'FreeUseCount': 7},
      ],
    });
    expect(decoded.entryFor('powerupwizardfinger').freeUseCount, 7);
    expect(decoded.entryFor('powerupflickzombie').freeUseCount, 3);
  });

  test('Power Ups success guidance covers processes that hold the package', () {
    final zh = lookupAppLocalizations(const Locale('zh'));
    final en = lookupAppLocalizations(const Locale('en'));

    expect(
      zh.powerUpsOrderInfo,
      '游戏中的金手指会按照此处的顺序排列。拖动 ⋮⋮ 可调整顺序。将金手指从列表中移除后，该金手指将不会在游戏中出现；需要时可在本模块中重新添加。',
    );
    expect(zh.exportSuccessMessage('dynamic.rsb.smf'), contains('彻底关闭游戏进程'));
    expect(
      zh.exportSuccessMessage('dynamic.rsb.smf'),
      contains('正在占用目标目录的文件管理器'),
    );
    expect(
      en.exportSuccessMessage('dynamic.rsb.smf'),
      contains('fully close the game process'),
    );
    expect(
      en.exportSuccessMessage('dynamic.rsb.smf'),
      contains('file manager currently accessing the target directory'),
    );
  });

  test('Power Ups is a gimmick immediately before Rocket Flick', () {
    final keys = ModuleRegistry.registry.keys.toList();
    final powerups = keys.indexOf('LevelPowerupModuleProperties');
    final rocketFlick = keys.indexOf('RocketZombieFlickModuleProperties');
    final metadata = ModuleRegistry.getMetadata('LevelPowerupModuleProperties');

    expect(powerups, rocketFlick - 1);
    expect(metadata.category, ModuleCategory.gimmick);
    expect(metadata.defaultAlias, 'LevelPowerups');
    expect(metadata.initialData, LevelPowerupModulePropertiesData().toJson());
  });

  testWidgets('Power Ups editor writes the selected free-use count', (
    tester,
  ) async {
    final object = PvzObject(
      aliases: const ['LevelPowerups'],
      objClass: 'LevelPowerupModuleProperties',
      objData: LevelPowerupModulePropertiesData().toJson(),
    );
    final level = PvzLevelFile(objects: [object]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelPowerupModuleScreen(
          rtid: 'RTID(LevelPowerups@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Tap or drag across zombies to unleash a powerful electric shock that continuously damages every zombie it touches.',
      ),
      findsNothing,
    );

    final field = find.byKey(
      const ValueKey('powerupFreeUseCount_powerupwizardfinger'),
    );
    expect(field, findsOneWidget);
    await tester.enterText(field, '5');
    await tester.pump();

    final json = Map<String, dynamic>.from(object.objData as Map);
    final entries = (json['Powerups'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    expect(
      entries.singleWhere(
        (entry) => entry['TypeName'] == 'powerupwizardfinger',
      )['FreeUseCount'],
      5,
    );
  });

  testWidgets('Power Ups count label moves above the field when needed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final object = PvzObject(
      aliases: const ['LevelPowerups'],
      objClass: 'LevelPowerupModuleProperties',
      objData: LevelPowerupModulePropertiesData().toJson(),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          );
        },
        home: LevelPowerupModuleScreen(
          rtid: 'RTID(LevelPowerups@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fieldFinder = find.byKey(
      const ValueKey('powerupFreeUseCount_powerupflickzombie'),
    );
    await tester.ensureVisible(fieldFinder);
    final field = tester.widget<TextField>(fieldFinder);
    expect(field.decoration?.labelText, isNull);
    expect(find.text('Бесплатные применения (FreeUseCount)'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Power Ups can be reordered, removed, and added back', (
    tester,
  ) async {
    final object = PvzObject(
      aliases: const ['LevelPowerups'],
      objClass: 'LevelPowerupModuleProperties',
      objData: LevelPowerupModulePropertiesData().toJson(),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelPowerupModuleScreen(
          rtid: 'RTID(LevelPowerups@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('powerupDragHandle_powerupflickzombie')),
      findsOneWidget,
    );
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    list.onReorderItem!(0, 2);
    await tester.pump();

    Map<String, dynamic> json() =>
        Map<String, dynamic>.from(object.objData as Map);
    List<String> order() => (json()['Powerups'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((entry) => entry['TypeName'] as String)
        .toList();

    expect(order(), [
      'powerupwizardfinger',
      'poweruppinchzombie',
      'powerupflickzombie',
    ]);

    await tester.tap(
      find.byKey(const ValueKey('powerupDelete_powerupflickzombie')),
    );
    await tester.pumpAndSettle();
    expect(order(), ['powerupwizardfinger', 'poweruppinchzombie']);

    await tester.tap(find.byKey(const ValueKey('powerupAddButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('powerupAddDialog')), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('powerupAddOption_powerupflickzombie')),
    );
    await tester.pumpAndSettle();
    expect(order(), [
      'powerupwizardfinger',
      'poweruppinchzombie',
      'powerupflickzombie',
    ]);
    expect((json()['Powerups'] as List<dynamic>).last, {
      'TypeName': 'powerupflickzombie',
      'FreeUseCount': 3,
    });
  });

  testWidgets('Power Ups add choices stay clear of Cancel on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final object = PvzObject(
      aliases: const ['LevelPowerups'],
      objClass: 'LevelPowerupModuleProperties',
      objData: LevelPowerupModulePropertiesData(powerups: const []).toJson(),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          );
        },
        home: LevelPowerupModuleScreen(
          rtid: 'RTID(LevelPowerups@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('powerupAddButton')));
    await tester.pumpAndSettle();
    final pinchOption = find.byKey(
      const ValueKey('powerupAddOption_poweruppinchzombie'),
    );
    final cancelButton = find.widgetWithText(TextButton, 'Cancel');
    await tester.ensureVisible(pinchOption);
    await tester.pumpAndSettle();

    expect(
      tester.getRect(pinchOption).bottom,
      lessThanOrEqualTo(tester.getRect(cancelButton).top),
    );
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    expect((object.objData as Map<String, dynamic>)['Powerups'], isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Power Ups help explains that list order controls game order', (
    tester,
  ) async {
    final object = PvzObject(
      aliases: const ['LevelPowerups'],
      objClass: 'LevelPowerupModuleProperties',
      objData: LevelPowerupModulePropertiesData().toJson(),
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LevelPowerupModuleScreen(
          rtid: 'RTID(LevelPowerups@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [object]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('• Order'), findsOneWidget);
    expect(find.textContaining('order shown here'), findsOneWidget);
  });
}
