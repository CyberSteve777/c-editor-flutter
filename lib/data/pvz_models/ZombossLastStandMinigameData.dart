import 'package:c_editor/data/pvz_models/PvzModel.dart';

class ZombossLastStandMinigameData extends PvzModel {
  ZombossLastStandMinigameData({
    List<String>? resourceGroupNames,
    this.startingPlantfood = 3,
    this.startingSun = 0,
    this.zombossInitialGridCol = 6,
    this.zombossInitialGridRow = 2,
    this.zombossStartStageIndex = 0,
    this.reservedColumnCount = 3,
    this.zombossTypeName = 'kongfu_zomboss_qigong',
    this.skipPlanting = true,
  }) : resourceGroupNames = List<String>.from(
         resourceGroupNames ??
             const [
               'ZombieKongFuZombossQigongGroup',
               'ZombossQigongAudio',
             ],
       );

  List<String> resourceGroupNames;
  int startingPlantfood;
  int startingSun;
  int zombossInitialGridCol;
  int zombossInitialGridRow;
  int zombossStartStageIndex;
  int reservedColumnCount;
  String zombossTypeName;
  bool skipPlanting;

  factory ZombossLastStandMinigameData.fromJson(Map<String, dynamic> json) {
    return ZombossLastStandMinigameData(
      resourceGroupNames:
          (json['ResourceGroupNames'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      startingPlantfood: json['StartingPlantfood'] as int? ?? 3,
      startingSun: json['StartingSun'] as int? ?? 0,
      zombossInitialGridCol: json['ZombossInitialGridCol'] as int? ?? 6,
      zombossInitialGridRow: json['ZombossInitialGridRow'] as int? ?? 2,
      zombossStartStageIndex: json['ZombossStartStageIndex'] as int? ?? 0,
      reservedColumnCount: json['ReservedColumnCount'] as int? ?? 3,
      zombossTypeName:
          json['ZombossTypeName'] as String? ?? 'kongfu_zomboss_qigong',
      skipPlanting: json['SkipPlanting'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ResourceGroupNames': resourceGroupNames,
    'IsRandom': false,
    'BossMusic': true,
    'StartingPlantfood': startingPlantfood,
    'StartingSun': startingSun,
    'ZombossInitialGridCol': zombossInitialGridCol,
    'ZombossInitialGridRow': zombossInitialGridRow,
    'ZombossStartStageIndex': 0,
    'ReservedColumnCount': reservedColumnCount,
    'ZombossTypeName': zombossTypeName,
    'SkipPlanting': skipPlanting,
  };
}
