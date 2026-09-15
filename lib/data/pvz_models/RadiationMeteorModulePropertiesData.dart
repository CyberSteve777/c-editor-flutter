import 'package:c_editor/data/pvz_models/PvzModel.dart';

class RadiationMeteorSpawnData extends PvzModel {
  RadiationMeteorSpawnData({this.wave = 1, this.gridX = 0, this.gridY = 0});

  int wave;
  int gridX;
  int gridY;

  factory RadiationMeteorSpawnData.fromJson(Map<String, dynamic> json) {
    return RadiationMeteorSpawnData(
      wave: (json['Wave'] as num?)?.toInt() ?? 1,
      gridX: (json['GridX'] as num?)?.toInt() ?? 0,
      gridY: (json['GridY'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Wave': wave,
    'GridX': gridX,
    'GridY': gridY,
  };
}

class RadiationMeteorModulePropertiesData extends PvzModel {
  RadiationMeteorModulePropertiesData({
    List<String>? resourceGroupNames,
    this.warningDuration = 5.0,
    this.pollutionInterval = 5.0,
    this.miningDurationRequired = 5.0,
    this.powerRewardOnDestroy = 4,
    List<RadiationMeteorSpawnData>? spawnSchedule,
  }) : resourceGroupNames =
           resourceGroupNames ?? <String>['Radiation_meteorite_group'],
       spawnSchedule = spawnSchedule ?? <RadiationMeteorSpawnData>[];

  List<String> resourceGroupNames;
  double warningDuration;
  double pollutionInterval;
  double miningDurationRequired;
  int powerRewardOnDestroy;
  List<RadiationMeteorSpawnData> spawnSchedule;

  factory RadiationMeteorModulePropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    return RadiationMeteorModulePropertiesData(
      resourceGroupNames:
          (json['ResourceGroupNames'] as List<dynamic>? ??
                  const <dynamic>['Radiation_meteorite_group'])
              .whereType<String>()
              .toList(),
      warningDuration: (json['WarningDuration'] as num?)?.toDouble() ?? 5.0,
      pollutionInterval: (json['PollutionInterval'] as num?)?.toDouble() ?? 5.0,
      miningDurationRequired:
          (json['MiningDurationRequired'] as num?)?.toDouble() ?? 5.0,
      powerRewardOnDestroy:
          (json['PowerRewardOnDestroy'] as num?)?.toInt() ?? 4,
      spawnSchedule:
          (json['SpawnSchedule'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (entry) => RadiationMeteorSpawnData.fromJson(
                  Map<String, dynamic>.from(entry),
                ),
              )
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ResourceGroupNames': resourceGroupNames,
    'WarningDuration': warningDuration,
    'PollutionInterval': pollutionInterval,
    'MiningDurationRequired': miningDurationRequired,
    'PowerRewardOnDestroy': powerRewardOnDestroy,
    'SpawnSchedule': spawnSchedule.map((entry) => entry.toJson()).toList(),
  };
}
