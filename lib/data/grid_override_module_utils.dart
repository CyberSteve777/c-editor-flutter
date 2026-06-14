import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Wave index used by [ArmrackPropertiesData] and [EnergyGridPropertiesData]
/// batch entries (1 = first wave). Later waves are ignored in-game.
const int gridOverrideFirstWave = 1;

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
  if (waveIndex != gridOverrideFirstWave) return false;
  return overrideWaves.any((w) => w == gridOverrideFirstWave);
}
