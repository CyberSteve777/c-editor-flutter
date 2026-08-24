import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/DropDelayConditionData.dart';
import 'package:c_editor/data/pvz_models/InitialPlantListData.dart';
import 'package:c_editor/data/pvz_models/SpeedConditionData.dart';

class ConveyorBeltData extends PvzModel {
  ConveyorBeltData({
    this.initialPlantList = const [],
    this.dropDelayConditions = const [],
    this.speedConditions = const [],
    this.manualPacketSpawning,
  });

  List<InitialPlantListData> initialPlantList;
  List<DropDelayConditionData> dropDelayConditions;
  List<SpeedConditionData> speedConditions;
  bool? manualPacketSpawning;

  factory ConveyorBeltData.fromJson(Map<String, dynamic> json) {
    return ConveyorBeltData(
      initialPlantList:
          (json['InitialPlantList'] as List<dynamic>?)
              ?.map(
                (e) => InitialPlantListData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      dropDelayConditions:
          (json['DropDelayConditions'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DropDelayConditionData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      speedConditions:
          (json['SpeedConditions'] as List<dynamic>?)
              ?.map(
                (e) => SpeedConditionData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      manualPacketSpawning: json['ManualPacketSpawning'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'InitialPlantList': initialPlantList.map((e) => e.toJson()).toList(),
    'DropDelayConditions': dropDelayConditions.map((e) => e.toJson()).toList(),
    'SpeedConditions': speedConditions.map((e) => e.toJson()).toList(),
    if (manualPacketSpawning != null)
      'ManualPacketSpawning': manualPacketSpawning,
  };
}
