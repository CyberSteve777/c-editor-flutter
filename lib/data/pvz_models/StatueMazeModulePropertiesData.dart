import 'package:c_editor/data/pvz_models/PvzModel.dart';

class StatueMazeModulePropertiesData extends PvzModel {
  StatueMazeModulePropertiesData({List<StatueMazeSetData>? sets})
    : sets = List<StatueMazeSetData>.from(sets ?? const []);

  List<StatueMazeSetData> sets;

  factory StatueMazeModulePropertiesData.createDefault() {
    return StatueMazeModulePropertiesData(
      sets: [StatueMazeSetData.createDefault()],
    );
  }

  factory StatueMazeModulePropertiesData.fromJson(Map<String, dynamic> json) {
    final raw = json['Sets'];
    final sets = <StatueMazeSetData>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          sets.add(
            StatueMazeSetData.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    return StatueMazeModulePropertiesData(sets: sets);
  }

  @override
  Map<String, dynamic> toJson() => {
    'Sets': sets.map((e) => e.toJson()).toList(),
  };
}

class StatueMazeSetData extends PvzModel {
  StatueMazeSetData({
    this.matrixSize = 3,
    this.displayTime = 10.0,
    this.targetNum = 1,
    this.bonusLife = 0,
    List<StatueMazeTileData>? tiles,
    List<StatueMazeRotationData>? rotations,
  }) : tiles = List<StatueMazeTileData>.from(tiles ?? const []),
       rotations = List<StatueMazeRotationData>.from(rotations ?? const []);

  int matrixSize;
  double displayTime;
  int targetNum;
  int bonusLife;
  List<StatueMazeTileData> tiles;
  List<StatueMazeRotationData> rotations;

  factory StatueMazeSetData.createDefault() {
    return StatueMazeSetData(
      matrixSize: 3,
      displayTime: 10.0,
      targetNum: 1,
      bonusLife: 0,
      tiles: [StatueMazeTileData(type: 'c')],
      rotations: [
        StatueMazeRotationData(
          type: 'c',
          waitDuration: 1.0,
          rotateTime: 0.5,
        ),
      ],
    );
  }

  factory StatueMazeSetData.fromJson(Map<String, dynamic> json) {
    final tiles = <StatueMazeTileData>[];
    final rawTiles = json['Tiles'];
    if (rawTiles is List) {
      for (final e in rawTiles) {
        if (e is Map) {
          tiles.add(
            StatueMazeTileData.fromJson(Map<String, dynamic>.from(e)),
          );
        } else if (e is String) {
          tiles.add(StatueMazeTileData(type: e));
        }
      }
    }

    final rotations = <StatueMazeRotationData>[];
    final rawRotations = json['Rotations'];
    if (rawRotations is List) {
      for (final e in rawRotations) {
        if (e is Map) {
          rotations.add(
            StatueMazeRotationData.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }

    return StatueMazeSetData(
      matrixSize: (json['MatrixSize'] as num?)?.toInt() ?? 3,
      displayTime: (json['DisplayTime'] as num?)?.toDouble() ?? 10.0,
      targetNum: (json['TargetNum'] as num?)?.toInt() ?? 1,
      bonusLife: (json['BonusLife'] as num?)?.toInt() ?? 0,
      tiles: tiles,
      rotations: rotations,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'MatrixSize': matrixSize,
    'DisplayTime': displayTime,
    'TargetNum': targetNum,
    'BonusLife': bonusLife,
    'Tiles': tiles.map((e) => e.toJson()).toList(),
    'Rotations': rotations.map((e) => e.toJson()).toList(),
  };
}

class StatueMazeTileData extends PvzModel {
  StatueMazeTileData({this.type = 'c'});

  /// `"c"` = correct tile, `"ac"` = all-correct target tile.
  String type;

  factory StatueMazeTileData.fromJson(Map<String, dynamic> json) {
    return StatueMazeTileData(
      type: json['Type'] as String? ?? 'c',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'Type': type};
}

class StatueMazeRotationData extends PvzModel {
  StatueMazeRotationData({
    this.type = 'c',
    this.waitDuration = 1.0,
    this.rotateTime = 0.5,
  });

  /// `"c"` = clockwise, `"ac"` = anti-clockwise.
  String type;
  double waitDuration;
  double rotateTime;

  factory StatueMazeRotationData.fromJson(Map<String, dynamic> json) {
    return StatueMazeRotationData(
      type: json['Type'] as String? ?? 'c',
      waitDuration: (json['WaitDuration'] as num?)?.toDouble() ?? 1.0,
      rotateTime: (json['RotateTime'] as num?)?.toDouble() ?? 0.5,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Type': type,
    'WaitDuration': waitDuration,
    'RotateTime': rotateTime,
  };
}
