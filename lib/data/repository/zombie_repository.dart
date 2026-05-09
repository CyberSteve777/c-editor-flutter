import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:z_editor/data/asset_loader.dart';
import 'package:z_editor/l10n/app_localizations.dart';

enum ZombieCategory { main, size, other, collection }

extension ZombieCategoryExtension on ZombieCategory {
  String getLabel(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    switch (this) {
      case ZombieCategory.main:
        return s.zombieCategoryMain;
      case ZombieCategory.size:
        return s.zombieCategorySize;
      case ZombieCategory.other:
        return s.zombieCategoryOther;
      case ZombieCategory.collection:
        return s.zombieCategoryCollection;
    }
  }
}

enum ZombieTag {
  all,
  egyptPirate,
  westFuture,
  darkBeach,
  iceageLostcity,
  kongfuSkycity,
  eightiesDino,
  modernPvz1,
  steamRenai,
  henaiAtlantis,
  taleZCorp,
  parkourSpeed,
  toTheWest,
  memory,
  universe,
  festival1,
  festival2,
  roman,
  pet,
  imp,
  basic,
  fat,
  strong,
  gargantuar,
  elite,
  custom,
  evildave,
}

extension ZombieTagExtension on ZombieTag {
  String getLabel(BuildContext context) {
    final s = AppLocalizations.of(context)!;
    switch (this) {
      case ZombieTag.all:
        return s.zombieTagAll;
      case ZombieTag.egyptPirate:
        return s.zombieTagEgyptPirate;
      case ZombieTag.westFuture:
        return s.zombieTagWestFuture;
      case ZombieTag.darkBeach:
        return s.zombieTagDarkBeach;
      case ZombieTag.iceageLostcity:
        return s.zombieTagIceageLostcity;
      case ZombieTag.kongfuSkycity:
        return s.zombieTagKongfuSkycity;
      case ZombieTag.eightiesDino:
        return s.zombieTagEightiesDino;
      case ZombieTag.modernPvz1:
        return s.zombieTagModernPvz1;
      case ZombieTag.steamRenai:
        return s.zombieTagSteamRenai;
      case ZombieTag.henaiAtlantis:
        return s.zombieTagHenaiAtlantis;
      case ZombieTag.taleZCorp:
        return s.zombieTagTaleZCorp;
      case ZombieTag.parkourSpeed:
        return s.zombieTagParkourSpeed;
      case ZombieTag.toTheWest:
        return s.zombieTagTothewest;
      case ZombieTag.memory:
        return s.zombieTagMemory;
      case ZombieTag.universe:
        return s.zombieTagUniverse;
      case ZombieTag.festival1:
        return s.zombieTagFestival1;
      case ZombieTag.festival2:
        return s.zombieTagFestival2;
      case ZombieTag.roman:
        return s.zombieTagRoman;
      case ZombieTag.pet:
        return s.zombieTagPet;
      case ZombieTag.imp:
        return s.zombieTagImp;
      case ZombieTag.basic:
        return s.zombieTagBasic;
      case ZombieTag.fat:
        return s.zombieTagFat;
      case ZombieTag.strong:
        return s.zombieTagStrong;
      case ZombieTag.gargantuar:
        return s.zombieTagGargantuar;
      case ZombieTag.elite:
        return s.zombieTagElite;
      case ZombieTag.custom:
        return s.zombieTagCustom;
      case ZombieTag.evildave:
        return s.zombieTagEvildave;
    }
  }

  ZombieCategory get category {
    switch (this) {
      case ZombieTag.all:
      case ZombieTag.egyptPirate:
      case ZombieTag.westFuture:
      case ZombieTag.darkBeach:
      case ZombieTag.iceageLostcity:
      case ZombieTag.kongfuSkycity:
      case ZombieTag.eightiesDino:
      case ZombieTag.modernPvz1:
      case ZombieTag.steamRenai:
      case ZombieTag.henaiAtlantis:
      case ZombieTag.taleZCorp:
      case ZombieTag.parkourSpeed:
      case ZombieTag.toTheWest:
      case ZombieTag.memory:
      case ZombieTag.universe:
      case ZombieTag.festival1:
      case ZombieTag.festival2:
      case ZombieTag.roman:
        return ZombieCategory.main;
      case ZombieTag.pet:
      case ZombieTag.imp:
      case ZombieTag.basic:
      case ZombieTag.fat:
      case ZombieTag.strong:
      case ZombieTag.gargantuar:
      case ZombieTag.elite:
        return ZombieCategory.size;
      case ZombieTag.evildave:
      case ZombieTag.custom:
        return ZombieCategory.other;
    }
  }

