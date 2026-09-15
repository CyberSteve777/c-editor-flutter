import 'package:c_editor/data/pvz_models/PvzModel.dart';

class HamsterZombieData extends PvzModel {
  HamsterZombieData({
    this.level = 1,
    this.behavior = 0,
    this.hasPlantfood = false,
    this.speedBeforeImpact = 0.3,
    this.type = 'RTID(hamster_ball@ZombieTypes)',
    this.zombieInsideBallType = '',
    Map<String, dynamic>? extraFields,
  }) : extraFields = Map<String, dynamic>.from(extraFields ?? const {});

  int level;
  int behavior;
  bool hasPlantfood;
  double speedBeforeImpact;
  String type;
  String zombieInsideBallType;
  final Map<String, dynamic> extraFields;

  factory HamsterZombieData.fromJson(Map<String, dynamic> json) {
    final extras = Map<String, dynamic>.from(json)
      ..remove('Level')
      ..remove('Behavior')
      ..remove('HasPlantfood')
      ..remove('SpeedBeforeImpact')
      ..remove('Type')
      ..remove('ZombieInsideBallType');
    return HamsterZombieData(
      level: (json['Level'] as num?)?.toInt() ?? 1,
      behavior: (json['Behavior'] as num?)?.toInt() ?? 0,
      hasPlantfood: json['HasPlantfood'] as bool? ?? false,
      speedBeforeImpact: (json['SpeedBeforeImpact'] as num?)?.toDouble() ?? 0.3,
      type: json['Type'] as String? ?? 'RTID(hamster_ball@ZombieTypes)',
      zombieInsideBallType: json['ZombieInsideBallType'] as String? ?? '',
      extraFields: extras,
    );
  }

  HamsterZombieData copyWith({
    int? level,
    int? behavior,
    bool? hasPlantfood,
    double? speedBeforeImpact,
    String? type,
    String? zombieInsideBallType,
  }) {
    return HamsterZombieData(
      level: level ?? this.level,
      behavior: behavior ?? this.behavior,
      hasPlantfood: hasPlantfood ?? this.hasPlantfood,
      speedBeforeImpact: speedBeforeImpact ?? this.speedBeforeImpact,
      type: type ?? this.type,
      zombieInsideBallType: zombieInsideBallType ?? this.zombieInsideBallType,
      extraFields: extraFields,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'Level': level,
    'Behavior': behavior,
    'HasPlantfood': hasPlantfood,
    'SpeedBeforeImpact': speedBeforeImpact,
    'Type': type,
    'ZombieInsideBallType': zombieInsideBallType,
  };
}

class HamsterZombieSpawnerPropsData extends PvzModel {
  HamsterZombieSpawnerPropsData({
    this.columnStart = 0,
    this.columnEnd = 8,
    this.groupSize = 1,
    this.timeBetweenGroups = 2,
    this.timeBeforeFullSpawn = 5,
    this.zombies = const [],
    Map<String, dynamic>? extraFields,
  }) : extraFields = Map<String, dynamic>.from(extraFields ?? const {});

  int columnStart;
  int columnEnd;
  int groupSize;
  double timeBetweenGroups;
  double timeBeforeFullSpawn;
  List<HamsterZombieData> zombies;
  final Map<String, dynamic> extraFields;

  factory HamsterZombieSpawnerPropsData.fromJson(Map<String, dynamic> json) {
    final extras = Map<String, dynamic>.from(json)
      ..remove('ColumnStart')
      ..remove('ColumnEnd')
      ..remove('GroupSize')
      ..remove('TimeBetweenGroups')
      ..remove('TimeBeforeFullSpawn')
      ..remove('Zombies');
    final zombieValues = json['Zombies'];
    return HamsterZombieSpawnerPropsData(
      columnStart: (json['ColumnStart'] as num?)?.toInt() ?? 0,
      columnEnd: (json['ColumnEnd'] as num?)?.toInt() ?? 8,
      groupSize: (json['GroupSize'] as num?)?.toInt() ?? 1,
      timeBetweenGroups: (json['TimeBetweenGroups'] as num?)?.toDouble() ?? 2,
      timeBeforeFullSpawn:
          (json['TimeBeforeFullSpawn'] as num?)?.toDouble() ?? 5,
      zombies: zombieValues is List
          ? zombieValues
                .whereType<Map>()
                .map(
                  (value) => HamsterZombieData.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList()
          : const [],
      extraFields: extras,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'ColumnStart': columnStart,
    'ColumnEnd': columnEnd,
    'GroupSize': groupSize,
    'TimeBetweenGroups': timeBetweenGroups,
    'TimeBeforeFullSpawn': timeBeforeFullSpawn,
    'Zombies': zombies.map((zombie) => zombie.toJson()).toList(),
  };
}
