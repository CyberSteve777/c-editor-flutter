/// PVZ2 `MusicSuffix` codenames and stage icon mapping for the editor UI.
class MusicSuffixCatalog {
  MusicSuffixCatalog._();

  static const String unknownIconAsset = 'assets/images/others/unknown.webp';

  /// Display order (excluding default empty suffix).
  static const List<String> orderedCodes = [
    'Tutorial',
    'Egypt',
    'Pirate',
    'WildWest',
    'Kongfu',
    'Future',
    'DarkAges',
    'Beach',
    'IceAge',
    'SkyCity',
    'LostCity',
    'Eighties',
    'Dino',
    'Modern',
    'Steam',
    'Renai',
    'Heian',
    'Atlantis',
    'Twister',
    'Uncharted',
    'BGMa',
    'BGMb',
    'BGMd',
    'mausoleum',
    'ghostdom',
    'BGMc',
    'retro',
    'SilkRoad',
    'BGMe',
    'Roman',
    'ZCorp',
    'rift',
    'circus',
  ];

  static String resourceKey(String code) =>
      code.isEmpty ? 'musicSuffix_default' : 'musicSuffix_$code';

  /// Stage alias to borrow an icon from (`Stage_Underground.webp` for mausoleum / ghostdom).
  static String? stageAliasForIcon(String code) {
    switch (code) {
      case '':
        return null;
      case 'ghostdom':
      case 'mausoleum':
        return 'UnchartedMausoleumStage';
      case 'Tutorial':
        return 'TutorialStage';
      case 'Egypt':
        return 'EgyptStage';
      case 'Pirate':
        return 'PirateStage';
      case 'WildWest':
        return 'WestStage';
      case 'Future':
        return 'FutureStage';
      case 'DarkAges':
        return 'DarkStage';
      case 'Beach':
        return 'BeachStage';
      case 'IceAge':
        return 'IceageStage';
      case 'LostCity':
        return 'LostCityStage';
      case 'Eighties':
        return 'EightiesStage';
      case 'Dino':
        return 'DinoStage';
      case 'Modern':
        return 'ModernStage';
      case 'Atlantis':
        return 'DeepseaLandStage';
      case 'Kongfu':
        return 'KongfuStage';
      case 'Renai':
        return 'RenaiStage';
      case 'Heian':
        return 'HeianStage';
      case 'SkyCity':
        return 'SkycityStage';
      case 'Steam':
        return 'SteamStage';
      case 'Twister':
        return 'TwisterStage';
      case 'Uncharted':
        return 'UnchartedAnniversaryStage';
      case 'SilkRoad':
        return 'JourneyToTheWestStage';
      case 'BGMa':
      case 'BGMb':
      case 'BGMd':
        return 'ModernStage';
      case 'BGMc':
        return 'BowlingStage';
      case 'retro':
      case 'BGMe':
      case 'Roman':
      case 'ZCorp':
      case 'rift':
      case 'circus':
        return null;
      default:
        return null;
    }
  }
}
