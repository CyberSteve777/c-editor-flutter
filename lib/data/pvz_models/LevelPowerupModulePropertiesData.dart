import 'package:c_editor/data/pvz_models/PvzModel.dart';

class LevelPowerupEntryData extends PvzModel {
  LevelPowerupEntryData({required this.typeName, this.freeUseCount = 3});

  String typeName;
  int freeUseCount;

  factory LevelPowerupEntryData.fromJson(Map<String, dynamic> json) {
    return LevelPowerupEntryData(
      typeName: json['TypeName'] as String? ?? '',
      freeUseCount: (json['FreeUseCount'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'TypeName': typeName,
    'FreeUseCount': freeUseCount,
  };
}

class LevelPowerupModulePropertiesData extends PvzModel {
  LevelPowerupModulePropertiesData({List<LevelPowerupEntryData>? powerups})
    : powerups = powerups ?? createDefaultPowerups();

  static const supportedTypeNames = <String>[
    'powerupflickzombie',
    'powerupwizardfinger',
    'poweruppinchzombie',
  ];

  List<LevelPowerupEntryData> powerups;

  static List<LevelPowerupEntryData> createDefaultPowerups() => [
    LevelPowerupEntryData(typeName: 'powerupflickzombie'),
    LevelPowerupEntryData(typeName: 'powerupwizardfinger'),
    LevelPowerupEntryData(typeName: 'poweruppinchzombie'),
  ];

  LevelPowerupEntryData entryFor(String typeName) {
    for (final entry in powerups) {
      if (entry.typeName == typeName) return entry;
    }
    final entry = LevelPowerupEntryData(typeName: typeName);
    powerups.add(entry);
    return entry;
  }

  factory LevelPowerupModulePropertiesData.fromJson(Map<String, dynamic> json) {
    return LevelPowerupModulePropertiesData(
      powerups: (json['Powerups'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map>()
          .map(
            (entry) => LevelPowerupEntryData.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Powerups': powerups.map((entry) => entry.toJson()).toList(),
  };
}
