import 'package:c_editor/data/custom_portal_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Conservatively finds named CurrentLevel objects that have no known use.
abstract final class UnusedLevelObjectUtils {
  static const _currentLevel = 'CurrentLevel';

  static Future<List<PvzObject>> findUnusedObjects(
    PvzLevelFile levelFile,
  ) async {
    await ZombossMechRepository.ensureLoaded();
    final usedAliases = _collectReferencedAliases(levelFile);
    return [
      for (final object in levelFile.objects)
        if (_canRemove(object, usedAliases)) object,
    ];
  }

  static bool _canRemove(PvzObject object, Set<String> usedAliases) {
    if (object.objClass == 'LevelDefinition') return false;
    final aliases = object.aliases;
    // Anonymous top-level objects cannot be referenced by alias, so their
    // reachability cannot be proven safely by this cleanup operation.
    if (aliases == null || aliases.isEmpty) return false;
    return !aliases.any(usedAliases.contains);
  }

  static Set<String> _collectReferencedAliases(PvzLevelFile levelFile) {
    final used = <String>{};
    final levelAliases = <String>{
      for (final object in levelFile.objects) ...?object.aliases,
    };

    void scan(dynamic value, Set<String> ownerAliases) {
      if (value is String) {
        final rtid = RtidParser.parse(value);
        if (rtid?.source == _currentLevel) {
          used.add(rtid!.alias);
        } else if (levelAliases.contains(value) &&
            !ownerAliases.contains(value)) {
          // Some game fields store a CurrentLevel alias/codename directly
          // instead of wrapping it in RTID(...@CurrentLevel).
          used.add(value);
        }
        return;
      }
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.key == 'ZombossMechType' && entry.value is String) {
            _protectCustomZombossProperties(used, entry.value as String);
          }
          scan(entry.value, ownerAliases);
        }
        return;
      }
      if (value is Iterable) {
        for (final item in value) {
          scan(item, ownerAliases);
        }
      }
    }

    for (final object in levelFile.objects) {
      scan(object.objData, (object.aliases ?? const <String>[]).toSet());
    }

    // PortalType is a short code, not an RTID. The global memo GridItemType
    // resolves its CurrentLevel property object by a fixed alias.
    for (final portal in CustomPortalLevelUtils.list(levelFile)) {
      if (CustomPortalLevelUtils.countUses(levelFile, portal.portalType) == 0) {
        continue;
      }
      used.addAll(portal.properties.aliases ?? const <String>[]);
      used.addAll(portal.gridItemType?.aliases ?? const <String>[]);
    }
    return used;
  }

  static void _protectCustomZombossProperties(
    Set<String> usedAliases,
    String mechType,
  ) {
    final catalog = ZombossMechRepository.findCatalogForVariation(mechType);
    if (catalog == null ||
        !ZombossMechRepository.isCustomVariation(mechType, catalog)) {
      return;
    }
    final alias = catalog.editableInstancePropsName;
    if (alias.isNotEmpty) usedAliases.add(alias);
  }
}