  String? get iconName {
    switch (this) {
      case ZombieTag.pet:
        return "Zombie_Pet.webp";
      case ZombieTag.imp:
        return "Zombie_Imp.webp";
      case ZombieTag.basic:
        return "Zombie_Basic.webp";
      case ZombieTag.fat:
        return "Zombie_Fat.webp";
      case ZombieTag.strong:
        return "Zombie_Strong.webp";
      case ZombieTag.gargantuar:
        return "Zombie_Gargantuar.webp";
      case ZombieTag.elite:
        return "Zombie_Elite.webp";
      default:
        return null;
    }
  }
}

class ZombieInfo {
  final String id;
  final String name;
  final List<ZombieTag> tags;
  final String? icon;

  ZombieInfo({
    required this.id,
    required this.name,
    required this.tags,
    this.icon,
  });

  String? get iconAssetPath {
    if (icon == null) return null;
    final path = icon!;
    return 'assets/images/zombies/$path';
  }
}

class ZombieRepository {
  static final ZombieRepository _instance = ZombieRepository._internal();
  factory ZombieRepository() => _instance;
  ZombieRepository._internal();

  List<ZombieInfo> _allZombies = [];
  final List<String> _favoriteIds = [];
  bool _isLoaded = false;
  final Set<String> _uiConfiguredAliases = {};

  List<ZombieInfo> get allZombies => _allZombies;
  List<String> get favoriteIds => _favoriteIds;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    if (_isLoaded) return;
    await _loadFavorites();
    try {
      final jsonString = await loadJsonString('assets/resources/Zombies.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final seenIds = <String>{};
      _allZombies = [];
      for (final jsonItem in jsonList) {
        final id = jsonItem['id'] as String;
        if (seenIds.contains(id)) continue;
        seenIds.add(id);

        final name = jsonItem['name'] as String;
        final icon = jsonItem['icon'] as String?;
        final tagsList = (jsonItem['tags'] as List<dynamic>?)?.cast<String>();

        _uiConfiguredAliases.add(id);

        final tags =
            tagsList
                ?.map((tagStr) {
                  final normalizedTag = tagStr
                      .replaceAll('_', '')
                      .toLowerCase();
                  return ZombieTag.values.firstWhere(
                    (e) => e.name.toLowerCase() == normalizedTag,
                    orElse: () => ZombieTag.all,
                  );
                })
                .where((element) => element != ZombieTag.all)
                .toList() ??
            [];

        _allZombies.add(ZombieInfo(
          id: id,
          name: name,
          icon: icon,
          tags: tags.isEmpty ? [ZombieTag.all] : tags,
        ));
      }

      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading zombies: $e');
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorite_zombies');
    if (favorites != null) {
      _favoriteIds.clear();
      _favoriteIds.addAll(favorites);
    }
  }

  /// Returns the name key for localization (e.g. "zombie_mummy").
  /// Use ResourceNames.lookup(context, getName(id)) for display.
  String getName(String id) {
    for (final z in _allZombies) {
      if (z.id == id) return z.name;
    }
    return 'zombie_$id';
  }

  /// Builds zombie alias string (for SeedRain, SeedBank, etc.).
  String buildZombieAliases(String id) {
    if (id == 'iceage_fat_weasel') return 'iceage_fat_weasel_elite';
    return id;
  }

  ZombieInfo? getZombieById(String id) {
    try {
      return _allZombies.firstWhere((z) => z.id == id);
    } catch (_) {
      return null;
    }
  }

  bool isElite(String id) {
    final zombie = getZombieById(id);
    if (zombie == null) return false;
    return zombie.tags.contains(ZombieTag.elite);
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);

  List<ZombieInfo> search(String query, ZombieTag? tag, ZombieCategory category) {
    if (!_isLoaded) return [];
    final baseList =
        category == ZombieCategory.collection
            ? _allZombies.where((z) => _favoriteIds.contains(z.id)).toList()
            : (tag != null && tag != ZombieTag.all
                ? _allZombies.where((z) => z.tags.contains(tag)).toList()
                : _allZombies);

    if (query.trim().isEmpty) return baseList;
    final lower = query.toLowerCase();
    return baseList
        .where(
          (z) =>
              z.id.toLowerCase().contains(lower) ||
              z.name.toLowerCase().contains(lower),
        )
        .toList();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_zombies', _favoriteIds);
  }
}
