import 'package:z_editor/data/pvz_models/PvzModel.dart';

import 'package:z_editor/data/pvz_models/LocationData.dart';

class ZombossMechBattleModuleData extends PvzModel {
  ZombossMechBattleModuleData({
    this.reservedColumnCount = 2,
    this.zombossMechType = 'zombossmech_egypt',
    this.zombossStageCount = 3,
    this.zombossDeathRow = 3,
    this.zombossDeathColumn = 5,
    this.zombossSpawnGridPosition,
  });

  int reservedColumnCount;
  String zombossMechType;
  int zombossStageCount;
  int zombossDeathRow;
  int zombossDeathColumn;
  LocationData? zombossSpawnGridPosition;

  factory ZombossMechBattleModuleData.fromJson(Map<String, dynamic> json) {
    return ZombossMechBattleModuleData(
      reservedColumnCount: json['ReservedColumnCount'] as int? ?? 2,
      zombossMechType:
          json['ZombossMechType'] as String? ?? 'zombossmech_egypt',
      zombossStageCount: json['ZombossStageCount'] as int? ?? 3,
      zombossDeathRow: json['ZombossDeathRow'] as int? ?? 3,
      zombossDeathColumn: json['ZombossDeathColumn'] as int? ?? 5,
      zombossSpawnGridPosition: json['ZombossSpawnGridPosition'] != null
          ? LocationData.fromJson(
              json['ZombossSpawnGridPosition'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'ReservedColumnCount': reservedColumnCount,
    'ZombossMechType': zombossMechType,
    'ZombossStageCount': zombossStageCount,
    'ZombossDeathRow': zombossDeathRow,
    'ZombossDeathColumn': zombossDeathColumn,
    if (zombossSpawnGridPosition != null)
      'ZombossSpawnGridPosition': zombossSpawnGridPosition!.toJson(),
  };
}
