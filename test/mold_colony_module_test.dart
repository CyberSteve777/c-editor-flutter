import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/mold_colony_challenge_screen.dart';

void main() {
  group('MoldColonyChallengeProps models', () {
    test('matches the level JSON structure', () {
      final data = MoldColonyChallengePropsData.fromJson({
        'Description': '',
        'Locations': 'RTID(Mold@CurrentLevel)',
      });

      expect(data.toJson(), {
        'Description': '',
        'Locations': 'RTID(Mold@CurrentLevel)',
      });
    });

    test('normalizes BoardGridMapProps to the requested lawn size', () {
      final data = BoardGridMapPropsData.fromJson({
        'Values': [
          [1, 0, 2],
          [0],
        ],
      }).normalized(rows: 3, columns: 2);

      expect(data.values, [
        [1, 0],
        [0, 0],
        [0, 0],
      ]);
    });
  });

  group('MoldColonyModuleUtils', () {
    test('detects and repairs a LevelModules Locations reference', () {
      final module = PvzObject(
        aliases: const ['DoNotPlantBeforeLine'],
        objClass: MoldColonyModuleUtils.moduleObjClass,
        objData: {'Description': '', 'Locations': 'RTID(Mold@LevelModules)'},
      );
      final layout = PvzObject(
        aliases: const ['Mold'],
        objClass: MoldColonyModuleUtils.layoutObjClass,
        objData: BoardGridMapPropsData.empty().toJson(),
      );
      final level = PvzLevelFile(objects: [module, layout]);
      final before = MoldColonyChallengePropsData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      );

      expect(MoldColonyModuleUtils.hasValidLayoutLink(level, before), isFalse);

      final alias = MoldColonyModuleUtils.ensureCurrentLevelLayout(
        levelFile: level,
        moduleObject: module,
      );
      final after = MoldColonyChallengePropsData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      );

      expect(alias, 'Mold');
      expect(after.locations, 'RTID(Mold@CurrentLevel)');
      expect(MoldColonyModuleUtils.hasValidLayoutLink(level, after), isTrue);
      expect(
        level.objects.where(
          (object) => object.objClass == MoldColonyModuleUtils.layoutObjClass,
        ),
        hasLength(1),
      );
    });

    test('creates a unique current-level layout when Mold is occupied', () {
      final module = PvzObject(
        aliases: const ['DoNotPlantBeforeLine'],
        objClass: MoldColonyModuleUtils.moduleObjClass,
        objData: MoldColonyChallengePropsData().toJson(),
      );
      final occupied = PvzObject(
        aliases: const ['Mold'],
        objClass: 'UnrelatedObject',
        objData: const <String, dynamic>{},
      );
      final level = PvzLevelFile(objects: [module, occupied]);

      final alias = MoldColonyModuleUtils.ensureCurrentLevelLayout(
        levelFile: level,
        moduleObject: module,
      );

      expect(alias, 'Mold_1');
      expect(
        (module.objData as Map<String, dynamic>)['Locations'],
        'RTID(Mold_1@CurrentLevel)',
      );
      final layout = level.objects.singleWhere(
        (object) => object.aliases?.contains('Mold_1') == true,
      );
      final values = (layout.objData as Map<String, dynamic>)['Values'] as List;
      expect(values, hasLength(5));
      expect(values.every((row) => (row as List).length == 9), isTrue);
    });

    test('removes an unreferenced owned layout', () {
      final layout = PvzObject(
        aliases: const ['Mold'],
        objClass: MoldColonyModuleUtils.layoutObjClass,
        objData: BoardGridMapPropsData.empty().toJson(),
      );
      final level = PvzLevelFile(objects: [layout]);

      MoldColonyModuleUtils.removeUnreferencedLayout(
        levelFile: level,
        locations: 'RTID(Mold@CurrentLevel)',
      );

      expect(level.objects, isEmpty);
    });
  });

  test('module is listed between protected items and pirate planks', () {
    final keys = ModuleRegistry.registry.keys.toList();
    final moldIndex = keys.indexOf(MoldColonyModuleUtils.moduleObjClass);

    expect(
      keys.indexOf('ProtectTheGridItemChallengeProperties'),
      lessThan(moldIndex),
    );
    expect(moldIndex, lessThan(keys.indexOf('PiratePlankProperties')));

    final metadata = ModuleRegistry.getMetadata(
      MoldColonyModuleUtils.moduleObjClass,
    );
    expect(metadata.category, ModuleCategory.scene);
    expect(metadata.defaultAlias, 'DoNotPlantBeforeLine');
    expect(metadata.icon, Icons.grid_3x3);
    expect(metadata.assetIconPath, isNull);
    expect(metadata.initialData, {
      'Description': '',
      'Locations': 'RTID(Mold@CurrentLevel)',
    });
  });

  testWidgets('editor warns, repairs the link, and toggles layout cells', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['DoNotPlantBeforeLine'],
      objClass: MoldColonyModuleUtils.moduleObjClass,
      objData: {'Description': '', 'Locations': 'RTID(Mold@LevelModules)'},
    );
    final level = PvzLevelFile(objects: [module]);
    var changeCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MoldColonyChallengeScreen(
          rtid: 'RTID(DoNotPlantBeforeLine@CurrentLevel)',
          levelFile: level,
          onChanged: () => changeCount++,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('引用源为 LevelModules'), findsOneWidget);
    await tester.tap(find.text('一键修复关联至：Mold'));
    await tester.pumpAndSettle();

    expect(
      (module.objData as Map<String, dynamic>)['Locations'],
      'RTID(Mold@CurrentLevel)',
    );
    expect(find.text('当前值：RTID(Mold@CurrentLevel)'), findsOneWidget);
    expect(changeCount, 1);

    await tester.tap(find.bySemanticsLabel('R1:C1, 空地'));
    await tester.pump();

    final layout = level.objects.singleWhere(
      (object) => object.objClass == MoldColonyModuleUtils.layoutObjClass,
    );
    final values = (layout.objData as Map<String, dynamic>)['Values'] as List;
    expect((values.first as List).first, 1);
    expect(changeCount, 2);
  });
}
