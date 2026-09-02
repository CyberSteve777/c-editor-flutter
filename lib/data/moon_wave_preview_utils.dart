import 'package:c_editor/data/pvz_models.dart';

/// Vein placements that emerge on [waveIndex] (1-based, matches EmergenceWave).
List<LunarMineVeinPlacementData> lunarMineVeinEmergingPlacementsForWave(
  LunarMineVeinModulePropertiesData data,
  int waveIndex,
) {
  return data.placements
      .where((placement) => placement.emergenceWave == waveIndex)
      .toList();
}

bool lunarMineVeinWaveHasPreviewActivity(
  LunarMineVeinModulePropertiesData data,
  int waveIndex,
) {
  return lunarMineVeinEmergingPlacementsForWave(data, waveIndex).isNotEmpty;
}

/// Meteor spawns scheduled for [waveIndex] (1-based timeline; stored Wave is 0-based).
List<RadiationMeteorSpawnData> radiationMeteorSpawnsForWave(
  RadiationMeteorModulePropertiesData data,
  int waveIndex,
) {
  final storedWave = waveIndex - 1;
  return data.spawnSchedule
      .where((spawn) => spawn.wave == storedWave)
      .toList();
}

bool radiationMeteorWaveHasPreviewActivity(
  RadiationMeteorModulePropertiesData data,
  int waveIndex,
) {
  return radiationMeteorSpawnsForWave(data, waveIndex).isNotEmpty;
}
