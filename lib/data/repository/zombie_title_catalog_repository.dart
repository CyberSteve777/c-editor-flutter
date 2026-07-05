import 'dart:convert';

import 'package:flutter/services.dart';

class ZombieTitleCatalogRepository {
  ZombieTitleCatalogRepository._();
  static final ZombieTitleCatalogRepository instance =
      ZombieTitleCatalogRepository._();

  final List<ZombieTitleEntry> _entries = [];
  bool _isInitialized = false;

  static Future<void> init() async {
    if (instance._isInitialized) return;
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/reference/PlantWarsZombieTitleConfig.json',
      );
      final root = jsonDecode(jsonStr) as Map<String, dynamic>;
      final objects = (root['objects'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      for (final raw in objects) {
        final aliases = (raw['aliases'] as List<dynamic>? ?? []).cast<String>();
        if (aliases.isEmpty) continue;
        final alias = aliases.first;
        final objClass = raw['objclass'] as String? ?? '';
        final objData = raw['objdata'];
        if (objData is! Map) continue;
        final data = Map<String, dynamic>.from(objData);
        final type = data['Type'] as String? ?? '';
        final numericProperties = <String, num>{};
        for (final entry in data.entries) {
          final key = entry.key;
          if (key.startsWith('#') ||
              key == 'Name' ||
              key == 'Description' ||
              key == 'Type' ||
              key == 'ImmuneConditions' ||
              key == 'ValidConditions') {
            continue;
          }
          final value = entry.value;
          if (value is int) {
            numericProperties[key] = value;
          } else if (value is double) {
            numericProperties[key] = value;
          } else if (value is num) {
            numericProperties[key] = value;
          }
        }
        instance._entries.add(
          ZombieTitleEntry(
            alias: alias,
            objClass: objClass,
            type: type,
            nameKey: _resourceKey(alias, data['Name'], suffix: '_name'),
            descriptionKey: _resourceKey(
              alias,
              data['Description'],
              suffix: '_description',
            ),
            numericProperties: numericProperties,
          ),
        );
      }
      instance._entries.sort((a, b) => a.alias.compareTo(b.alias));
    } catch (_) {
      // Leave catalog empty when reference file is unavailable.
    } finally {
      instance._isInitialized = true;
    }
  }

  static String _resourceKey(String alias, dynamic raw, {required String suffix}) {
    return 'plantwars_${alias.toLowerCase()}$suffix';
  }

  static List<ZombieTitleEntry> getAll() => List.unmodifiable(instance._entries);

  static ZombieTitleEntry? getByAlias(String alias) {
    for (final entry in instance._entries) {
      if (entry.alias == alias) return entry;
    }
    return null;
  }

  static String iconAssetForType(String type) {
    return switch (type) {
      'zombie_title_crystal' => 'assets/images/ztalemate_perks/Crystal.webp',
      'zombie_title_attack' => 'assets/images/ztalemate_perks/Attack.webp',
      'zombie_title_speed' => 'assets/images/ztalemate_perks/Speed.webp',
      'zombie_title_shield' => 'assets/images/ztalemate_perks/Shield.webp',
      'zombie_title_gravity' => 'assets/images/ztalemate_perks/Gravity.webp',
      'zombie_title_immunecontrol' =>
        'assets/images/ztalemate_perks/ImmuneControl.webp',
      'zombie_title_anticontrol' =>
        'assets/images/ztalemate_perks/AntiControl.webp',
      _ => 'assets/images/others/unknown.webp',
    };
  }

  static bool get isInitialized => instance._isInitialized;
}

class ZombieTitleEntry {
  const ZombieTitleEntry({
    required this.alias,
    required this.objClass,
    required this.type,
    required this.nameKey,
    required this.descriptionKey,
    required this.numericProperties,
  });

  final String alias;
  final String objClass;
  final String type;
  final String nameKey;
  final String descriptionKey;
  final Map<String, num> numericProperties;
}
