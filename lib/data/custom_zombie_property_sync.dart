import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';

abstract final class CustomZombiePropertySync {
  static void sync({
    required PvzObject typeObj,
    required PvzObject propsObj,
    required ZombieTypeData typeData,
    required ZombiePropertySheetData propsData,
    required List<double> resistances,
    bool patchResistances = false,
  }) {
    final protectFullObjects = ZombiePropertiesRepository
        .supportsResilienceShield(typeData.typeName);
    final typeRaw = _baseData(
      current: typeObj.objData,
      original: protectFullObjects
          ? ZombiePropertiesRepository.cloneOriginalTypeData(typeData.typeName)
          : null,
    );
    final propsRaw = _baseData(
      current: propsObj.objData,
      original: protectFullObjects
          ? ZombiePropertiesRepository.cloneOriginalPropertyData(
              typeData.typeName,
            )
          : null,
    );

    _patchTypeData(
      typeRaw,
      typeData,
      resistances,
      patchResistances: patchResistances,
    );
    _patchPropertyData(propsRaw, propsData);

    typeObj.objData = typeRaw;
    propsObj.objData = propsRaw;
  }

  static Map<String, dynamic> _baseData({
    required dynamic current,
    required Map<String, dynamic>? original,
  }) {
    final currentMap = current is Map
        ? Map<String, dynamic>.from(_cloneJson(current) as Map)
        : <String, dynamic>{};
    if (original == null) return currentMap;

    final merged = Map<String, dynamic>.from(_cloneJson(original) as Map);
    merged.addAll(currentMap);
    return merged;
  }

  static dynamic _cloneJson(dynamic value) => jsonDecode(jsonEncode(value));

  static void _patchTypeData(
    Map<String, dynamic> raw,
    ZombieTypeData data,
    List<double> resistances, {
    required bool patchResistances,
  }) {
    raw['TypeName'] = data.typeName;
    raw['Properties'] = data.properties;

    if (!patchResistances) return;
    final allZero = resistances.every((e) => e == 0.0);
    if (allZero) {
      raw.remove('Resistences');
    } else {
      raw['Resistences'] = List<double>.from(resistances);
    }
  }

  static void _patchPropertyData(
    Map<String, dynamic> raw,
    ZombiePropertySheetData data,
  ) {
    raw['Hitpoints'] = data.hitpoints;
    raw['Speed'] = data.speed;
    _setOrRemove(raw, 'SpeedVariance', data.speedVariance);
    raw['EatDPS'] = data.eatDPS;
    raw['Weight'] = data.weight;
    raw['WavePointCost'] = data.wavePointCost;
    _setOrRemove(raw, 'SizeType', data.sizeType);
    _setOrRemove(raw, 'HitRect', data.hitRect?.toJson());
    _setOrRemove(raw, 'AttackRect', data.attackRect?.toJson());
    _setOrRemove(raw, 'ArtCenter', data.artCenter?.toJson());
    _setOrRemove(raw, 'ShadowOffset', data.shadowOffset?.toJson());
    if (data.groundTrackName.isNotEmpty || raw.containsKey('GroundTrackName')) {
      raw['GroundTrackName'] = data.groundTrackName;
    }
    if (data.canSpawnPlantFood || raw.containsKey('CanSpawnPlantFood')) {
      raw['CanSpawnPlantFood'] = data.canSpawnPlantFood;
    }
    _setOrRemove(raw, 'CanSurrender', data.canSurrender);
    _setOrRemove(
      raw,
      'EnableShowHealthBarByDamage',
      data.enableShowHealthBarByDamage,
    );
    _setOrRemove(raw, 'CanBePlantTossedweak', data.canBePlantTossedweak);
    _setOrRemove(raw, 'CanBePlantTossedStrong', data.canBePlantTossedStrong);
    _setOrRemove(raw, 'CanBeLaunchedByPlants', data.canBeLaunchedByPlants);
    _setOrRemove(raw, 'DrawHealthBarTime', data.drawHealthBarTime);
    _setOrRemove(raw, 'EnableEliteImmunities', data.enableEliteImmunities);
    _setOrRemove(raw, 'EnableEliteScale', data.enableEliteScale);
    _setOrRemove(raw, 'CanTriggerZombieWin', data.canTriggerZombieWin);
    _setOrRemove(raw, 'ChillInsteadOfFreeze', data.chillInsteadOfFreeze);
    _setOrRemove(raw, 'EliteScale', data.eliteScale);
    _setOrRemove(raw, 'ArmDropFraction', data.armDropFraction);
    _setOrRemove(raw, 'HeadDropFraction', data.headDropFraction);

    final resilience = data.resilience;
    if (resilience == null) {
      raw.remove('Resilience');
    } else if (resilience is ZombieResilienceData) {
      raw['Resilience'] = resilience.toJson();
    } else {
      raw['Resilience'] = resilience;
    }
  }

  static void _setOrRemove(
    Map<String, dynamic> raw,
    String key,
    Object? value,
  ) {
    if (value == null) {
      raw.remove(key);
    } else {
      raw[key] = value;
    }
  }
}
