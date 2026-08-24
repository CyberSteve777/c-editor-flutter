import 'dart:convert';

import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';

abstract final class ModuleInstanceUtils {
  /// Resolves one concrete CurrentLevel module. An invalid or mismatched RTID
  /// never falls back to another object of the same objclass.
  static PvzObject? findCurrentLevelObject({
    required PvzLevelFile levelFile,
    required String rtid,
    required String expectedObjClass,
  }) {
    final info = RtidParser.parse(rtid);
    if (info?.source != 'CurrentLevel') return null;
    for (final object in levelFile.objects) {
      if (object.objClass == expectedObjClass &&
          object.aliases?.contains(info!.alias) == true) {
        return object;
      }
    }
    return null;
  }

  /// Deep-copies one concrete repeatable CurrentLevel module and inserts its
  /// new reference immediately after the source reference.
  static String? duplicateCurrentLevelModule({
    required PvzLevelFile levelFile,
    required LevelDefinitionData levelDef,
    required String rtid,
    required ModuleMetadata metadata,
  }) {
    if (!metadata.allowMultiple) return null;
    final source = findCurrentLevelObject(
      levelFile: levelFile,
      rtid: rtid,
      expectedObjClass: metadata.objClass,
    );
    if (source == null) return null;

    final alias = PvzAliasUtils.uniqueAlias(
      levelFile,
      metadata.effectiveAlias,
      numberSeparator: metadata.duplicateAliasNumberSeparator,
    );
    final duplicateRtid = RtidParser.build(alias, 'CurrentLevel');
    final moduleIndex = levelDef.modules.indexOf(rtid);
    levelDef.modules.insert(
      moduleIndex < 0 ? levelDef.modules.length : moduleIndex + 1,
      duplicateRtid,
    );
    final sourceIndex = levelFile.objects.indexOf(source);
    levelFile.objects.insert(
      sourceIndex + 1,
      PvzObject(
        aliases: [alias],
        objClass: source.objClass,
        objData: jsonDecode(jsonEncode(source.objData)),
      ),
    );
    return duplicateRtid;
  }

  /// Removes exactly the referenced module object and its one module-list
  /// entry. Other instances with the same objclass remain untouched.
  static PvzObject? removeModule({
    required PvzLevelFile levelFile,
    required LevelDefinitionData levelDef,
    required String rtid,
  }) {
    levelDef.modules.remove(rtid);
    final info = RtidParser.parse(rtid);
    if (info?.source != 'CurrentLevel') return null;
    final objectIndex = levelFile.objects.indexWhere(
      (object) => object.aliases?.contains(info!.alias) == true,
    );
    if (objectIndex < 0) return null;
    return levelFile.objects.removeAt(objectIndex);
  }
}
