import 'package:c_editor/data/pvz_models/PvzModel.dart';

class LevelDefinitionData extends PvzModel {
  LevelDefinitionData({
    this.name = '',
    this.levelNumber = 1,
    this.description = '',
    this.stageModule = '',
    this.loot = 'RTID(DefaultLoot@LevelModules)',
    this.startingSun = 200,
    this.victoryModule = 'RTID(VictoryOutro@LevelModules)',
    this.musicType = 'MainPath',
    this.musicSuffix = '',
    this.ambientAudioSuffix = '',
    this.disablePeavine,
    this.isArtifactDisabled,
    this.boardType,
    this.modules = const [],
  });

  String name;
  int? levelNumber;
  String description;
  String stageModule;
  String loot;
  int? startingSun;
  String victoryModule;
  String musicType;
  String musicSuffix;
  String ambientAudioSuffix;
  bool? disablePeavine;
  bool? isArtifactDisabled;
  /// Deep-sea lawns require `"submarine"` so row 6 stays plantable.
  String? boardType;
  List<String> modules;

  factory LevelDefinitionData.fromJson(Map<String, dynamic> json) {
    final mods = json['Modules'] as List<dynamic>? ?? [];
    final rawMusicType = json['MusicType'] as String?;
    final rawBoardType = json['BoardType'] as String?;
    return LevelDefinitionData(
      name: json['Name'] as String? ?? '',
      levelNumber: json['LevelNumber'] as int?,
      description: json['Description'] as String? ?? '',
      stageModule: json['StageModule'] as String? ?? '',
      loot: json['Loot'] as String? ?? 'RTID(DefaultLoot@LevelModules)',
      startingSun: json['StartingSun'] as int?,
      victoryModule:
          json['VictoryModule'] as String? ?? 'RTID(VictoryOutro@LevelModules)',
      musicType: (rawMusicType == null || rawMusicType.isEmpty)
          ? 'MainPath'
          : rawMusicType,
      musicSuffix: json['MusicSuffix'] as String? ?? '',
      ambientAudioSuffix: json['AmbientAudioSuffix'] as String? ?? '',
      disablePeavine: json['DisablePeavine'] as bool?,
      isArtifactDisabled: json['IsArtifactDisabled'] as bool?,
      boardType: (rawBoardType == null || rawBoardType.isEmpty)
          ? null
          : rawBoardType,
      modules: mods.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Name': name,
    'LevelNumber': levelNumber,
    'Description': description,
    'StageModule': stageModule,
    'Loot': loot,
    'StartingSun': startingSun,
    'VictoryModule': victoryModule,
    'MusicType': musicType,
    if (musicSuffix.isNotEmpty) 'MusicSuffix': musicSuffix,
    if (ambientAudioSuffix.isNotEmpty) 'AmbientAudioSuffix': ambientAudioSuffix,
    if (disablePeavine != null) 'DisablePeavine': disablePeavine,
    if (isArtifactDisabled != null) 'IsArtifactDisabled': isArtifactDisabled,
    if (boardType != null && boardType!.isNotEmpty) 'BoardType': boardType,
    'Modules': modules,
  };
}
