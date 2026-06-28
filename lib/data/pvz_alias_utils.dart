import 'package:collection/collection.dart';
import 'package:c_editor/data/level_rtid_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Renames a [CurrentLevel] (or other source) object alias and updates RTIDs.
abstract final class PvzAliasUtils {
  static bool isAliasAvailable(
    PvzLevelFile levelFile,
    String alias, {
    String? excludeAlias,
  }) {
    final trimmed = alias.trim();
    if (trimmed.isEmpty) return false;
    return !levelFile.objects.any((o) {
      final aliases = o.aliases;
      if (aliases == null || aliases.isEmpty) return false;
      if (excludeAlias != null && aliases.contains(excludeAlias)) return false;
      return aliases.contains(trimmed);
    });
  }

  static String uniqueAlias(PvzLevelFile levelFile, String baseAlias) {
    var candidate = baseAlias.trim();
    if (candidate.isEmpty) candidate = 'Object';
    if (isAliasAvailable(levelFile, candidate)) return candidate;
    var i = 1;
    while (!isAliasAvailable(levelFile, '${candidate}_$i')) {
      i++;
    }
    return '${candidate}_$i';
  }

  static void renameAlias({
    required PvzLevelFile levelFile,
    required String oldAlias,
    required String newAlias,
    String source = 'CurrentLevel',
  }) {
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty || trimmed == oldAlias) return;
    final oldRtid = RtidParser.build(oldAlias, source);
    final newRtid = RtidParser.build(trimmed, source);

    final obj = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(oldAlias) == true,
    );
    if (obj != null) {
      obj.aliases = [trimmed];
    }

    LevelRtidUtils.replaceReferences(levelFile, oldRtid, newRtid);
  }
}
