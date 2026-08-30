import 'package:c_editor/data/pvz_models/PvzModel.dart';

class MoonPlantImmunityListData extends PvzModel {
  MoonPlantImmunityListData({List<String>? plants, this.listType = 'blacklist'})
    : plants = List<String>.from(plants ?? const <String>[]);

  List<String> plants;
  String listType;

  factory MoonPlantImmunityListData.fromJson(Map<String, dynamic> json) {
    return MoonPlantImmunityListData(
      plants: (json['List'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<String>()
          .toList(),
      listType: json['ListType'] as String? ?? 'blacklist',
    );
  }

  @override
  Map<String, dynamic> toJson() => {'List': plants, 'ListType': listType};
}

class MoonLifeSupportSystemPropertiesData extends PvzModel {
  MoonLifeSupportSystemPropertiesData({
    this.initialCapacity = 10,
    this.bufferOverloadRatio = 2.0,
    this.penaltyCountdown = 5.0,
    MoonPlantImmunityListData? plantImmunityList,
    List<String>? resourceGroupNames,
  }) : plantImmunityList =
           plantImmunityList ??
           MoonPlantImmunityListData(plants: defaultPlants),
       resourceGroupNames =
           resourceGroupNames ??
           <String>['ZombieArchmageGroup', 'LunarLifeSupport'];

  static const defaultPlants = <String>[
    'lilypad',
    'blover',
    'buduhboom',
    'cherry_bomb',
    'coffeebean',
    'cosmoss',
    'doublesamara',
    'empea',
    'flowerpot',
    'gloombara',
    'goldleaf',
    'grapeshot',
    'gravebuster',
    'heathseeker',
    'hotpotato',
    'hurrikale',
    'imitater',
    'jalapeno',
    'olive',
    'perfumeshroom',
    'powerplant',
    'seaderris',
    'thymewarp',
    'doomshroom',
  ];

  int initialCapacity;
  double bufferOverloadRatio;
  double penaltyCountdown;
  MoonPlantImmunityListData plantImmunityList;
  List<String> resourceGroupNames;

  factory MoonLifeSupportSystemPropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    final immunity = json['PlantImmunityList'];
    return MoonLifeSupportSystemPropertiesData(
      initialCapacity: (json['InitialCapacity'] as num?)?.toInt() ?? 10,
      bufferOverloadRatio:
          (json['BufferOverloadRatio'] as num?)?.toDouble() ?? 2.0,
      penaltyCountdown: (json['PenaltyCountdown'] as num?)?.toDouble() ?? 5.0,
      plantImmunityList: immunity is Map
          ? MoonPlantImmunityListData.fromJson(
              Map<String, dynamic>.from(immunity),
            )
          : MoonPlantImmunityListData(plants: defaultPlants),
      resourceGroupNames:
          (json['ResourceGroupNames'] as List<dynamic>? ??
                  const <dynamic>['ZombieArchmageGroup', 'LunarLifeSupport'])
              .whereType<String>()
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'InitialCapacity': initialCapacity,
    'BufferOverloadRatio': bufferOverloadRatio,
    'PenaltyCountdown': penaltyCountdown,
    'PlantImmunityList': plantImmunityList.toJson(),
    'ResourceGroupNames': resourceGroupNames,
  };
}
