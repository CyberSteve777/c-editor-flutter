import 'package:collection/collection.dart';
import 'package:c_editor/data/level_rtid_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Helpers for [ZombieResilience] presets and level-local custom shields.
abstract final class ResilienceShieldUtils {
  static const catalogSource = 'ResilienceConfig';
  static const customSource = 'CurrentLevel';

  static bool isCustomRtid(String? rtid) {
    if (rtid == null || rtid.isEmpty) return false;
    return RtidParser.parse(rtid)?.source == customSource;
  }

  static PvzObject? findLevelObject(PvzLevelFile levelFile, String rtid) {
    final info = RtidParser.parse(rtid);
    if (info == null || info.source != customSource) return null;
    return levelFile.objects.firstWhereOrNull(
      (o) =>
          o.objClass == 'ZombieResilience' &&
          o.aliases?.contains(info.alias) == true,
    );
  }

  static String nextCustomCodename(PvzLevelFile levelFile) {
    for (var i = 0; i < 1000; i++) {
      final codename = 'CustomResilience$i';
      if (!levelFile.objects.any((o) => o.aliases?.contains(codename) == true)) {
        return codename;
      }
    }
    return 'CustomResilience999';
  }

  static bool isCodenameAvailable(
    PvzLevelFile levelFile,
    String codename, {
    PvzObject? except,
  }) {
    return !levelFile.objects.any(
      (o) => o != except && o.aliases?.contains(codename) == true,
    );
  }

  static PvzObject createCustomShield({
    required PvzLevelFile levelFile,
    required String alias,
    required ZombieResilienceData data,
  }) {
    final obj = PvzObject(
      aliases: [alias],
      objClass: 'ZombieResilience',
      objData: data.toLevelJson(),
    );
    levelFile.objects.add(obj);
    return obj;
  }

  static void deleteCustomShield(PvzLevelFile levelFile, String rtid) {
    final info = RtidParser.parse(rtid);
    if (info?.source != customSource) return;
    levelFile.objects.removeWhere(
      (o) =>
          o.objClass == 'ZombieResilience' &&
          o.aliases?.contains(info!.alias) == true,
    );
  }

  static void renameCustomShield({
    required PvzLevelFile levelFile,
    required String oldAlias,
    required String newAlias,
    PvzObject? obj,
  }) {
    if (oldAlias == newAlias) return;
    final oldRtid = RtidParser.build(oldAlias, customSource);
    final newRtid = RtidParser.build(newAlias, customSource);
    LevelRtidUtils.replaceReferences(levelFile, oldRtid, newRtid);
    if (obj != null) {
      obj.aliases = [newAlias];
    }
  }

  static bool hasCustomShields(PvzLevelFile levelFile) {
    return levelFile.objects.any((o) => o.objClass == 'ZombieResilience');
  }

  static int countReferences(PvzLevelFile levelFile, String rtid) {
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

  static ResilienceConfigEntry? resolveEntry(
    String? rtid,
    PvzLevelFile levelFile,
  ) {
    if (rtid == null || rtid.isEmpty) return null;
    return ResilienceConfigRepository.getByRtid(
      rtid,
      levelObjects: levelFile.objects,
    );
  }

  static List<ResilienceShieldListItem> listItems(PvzLevelFile levelFile) {
    final items = <ResilienceShieldListItem>[];
    for (final entry in ResilienceConfigRepository.getAll()) {
      items.add(
        ResilienceShieldListItem(
          rtid: entry.rtid,
          alias: entry.alias,
          source: catalogSource,
          weakType: entry.data.weakType,
          data: entry.data,
          isCustom: false,
        ),
      );
    }
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'ZombieResilience') continue;
      final alias = obj.aliases?.firstOrNull;
      if (alias == null) continue;
      if (items.any((e) => e.alias == alias && e.source == customSource)) {
        continue;
      }
      final data = obj.objData is Map
          ? ZombieResilienceData.fromJson(
              Map<String, dynamic>.from(obj.objData as Map),
            )
          : ZombieResilienceData();
      items.add(
        ResilienceShieldListItem(
          rtid: RtidParser.build(alias, customSource),
          alias: alias,
          source: customSource,
          weakType: data.weakType,
          data: data,
          isCustom: true,
        ),
      );
    }
    items.sort((a, b) {
      final sourceCmp = a.source.compareTo(b.source);
      if (sourceCmp != 0) return sourceCmp;
      return a.alias.compareTo(b.alias);
    });
    return items;
  }
}

class ResilienceShieldListItem {
  const ResilienceShieldListItem({
    required this.rtid,
    required this.alias,
    required this.source,
    required this.weakType,
    required this.data,
    required this.isCustom,
  });

  final String rtid;
  final String alias;
  final String source;
  final int weakType;
  final ZombieResilienceData data;
  final bool isCustom;

  String get displayRtid => '$alias@$source';
}
