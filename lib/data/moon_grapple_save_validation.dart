import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Returns whether every Moon Grapple module used by [levelFile] has enough
/// rounds to be playable.
bool moonGrappleHasEnoughRounds(PvzLevelFile levelFile) {
  final parsed = LevelParser.parseLevel(levelFile);
  final levelDefinition = parsed.levelDef;
  if (levelDefinition == null) return true;

  for (final rtid in levelDefinition.modules) {
    final info = RtidParser.parse(rtid);
    if (info == null) continue;
    final object = info.source == 'CurrentLevel'
        ? parsed.objectMap[info.alias]
        : ReferenceRepository.instance.objectForAlias(info.alias);
    if (object == null && info.alias == 'MoonGrappleDefault') return false;
    if (object?.objClass != 'MoonGrappleModuleProperties') continue;

    final data = object?.objData;
    final rounds = data is Map ? data['Rounds'] : null;
    if (rounds is! List || rounds.length < 3) return false;
  }
  return true;
}
