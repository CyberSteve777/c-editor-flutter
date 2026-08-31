import 'dart:typed_data';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_dialog.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/level_preview_widgets.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart'
    show CustomResourceBadge;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _preview(PvzLevelFile level) {
  if (!level.objects.any((object) => object.objClass == 'LevelDefinition')) {
    level.objects.insert(
      0,
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData().toJson(),
      ),
    );
  }
  final host = PluginHostImpl(
    pluginId: 'team.international2c.level_preview',
    assets: MemoryCPluginAssets(const <String, Uint8List>{}),
    registry: PluginScreenRegistry(),
  );
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LevelPreviewDialog(
      host: host,
      levelFile: level,
      parsed: LevelParser.parseLevel(level),
      fileName: 'grid_items.json',
      onBack: () {},
    ),
  );
}

PvzObject _customGridItemType(String id) {
  return switch (id) {
    'armrack' => PvzObject(
      aliases: const ['armrack'],
      objClass: 'GridItemType',
      objData: const <String, dynamic>{
        'TypeName': 'armrack',
        'GridItemClass': 'GridItemArmrack',
        'Properties': 'RTID(GridItemArmrackDefault@PropertySheets)',
      },
    ),
    'energyGrid' => PvzObject(
      aliases: const ['energyGrid'],
      objClass: 'GridItemType',
      objData: const <String, dynamic>{
        'TypeName': 'energyGrid',
        'GridItemClass': 'GridItemEnergyGrid',
        'Properties': 'RTID(GridItemEnergyGridDefault@PropertySheets)',
      },
    ),
    _ => throw ArgumentError.value(id),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);
  });

  testWidgets('bronze matrix statues use their corresponding zombie icons', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['BronzeStatues'],
          objClass: 'BronzeProperties',
          objData: const <String, dynamic>{
            'data': [
              {
                'itemList': [
                  {'mX': 7, 'mY': 0, 'spawnTime': 60, 'type': 'strength'},
                  {'mX': 8, 'mY': 1, 'spawnTime': 60, 'type': 'mage'},
                  {'mX': 7, 'mY': 2, 'spawnTime': 60, 'type': 'agile'},
                ],
              },
            ],
          },
        ),
      ],
    );

    await tester.pumpWidget(_preview(level));
    await tester.pumpAndSettle();

    for (final id in const [
      'kongfu_strong_bronze',
      'kongfu_magic_bronze',
      'kongfu_agile_bronze',
    ]) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is ZombieIcon && widget.id == id && widget.isGrid,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) => widget is GridItemIcon && widget.id == id,
        ),
        findsNothing,
      );
    }
  });

  testWidgets(
    'overview separates dedicated-module and generic custom grid items',
    (tester) async {
      final level = PvzLevelFile(
        objects: [
          _customGridItemType('armrack'),
          _customGridItemType('energyGrid'),
          PvzObject(
            aliases: const ['InitialGridItems'],
            objClass: 'InitialGridItemProperties',
            objData: const <String, dynamic>{
              'InitialGridItemPlacements': [
                {'GridX': 1, 'GridY': 0, 'TypeName': 'armrack'},
                {'GridX': 2, 'GridY': 0, 'TypeName': 'energyGrid'},
              ],
            },
          ),
          PvzObject(
            aliases: const ['Armrack'],
            objClass: 'ArmrackProperties',
            objData: const <String, dynamic>{
              'Overrides': [
                {
                  'wave': 2,
                  'itemList': [
                    {'mX': 3, 'mY': 0, 'type': 'armrack'},
                  ],
                },
              ],
            },
          ),
          PvzObject(
            aliases: const ['EnergyGrid'],
            objClass: 'EnergyGridProperties',
            objData: const <String, dynamic>{
              'Overrides': [
                {
                  'wave': 3,
                  'itemList': [
                    {'mX': 4, 'mY': 0},
                  ],
                },
              ],
            },
          ),
        ],
      );

      await tester.pumpWidget(_preview(level));
      await tester.pumpAndSettle();

      for (final id in const ['armrack', 'energyGrid']) {
        final dedicatedModule = find.byKey(
          ValueKey('levelOverviewGridItem_${id}_dedicatedModule'),
        );
        final genericCustom = find.byKey(
          ValueKey('levelOverviewGridItem_${id}_standard'),
        );

        expect(dedicatedModule, findsOneWidget);
        expect(genericCustom, findsOneWidget);
        expect(
          find.descendant(
            of: dedicatedModule,
            matching: find.byType(CustomResourceBadge),
          ),
          findsNothing,
        );
        expect(
          find.descendant(
            of: genericCustom,
            matching: find.byType(CustomResourceBadge),
          ),
          findsOneWidget,
        );
      }
    },
  );
}
