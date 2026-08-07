import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

class CustomPortalInfo {
  const CustomPortalInfo({
    required this.portalType,
    required this.index,
    this.gridItemType,
    required this.properties,
  });

  final String portalType;
  final int index;
  final PvzObject? gridItemType;
  final PvzObject properties;

  List<String> get representativeZombies {
    final data = properties.objData;
    if (data is! Map) return const [];
    final entries = data['ZombieTypesToSpawn'];
    if (entries is! List) return const [];
    return entries
        .whereType<Map>()
        .map((entry) => entry['ZombieTypeName']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();
  }
}

abstract final class CustomPortalLevelUtils {
  static const currentLevel = 'CurrentLevel';
  static const gridItemTypeClass = 'GridItemType';
  static const portalPropertiesClass = 'GridItemZombiePortalProps';
  static const portalGridItemClass = 'GridItemZombiePortal';
  static const gridAliasPrefix = 'zombieportal_';
  static const portalTypeBase = 'memo';
  static const propertiesAliasBase = 'GridItemZombiePortalMemo';

  static final RegExp _memoTypePattern = RegExp(r'^memo(\d+)?$');

  static List<CustomPortalInfo> list(PvzLevelFile levelFile) {
    final found = <CustomPortalInfo>[];
    final foundPropertyAliases = <String>{};

    // The official memo slot is registered globally in GridItemTypes.json and
    // only its property object is stored in CurrentLevel (PVZ1_S31_41_N).
    for (final properties in levelFile.objects) {
      if (properties.objClass != portalPropertiesClass) continue;
      final alias = properties.aliases?.firstOrNull;
      if (alias == null || !alias.startsWith(propertiesAliasBase)) continue;
      final suffix = alias.substring(propertiesAliasBase.length);
      if (suffix.isNotEmpty && int.tryParse(suffix) == null) continue;
      final index = suffix.isEmpty ? 1 : int.parse(suffix);
      final portalType = '$portalTypeBase${index == 1 ? '' : index}';
      final gridItemType = _findObject(
        levelFile,
        '$gridAliasPrefix$portalType',
      );
      foundPropertyAliases.add(alias);
      found.add(
        CustomPortalInfo(
          portalType: portalType,
          index: index,
          gridItemType: gridItemType,
          properties: properties,
        ),
      );
    }

    var legacyIndex = 1000;
    for (final object in levelFile.objects) {
      final data = object.objData;
      if (object.objClass != gridItemTypeClass || data is! Map) continue;
      if (data['GridItemClass'] != portalGridItemClass) continue;
      final alias = object.aliases?.firstOrNull;
      if (alias == null || !alias.startsWith(gridAliasPrefix)) continue;
      final propertiesInfo = RtidParser.parse(
        data['Properties']?.toString() ?? '',
      );
      if (propertiesInfo?.source != currentLevel) continue;
      final properties = _findObject(levelFile, propertiesInfo!.alias);
      if (properties?.objClass != portalPropertiesClass) continue;
      if (foundPropertyAliases.contains(propertiesInfo.alias)) continue;
      final portalType = alias.substring(gridAliasPrefix.length);
      final match = _memoTypePattern.firstMatch(portalType);
      final index = match == null
          ? legacyIndex++
          : int.tryParse(match.group(1) ?? '') ?? 1;
      found.add(
        CustomPortalInfo(
          portalType: portalType,
          index: index,
          gridItemType: object,
          properties: properties!,
        ),
      );
    }
    found.sort((a, b) {
      final indexOrder = a.index.compareTo(b.index);
      return indexOrder != 0
          ? indexOrder
          : a.portalType.compareTo(b.portalType);
    });
    return found;
  }

  static CustomPortalInfo? find(PvzLevelFile levelFile, String portalType) {
    for (final item in list(levelFile)) {
      if (item.portalType == portalType) return item;
    }
    return null;
  }

  static bool isCustom(PvzLevelFile levelFile, String? portalType) {
    if (portalType == null || portalType.isEmpty) return false;
    return find(levelFile, portalType) != null;
  }

