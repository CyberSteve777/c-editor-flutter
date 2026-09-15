import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';

enum RiftThemeTargetType { plants, zombies }

class RiftThemeTargetList {
  const RiftThemeTargetList({
    required this.type,
    required this.ids,
    this.isBlacklist = false,
  });

  final RiftThemeTargetType type;
  final List<String> ids;
  final bool isBlacklist;

  /// Zombie blacklists describe internal exclusions rather than the zombies
  /// affected by a theme, so they should not be presented as a related list.
  bool get shouldDisplayInThemeDetails =>
      type != RiftThemeTargetType.zombies || !isBlacklist;
}

/// Known Penny Pursuit / Memory Lane rift themes and their reference data.
class RiftThemeRepository {
  RiftThemeRepository._();

  static const referenceAssetPath = 'assets/reference/Rift_Themes.json';

  static const themeIds = [
    'zombie',
    'ko',
    'projectile',
    'nuke',
    'gravity',
    'rift',
    'spawn_offset',
    'fire_reduce',
    'lighting_reduce',
    'cold_reduce',
    'heavy_ballon',
    'miner_cheating',
    'mage_cheating',
    'knight_cheating',
    'invisible',
    'sun',
    'dark',
    'rusher',
    'blizzard',
    'gravestone',
    'plant_exploder',
    'plant_aoe',
    'plant_fastcd',
    'plant_melee',
    'lemon',
    'balloon',
    'plant_seed',
    'piggy_bank',
    'energy_fly',
    'watering',
    'disable_boost',
    'printer',
    'pea_rain',
    'sun_disabled',
    'zombie_sun',
  ];

  static const _pursuitIconThemeIds = {
    'zombie',
    'exploder',
    'ko',
    'projectile',
    'nuke',
    'gravity',
    'rift',
  };

  static const _sourceTypeToThemeId = {
    'armored': 'zombie',
    'noplantfood': 'ko',
    'healthdebuff': 'nuke',
    'reducerange': 'gravity',
    'shrunken': 'rusher',
  };

  /// Theme query targets recovered from the game's exact ZombieClass checks.
  /// Alias discovery remains dynamic through the bundled ZombieTypes data.
  static const Map<String, Set<String>> targetZombieClasses = {
    'knight_cheating': {'ZombieModernAllStar', 'ZombieCavalry', 'ZombieBull'},
    'mage_cheating': {
      'ZombieBeachOctopus',
      'ZombieDarkWizard',
      'ZombieArchmage',
      'ZombieRa',
      'ZombieTombRaiser',
      'ZombiePerfumer',
      'ZombieToxicWater',
      'ZombieRomanHealer',
    },
    'miner_cheating': {'ZombieProspector', 'ZombieModernMiner'},
  };

  static Map<String, RiftThemeTargetList> _targetLists = const {};
  static Future<void>? _loadFuture;

  static Map<String, RiftThemeTargetList> get targetLists => _targetLists;

  /// Loads theme target lists directly from the bundled official reference.
  /// Updating [referenceAssetPath] is therefore enough to pick up expanded
  /// plant and zombie lists on the next app launch.
  static Future<void> ensureTargetListsLoaded() {
    return _loadFuture ??= _loadTargetLists();
  }

  static Future<void> _loadTargetLists() async {
    try {
      final source = await loadJsonString(referenceAssetPath);
      final root = jsonDecode(source);
      if (root is! Map) return;
      final objects = root['objects'];
      if (objects is! List) return;

      final parsed = <String, RiftThemeTargetList>{};
      for (final rawObject in objects) {
        if (rawObject is! Map) continue;
        final rawData = rawObject['objdata'];
        if (rawData is! Map) continue;
        final data = Map<String, dynamic>.from(rawData);
        final sourceType = _sourceType(rawObject, data);
        if (sourceType == null) continue;
        final targetList = _extractTargetList(data);
        if (targetList == null || targetList.ids.isEmpty) continue;
        parsed[_sourceTypeToThemeId[sourceType] ?? sourceType] = targetList;
      }
      _targetLists = Map.unmodifiable(parsed);
    } catch (error) {
      debugPrint('Failed to load $referenceAssetPath: $error');
    }
  }

