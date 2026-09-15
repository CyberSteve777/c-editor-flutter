import 'dart:convert';

import 'package:flutter/services.dart';
import '../pvz_models.dart';
import '../rtid_parser.dart';

/// Loads ResilienceConfig.json and provides presets for ZombieResilience.
class ResilienceConfigRepository {
  ResilienceConfigRepository._();
  static final ResilienceConfigRepository instance =
      ResilienceConfigRepository._();

  final List<ResilienceConfigEntry> _entries = [];
  bool _isInitialized = false;

  static Future<void> init() async {
    if (instance._isInitialized) return;
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/reference/ResilienceConfig.json',
      );
      final Map<String, dynamic> root =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final objects = (root['objects'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      for (final raw in objects) {
        try {
          final obj = PvzObject.fromJson(raw);
          final alias = obj.aliases?.isNotEmpty == true
              ? obj.aliases!.first
              : 'unknown';
          if (obj.objClass != 'ZombieResilience' || obj.objData is! Map) {
            continue;
          }
          final data = ZombieResilienceData.fromJson(
            Map<String, dynamic>.from(obj.objData as Map),
          );
          instance._entries.add(
            ResilienceConfigEntry(
              alias: alias,
              rtid: RtidParser.build(alias, 'ResilienceConfig'),
              data: data,
            ),
          );
        } catch (_) {}
      }
      instance._entries.sort((a, b) => a.alias.compareTo(b.alias));
      instance._isInitialized = true;
    } catch (_) {
      instance._isInitialized = true;
    }
  }

  static List<ResilienceConfigEntry> getAll() => List.from(instance._entries);

  static ResilienceConfigEntry? getByAlias(String alias) {
    try {
      return instance._entries.firstWhere((e) => e.alias == alias);
    } catch (_) {
      return null;
    }
  }

  /// Resolves RTID to ResilienceConfigEntry. For ResilienceConfig source uses
  /// presets; for CurrentLevel, looks up object in [levelObjects].
  static ResilienceConfigEntry? getByRtid(
    String rtid, {
    List<PvzObject>? levelObjects,
  }) {
    final info = RtidParser.parse(rtid);
    if (info == null) return null;
    if (info.source == 'ResilienceConfig') {
      return getByAlias(info.alias);
    }
    if (info.source == 'CurrentLevel' && levelObjects != null) {
      final list = levelObjects
          .where((o) => o.aliases?.contains(info.alias) == true)
          .toList();
      if (list.isEmpty) return null;
      final obj = list.first;
      if (obj.objClass != 'ZombieResilience' || obj.objData is! Map) {
        return null;
      }
      final data = ZombieResilienceData.fromJson(
        Map<String, dynamic>.from(obj.objData as Map),
      );
      return ResilienceConfigEntry(alias: info.alias, rtid: rtid, data: data);
    }
    return null;
  }

  static bool get isInitialized => instance._isInitialized;
}

class ResilienceConfigEntry {
  ResilienceConfigEntry({
    required this.alias,
    required this.rtid,
    required this.data,
  });

  final String alias;
  final String rtid;
  final ZombieResilienceData data;
}

// WeakType values for ZombieResilience:
// 1=Physics, 2=Poison, 3=Electric, 4=Magic, 5=Ice, 6=Fire.
