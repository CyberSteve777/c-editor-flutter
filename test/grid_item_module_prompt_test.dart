import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/grid_item_module_prompt.dart';
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
  test('regular grid item assets omit the steam smoke manhole', () {
    final raw =
        jsonDecode(File('assets/resources/GridItems.json').readAsStringSync())
            as List<dynamic>;
    final typeNames = raw
        .map((item) => (item as Map<String, dynamic>)['typeName'])
        .toSet();

    expect(typeNames, isNot(contains('SmokeManhole')));
    expect(typeNames, isNot(contains('SteamManhole')));
  });

  test('Zomboss speaker follows the weapon stand in regular grid items', () {
    final raw =
        jsonDecode(File('assets/resources/GridItems.json').readAsStringSync())
            as List<dynamic>;
    final items = raw.cast<Map<String, dynamic>>();
    final armrackIndex = items.indexWhere(
      (item) => item['typeName'] == 'armrack',
    );
    final speakerIndex = items.indexWhere(
      (item) => item['typeName'] == 'speaker_zomboss',
    );

    expect(speakerIndex, armrackIndex + 1);
    expect(items[speakerIndex]['category'], 'scene');
    expect(items[speakerIndex]['icon'], 'speaker_zomboss.webp');
  });

  test('Player House tombstone preset follows the PvZ1 tombstone', () {
    final raw =
        jsonDecode(File('assets/resources/GridItems.json').readAsStringSync())
            as List<dynamic>;
    final items = raw.cast<Map<String, dynamic>>();
    final pvz1Index = items.indexWhere(
      (item) => item['typeName'] == 'pvz1grid',
    );
    final memoIndex = items.indexWhere(
      (item) => item['typeName'] == 'gravestone_tutorial',
    );
    final memo = items[memoIndex];

    expect(memoIndex, pvz1Index + 1);
    expect(memo['category'], 'scene');
    expect(memo['source'], 'custom');
    expect(memo['gameTypeName'], 'gravestone_egypt_memo');
    expect(memo['gridItemTypeAlias'], 'gravestone_memo');
    expect(memo['exclusivePresetGroup'], 'gravestone_egypt_memo');
    expect(memo['icon'], 'gravestone_tutorial.webp');
    expect(
      File('assets/images/griditems/gravestone_tutorial.webp').existsSync(),
      isTrue,
    );
    final zhNames =
        jsonDecode(File('assets/l10n/resource_zh.json').readAsStringSync())
            as Map<String, dynamic>;
    expect(zhNames['griditem_gravestone_egypt_memo'], '庭院墓碑');
    expect(zhNames, isNot(contains('griditem_gravestone_tutorial')));
    expect((memo['companionObjects'] as List<dynamic>).single, {
      'objclass': 'GridItemGravestonePropertySheet',
      'aliases': ['GridItemGravestoneDefaultMemo'],
      'objdata': {
        'Hitpoints': 700,
        'HitRectOffsetX': 15,
        'HitRectOffsetWidth': -30,
        'GridItemLevelStats': [
          {'HitPointsLevel': 1},
          {'HitPointsLevel': 2},
          {'HitPointsLevel': 3},
          {'HitPointsLevel': 4},
          {'HitPointsLevel': 5},
        ],
        'ArtCenter': {'x': 98, 'y': 127},
        'PopAnim': 'POPANIM_GRAVESTONES_TUTORIAL_GRAVESTONE',
        'DamageStateCount': 5,
        'BreakEffect': 'POPANIM_EFFECTS_TOMBSTONE_TUTORIAL_DAMAGE',
        'BreakEffectSound': 'Play_Zomb_Egypt_Grave_Crumble',
      },
    });
  });

  for (final typeName in const [
    'renai_roller',
    'renai_tile_left',
    'renai_tile_right',
  ]) {
    testWidgets('$typeName offers to add the Renaissance module', (
      tester,
    ) async {
      String? addedModule;
      bool? selectionProceeds;
      final level = PvzLevelFile(objects: []);

      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                selectionProceeds = await confirmGridItemModuleRequirements(
                  context,
                  typeName: typeName,
                  levelFile: level,
                  onAddModule: (objClass) => addedModule = objClass,
                );
              },
              child: const Text('选择'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('选择'));
      await tester.pumpAndSettle();
      expect(find.text('复兴圆环需要搭配「复兴时代模块」才能正常生效。是否添加？'), findsOneWidget);

      await tester.tap(find.text('添加'));
      await tester.pumpAndSettle();
      expect(addedModule, 'RenaiModuleProperties');
      expect(selectionProceeds, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('existing Renaissance module skips the dependency dialog', (
    tester,
  ) async {
    String? addedModule;
    bool? selectionProceeds;
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['RenaiModule'],
          objClass: 'RenaiModuleProperties',
          objData: RenaiModulePropertiesData().toJson(),
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              selectionProceeds = await confirmGridItemModuleRequirements(
                context,
                typeName: 'renai_roller',
                levelFile: level,
                onAddModule: (objClass) => addedModule = objClass,
              );
            },
            child: const Text('选择'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('选择'));
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
    expect(addedModule, isNull);
    expect(selectionProceeds, isTrue);
    expect(tester.takeException(), isNull);
  });
}
