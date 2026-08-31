import 'package:c_editor/data/models/world_info.dart';

class WorldRepository {
  WorldRepository._();

  static final List<WorldInfo> _worlds = [
    WorldInfo(
      codename: "egypt",
      levelCount: 15,
      iconAsset: "Stage_Egypt.webp",
      nameGetter: (l10n) => l10n.plantTagWorldEgypt,
    ),
    WorldInfo(
      codename: "pirate",
      levelCount: 25,
      iconAsset: "Stage_Pirate.webp",
      nameGetter: (l10n) => l10n.plantTagWorldPirate,
    ),
    WorldInfo(
      codename: "cowboy",
      levelCount: 25,
      iconAsset: "Stage_West.webp",
      nameGetter: (l10n) => l10n.plantTagWorldWildWest,
    ),
    WorldInfo(
      codename: "kongfu",
      levelCount: 25,
      iconAsset: "Stage_Kongfu.webp",
      nameGetter: (l10n) => l10n.plantTagWorldKongfu,
    ),
    WorldInfo(
      codename: "future",
      levelCount: 25,
      iconAsset: "Stage_Future.webp",
      nameGetter: (l10n) => l10n.plantTagWorldFuture,
    ),
    WorldInfo(
      codename: "dark",
      levelCount: 25,
      iconAsset: "Stage_Dark.webp",
      nameGetter: (l10n) => l10n.plantTagWorldDarkAges,
    ),
    WorldInfo(
      codename: "iceage",
      levelCount: 25,
      iconAsset: "Stage_Iceage.webp",
      nameGetter: (l10n) => l10n.plantTagWorldIceage,
    ),
    WorldInfo(
      codename: "beach",
      levelCount: 25,
      iconAsset: "Stage_Beach.webp",
      nameGetter: (l10n) => l10n.plantTagWorldBeach,
    ),
    WorldInfo(
      codename: "skycity",
      levelCount: 25,
      iconAsset: "Stage_Skycity.webp",
      nameGetter: (l10n) => l10n.plantTagWorldSkycity,
    ),
    WorldInfo(
      codename: "lostcity",
      levelCount: 25,
      iconAsset: "Stage_LostCity.webp",
      nameGetter: (l10n) => l10n.plantTagWorldLostCity,
    ),
    WorldInfo(
      codename: "eighties",
      levelCount: 25,
      iconAsset: "Stage_Eighties.webp",
      nameGetter: (l10n) => l10n.plantTagWorldEighties,
    ),
    WorldInfo(
      codename: "dino",
      levelCount: 25,
      iconAsset: "Stage_Dino.webp",
      nameGetter: (l10n) => l10n.plantTagWorldDino,
    ),
    WorldInfo(
      codename: "modern",
      levelCount: 27,
      iconAsset: "Stage_Modern.webp",
      nameGetter: (l10n) => l10n.plantTagWorldModern,
    ),
    WorldInfo(
      codename: "steam",
      levelCount: 25,
      iconAsset: "Stage_Steam.webp",
      nameGetter: (l10n) => l10n.plantTagWorldSteam,
    ),
    WorldInfo(
      codename: "renai",
      levelCount: 25,
      iconAsset: "Stage_Renai.webp",
      nameGetter: (l10n) => l10n.plantTagWorldRenai,
    ),
    WorldInfo(
      codename: "heian",
      levelCount: 24,
      iconAsset: "Stage_Heian.webp",
      nameGetter: (l10n) => l10n.plantTagWorldHeian,
    ),
    WorldInfo(
      codename: "atlantis",
      levelCount: 24,
      iconAsset: "Stage_Atlantis.webp",
      nameGetter: (l10n) => l10n.plantTagWorldAtlantis,
    ),
    WorldInfo(
      codename: "moon",
      levelCount: 12,
      iconAsset: "Stage_Moon.webp",
      nameGetter: (l10n) => l10n.plantTagWorldMoon,
    ),
  ];

  static List<WorldInfo> get allWorlds => _worlds;

  static WorldInfo? findByCodename(String codename) {
    return _worlds.where((w) => w.codename == codename).firstOrNull;
  }
}