  static String create({
    required PvzLevelFile levelFile,
    required Map<String, dynamic> propertiesData,
  }) {
    final index = _nextIndex(levelFile);
    final suffix = index == 1 ? '' : '$index';
    final portalType = '$portalTypeBase$suffix';
    final gridAlias = '$gridAliasPrefix$portalType';
    final propertiesAlias = '$propertiesAliasBase$suffix';

    if (index > 1) {
      levelFile.objects.add(
        PvzObject(
          aliases: [gridAlias],
          objClass: gridItemTypeClass,
          objData: {
            'TypeName': gridAlias,
            'GridItemClass': portalGridItemClass,
            'Properties': RtidParser.build(propertiesAlias, currentLevel),
            'ResourceGroups': ['ModernPortalGroup'],
          },
        ),
      );
    }
    levelFile.objects.add(
      PvzObject(
        aliases: [propertiesAlias],
        objClass: portalPropertiesClass,
        objData: PortalRepository.cloneMap(propertiesData),
      ),
    );
    return portalType;
  }

  static void updateProperties(
    CustomPortalInfo info,
    Map<String, dynamic> propertiesData,
  ) {
    info.properties.objData = PortalRepository.cloneMap(propertiesData);
  }

  static int countUses(PvzLevelFile levelFile, String portalType) {
    var count = 0;
    for (final object in levelFile.objects) {
      count += _countPortalTypeInValue(object.objData, portalType);
    }
    return count;
  }

  static bool removeIfUnused(PvzLevelFile levelFile, String portalType) {
    if (countUses(levelFile, portalType) != 0) return false;
    final info = find(levelFile, portalType);
    if (info == null) return false;
    final gridItemType = info.gridItemType;
    if (gridItemType != null) levelFile.objects.remove(gridItemType);
    levelFile.objects.remove(info.properties);
    return true;
  }

  static Future<bool> maybePromptRemoveUnused({
    required BuildContext context,
    required PvzLevelFile levelFile,
    required String portalType,
  }) async {
    final info = find(levelFile, portalType);
    if (info == null || countUses(levelFile, portalType) != 0) return false;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          l10n?.customPortalUnusedTitle ?? 'Remove unused custom portal?',
        ),
        content: Text(
          l10n?.customPortalUnusedMessage(info.index) ??
              'Custom Portal ${info.index} is no longer used. Remove its '
                  'associated data objects from this level?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n?.customZombieOrphanDeleteKeep ?? 'Keep in level'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.brightness == Brightness.dark
                  ? pvzGreenLight
                  : pvzGreenDark,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n?.customZombieOrphanDeleteErase ?? 'Erase from level',
            ),
          ),
        ],
      ),
    );
    if (remove != true) return false;
    return removeIfUnused(levelFile, portalType);
  }

  static int _nextIndex(PvzLevelFile levelFile) {
    final used = list(levelFile).map((item) => item.index).toSet();
    var index = 1;
    while (used.contains(index) ||
        _findObject(
              levelFile,
              '$gridAliasPrefix$portalTypeBase${index == 1 ? '' : index}',
            ) !=
            null ||
        _findObject(
              levelFile,
              '$propertiesAliasBase${index == 1 ? '' : index}',
            ) !=
            null) {
      index++;
    }
    return index;
  }

  static PvzObject? _findObject(PvzLevelFile levelFile, String alias) {
    for (final object in levelFile.objects) {
      if (object.aliases?.contains(alias) == true) return object;
    }
    return null;
  }

  static int _countPortalTypeInValue(dynamic value, String portalType) {
    if (value is List) {
      return value.fold(
        0,
        (count, item) => count + _countPortalTypeInValue(item, portalType),
      );
    }
    if (value is Map) {
      var count = 0;
      for (final entry in value.entries) {
        if (entry.key == 'PortalType' && entry.value == portalType) {
          count++;
        } else {
          count += _countPortalTypeInValue(entry.value, portalType);
        }
      }
      return count;
    }
    return 0;
  }
}

extension _FirstOrNullExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
