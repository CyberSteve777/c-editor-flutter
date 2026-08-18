import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
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
}
