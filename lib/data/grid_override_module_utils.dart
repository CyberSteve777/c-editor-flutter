import 'package:collection/collection.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Module wave index for the initial preset (before the level starts).
const int gridOverrideInitialWave = 1;

/// @deprecated Use [gridOverrideInitialWave].
const int gridOverrideFirstWave = gridOverrideInitialWave;

/// Module wave [N] (N ≥ 2) applies when wave-generator wave [N − 1] runs.
int moduleWaveForWaveGeneratorWave(int waveGeneratorWaveIndex) {
  return waveGeneratorWaveIndex + 1;
}

/// Wave-generator wave that a module wave spawns on, or `null` for wave 1 (initial).
int? waveGeneratorWaveForModuleWave(int moduleWave) {
  if (moduleWave <= gridOverrideInitialWave) return null;
  return moduleWave - 1;
}

List<ArmrackOverrideItemData> armrackItemsForModuleWave(
  ArmrackPropertiesData? data,
  int moduleWave,
) {
  if (data == null) return const [];
  return data.overrides
      .where((o) => o.wave == moduleWave)
      .expand((o) => o.itemList)
      .toList();
}

List<EnergyGridOverrideItemData> energyGridItemsForModuleWave(
  EnergyGridPropertiesData? data,
  int moduleWave,
) {
  if (data == null) return const [];
  return data.overrides
      .where((o) => o.wave == moduleWave)
      .expand((o) => o.itemList)
      .toList();
}

List<ArmrackOverrideItemData> initialArmrackItems(ArmrackPropertiesData? data) {
  return armrackItemsForModuleWave(data, gridOverrideInitialWave);
}

List<EnergyGridOverrideItemData> initialEnergyGridItems(
  EnergyGridPropertiesData? data,
) {
  return energyGridItemsForModuleWave(data, gridOverrideInitialWave);
}

bool hasInitialArmrackItems(ArmrackPropertiesData? data) {
  return initialArmrackItems(data).isNotEmpty;
}

bool hasInitialEnergyGridItems(EnergyGridPropertiesData? data) {
  return initialEnergyGridItems(data).isNotEmpty;
}

bool waveGeneratorWaveHasArmrackActivity({
  required int waveGeneratorWaveIndex,
  required ArmrackPropertiesData? data,
}) {
  final moduleWave = moduleWaveForWaveGeneratorWave(waveGeneratorWaveIndex);
  return armrackItemsForModuleWave(data, moduleWave).isNotEmpty;
}

bool waveGeneratorWaveHasEnergyGridActivity({
  required int waveGeneratorWaveIndex,
  required EnergyGridPropertiesData? data,
}) {
  final moduleWave = moduleWaveForWaveGeneratorWave(waveGeneratorWaveIndex);
  return energyGridItemsForModuleWave(data, moduleWave).isNotEmpty;
}

Set<String> levelModuleKeys(PvzLevelFile levelFile) {
  final parsed = LevelParser.parseLevel(levelFile);
  final levelDef = parsed.levelDef;
  if (levelDef == null) return {};
  final objectMap = parsed.objectMap;
  final keys = <String>{};
  for (final rtid in levelDef.modules) {
    final info = RtidParser.parse(rtid);
    if (info == null) continue;
    keys.add(info.alias);
    if (info.source == 'CurrentLevel') {
      final obj = objectMap[info.alias];
      if (obj != null) keys.add(obj.objClass);
    }
  }
  return keys;
}

bool levelHasModule(PvzLevelFile levelFile, String objClass) {
  if (levelFile.objects.any((o) => o.objClass == objClass)) return true;
  final keys = levelModuleKeys(levelFile);
  if (keys.contains(objClass)) return true;
  final meta = ModuleRegistry.getMetadata(objClass);
  return keys.contains(meta.effectiveAlias);
}

bool levelHasKongfuGridOverrideModules(PvzLevelFile levelFile) {
  return levelHasModule(levelFile, 'ArmrackProperties') ||
      levelHasModule(levelFile, 'EnergyGridProperties');
}

String? moduleRtidForClass(PvzLevelFile levelFile, String objClass) {
  final obj = levelFile.objects.firstWhereOrNull(
    (o) => o.objClass == objClass,
  );
  final alias = obj?.aliases?.firstOrNull;
  if (alias == null) return null;
  return RtidParser.build(alias, 'CurrentLevel');
}

PvzObject? _moduleObject(PvzLevelFile levelFile, String objClass) {
  for (final o in levelFile.objects) {
    if (o.objClass == objClass) return o;
  }
  return null;
}

ArmrackPropertiesData? readArmrackModuleData(PvzLevelFile levelFile) {
  final obj = _moduleObject(levelFile, 'ArmrackProperties');
  if (obj?.objData is! Map<String, dynamic>) return null;
  try {
    return ArmrackPropertiesData.fromJson(
      Map<String, dynamic>.from(obj!.objData as Map),
    );
  } catch (_) {
    return null;
  }
}

EnergyGridPropertiesData? readEnergyGridModuleData(PvzLevelFile levelFile) {
  final obj = _moduleObject(levelFile, 'EnergyGridProperties');
  if (obj?.objData is! Map<String, dynamic>) return null;
  try {
    return EnergyGridPropertiesData.fromJson(
      Map<String, dynamic>.from(obj!.objData as Map),
    );
  } catch (_) {
    return null;
  }
}

bool waveHasGridOverrideActivity({
  required int waveIndex,
  required List<int> overrideWaves,
}) {
  if (waveIndex != gridOverrideInitialWave) return false;
  return overrideWaves.any((w) => w == gridOverrideInitialWave);
}
