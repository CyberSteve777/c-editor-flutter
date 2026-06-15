import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// Resolves zombie icons and localized display names from RTIDs or aliases.
abstract final class ZombieDisplayUtils {
  static String codename(String typeOrRtid) {
    return RtidParser.parse(typeOrRtid)?.alias ?? typeOrRtid;
  }

  static String localizedName(
    BuildContext context, {
    required String typeOrRtid,
    PvzLevelFile? levelFile,
  }) {
    final typeName = _resolveTypeName(typeOrRtid, levelFile: levelFile);
    final info = ZombieRepository().getZombieById(typeName) ??
        ZombieRepository().getZombieById(typeName.replaceAll('_elite', ''));
    if (info != null) {
      return ResourceNames.lookup(context, info.name);
    }

    final nameKey = ZombieRepository().getName(typeName);
    final translated = ResourceNames.lookup(context, nameKey);
    if (translated != nameKey) return translated;

    return codename(typeOrRtid);
  }

  static String? iconPath(
    String typeOrRtid, {
    PvzLevelFile? levelFile,
  }) {
    final typeName = _resolveTypeName(typeOrRtid, levelFile: levelFile);
    return ZombieRepository().getZombieById(typeName)?.iconAssetPath ??
        ZombieRepository()
            .getZombieById(typeName.replaceAll('_elite', ''))
            ?.iconAssetPath;
  }

  static String _resolveTypeName(
    String typeOrRtid, {
    PvzLevelFile? levelFile,
  }) {
    final alias = codename(typeOrRtid);
    final mapped = ZombiePropertiesRepository.getTypeNameByAlias(alias);
    if (mapped != alias) return mapped;

    if (levelFile != null) {
      final customBase = _customBaseType(levelFile, alias);
      if (customBase != null && customBase.isNotEmpty) return customBase;
    }

    return mapped;
  }

  static String? _customBaseType(PvzLevelFile levelFile, String alias) {
    final typeObj = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ZombieType' && o.aliases?.contains(alias) == true,
    );
    if (typeObj?.objData is Map<String, dynamic>) {
      return (typeObj!.objData as Map<String, dynamic>)['TypeName'] as String?;
    }
    return null;
  }
}
