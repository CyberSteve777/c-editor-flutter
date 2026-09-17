import 'package:c_editor/data/pvz_models/PvzModel.dart';

class MoonGrappleVectorData extends PvzModel {
  MoonGrappleVectorData({this.x = 0.0, this.y = 0.0});

  double x;
  double y;

  factory MoonGrappleVectorData.fromJson(Map<String, dynamic> json) {
    return MoonGrappleVectorData(
      x: (json['x'] as num?)?.toDouble() ?? 0.0,
      y: (json['y'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class MoonGrappleItemData extends PvzModel {
  MoonGrappleItemData._({
    required this.type,
    required this.popAnimName,
    required this.animationLabel,
    required this.alternatePopAnimName,
    required this.alternateAnimationLabel,
    required this.collisionRadius,
    required this.attachedPamOffset,
    required this.spawnWeight,
    required this.returnSpeedFactor,
    required this.score,
    required this.experience,
  });

  factory MoonGrappleItemData({
    required String type,
    double spawnWeight = 0.0,
    double returnSpeedFactor = 1.0,
    int score = 0,
    int experience = 0,
  }) => MoonGrappleItemData._create(
    type: type,
    animationLabel: 'animation',
    spawnWeight: spawnWeight,
    returnSpeedFactor: returnSpeedFactor,
    score: score,
    experience: experience,
  );

  factory MoonGrappleItemData._create({
    required String type,
    required String animationLabel,
    double spawnWeight = 0.0,
    double returnSpeedFactor = 1.0,
    int score = 0,
    int experience = 0,
    double? collisionRadius,
  }) {
    final definition = _definitions[type];
    if (definition == null) {
      throw ArgumentError.value(type, 'type', 'Unsupported Moon Grapple item');
    }
    return MoonGrappleItemData._(
      type: type,
      popAnimName: definition.popAnimName,
      animationLabel: animationLabel,
      alternatePopAnimName: definition.alternatePopAnimName,
      alternateAnimationLabel: definition.alternateAnimationLabel,
      collisionRadius: collisionRadius ?? definition.collisionRadius,
      attachedPamOffset: MoonGrappleVectorData(
        x: definition.attachedPamOffset.x,
        y: definition.attachedPamOffset.y,
      ),
      spawnWeight: spawnWeight,
      returnSpeedFactor: returnSpeedFactor,
      score: score,
      experience: experience,
    );
  }

  static const supportedTypes = <String>[
    'SmallCrystal',
    'LargeOre',
    'Rock',
    'Chest',
    'MeteorFlower',
  ];

  static final _definitions = <String, _MoonGrappleItemDefinition>{
    'SmallCrystal': _MoonGrappleItemDefinition(
      popAnimName: 'POPANIM_EFFECTS_GRAPPLE_SMALL_CRYSTAL',
      collisionRadius: 28.0,
      attachedPamOffset: MoonGrappleVectorData(x: -112.5, y: -111.5),
    ),
    'LargeOre': _MoonGrappleItemDefinition(
      popAnimName: 'POPANIM_EFFECTS_GRAPPLE_LARGE_ORE',
      collisionRadius: 38.0,
      attachedPamOffset: MoonGrappleVectorData(x: -112.5, y: -111.5),
    ),
    'Rock': _MoonGrappleItemDefinition(
      popAnimName: 'POPANIM_EFFECTS_GRAPPLE_ROCK',
      alternatePopAnimName: 'POPANIM_EFFECTS_GRAPPLE_ROCK_RARE',
      alternateAnimationLabel: 'idle',
      collisionRadius: 35.0,
      attachedPamOffset: MoonGrappleVectorData(x: -110.0, y: -108.0),
    ),
    'Chest': _MoonGrappleItemDefinition(
      popAnimName: 'POPANIM_EFFECTS_GRAPPLE_CHEST',
      collisionRadius: 34.0,
      attachedPamOffset: MoonGrappleVectorData(x: -113.5, y: -112.5),
    ),
    'MeteorFlower': _MoonGrappleItemDefinition(
      popAnimName: 'POPANIM_EFFECTS_GRAPPLE_METEORFLOWER',
      collisionRadius: 28.0,
      attachedPamOffset: MoonGrappleVectorData(x: -112.5, y: -111.5),
    ),
  };

  final String type;
  final String popAnimName;
  final String animationLabel;
  final String? alternatePopAnimName;
  final String? alternateAnimationLabel;
  double spawnWeight;
  double returnSpeedFactor;
  int score;
  int experience;
  double collisionRadius;
  final MoonGrappleVectorData attachedPamOffset;

  factory MoonGrappleItemData.fromJson(
    Map<String, dynamic> json, {
    String animationLabel = 'animation',
  }) {
    return MoonGrappleItemData._create(
      type: json['Type'] as String? ?? supportedTypes.first,
      animationLabel: animationLabel,
      spawnWeight: (json['SpawnWeight'] as num?)?.toDouble() ?? 0.0,
      returnSpeedFactor: (json['ReturnSpeedFactor'] as num?)?.toDouble() ?? 1.0,
      score: (json['Score'] as num?)?.toInt() ?? 0,
      experience: (json['Experience'] as num?)?.toInt() ?? 0,
      collisionRadius: (json['CollisionRadius'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Type': type,
    'PopAnimName': popAnimName,
    'AnimationLabel': animationLabel,
    if (alternatePopAnimName != null)
      'AlternatePopAnimName': alternatePopAnimName,
    if (alternateAnimationLabel != null)
      'AlternateAnimationLabel': alternateAnimationLabel,
    'SpawnWeight': spawnWeight,
    'ReturnSpeedFactor': returnSpeedFactor,
    'Score': score,
    'Experience': experience,
    'CollisionRadius': collisionRadius,
    'AttachedPAMOffset': attachedPamOffset.toJson(),
  };
}

class _MoonGrappleItemDefinition {
  const _MoonGrappleItemDefinition({
    required this.popAnimName,
    required this.collisionRadius,
    required this.attachedPamOffset,
    this.alternatePopAnimName,
    this.alternateAnimationLabel,
  });

  final String popAnimName;
  final String? alternatePopAnimName;
  final String? alternateAnimationLabel;
  final double collisionRadius;
  final MoonGrappleVectorData attachedPamOffset;
}

class MoonGrappleRoundData extends PvzModel {
  MoonGrappleRoundData({
    this.duration = 60.0,
    this.targetScore = 0,
    this.spawnThreshold = 0,
    this.spawnInterval = 0.0,
    this.minimumSpeed = 0.0,
    this.maximumSpeed = 0.0,
    this.leftToRightChance = 0.5,
    this.minimumFormationSize = 0,
    this.maximumFormationSize = 0,
    List<MoonGrappleItemData>? items,
  }) : items = List<MoonGrappleItemData>.from(items ?? const []);

  double duration;
  int targetScore;
  int spawnThreshold;
  double spawnInterval;
  double minimumSpeed;
  double maximumSpeed;
  double leftToRightChance;
  int minimumFormationSize;
  int maximumFormationSize;
  List<MoonGrappleItemData> items;

  factory MoonGrappleRoundData.fromJson(
    Map<String, dynamic> json, {
    bool firstRound = false,
  }) {
    final rawItems = json['Items'];
    return MoonGrappleRoundData(
      duration: (json['Duration'] as num?)?.toDouble() ?? 60.0,
      targetScore: (json['TargetScore'] as num?)?.toInt() ?? 0,
      spawnThreshold: (json['SpawnThreshold'] as num?)?.toInt() ?? 0,
      spawnInterval: (json['SpawnInterval'] as num?)?.toDouble() ?? 0.0,
      minimumSpeed: (json['MinimumSpeed'] as num?)?.toDouble() ?? 0.0,
      maximumSpeed: (json['MaximumSpeed'] as num?)?.toDouble() ?? 0.0,
      leftToRightChance: (json['LeftToRightChance'] as num?)?.toDouble() ?? 0.5,
      minimumFormationSize:
          (json['MinimumFormationSize'] as num?)?.toInt() ?? 0,
      maximumFormationSize:
          (json['MaximumFormationSize'] as num?)?.toInt() ?? 0,
      items: rawItems is List
          ? rawItems
                .whereType<Map>()
                .map(
                  (item) => MoonGrappleItemData.fromJson(
                    Map<String, dynamic>.from(item),
                    animationLabel: firstRound ? 'idle' : 'animation',
                  ),
                )
                .toList()
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Duration': duration,
    'TargetScore': targetScore,
    'SpawnThreshold': spawnThreshold,
    'SpawnInterval': spawnInterval,
    'MinimumSpeed': minimumSpeed,
    'MaximumSpeed': maximumSpeed,
    'LeftToRightChance': leftToRightChance,
    'MinimumFormationSize': minimumFormationSize,
    'MaximumFormationSize': maximumFormationSize,
    'Items': items.map((item) => item.toJson()).toList(),
  };
}

class MoonGrappleBackgroundObjectData extends PvzModel {
  MoonGrappleBackgroundObjectData._({
    required this.popAnimName,
    required this.artCenter,
    required this.speed,
  });

  factory MoonGrappleBackgroundObjectData({
    required String popAnimName,
    double speed = 0.0,
  }) {
    final definition = _definitions[popAnimName];
    if (definition == null) {
      throw ArgumentError.value(
        popAnimName,
        'popAnimName',
        'Unsupported Moon Grapple background object',
      );
    }
    return MoonGrappleBackgroundObjectData._(
      popAnimName: popAnimName,
      artCenter: MoonGrappleVectorData(
        x: definition.artCenter.x,
        y: definition.artCenter.y,
      ),
      speed: speed,
    );
  }

  static const supportedPopAnimNames = <String>[
    'POPANIM_EFFECTS_GRAPPLE_JACKFRUIT',
    'POPANIM_EFFECTS_GRAPPLE_SAUCER',
    'POPANIM_EFFECTS_GRAPPLE_DUCKPEAR',
  ];

  static final _definitions = <String, _MoonGrappleBackgroundDefinition>{
    'POPANIM_EFFECTS_GRAPPLE_JACKFRUIT': _MoonGrappleBackgroundDefinition(
      artCenter: MoonGrappleVectorData(x: 97.0, y: 119.0),
    ),
    'POPANIM_EFFECTS_GRAPPLE_SAUCER': _MoonGrappleBackgroundDefinition(
      artCenter: MoonGrappleVectorData(x: 97.0, y: 105.0),
    ),
    'POPANIM_EFFECTS_GRAPPLE_DUCKPEAR': _MoonGrappleBackgroundDefinition(
      artCenter: MoonGrappleVectorData(x: 99.0, y: 110.0),
    ),
  };

  final String popAnimName;
  final MoonGrappleVectorData artCenter;
  double speed;

  factory MoonGrappleBackgroundObjectData.fromJson(Map<String, dynamic> json) {
    return MoonGrappleBackgroundObjectData(
      popAnimName:
          json['PopAnimName'] as String? ?? supportedPopAnimNames.first,
      speed: (json['Speed'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'PopAnimName': popAnimName,
    'ArtCenter': artCenter.toJson(),
    'Speed': speed,
  };
}

class _MoonGrappleBackgroundDefinition {
  const _MoonGrappleBackgroundDefinition({required this.artCenter});

  final MoonGrappleVectorData artCenter;
}

/// Configuration for the `MoonGrappleDefault` level module.
class MoonGrappleModulePropertiesData extends PvzModel {
  static MoonGrappleModulePropertiesData createDefault() {
    MoonGrappleItemData item(
      String type,
      double weight,
      double returnSpeedFactor,
      int score,
      int experience, {
      required bool firstRound,
    }) {
      return MoonGrappleItemData._create(
        type: type,
        animationLabel: firstRound ? 'idle' : 'animation',
        spawnWeight: weight,
        returnSpeedFactor: returnSpeedFactor,
        score: score,
        experience: experience,
      );
    }

    List<MoonGrappleItemData> items(
      List<(String, double, double, int, int)> values, {
      required bool firstRound,
    }) {
      return values
          .map(
            (value) => item(
              value.$1,
              value.$2,
              value.$3,
              value.$4,
              value.$5,
              firstRound: firstRound,
            ),
          )
          .toList();
    }

    return MoonGrappleModulePropertiesData(
      shipPosition: MoonGrappleVectorData(x: 400.0, y: 570.0),
      minimumHookDistance: 80.0,
      maximumHookDistance: 430.0,
      firingArcDegrees: 130.0,
      launchSpeed: 520.0,
      emptyReturnSpeed: 600.0,
      loadedReturnSpeed: 420.0,
      hookCollisionRadius: 12.0,
      laneY: [180.0, 270.0, 360.0],
      spawnLeftX: -80.0,
      spawnRightX: 880.0,
      formationSpacing: 75.0,
      formationYOffset: 10.0,
      rounds: [
        MoonGrappleRoundData(
          targetScore: 650,
          spawnThreshold: 4,
          spawnInterval: 2.5,
          minimumSpeed: 95.0,
          maximumSpeed: 125.0,
          minimumFormationSize: 2,
          maximumFormationSize: 3,
          items: items([
            ('SmallCrystal', 0.55, 1.0, 25, 2),
            ('LargeOre', 0.25, 0.2, 90, 4),
            ('Rock', 0.2, 1.0, 0, 1),
            ('Chest', 0.0, 0.7, 160, 6),
            ('MeteorFlower', 0.0, 0.85, 50, 4),
          ], firstRound: true),
        ),
        MoonGrappleRoundData(
          targetScore: 950,
          spawnThreshold: 5,
          spawnInterval: 2.2,
          minimumSpeed: 125.0,
          maximumSpeed: 165.0,
          minimumFormationSize: 2,
          maximumFormationSize: 3,
          items: items([
            ('SmallCrystal', 0.45, 1.0, 25, 2),
            ('LargeOre', 0.3, 0.2, 90, 4),
            ('Rock', 0.2, 1.0, 0, 1),
            ('Chest', 0.05, 0.7, 160, 6),
            ('MeteorFlower', 0.0, 0.85, 50, 4),
          ], firstRound: false),
        ),
        MoonGrappleRoundData(
          targetScore: 1300,
          spawnThreshold: 6,
          spawnInterval: 1.9,
          minimumSpeed: 155.0,
          maximumSpeed: 205.0,
          minimumFormationSize: 2,
          maximumFormationSize: 3,
          items: items([
            ('SmallCrystal', 0.4, 1.0, 25, 2),
            ('LargeOre', 0.35, 0.2, 90, 4),
            ('Rock', 0.18, 1.0, 0, 1),
            ('Chest', 0.07, 0.7, 160, 6),
            ('MeteorFlower', 0.0, 0.85, 50, 4),
          ], firstRound: false),
        ),
      ],
      feverCombo: 5,
      feverDuration: 6.0,
      feverExtraItems: 2,
      feverMinimumSpawnInterval: 0.8,
      feverHookSpeedMultiplier: 2.0,
      meteorFlowerSpeed: 260.0,
      meteorShowerDuration: 8.0,
      meteorShowerScoreMultiplier: 2.0,
      backgroundMinimumInterval: 12.0,
      backgroundMaximumInterval: 25.0,
      backgroundSpawnChance: 0.25,
      backgroundObjects: [
        MoonGrappleBackgroundObjectData(
          popAnimName: 'POPANIM_EFFECTS_GRAPPLE_JACKFRUIT',
          speed: 150.0,
        ),
        MoonGrappleBackgroundObjectData(
          popAnimName: 'POPANIM_EFFECTS_GRAPPLE_SAUCER',
          speed: 500.0,
        ),
        MoonGrappleBackgroundObjectData(
          popAnimName: 'POPANIM_EFFECTS_GRAPPLE_DUCKPEAR',
          speed: 30.0,
        ),
      ],
      experienceRequirements: [10, 12, 14, 16, 18, 21, 24, 27, 31],
      winchBonuses: [0.35, 0.7, 1.1],
      winchHeavySlowdownReduction: 0.25,
      launcherLaunchBonuses: [0.35, 0.7, 1.1],
      launcherReturnBonuses: [0.2, 0.5, 0.9],
      magnetRadii: [70.0, 105.0, 140.0],
      magnetPullSpeeds: [1.0, 1.35, 1.7],
      magnetCapacities: [1, 1, 2],
      doubleHookSpeedFactors: [0.7, 0.9, 1.0],
      bountyIntervals: [12.0, 10.0, 10.0],
      bountyScoreBonuses: [0.5, 1.0, 1.0],
    );
  }

  MoonGrappleModulePropertiesData({
    MoonGrappleVectorData? shipPosition,
    this.minimumHookDistance = 0.0,
    this.maximumHookDistance = 0.0,
    this.firingArcDegrees = 0.0,
    this.launchSpeed = 0.0,
    this.emptyReturnSpeed = 0.0,
    this.loadedReturnSpeed = 0.0,
    this.hookCollisionRadius = 0.0,
    this.collisionDebugDraw = false,
    List<double>? laneY,
    this.spawnLeftX = 0.0,
    this.spawnRightX = 0.0,
    this.formationSpacing = 0.0,
    this.formationYOffset = 0.0,
    List<MoonGrappleRoundData>? rounds,
    this.feverCombo = 0,
    this.feverDuration = 0.0,
    this.feverExtraItems = 0,
    this.feverMinimumSpawnInterval = 0.0,
    this.feverHookSpeedMultiplier = 0.0,
    this.meteorFlowerSpeed = 0.0,
    this.meteorShowerDuration = 0.0,
    this.meteorShowerScoreMultiplier = 0.0,
    this.backgroundMinimumInterval = 0.0,
    this.backgroundMaximumInterval = 0.0,
    this.backgroundSpawnChance = 0.0,
    List<MoonGrappleBackgroundObjectData>? backgroundObjects,
    List<int>? experienceRequirements,
    List<double>? winchBonuses,
    this.winchHeavySlowdownReduction = 0.0,
    List<double>? launcherLaunchBonuses,
    List<double>? launcherReturnBonuses,
    List<double>? magnetRadii,
    List<double>? magnetPullSpeeds,
    List<int>? magnetCapacities,
    List<double>? doubleHookSpeedFactors,
    List<double>? bountyIntervals,
    List<double>? bountyScoreBonuses,
  }) : shipPosition = shipPosition ?? MoonGrappleVectorData(),
       shipArtCenter = MoonGrappleVectorData(x: 98.0, y: 110.0),
       shipPopAnimName = 'POPANIM_EFFECTS_GRAPPLE_CONSOLE',
       hookPositionOffset = MoonGrappleVectorData(x: 0.0, y: -43.0),
       hookPopAnimName = 'POPANIM_EFFECTS_GRAPPLE_HOOK',
       hookArtCenter = MoonGrappleVectorData(x: 98.0, y: 90.0),
       hookBodyPopAnimName = 'POPANIM_EFFECTS_GRAPPLE_HOOK_BODY',
       hookBodyAnimationLabel = 'idle',
       hookBodyOriginOffset = MoonGrappleVectorData(x: 0.0, y: 20.0),
       hookBodyStartArtOffset = MoonGrappleVectorData(x: 0.0, y: 99.5),
       hookBodyEndArtOffset = MoonGrappleVectorData(x: 198.0, y: 99.5),
       hookBodyScaleY = 1.0,
       aimLinePopAnimName = 'POPANIM_EFFECTS_GRAPPLE_HOOK_BODY',
       aimLineAnimationLabel = 'guide_idle',
       aimLineStartArtOffset = MoonGrappleVectorData(x: 1.5, y: 97.0),
       aimLineEndArtOffset = MoonGrappleVectorData(x: 198.5, y: 97.0),
       aimLineScaleY = 1.0,
       laneY = List<double>.from(laneY ?? const []),
       rounds = List<MoonGrappleRoundData>.from(rounds ?? const []),
       backgroundObjects = List<MoonGrappleBackgroundObjectData>.from(
         backgroundObjects ?? const [],
       ),
       experienceRequirements = List<int>.from(
         experienceRequirements ?? const [],
       ),
       winchBonuses = List<double>.from(winchBonuses ?? const []),
       launcherLaunchBonuses = List<double>.from(
         launcherLaunchBonuses ?? const [],
       ),
       launcherReturnBonuses = List<double>.from(
         launcherReturnBonuses ?? const [],
       ),
       magnetRadii = List<double>.from(magnetRadii ?? const []),
       magnetPullSpeeds = List<double>.from(magnetPullSpeeds ?? const []),
       magnetCapacities = List<int>.from(magnetCapacities ?? const []),
       doubleHookSpeedFactors = List<double>.from(
         doubleHookSpeedFactors ?? const [],
       ),
       bountyIntervals = List<double>.from(bountyIntervals ?? const []),
       bountyScoreBonuses = List<double>.from(bountyScoreBonuses ?? const []);

  MoonGrappleVectorData shipPosition;
  final MoonGrappleVectorData shipArtCenter;
  final String shipPopAnimName;
  final MoonGrappleVectorData hookPositionOffset;
  final String hookPopAnimName;
  final MoonGrappleVectorData hookArtCenter;
  final String hookBodyPopAnimName;
  final String hookBodyAnimationLabel;
  final MoonGrappleVectorData hookBodyOriginOffset;
  final MoonGrappleVectorData hookBodyStartArtOffset;
  final MoonGrappleVectorData hookBodyEndArtOffset;
  final double hookBodyScaleY;
  final String aimLinePopAnimName;
  final String aimLineAnimationLabel;
  final MoonGrappleVectorData aimLineStartArtOffset;
  final MoonGrappleVectorData aimLineEndArtOffset;
  final double aimLineScaleY;
  double minimumHookDistance;
  double maximumHookDistance;
  double firingArcDegrees;
  double launchSpeed;
  double emptyReturnSpeed;
  double loadedReturnSpeed;
  double hookCollisionRadius;
  bool collisionDebugDraw;
  List<double> laneY;
  double spawnLeftX;
  double spawnRightX;
  double formationSpacing;
  double formationYOffset;
  List<MoonGrappleRoundData> rounds;
  int feverCombo;
  double feverDuration;
  int feverExtraItems;
  double feverMinimumSpawnInterval;
  double feverHookSpeedMultiplier;
  double meteorFlowerSpeed;
  double meteorShowerDuration;
  double meteorShowerScoreMultiplier;
  double backgroundMinimumInterval;
  double backgroundMaximumInterval;
  double backgroundSpawnChance;
  List<MoonGrappleBackgroundObjectData> backgroundObjects;
  List<int> experienceRequirements;
  List<double> winchBonuses;
  double winchHeavySlowdownReduction;
  List<double> launcherLaunchBonuses;
  List<double> launcherReturnBonuses;
  List<double> magnetRadii;
  List<double> magnetPullSpeeds;
  List<int> magnetCapacities;
  List<double> doubleHookSpeedFactors;
  List<double> bountyIntervals;
  List<double> bountyScoreBonuses;

  factory MoonGrappleModulePropertiesData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? map(String key) {
      final value = json[key];
      return value is Map ? Map<String, dynamic>.from(value) : null;
    }

    List<double> doubles(String key) => (json[key] as List<dynamic>? ?? [])
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
    List<int> ints(String key) => (json[key] as List<dynamic>? ?? [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toList();

    final rawRounds = json['Rounds'];
    final rawBackgroundObjects = json['BackgroundObjects'];
    return MoonGrappleModulePropertiesData(
      shipPosition: map('ShipPosition') == null
          ? null
          : MoonGrappleVectorData.fromJson(map('ShipPosition')!),
      minimumHookDistance:
          (json['MinimumHookDistance'] as num?)?.toDouble() ?? 0.0,
      maximumHookDistance:
          (json['MaximumHookDistance'] as num?)?.toDouble() ?? 0.0,
      firingArcDegrees: (json['FiringArcDegrees'] as num?)?.toDouble() ?? 0.0,
      launchSpeed: (json['LaunchSpeed'] as num?)?.toDouble() ?? 0.0,
      emptyReturnSpeed: (json['EmptyReturnSpeed'] as num?)?.toDouble() ?? 0.0,
      loadedReturnSpeed: (json['LoadedReturnSpeed'] as num?)?.toDouble() ?? 0.0,
      hookCollisionRadius:
          (json['HookCollisionRadius'] as num?)?.toDouble() ?? 0.0,
      collisionDebugDraw: json['CollisionDebugDraw'] as bool? ?? false,
      laneY: doubles('LaneY'),
      spawnLeftX: (json['SpawnLeftX'] as num?)?.toDouble() ?? 0.0,
      spawnRightX: (json['SpawnRightX'] as num?)?.toDouble() ?? 0.0,
      formationSpacing: (json['FormationSpacing'] as num?)?.toDouble() ?? 0.0,
      formationYOffset: (json['FormationYOffset'] as num?)?.toDouble() ?? 0.0,
      rounds: rawRounds is List
          ? rawRounds
                .whereType<Map>()
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => MoonGrappleRoundData.fromJson(
                    Map<String, dynamic>.from(entry.value),
                    firstRound: entry.key == 0,
                  ),
                )
                .toList()
          : null,
      feverCombo: (json['FeverCombo'] as num?)?.toInt() ?? 0,
      feverDuration: (json['FeverDuration'] as num?)?.toDouble() ?? 0.0,
      feverExtraItems: (json['FeverExtraItems'] as num?)?.toInt() ?? 0,
      feverMinimumSpawnInterval:
          (json['FeverMinimumSpawnInterval'] as num?)?.toDouble() ?? 0.0,
      feverHookSpeedMultiplier:
          (json['FeverHookSpeedMultiplier'] as num?)?.toDouble() ?? 0.0,
      meteorFlowerSpeed: (json['MeteorFlowerSpeed'] as num?)?.toDouble() ?? 0.0,
      meteorShowerDuration:
          (json['MeteorShowerDuration'] as num?)?.toDouble() ?? 0.0,
      meteorShowerScoreMultiplier:
          (json['MeteorShowerScoreMultiplier'] as num?)?.toDouble() ?? 0.0,
      backgroundMinimumInterval:
          (json['BackgroundMinimumInterval'] as num?)?.toDouble() ?? 0.0,
      backgroundMaximumInterval:
          (json['BackgroundMaximumInterval'] as num?)?.toDouble() ?? 0.0,
      backgroundSpawnChance:
          (json['BackgroundSpawnChance'] as num?)?.toDouble() ?? 0.0,
      backgroundObjects: rawBackgroundObjects is List
          ? rawBackgroundObjects
                .whereType<Map>()
                .map(
                  (object) => MoonGrappleBackgroundObjectData.fromJson(
                    Map<String, dynamic>.from(object),
                  ),
                )
                .toList()
          : null,
      experienceRequirements: ints('ExperienceRequirements'),
      winchBonuses: doubles('WinchBonuses'),
      winchHeavySlowdownReduction:
          (json['WinchHeavySlowdownReduction'] as num?)?.toDouble() ?? 0.0,
      launcherLaunchBonuses: doubles('LauncherLaunchBonuses'),
      launcherReturnBonuses: doubles('LauncherReturnBonuses'),
      magnetRadii: doubles('MagnetRadii'),
      magnetPullSpeeds: doubles('MagnetPullSpeeds'),
      magnetCapacities: ints('MagnetCapacities'),
      doubleHookSpeedFactors: doubles('DoubleHookSpeedFactors'),
      bountyIntervals: doubles('BountyIntervals'),
      bountyScoreBonuses: doubles('BountyScoreBonuses'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'ShipPosition': shipPosition.toJson(),
    'ShipArtCenter': shipArtCenter.toJson(),
    'ShipPopAnimName': shipPopAnimName,
    'HookPositionOffset': hookPositionOffset.toJson(),
    'HookPopAnimName': hookPopAnimName,
    'HookArtCenter': hookArtCenter.toJson(),
    'HookBodyPopAnimName': hookBodyPopAnimName,
    'HookBodyAnimationLabel': hookBodyAnimationLabel,
    'HookBodyOriginOffset': hookBodyOriginOffset.toJson(),
    'HookBodyStartArtOffset': hookBodyStartArtOffset.toJson(),
    'HookBodyEndArtOffset': hookBodyEndArtOffset.toJson(),
    'HookBodyScaleY': hookBodyScaleY,
    'AimLinePopAnimName': aimLinePopAnimName,
    'AimLineAnimationLabel': aimLineAnimationLabel,
    'AimLineStartArtOffset': aimLineStartArtOffset.toJson(),
    'AimLineEndArtOffset': aimLineEndArtOffset.toJson(),
    'AimLineScaleY': aimLineScaleY,
    'MinimumHookDistance': minimumHookDistance,
    'MaximumHookDistance': maximumHookDistance,
    'FiringArcDegrees': firingArcDegrees,
    'LaunchSpeed': launchSpeed,
    'EmptyReturnSpeed': emptyReturnSpeed,
    'LoadedReturnSpeed': loadedReturnSpeed,
    'HookCollisionRadius': hookCollisionRadius,
    'CollisionDebugDraw': collisionDebugDraw,
    'LaneY': laneY,
    'SpawnLeftX': spawnLeftX,
    'SpawnRightX': spawnRightX,
    'FormationSpacing': formationSpacing,
    'FormationYOffset': formationYOffset,
    'Rounds': rounds.map((round) => round.toJson()).toList(),
    'FeverCombo': feverCombo,
    'FeverDuration': feverDuration,
    'FeverExtraItems': feverExtraItems,
    'FeverMinimumSpawnInterval': feverMinimumSpawnInterval,
    'FeverHookSpeedMultiplier': feverHookSpeedMultiplier,
    'MeteorFlowerSpeed': meteorFlowerSpeed,
    'MeteorShowerDuration': meteorShowerDuration,
    'MeteorShowerScoreMultiplier': meteorShowerScoreMultiplier,
    'BackgroundMinimumInterval': backgroundMinimumInterval,
    'BackgroundMaximumInterval': backgroundMaximumInterval,
    'BackgroundSpawnChance': backgroundSpawnChance,
    'BackgroundObjects': backgroundObjects
        .map((object) => object.toJson())
        .toList(),
    'ExperienceRequirements': experienceRequirements,
    'WinchBonuses': winchBonuses,
    'WinchHeavySlowdownReduction': winchHeavySlowdownReduction,
    'LauncherLaunchBonuses': launcherLaunchBonuses,
    'LauncherReturnBonuses': launcherReturnBonuses,
    'MagnetRadii': magnetRadii,
    'MagnetPullSpeeds': magnetPullSpeeds,
    'MagnetCapacities': magnetCapacities,
    'DoubleHookSpeedFactors': doubleHookSpeedFactors,
    'BountyIntervals': bountyIntervals,
    'BountyScoreBonuses': bountyScoreBonuses,
  };
}
