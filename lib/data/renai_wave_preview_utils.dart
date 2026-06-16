import 'package:c_editor/data/pvz_models.dart';

/// Night grid items that spawn when night begins on [waveIndex] (1-based).
List<RenaiStatueInfoData> renaiNightSpawnStatuesForWave(
  RenaiModulePropertiesData renai,
  int waveIndex,
) {
  if (!renai.nightEnabled) return const [];
  if (renai.nightStartWaveNum + 1 != waveIndex) return const [];
  return List<RenaiStatueInfoData>.from(renai.statueNightInfos);
}

/// Day and night statues that revive (carve) on [waveIndex] (1-based).
List<RenaiStatueInfoData> renaiRevivingStatuesForWave(
  RenaiModulePropertiesData renai,
  int waveIndex,
) {
  return [
    ...renai.statueInfos.where((s) => s.waveNumber + 1 == waveIndex),
    ...renai.statueNightInfos.where((s) => s.waveNumber + 1 == waveIndex),
  ];
}

bool renaiNightStartsOnWave(RenaiModulePropertiesData renai, int waveIndex) {
  return renai.nightEnabled && renai.nightStartWaveNum + 1 == waveIndex;
}

bool renaiWaveHasPreviewActivity(
  RenaiModulePropertiesData renai,
  int waveIndex,
) {
  if (!renai.nightEnabled &&
      renai.statueInfos.isEmpty &&
      renai.statueNightInfos.isEmpty) {
    return false;
  }
  if (renaiNightStartsOnWave(renai, waveIndex)) return true;
  return renaiRevivingStatuesForWave(renai, waveIndex).isNotEmpty;
}
