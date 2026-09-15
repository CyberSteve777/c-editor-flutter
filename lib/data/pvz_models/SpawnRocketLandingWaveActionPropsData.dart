import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/TileLocationData.dart';

class RocketPoolEntryData extends PvzModel {
  RocketPoolEntryData({
    this.type = 'RTID(rocket_landing@GridItemTypes)',
    this.count = 1,
  });

  String type;
  int count;

  factory RocketPoolEntryData.fromJson(Map<String, dynamic> json) {
    return RocketPoolEntryData(
      type: json['Type'] as String? ?? 'RTID(rocket_landing@GridItemTypes)',
      count: (json['Count'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'Type': type, 'Count': count};
}

class SpawnRocketLandingWaveActionPropsData extends PvzModel {
  SpawnRocketLandingWaveActionPropsData({
    List<RocketPoolEntryData>? rocketPool,
    List<TileLocationData>? spawnPositionsPool,
    this.spawnCount = 1,
    this.spawnInterval = 3.0,
    this.displacePlants = false,
    this.ignoreGraveStone = true,
  }) : rocketPool = rocketPool ?? <RocketPoolEntryData>[RocketPoolEntryData()],
       spawnPositionsPool = spawnPositionsPool ?? <TileLocationData>[];

  List<RocketPoolEntryData> rocketPool;
  List<TileLocationData> spawnPositionsPool;
  int spawnCount;
  double spawnInterval;
  bool displacePlants;
  bool ignoreGraveStone;

  factory SpawnRocketLandingWaveActionPropsData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SpawnRocketLandingWaveActionPropsData(
      rocketPool: (json['RocketPool'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (entry) =>
                RocketPoolEntryData.fromJson(Map<String, dynamic>.from(entry)),
          )
          .toList(),
      spawnPositionsPool:
          (json['SpawnPositionsPool'] as List<dynamic>? ?? const <dynamic>[])
              .whereType<Map>()
              .map(
                (entry) =>
                    TileLocationData.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList(),
      spawnCount: (json['SpawnCount'] as num?)?.toInt() ?? 1,
      spawnInterval: (json['SpawnInterval'] as num?)?.toDouble() ?? 3.0,
      displacePlants: json['DisplacePlants'] as bool? ?? false,
      ignoreGraveStone: json['IgnoreGraveStone'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'RocketPool': rocketPool.map((entry) => entry.toJson()).toList(),
    'SpawnPositionsPool': spawnPositionsPool
        .map((entry) => entry.toJson())
        .toList(),
    'SpawnCount': spawnCount,
    'SpawnInterval': spawnInterval,
    'DisplacePlants': displacePlants,
    'IgnoreGraveStone': ignoreGraveStone,
  };
}
