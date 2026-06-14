import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Helpers for level-local custom [ZombieType] objects and their references.
abstract final class CustomZombieLevelUtils {
  static const _currentLevel = 'CurrentLevel';

  static bool isCustomZombieRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    final info = RtidParser.parse(rtid);
    return info?.source == _currentLevel;
  }

  /// Resolves a custom zombie alias from an RTID or a bare level-local alias.
  static String? resolveCustomZombieAlias(
    PvzLevelFile levelFile,
    String typeOrRtid,
  ) {
    final info = RtidParser.parse(typeOrRtid);
    if (info?.source == _currentLevel) return info!.alias;
    final isLevelType = levelFile.objects.any(
      (o) =>
          o.objClass == 'ZombieType' && o.aliases?.contains(typeOrRtid) == true,
    );
    return isLevelType ? typeOrRtid : null;
  }

  /// Counts how many times [alias@CurrentLevel] appears anywhere in level object data.
  static int countReferences(PvzLevelFile levelFile, String alias) {
    final rtid = RtidParser.build(alias, _currentLevel);
    var count = 0;
    for (final obj in levelFile.objects) {
      count += _countRtidInValue(obj.objData, rtid);
    }
    return count;
  }

  static int _countRtidInValue(dynamic value, String rtid) {
    if (value == rtid) return 1;
    if (value is List) {
      var sum = 0;
      for (final item in value) {
        sum += _countRtidInValue(item, rtid);
      }
      return sum;
    }
    if (value is Map) {
      var sum = 0;
      for (final entry in value.entries) {
        sum += _countRtidInValue(entry.value, rtid);
      }
      return sum;
    }
    return 0;
  }

  /// Removes [ZombieType] and its [CurrentLevel] property sheet, if present.
  static void removeTypeAndProperties(PvzLevelFile levelFile, String alias) {
    final typeObj = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ZombieType' && o.aliases?.contains(alias) == true,
    );
    if (typeObj == null) return;

    final data = typeObj.objData;
    if (data is Map<String, dynamic>) {
      final propsRtid = data['Properties'] as String?;
      final propsInfo = propsRtid != null ? RtidParser.parse(propsRtid) : null;
      if (propsInfo?.source == _currentLevel) {
        levelFile.objects.removeWhere(
          (o) => o.aliases?.contains(propsInfo!.alias) == true,
        );
      }
    }
    levelFile.objects.remove(typeObj);
  }

  /// After removing the last in-level reference, optionally delete the orphan type.
  static Future<void> maybePromptDeleteOrphan({
    required BuildContext context,
    required PvzLevelFile levelFile,
    required String alias,
    required VoidCallback onChanged,
  }) async {
    if (countReferences(levelFile, alias) > 0) return;

    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.customZombieOrphanDeleteTitle ?? 'Remove custom zombie data?',
        ),
        content: Text(
          l10n?.customZombieOrphanDeleteMessage(alias) ??
              '“$alias” is no longer used in this level. Remove its zombie type and property objects from the level file?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
    if (ok == true) {
      removeTypeAndProperties(levelFile, alias);
      onChanged();
    }
  }
}
