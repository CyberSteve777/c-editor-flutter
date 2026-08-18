import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('level overview tunnel variants', () {
    test('recognizes expedition tiles by alias or brick map index', () {
      final byAlias = PvzObject(
        aliases: const ['SouDaCheTunnelDefendDefault'],
        objClass: 'TunnelDefendModuleProperties',
        objData: const <String, dynamic>{'BrickMapIndex': 1},
      );
      final byData = PvzObject(
        aliases: const ['CustomExpeditionTiles'],
        objClass: 'TunnelDefendModuleProperties',
        objData: const <String, dynamic>{'BrickMapIndex': 3},
      );
      final regular = PvzObject(
        aliases: const ['TunnelDefend'],
        objClass: 'TunnelDefendModuleProperties',
        objData: const <String, dynamic>{'BrickMapIndex': 1},
      );

      expect(isExpeditionTilesModuleObject(byAlias), isTrue);
      expect(isExpeditionTilesModuleObject(byData), isTrue);
      expect(isExpeditionTilesModuleObject(regular), isFalse);
    });

    test('keeps regular pathways and expedition tiles separate', () {
      final regular = PvzObject(
        aliases: const ['TunnelDefend'],
        objClass: 'TunnelDefendModuleProperties',
        objData: const <String, dynamic>{
          'BrickMapIndex': 1,
          'Roads': [
            {'GridX': 1, 'GridY': 2, 'Img': 'REGULAR_ROAD'},
          ],
        },
      );
      final expedition = PvzObject(
        aliases: const ['SouDaCheTunnelDefendDefault'],
        objClass: 'TunnelDefendModuleProperties',
        objData: const <String, dynamic>{
          'BrickMapIndex': 3,
          'Roads': [
            {'GridX': 4, 'GridY': 3, 'Img': ''},
          ],
        },
      );
      final level = PvzLevelFile(objects: [expedition, regular]);

      expect(levelHasStandardTunnelDefendModule(level), isTrue);
      expect(levelHasExpeditionTilesModule(level), isTrue);
      expect(readTunnelDefendData(level)!.roads.single.gridX, 1);
      expect(readExpeditionTilesData(level)!.roads.single.gridX, 4);
    });
  });

  testWidgets(
    'includes bowling foul line and mold colony grids in item categories',
    (tester) async {
      final bowling = PvzObject(
        aliases: const ['BowlingMinigame'],
        objClass: 'BowlingMinigameProperties',
        objData: const <String, dynamic>{'BowlingFoulLine': 3},
      );
      final mold = PvzObject(
        aliases: const ['DoNotPlantBeforeLine'],
        objClass: MoldColonyModuleUtils.moduleObjClass,
        objData: const <String, dynamic>{
          'Description': '',
          'Locations': 'RTID(Mold@CurrentLevel)',
        },
      );
      final layout = PvzObject(
        aliases: const ['Mold'],
        objClass: MoldColonyModuleUtils.layoutObjClass,
        objData: const <String, dynamic>{
          'Values': [
            [1, 0],
            [0, 1],
          ],
        },
      );
      final level = PvzLevelFile(objects: [bowling, mold, layout]);
      late List<GridPreviewCategoryOption> categories;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              categories = collectGridPreviewCategories(
                context,
                level,
                AppLocalizations.of(context)!,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(levelHasPrePlacedGridPreview(level), isTrue);
      expect(
        categories.map((category) => category.kind),
        containsAll(const [
          GridPreviewModuleKind.bowlingFoulLine,
          GridPreviewModuleKind.moldColony,
        ]),
      );
      expect(readBowlingMinigameData(level)!.bowlingFoulLine, 3);
      expect(readMoldColonyLayoutData(level)!.values, [
        [1, 0],
        [0, 1],
      ]);
    },
  );
}
