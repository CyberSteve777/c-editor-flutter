import 'package:c_editor/data/pvz_models.dart';

/// Target zombies used by the Oak Archer (OakTrain) minigame.
bool isTargetZombie(String id) {
  return id.startsWith('zombie_target_arrow') ||
      id.startsWith('zombie_target_bottle') ||
      id.startsWith('zombie_target_wizard') ||
      id.startsWith('zombie_target_archmage') ||
      id.startsWith('zombie_target_gargantuar');
}

final RegExp _camelTouchPattern = RegExp(r'camel_.*_touch');

/// Camel card-match touch zombies (e.g. camel_onehump_touch, camel_segment_touch).
bool isCamelTouchZombie(String id) {
  if (_camelTouchPattern.hasMatch(id)) return true;
  final lower = id.toLowerCase();
  return lower.contains('_touch') && lower.contains('camel');
}

/// True when [id] is a target zombie but the level has no OakTrain module.
bool isTargetZombieBlocked(String id, PvzLevelFile levelFile) {
  if (!isTargetZombie(id)) return false;
  return !levelFile.objects.any((o) => o.objClass == 'OakTrainProperties');
}