  static String? _sourceType(Map rawObject, Map<String, dynamic> data) {
    final typeName = data['TypeName']?.toString().trim();
    if (typeName != null && typeName.isNotEmpty) return typeName;
    final aliases = rawObject['aliases'];
    if (aliases is List && aliases.isNotEmpty) {
      final alias = aliases.first.toString().trim();
      if (alias.isNotEmpty) return alias;
    }
    return null;
  }

  static RiftThemeTargetList? _extractTargetList(Map<String, dynamic> data) {
    final knightTargets = _stringList(data['ValidKnightTargets']);
    if (knightTargets.isNotEmpty) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.zombies,
        ids: knightTargets,
      );
    }

    final targetableZombies = _typedList(data['TargetableZombieTypes']);
    if (targetableZombies != null) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.zombies,
        ids: targetableZombies.ids,
        isBlacklist: targetableZombies.isBlacklist,
      );
    }

    final targetablePlants = _typedList(data['TargetablePlantTypes']);
    if (targetablePlants != null) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.plants,
        ids: targetablePlants.ids,
        isBlacklist: targetablePlants.isBlacklist,
      );
    }

    final validPlants = _typedList(data['ValidPlants']);
    if (validPlants != null) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.plants,
        ids: validPlants.ids,
        isBlacklist: validPlants.isBlacklist,
      );
    }

    final plantBlacklist = _stringList(data['PlantBlackList']);
    if (plantBlacklist.isNotEmpty) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.plants,
        ids: plantBlacklist,
        isBlacklist: true,
      );
    }

    final blacklistPlants = _typedList(data['BlackListPlantTypes']);
    if (blacklistPlants != null) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.plants,
        ids: blacklistPlants.ids,
        isBlacklist: true,
      );
    }

    return null;
  }

  static ({List<String> ids, bool isBlacklist})? _typedList(dynamic raw) {
    if (raw is! Map) return null;
    final ids = _stringList(raw['List']);
    if (ids.isEmpty) return null;
    return (
      ids: ids,
      isBlacklist: raw['ListType']?.toString().toLowerCase() == 'blacklist',
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map((value) => value.toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  static String nameKey(String id) => 'rift_theme_$id';

  static String descriptionKey(String id) => 'rift_theme_description_$id';

  static String descriptionDetailsKey(String id) =>
      'rift_theme_description_details_$id';

  static String iconAssetPath(String id) {
    final fileName = _pursuitIconThemeIds.contains(id) ? 'pursuit' : id;
    return 'assets/images/rift_themes/$fileName.webp';
  }

  static List<String> availableThemes(Iterable<String> used) {
    final usedSet = used.toSet();
    return themeIds.where((id) => !usedSet.contains(id)).toList();
  }

  /// Resolves a ZombieClass-targeted theme to editor-supported zombies.
  ///
  /// Iterating [ZombieRepository.allZombies] preserves the Zombies.json / chooser
  /// order and naturally intersects ZombieTypes with editor-known aliases.
  /// Class matching is intentionally exact; derived or similarly named classes
  /// are not inferred.
  static List<ZombieInfo> getAffectedZombiesForRiftTheme(String themeId) {
    final targetClasses = targetZombieClasses[themeId];
    if (targetClasses == null) return const [];
    return List<ZombieInfo>.unmodifiable(
      ZombieRepository().allZombies.where((zombie) {
        final zombieClass = ZombiePropertiesRepository.getZombieClassByAlias(
          zombie.id,
        );
        return zombieClass != null && targetClasses.contains(zombieClass);
      }),
    );
  }

  /// Returns the list shown by the theme details UI.
  ///
  /// The three behavior-driven themes use exact ZombieClass resolution. Other
  /// themes continue to use explicit lists from the official Rift_Themes file.
  static RiftThemeTargetList? detailsTargetList(String themeId) {
    if (targetZombieClasses.containsKey(themeId)) {
      return RiftThemeTargetList(
        type: RiftThemeTargetType.zombies,
        ids: getAffectedZombiesForRiftTheme(
          themeId,
        ).map((zombie) => zombie.id).toList(growable: false),
      );
    }
    final targetList = _targetLists[themeId];
    return targetList?.shouldDisplayInThemeDetails == true ? targetList : null;
  }

  static bool isKnown(String id) => themeIds.contains(id);
}
