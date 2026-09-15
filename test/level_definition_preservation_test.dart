import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> levelDefinitionJson() => <String, dynamic>{
    'Name': 'Original name',
    'LevelNumber': 7,
    'Description': 'Original description',
    'StageModule': 'RTID(EgyptStage@LevelModules)',
    'Loot': 'RTID(DefaultLoot@LevelModules)',
    'StartingSun': 100,
    'VictoryModule': 'RTID(VictoryOutro@LevelModules)',
    'MusicType': 'MainPath',
    'MusicSuffix': 'egypt',
    'DisablePeavine': true,
    'Modules': <String>['RTID(WaveManagerModule@CurrentLevel)'],
    'FirstIntroNarrative': 'RTID(MyFirstIntro@CurrentLevel)',
    'LastIntroNarrative': 'RTID(MyLastIntro@CurrentLevel)',
    'ExtensionData': <String, dynamic>{
      'Enabled': true,
      'Values': <int>[1, 2, 3],
    },
  };

  test(
    'LevelDefinitionData preserves fields that the editor does not expose',
    () {
      final definition = LevelDefinitionData.fromJson(levelDefinitionJson());

      definition.name = 'Edited name';
      definition.musicSuffix = '';
      definition.disablePeavine = null;
      final encoded = definition.toJson();

      expect(encoded['Name'], 'Edited name');
      expect(encoded.containsKey('MusicSuffix'), isFalse);
      expect(encoded.containsKey('DisablePeavine'), isFalse);
      expect(encoded['FirstIntroNarrative'], 'RTID(MyFirstIntro@CurrentLevel)');
      expect(encoded['LastIntroNarrative'], 'RTID(MyLastIntro@CurrentLevel)');
      expect(encoded['ExtensionData'], <String, dynamic>{
        'Enabled': true,
        'Values': <int>[1, 2, 3],
      });
    },
  );

  test('basic info write-back keeps unexposed LevelDefinition fields', () {
    final levelFile = PvzLevelFile(
      objects: <PvzObject>[
        PvzObject(
          aliases: const <String>['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: levelDefinitionJson(),
        ),
      ],
    );
    final definition = LevelParser.parseLevel(levelFile).levelDef!;

    definition.description = 'Edited description';
    definition.startingSun = 250;
    LevelParser.syncAndWriteLevelDefinition(definition, levelFile);

    final written = levelFile.objects.single.objData as Map<String, dynamic>;
    expect(written['Description'], 'Edited description');
    expect(written['StartingSun'], 250);
    expect(written['FirstIntroNarrative'], 'RTID(MyFirstIntro@CurrentLevel)');
    expect(written['LastIntroNarrative'], 'RTID(MyLastIntro@CurrentLevel)');
    expect(written['ExtensionData'], <String, dynamic>{
      'Enabled': true,
      'Values': <int>[1, 2, 3],
    });
  });
}
