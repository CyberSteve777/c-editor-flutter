import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';

void main() {
  PvzLevelFile levelWithStage({
    required String stageModule,
    String? boardType,
    String? customObjClass,
  }) {
    final objects = <PvzObject>[
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData(
          stageModule: stageModule,
          boardType: boardType,
        ).toJson(),
      ),
    ];
    if (customObjClass != null) {
      objects.add(
        PvzObject(
          aliases: const ['MyDeepSea'],
          objClass: customObjClass,
          objData: <String, dynamic>{},
        ),
      );
    }
    return PvzLevelFile(objects: objects);
  }

  test('adds BoardType submarine for DeepseaStageProperties lawns', () {
    final level = levelWithStage(
      stageModule: 'RTID(MyDeepSea@CurrentLevel)',
      customObjClass: 'DeepseaStageProperties',
    );
    final def = LevelDefinitionData.fromJson(
      Map<String, dynamic>.from(
        level.objects.firstWhere((o) => o.objClass == 'LevelDefinition').objData
            as Map,
      ),
    );

    expect(LevelParser.syncDeepSeaBoardType(def, level), isTrue);
    expect(def.boardType, 'submarine');
    expect(
      (level.objects.first.objData as Map)['BoardType'],
      'submarine',
    );
  });

  test('adds BoardType submarine for DeepseaStageLandProperties lawns', () {
    final level = levelWithStage(
      stageModule: 'RTID(MyDeepSea@CurrentLevel)',
      customObjClass: 'DeepseaStageLandProperties',
    );
    final def = LevelDefinitionData.fromJson(
      Map<String, dynamic>.from(
        level.objects.first.objData as Map,
      ),
    );

    expect(LevelParser.syncDeepSeaBoardType(def, level), isTrue);
    expect(def.boardType, 'submarine');
  });

  test('removes BoardType when lawn is no longer deep sea', () {
    final level = levelWithStage(
      stageModule: 'RTID(MyDeepSea@CurrentLevel)',
      boardType: 'submarine',
      customObjClass: 'EgyptStageProperties',
    );
    final def = LevelDefinitionData.fromJson(
      Map<String, dynamic>.from(
        level.objects.first.objData as Map,
      ),
    );

    expect(LevelParser.syncDeepSeaBoardType(def, level), isTrue);
    expect(def.boardType, isNull);
    expect((level.objects.first.objData as Map).containsKey('BoardType'), isFalse);
  });

  test('round-trips BoardType through LevelDefinitionData', () {
    final withBoard = LevelDefinitionData(boardType: 'submarine').toJson();
    expect(withBoard['BoardType'], 'submarine');
    expect(
      LevelDefinitionData.fromJson(withBoard).boardType,
      'submarine',
    );

    final without = LevelDefinitionData().toJson();
    expect(without.containsKey('BoardType'), isFalse);
  });
}
