import 'package:c_editor/data/pvz_models.dart';

abstract final class CowboyMinigameUtils {
  static const String moduleObjClass = 'CowboyMinigameProperties';
  static const String conveyorObjClass = 'ConveyorSeedBankProperties';

  static bool enableManualPacketSpawning(PvzLevelFile levelFile) {
    var changed = false;
    for (final object in levelFile.objects) {
      if (object.objClass != conveyorObjClass || object.objData is! Map) {
        continue;
      }
      final data = Map<String, dynamic>.from(object.objData as Map);
      if (data['ManualPacketSpawning'] == true) continue;
      data['ManualPacketSpawning'] = true;
      object.objData = data;
      changed = true;
    }
    return changed;
  }

  static bool removeManualPacketSpawning(PvzLevelFile levelFile) {
    var changed = false;
    for (final object in levelFile.objects) {
      if (object.objClass != conveyorObjClass || object.objData is! Map) {
        continue;
      }
      final data = Map<String, dynamic>.from(object.objData as Map);
      if (!data.containsKey('ManualPacketSpawning')) continue;
      data.remove('ManualPacketSpawning');
      object.objData = data;
      changed = true;
    }
    return changed;
  }
}
