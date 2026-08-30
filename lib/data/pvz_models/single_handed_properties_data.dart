import 'package:c_editor/data/pvz_models/PvzModel.dart';

num _normalizedNumber(double value) =>
    value == value.roundToDouble() ? value.toInt() : value;

Map<String, dynamic> _extraFields(
  Map<String, dynamic> json,
  Set<String> knownKeys,
) =>
    Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => knownKeys.contains(key));

class SingleHandedDropWeaponData extends PvzModel {
  SingleHandedDropWeaponData({
    required this.weaponName,
    this.killCount = 20,
    this.launchTimePercent = 1,
    Map<String, dynamic>? extraFields,
  }) : extraFields = extraFields ?? <String, dynamic>{};

  String weaponName;
  int killCount;
  double launchTimePercent;
  final Map<String, dynamic> extraFields;

  factory SingleHandedDropWeaponData.fromJson(Map<String, dynamic> json) {
    return SingleHandedDropWeaponData(
      weaponName: json['weaponname'] as String? ?? 'repeater',
      killCount: (json['killnum'] as num?)?.toInt() ?? 20,
      launchTimePercent: (json['launchtimepercent'] as num?)?.toDouble() ?? 1,
      extraFields: _extraFields(json, const {
        'weaponname',
        'killnum',
        'launchtimepercent',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'weaponname': weaponName,
    'killnum': killCount,
    'launchtimepercent': _normalizedNumber(launchTimePercent),
  };
}

class SingleHandedSpecialWaveData extends PvzModel {
  SingleHandedSpecialWaveData({
    this.wave = 5,
    this.zombiesWalkSpeed = 1,
    this.zombiesHitpointsPercent = 1,
    this.showHealthBar = true,
    Map<String, dynamic>? extraFields,
  }) : extraFields = extraFields ?? <String, dynamic>{};

  int wave;
  double zombiesWalkSpeed;
  double zombiesHitpointsPercent;
  bool showHealthBar;
  final Map<String, dynamic> extraFields;

  factory SingleHandedSpecialWaveData.fromJson(Map<String, dynamic> json) {
    return SingleHandedSpecialWaveData(
      wave: (json['wave'] as num?)?.toInt() ?? 5,
      zombiesWalkSpeed: (json['ZombiesWalkSpeed'] as num?)?.toDouble() ?? 1,
      zombiesHitpointsPercent:
          (json['ZombiesHitpointsPercent'] as num?)?.toDouble() ?? 1,
      showHealthBar: json['ShowHealthBar'] as bool? ?? true,
      extraFields: _extraFields(json, const {
        'wave',
        'ZombiesWalkSpeed',
        'ZombiesHitpointsPercent',
        'ShowHealthBar',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'wave': wave,
    'ZombiesWalkSpeed': _normalizedNumber(zombiesWalkSpeed),
    'ZombiesHitpointsPercent': _normalizedNumber(zombiesHitpointsPercent),
    'ShowHealthBar': showHealthBar,
  };
}

class SingleHandedPropertiesData extends PvzModel {
  SingleHandedPropertiesData({
    List<String>? resourceGroupNames,
    this.initWeapon = 'peashooter',
    this.initWeaponLaunchTimePercent = 1,
    this.missileCount = 1,
    this.missileInterval = 30,
    this.rocketHitTime = 6,
    this.rocketSpeed = 500,
    this.timeSpeed = 2,
    this.zombiesWalkSpeed = 1,
    this.zombiesHitpointsPercent = 0.1,
    List<SingleHandedDropWeaponData>? dropWeaponDatas,
    List<SingleHandedSpecialWaveData>? specialWaveDatas,
    Map<String, dynamic>? extraFields,
  }) : resourceGroupNames = resourceGroupNames ?? ['SingleHandedGroup'],
       dropWeaponDatas = dropWeaponDatas ?? [],
       specialWaveDatas = specialWaveDatas ?? [],
       extraFields = extraFields ?? <String, dynamic>{};

  List<String> resourceGroupNames;
  String initWeapon;
  double initWeaponLaunchTimePercent;
  int missileCount;
  double missileInterval;
  double rocketHitTime;
  double rocketSpeed;
  double timeSpeed;
  double zombiesWalkSpeed;
  double zombiesHitpointsPercent;
  final List<SingleHandedDropWeaponData> dropWeaponDatas;
  final List<SingleHandedSpecialWaveData> specialWaveDatas;
  final Map<String, dynamic> extraFields;

  factory SingleHandedPropertiesData.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> mapsFor(String key) {
      final raw = json[key];
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList(growable: false);
    }

    final groups = (json['ResourceGroupNames'] as List?)
        ?.whereType<String>()
        .toList();
    return SingleHandedPropertiesData(
      resourceGroupNames: groups == null || groups.isEmpty
          ? ['SingleHandedGroup']
          : groups,
      initWeapon: json['InitWeapon'] as String? ?? 'peashooter',
      initWeaponLaunchTimePercent:
          (json['InitWeaponLaunchTimePercent'] as num?)?.toDouble() ?? 1,
      missileCount: (json['MissileCount'] as num?)?.toInt() ?? 1,
      missileInterval: (json['MissileInterval'] as num?)?.toDouble() ?? 30,
      rocketHitTime: (json['RocketHitTime'] as num?)?.toDouble() ?? 6,
      rocketSpeed: (json['RocketSpeed'] as num?)?.toDouble() ?? 500,
      timeSpeed: (json['TimeSpeed'] as num?)?.toDouble() ?? 2,
      zombiesWalkSpeed: (json['ZombiesWalkSpeed'] as num?)?.toDouble() ?? 1,
      zombiesHitpointsPercent:
          (json['ZombiesHitpointsPercent'] as num?)?.toDouble() ?? 0.1,
      dropWeaponDatas: mapsFor(
        'DropWeaponDatas',
      ).map(SingleHandedDropWeaponData.fromJson).toList(),
      specialWaveDatas: mapsFor(
        'SpecialWaveDatas',
      ).map(SingleHandedSpecialWaveData.fromJson).toList(),
      extraFields: _extraFields(json, const {
        'ResourceGroupNames',
        'InitWeapon',
        'InitWeaponLaunchTimePercent',
        'MissileCount',
        'MissileInterval',
        'RocketHitTime',
        'RocketSpeed',
        'TimeSpeed',
        'ZombiesWalkSpeed',
        'ZombiesHitpointsPercent',
        'DropWeaponDatas',
        'SpecialWaveDatas',
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'ResourceGroupNames': resourceGroupNames,
    'InitWeapon': initWeapon,
    'InitWeaponLaunchTimePercent': _normalizedNumber(
      initWeaponLaunchTimePercent,
    ),
    'MissileCount': missileCount,
    'MissileInterval': _normalizedNumber(missileInterval),
    'RocketHitTime': _normalizedNumber(rocketHitTime),
    'RocketSpeed': _normalizedNumber(rocketSpeed),
    'TimeSpeed': _normalizedNumber(timeSpeed),
    'ZombiesWalkSpeed': _normalizedNumber(zombiesWalkSpeed),
    'ZombiesHitpointsPercent': _normalizedNumber(zombiesHitpointsPercent),
    'DropWeaponDatas': dropWeaponDatas.map((entry) => entry.toJson()).toList(),
    'SpecialWaveDatas': specialWaveDatas
        .map((entry) => entry.toJson())
        .toList(),
  };
}
