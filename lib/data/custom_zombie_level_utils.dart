import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

/// A level-local custom zombie variant sharing the same base [TypeName].
class CustomZombieVariation {
  const CustomZombieVariation({
    required this.alias,
    required this.rtid,
  });

  final String alias;
  final String rtid;
}

/// Helpers for level-local custom [ZombieType] objects and their references.
abstract final class CustomZombieLevelUtils {
  static const _currentLevel = 'CurrentLevel';

  static bool isCustomZombieRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    final info = RtidParser.parse(rtid);
    return info?.source == _currentLevel;
  }

  static String defaultRtid(String baseType) {
    final aliases = ZombieRepository().buildZombieAliases(baseType);
    return RtidParser.build(aliases, 'ZombieTypes');
  }

  static String? aliasFromRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return null;
    return RtidParser.parse(rtid)?.alias;
  }

  static List<CustomZombieVariation> listVariations(
    PvzLevelFile levelFile,
    String baseType,
  ) {
    final items = <CustomZombieVariation>[];
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'ZombieType') continue;
      final alias = obj.aliases?.firstOrNull;
      if (alias == null) continue;
      final data = obj.objData;
      if (data is! Map<String, dynamic>) continue;
      if (data['TypeName'] != baseType) continue;
      items.add(
        CustomZombieVariation(
          alias: alias,
          rtid: RtidParser.build(alias, _currentLevel),
        ),
      );
    }
    items.sort((a, b) => a.alias.compareTo(b.alias));
    return items;
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

  /// Whether removing one more reference would leave [alias] unused.
  static bool willBeOrphanAfterRemove(PvzLevelFile levelFile, String alias) {
    return countReferences(levelFile, alias) <= 1;
  }

  /// Asks whether orphan type/property objects should be erased from the level.
  /// Returns `true` to erase, `false` to keep them in the level file.
  static Future<bool?> promptDeleteOrphanProperties(
    BuildContext context, {
    required String alias,
  }) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final okGreen = isDark ? pvzGreenLight : pvzGreenDark;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.customZombieOrphanDeleteTitle ??
              'Erase custom properties from level?',
        ),
        content: Text(
          l10n?.customZombieOrphanDeleteMessage(alias) ??
              'This is the last use of "$alias" in this level. '
                  'Remove its zombie type and property objects from the level file? '
                  'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n?.customZombieOrphanDeleteKeep ?? 'Keep in level'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: okGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.customZombieOrphanDeleteErase ?? 'Erase from level'),
          ),
        ],
      ),
    );
  }

  /// Deletes a zombie from a modal bottom sheet: prompts for orphan cleanup,
  /// closes the sheet, then runs [onRemove].
  static Future<void> handleDeleteFromBottomSheet({
    required BuildContext sheetContext,
    required BuildContext parentContext,
    required PvzLevelFile levelFile,
    required String zombieTypeRtid,
    required Future<void> Function(bool eraseOrphanProperties) onRemove,
  }) async {
    final alias = aliasFromRtid(zombieTypeRtid);
    var eraseOrphan = false;
    if (alias != null && willBeOrphanAfterRemove(levelFile, alias)) {
      final choice = await promptDeleteOrphanProperties(
        parentContext,
        alias: alias,
      );
      if (choice == null) return;
      eraseOrphan = choice;
    }
    if (sheetContext.mounted) {
      Navigator.pop(sheetContext);
    }
    await onRemove(eraseOrphan);
  }

  /// After removing the last in-level reference, optionally delete the orphan type.
  static Future<void> maybePromptDeleteOrphan({
    required BuildContext context,
    required PvzLevelFile levelFile,
    required String alias,
    required VoidCallback onChanged,
  }) async {
    if (countReferences(levelFile, alias) > 0) return;

    final erase = await promptDeleteOrphanProperties(context, alias: alias);
    if (erase == true) {
      removeTypeAndProperties(levelFile, alias);
      onChanged();
    }
  }
}
