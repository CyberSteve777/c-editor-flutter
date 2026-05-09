import 'package:flutter/material.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/data/pvz_models.dart';

enum ModuleCategory { base, mode, scene, gimmick }

class ModuleMetadata {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final bool isCore;
  final ModuleCategory category;
  final String defaultAlias;
  final String defaultSource;
  final bool allowMultiple;
  final dynamic Function()? initialDataFactory;
  // In Flutter, we might use a route name or a widget builder
  // For now, we'll just store the route name or ID
  final String routeId;
  final String objClass;

  const ModuleMetadata({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.isCore,
    required this.category,
    required this.defaultAlias,
    this.defaultSource = 'CurrentLevel',
    this.allowMultiple = false,
    this.initialDataFactory,
    required this.routeId,
    this.objClass = '',
  });

  String get effectiveAlias => defaultAlias;

  Map<String, dynamic>? get initialData {
    final obj = initialDataFactory?.call();
    if (obj == null) return null;
    if (obj is Map<String, dynamic>) return obj;
    return (obj as dynamic).toJson() as Map<String, dynamic>;
  }

  String getTitle(BuildContext context) {
    return ModuleRegistry.getTitle(context, titleKey);
  }

  String getDescription(BuildContext context) {
    return ModuleRegistry.getDescription(context, descriptionKey);
  }
}

class ModuleRegistry {
  static const String defaultMetadataKey = 'Unknown';

  static ModuleMetadata getMetadata(String objClass) {
    final meta = registry[objClass];
    if (meta != null) return meta.copyWith(objClass: objClass);
    return ModuleMetadata(
      titleKey: defaultMetadataKey,
      descriptionKey: defaultMetadataKey,
      icon: Icons.help_outline,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: objClass,
      defaultSource: 'CurrentLevel',
      routeId: 'Unknown',
      objClass: objClass,
    );
  }

  static List<ModuleMetadata> getAllModules() => all;

  static String getTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'moduleTitle_WaveManagerModuleProperties':
        return l10n.moduleTitle_WaveManagerModuleProperties;
      case 'moduleTitle_CustomLevelModuleProperties':
        return l10n.moduleTitle_CustomLevelModuleProperties;
      case 'moduleTitle_UnchartedModeNo42UniverseModule':
        return l10n.moduleTitle_UnchartedModeNo42UniverseModule;
      case 'moduleTitle_PVZ2MausoleumModuleUnchartedMode':
        return l10n.moduleTitle_PVZ2MausoleumModuleUnchartedMode;
      case 'moduleTitle_StandardLevelIntroProperties':
        return l10n.moduleTitle_StandardLevelIntroProperties;
      case 'moduleTitle_ZombiesAteYourBrainsProperties':
        return l10n.moduleTitle_ZombiesAteYourBrainsProperties;
      case 'moduleTitle_ZombiesDeadWinConProperties':
        return l10n.moduleTitle_ZombiesDeadWinConProperties;
      case 'moduleTitle_BronzeDeadWinConProperties':
        return l10n.moduleTitle_BronzeDeadWinConProperties;
      case 'moduleTitle_SpermWhaleModuleProperties':
        return l10n.moduleTitle_SpermWhaleModuleProperties;
      case 'moduleTitle_PennyClassroomModuleProperties':
        return l10n.moduleTitle_PennyClassroomModuleProperties;
      case 'moduleTitle_SeedBankProperties':
        return l10n.moduleTitle_SeedBankProperties;
      case 'moduleTitle_ConveyorSeedBankProperties':
        return l10n.moduleTitle_ConveyorSeedBankProperties;
      case 'moduleTitle_SunDropperProperties':
        return l10n.moduleTitle_SunDropperProperties;
      case 'moduleTitle_LevelMutatorMaxSunProps':
        return l10n.moduleTitle_LevelMutatorMaxSunProps;
      case 'moduleTitle_LevelMutatorStartingPlantfoodProps':
        return l10n.moduleTitle_LevelMutatorStartingPlantfoodProps;
      case 'moduleTitle_LevelMutatorRiftTimedSunProps':
        return l10n.moduleTitle_LevelMutatorRiftTimedSunProps;
      case 'moduleTitle_PickupCollectableTutorialProperties':
        return l10n.moduleTitle_PickupCollectableTutorialProperties;
      case 'moduleTitle_StarChallengeModuleProperties':
        return l10n.moduleTitle_StarChallengeModuleProperties;
      case 'moduleTitle_LevelScoringModuleProperties':
        return l10n.moduleTitle_LevelScoringModuleProperties;
      case 'moduleTitle_BowlingMinigameProperties':
        return l10n.moduleTitle_BowlingMinigameProperties;
      case 'moduleTitle_NewBowlingMinigameProperties':
        return l10n.moduleTitle_NewBowlingMinigameProperties;
      case 'moduleTitle_VaseBreakerPresetProperties':
        return l10n.moduleTitle_VaseBreakerPresetProperties;
      case 'moduleTitle_VaseBreakerArcadeModuleProperties':
        return l10n.moduleTitle_VaseBreakerArcadeModuleProperties;
      case 'moduleTitle_VaseBreakerFlowModuleProperties':
        return l10n.moduleTitle_VaseBreakerFlowModuleProperties;
      case 'moduleTitle_EvilDaveProperties':
        return l10n.moduleTitle_EvilDaveProperties;
      case 'moduleTitle_ZombossBattleModuleProperties':
        return l10n.moduleTitle_ZombossBattleModuleProperties;
      case 'moduleTitle_ZombossBattleIntroProperties':
        return l10n.moduleTitle_ZombossBattleIntroProperties;
      case 'moduleTitle_SeedRainProperties':
        return l10n.moduleTitle_SeedRainProperties;
      case 'moduleTitle_LastStandMinigameProperties':
        return l10n.moduleTitle_LastStandMinigameProperties;
      case 'moduleTitle_PVZ1OverwhelmModuleProperties':
        return l10n.moduleTitle_PVZ1OverwhelmModuleProperties;
      case 'moduleTitle_SunBombChallengeProperties':
        return l10n.moduleTitle_SunBombChallengeProperties;
      case 'moduleTitle_IncreasedCostModuleProperties':
        return l10n.moduleTitle_IncreasedCostModuleProperties;
      case 'moduleTitle_DeathHoleModuleProperties':
        return l10n.moduleTitle_DeathHoleModuleProperties;
      case 'moduleTitle_ZombieMoveFastModuleProperties':
        return l10n.moduleTitle_ZombieMoveFastModuleProperties;
      case 'moduleTitle_InitialPlantProperties':
        return l10n.moduleTitle_InitialPlantProperties;
      case 'moduleTitle_InitialPlantEntryProperties':
        return l10n.moduleTitle_InitialPlantEntryProperties;
      case 'moduleTitle_InitialZombieProperties':
        return l10n.moduleTitle_InitialZombieProperties;
      case 'moduleTitle_InitialGridItemProperties':
        return l10n.moduleTitle_InitialGridItemProperties;
      case 'moduleTitle_ProtectThePlantChallengeProperties':
        return l10n.moduleTitle_ProtectThePlantChallengeProperties;
      case 'moduleTitle_ProtectTheGridItemChallengeProperties':
        return l10n.moduleTitle_ProtectTheGridItemChallengeProperties;
      case 'moduleTitle_ZombiePotionModuleProperties':
        return l10n.moduleTitle_ZombiePotionModuleProperties;
      case 'moduleTitle_PiratePlankProperties':
        return l10n.moduleTitle_PiratePlankProperties;
      case 'moduleTitle_RailcartProperties':
        return l10n.moduleTitle_RailcartProperties;
      case 'moduleTitle_PowerTileProperties':
        return l10n.moduleTitle_PowerTileProperties;
      case 'moduleTitle_ManholePipelineModuleProperties':
        return l10n.moduleTitle_ManholePipelineModuleProperties;
      case 'moduleTitle_RoofProperties':
        return l10n.moduleTitle_RoofProperties;
      case 'moduleTitle_TideProperties':
        return l10n.moduleTitle_TideProperties;
      case 'moduleTitle_BombProperties':
        return l10n.moduleTitle_BombProperties;
      case 'moduleTitle_BronzeProperties':
        return l10n.moduleTitle_BronzeProperties;
      case 'moduleTitle_WarMistProperties':
        return l10n.moduleTitle_WarMistProperties;
      case 'moduleTitle_RainDarkProperties':
        return l10n.moduleTitle_RainDarkProperties;
      case 'moduleTitle_LawnMowerProperties':
        return l10n.moduleTitle_LawnMowerProperties;
      case 'moduleTitle_TunnelDefendModuleProperties':
        return l10n.moduleTitle_TunnelDefendModuleProperties;
      case 'moduleTitle_ZombieRushModuleProperties':
        return l10n.moduleTitle_ZombieRushModuleProperties;
      case 'moduleTitle_RenaiModuleProperties':
        return l10n.moduleTitle_RenaiModuleProperties;
      case 'moduleTitle_DropShipProperties':
        return l10n.moduleTitle_DropShipProperties;
      case 'moduleTitle_HeianWindModuleProperties':
        return l10n.moduleTitle_HeianWindModuleProperties;
      case 'moduleTitle_RocketZombieFlickModuleProperties':
        return l10n.moduleTitle_RocketZombieFlickModuleProperties;
      case 'moduleTitle_PVZ1PassageModuleProperties':
        return l10n.moduleTitle_PVZ1PassageModuleProperties;
      case 'moduleTitle_PVZ1CopycatsModuleProperties':
        return l10n.moduleTitle_PVZ1CopycatsModuleProperties;
      default:
        return key;
    }
  }

  static String getDescription(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'moduleDesc_WaveManagerModuleProperties':
        return l10n.moduleDesc_WaveManagerModuleProperties;
      case 'moduleDesc_CustomLevelModuleProperties':
        return l10n.moduleDesc_CustomLevelModuleProperties;
      case 'moduleDesc_UnchartedModeNo42UniverseModule':
        return l10n.moduleDesc_UnchartedModeNo42UniverseModule;
      case 'moduleDesc_PVZ2MausoleumModuleUnchartedMode':
        return l10n.moduleDesc_PVZ2MausoleumModuleUnchartedMode;
      case 'moduleDesc_StandardLevelIntroProperties':
        return l10n.moduleDesc_StandardLevelIntroProperties;
      case 'moduleDesc_ZombiesAteYourBrainsProperties':
        return l10n.moduleDesc_ZombiesAteYourBrainsProperties;
      case 'moduleDesc_ZombiesDeadWinConProperties':
        return l10n.moduleDesc_ZombiesDeadWinConProperties;
      case 'moduleDesc_BronzeDeadWinConProperties':
        return l10n.moduleDesc_BronzeDeadWinConProperties;
      case 'moduleDesc_SpermWhaleModuleProperties':
        return l10n.moduleDesc_SpermWhaleModuleProperties;
      case 'moduleDesc_PennyClassroomModuleProperties':
        return l10n.moduleDesc_PennyClassroomModuleProperties;
      case 'moduleDesc_SeedBankProperties':
        return l10n.moduleDesc_SeedBankProperties;
      case 'moduleDesc_ConveyorSeedBankProperties':
        return l10n.moduleDesc_ConveyorSeedBankProperties;
      case 'moduleDesc_SunDropperProperties':
        return l10n.moduleDesc_SunDropperProperties;
      case 'moduleDesc_LevelMutatorMaxSunProps':
        return l10n.moduleDesc_LevelMutatorMaxSunProps;
      case 'moduleDesc_LevelMutatorStartingPlantfoodProps':
        return l10n.moduleDesc_LevelMutatorStartingPlantfoodProps;
      case 'moduleDesc_LevelMutatorRiftTimedSunProps':
        return l10n.moduleDesc_LevelMutatorRiftTimedSunProps;
      case 'moduleDesc_PickupCollectableTutorialProperties':
        return l10n.moduleDesc_PickupCollectableTutorialProperties;
      case 'moduleDesc_StarChallengeModuleProperties':
        return l10n.moduleDesc_StarChallengeModuleProperties;
      case 'moduleDesc_LevelScoringModuleProperties':
        return l10n.moduleDesc_LevelScoringModuleProperties;
      case 'moduleDesc_BowlingMinigameProperties':
        return l10n.moduleDesc_BowlingMinigameProperties;
      case 'moduleDesc_NewBowlingMinigameProperties':
        return l10n.moduleDesc_NewBowlingMinigameProperties;
      case 'moduleDesc_VaseBreakerPresetProperties':
        return l10n.moduleDesc_VaseBreakerPresetProperties;
      case 'moduleDesc_VaseBreakerArcadeModuleProperties':
        return l10n.moduleDesc_VaseBreakerArcadeModuleProperties;
      case 'moduleDesc_VaseBreakerFlowModuleProperties':
        return l10n.moduleDesc_VaseBreakerFlowModuleProperties;
      case 'moduleDesc_EvilDaveProperties':
        return l10n.moduleDesc_EvilDaveProperties;
      case 'moduleDesc_ZombossBattleModuleProperties':
        return l10n.moduleDesc_ZombossBattleModuleProperties;
      case 'moduleDesc_ZombossBattleIntroProperties':
        return l10n.moduleDesc_ZombossBattleIntroProperties;
      case 'moduleDesc_SeedRainProperties':
        return l10n.moduleDesc_SeedRainProperties;
      case 'moduleDesc_LastStandMinigameProperties':
        return l10n.moduleDesc_LastStandMinigameProperties;
      case 'moduleDesc_PVZ1OverwhelmModuleProperties':
        return l10n.moduleDesc_PVZ1OverwhelmModuleProperties;
      case 'moduleDesc_SunBombChallengeProperties':
        return l10n.moduleDesc_SunBombChallengeProperties;
      case 'moduleDesc_IncreasedCostModuleProperties':
        return l10n.moduleDesc_IncreasedCostModuleProperties;
      case 'moduleDesc_DeathHoleModuleProperties':
        return l10n.moduleDesc_DeathHoleModuleProperties;
      case 'moduleDesc_ZombieMoveFastModuleProperties':
        return l10n.moduleDesc_ZombieMoveFastModuleProperties;
      case 'moduleDesc_InitialPlantProperties':
        return l10n.moduleDesc_InitialPlantProperties;
      case 'moduleDesc_InitialPlantEntryProperties':
        return l10n.moduleDesc_InitialPlantEntryProperties;
      case 'moduleDesc_InitialZombieProperties':
        return l10n.moduleDesc_InitialZombieProperties;
      case 'moduleDesc_InitialGridItemProperties':
        return l10n.moduleDesc_InitialGridItemProperties;
      case 'moduleDesc_ProtectThePlantChallengeProperties':
        return l10n.moduleDesc_ProtectThePlantChallengeProperties;
      case 'moduleDesc_ProtectTheGridItemChallengeProperties':
        return l10n.moduleDesc_ProtectTheGridItemChallengeProperties;
      case 'moduleDesc_ZombiePotionModuleProperties':
        return l10n.moduleDesc_ZombiePotionModuleProperties;
      case 'moduleDesc_PiratePlankProperties':
        return l10n.moduleDesc_PiratePlankProperties;
      case 'moduleDesc_RailcartProperties':
        return l10n.moduleDesc_RailcartProperties;
      case 'moduleDesc_PowerTileProperties':
        return l10n.moduleDesc_PowerTileProperties;
      case 'moduleDesc_ManholePipelineModuleProperties':
        return l10n.moduleDesc_ManholePipelineModuleProperties;
      case 'moduleDesc_RoofProperties':
        return l10n.moduleDesc_RoofProperties;
      case 'moduleDesc_TideProperties':
        return l10n.moduleDesc_TideProperties;
      case 'moduleDesc_BombProperties':
        return l10n.moduleDesc_BombProperties;
      case 'moduleDesc_BronzeProperties':
        return l10n.moduleDesc_BronzeProperties;
      case 'moduleDesc_WarMistProperties':
        return l10n.moduleDesc_WarMistProperties;
      case 'moduleDesc_RainDarkProperties':
        return l10n.moduleDesc_RainDarkProperties;
      case 'moduleDesc_LawnMowerProperties':
        return l10n.moduleDesc_LawnMowerProperties;
      case 'moduleDesc_TunnelDefendModuleProperties':
        return l10n.moduleDesc_TunnelDefendModuleProperties;
      case 'moduleDesc_ZombieRushModuleProperties':
        return l10n.moduleDesc_ZombieRushModuleProperties;
      case 'moduleDesc_RenaiModuleProperties':
        return l10n.moduleDesc_RenaiModuleProperties;
      case 'moduleDesc_DropShipProperties':
        return l10n.moduleDesc_DropShipProperties;
      case 'moduleDesc_HeianWindModuleProperties':
        return l10n.moduleDesc_HeianWindModuleProperties;
      case 'moduleDesc_RocketZombieFlickModuleProperties':
        return l10n.moduleDesc_RocketZombieFlickModuleProperties;
      case 'moduleDesc_PVZ1PassageModuleProperties':
        return l10n.moduleDesc_PVZ1PassageModuleProperties;
      case 'moduleDesc_PVZ1CopycatsModuleProperties':
        return l10n.moduleDesc_PVZ1CopycatsModuleProperties;
      default:
        return key;
    }
  }

  static final Map<String, ModuleMetadata> registry = {
    'WaveManagerModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_WaveManagerModuleProperties',
      descriptionKey: 'moduleDesc_WaveManagerModuleProperties',
      icon: Icons.timeline,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'NewWaves',
      initialDataFactory: () => WaveManagerModuleData(
        waveManagerProps: 'RTID(WaveManagerProps@CurrentLevel)',
        dynamicZombies: [
          DynamicZombieGroup(
            pointIncrement: 0,
            startingPoints: 0,
            startingWave: 0,
            zombiePool: [],
            zombieLevel: [],
          ),
        ],
      ),
      routeId: 'WaveManagerModule',
    ),
    'CustomLevelModuleProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_CustomLevelModuleProperties',
      descriptionKey: 'moduleDesc_CustomLevelModuleProperties',
      icon: Icons.home,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultCustomLevel',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'UnchartedModeNo42UniverseModule': const ModuleMetadata(
      titleKey: 'moduleTitle_UnchartedModeNo42UniverseModule',
      descriptionKey: 'moduleDesc_UnchartedModeNo42UniverseModule',
      icon: Icons.science,
      isCore: false,
      allowMultiple: false,
      category: ModuleCategory.base,
      defaultAlias: 'UnchartedModeNo42UniverseModule',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'PVZ2MausoleumModuleUnchartedMode': const ModuleMetadata(
      titleKey: 'moduleTitle_PVZ2MausoleumModuleUnchartedMode',
      descriptionKey: 'moduleDesc_PVZ2MausoleumModuleUnchartedMode',
      icon: Icons.landscape,
      isCore: false,
      allowMultiple: false,
      category: ModuleCategory.base,
      defaultAlias: 'PVZ2MausoleumModuleUnchartedMode',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'StandardLevelIntroProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_StandardLevelIntroProperties',
      descriptionKey: 'moduleDesc_StandardLevelIntroProperties',
      icon: Icons.movie_filter,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'StandardIntro',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'ZombiesAteYourBrainsProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_ZombiesAteYourBrainsProperties',
      descriptionKey: 'moduleDesc_ZombiesAteYourBrainsProperties',
      icon: Icons.dangerous,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultZombieWinCondition',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'ZombiesDeadWinConProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_ZombiesDeadWinConProperties',
      descriptionKey: 'moduleDesc_ZombiesDeadWinConProperties',
      icon: Icons.redeem,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'ZombiesDeadWinCon',
      defaultSource: 'LevelModules',
      routeId: 'UnknownDetail',
    ),
    'BronzeDeadWinConProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BronzeDeadWinConProperties',
      descriptionKey: 'moduleDesc_BronzeDeadWinConProperties',
      icon: Icons.emoji_events,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'BronzeDeadWinCon',
      defaultSource: 'LevelModules',
      initialDataFactory: () => <String, dynamic>{},
      routeId: 'UnknownDetail',
    ),
    'PennyClassroomModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PennyClassroomModuleProperties',
      descriptionKey: 'moduleDesc_PennyClassroomModuleProperties',
      icon: Icons.layers,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'PennyClassroom',
      initialDataFactory: () => PennyClassroomModuleData(),
      routeId: 'PennyClassroomModule',
    ),
    'SeedBankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SeedBankProperties',
      descriptionKey: 'moduleDesc_SeedBankProperties',
      icon: Icons.yard,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.base,
      defaultAlias: 'SeedBank',
      initialDataFactory: () => SeedBankData(),
      routeId: 'SeedBank',
    ),
    'ConveyorSeedBankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ConveyorSeedBankProperties',
      descriptionKey: 'moduleDesc_ConveyorSeedBankProperties',
      icon: Icons.linear_scale,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'ConveyorBelt',
      initialDataFactory: () => ConveyorBeltData(),
      routeId: 'ConveyorBelt',
    ),
    'SunDropperProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_SunDropperProperties',
      descriptionKey: 'moduleDesc_SunDropperProperties',
      icon: Icons.wb_sunny,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'DefaultSunDropper',
      defaultSource: 'LevelModules',
      routeId: 'SunDropper',
    ),
    'LevelMutatorMaxSunProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorMaxSunProps',
      descriptionKey: 'moduleDesc_LevelMutatorMaxSunProps',
      icon: Icons.brightness_high,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'OverrideMaxSun',
      initialDataFactory: () => LevelMutatorMaxSunPropsData(),
      routeId: 'MaxSunModule',
    ),
    'LevelMutatorStartingPlantfoodProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorStartingPlantfoodProps',
      descriptionKey: 'moduleDesc_LevelMutatorStartingPlantfoodProps',
      icon: Icons.eco,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'OverrideStartingPlantFood',
      initialDataFactory: () => LevelMutatorStartingPlantfoodPropsData(),
      routeId: 'StartingPlantfoodModule',
    ),
    'LevelMutatorRiftTimedSunProps': ModuleMetadata(
      titleKey: 'moduleTitle_LevelMutatorRiftTimedSunProps',
      descriptionKey: 'moduleDesc_LevelMutatorRiftTimedSunProps',
      icon: Icons.wb_sunny_outlined,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombieSunDrop',
      initialDataFactory: () => RiftTimedSunModuleData(),
      routeId: 'ZombieSunDropModule',
    ),
    'PickupCollectableTutorialProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PickupCollectableTutorialProperties',
      descriptionKey: 'moduleDesc_PickupCollectableTutorialProperties',
      icon: Icons.school,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'PickupCollectableTutorial',
      initialDataFactory: () => PickupCollectableTutorialData(),
      routeId: 'PickupCollectableTutorial',
    ),
    'StarChallengeModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_StarChallengeModuleProperties',
      descriptionKey: 'moduleDesc_StarChallengeModuleProperties',
      icon: Icons.fact_check,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'ChallengeModule',
      initialDataFactory: () => StarChallengeModuleData(),
      routeId: 'StarChallenge',
    ),
    'LevelScoringModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LevelScoringModuleProperties',
      descriptionKey: 'moduleDesc_LevelScoringModuleProperties',
      icon: Icons.scoreboard,
      isCore: false,
      category: ModuleCategory.base,
      defaultAlias: 'LevelScoring',
      initialDataFactory: () => LevelScoringData(),
      routeId: 'UnknownDetail',
    ),
    'BowlingMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BowlingMinigameProperties',
      descriptionKey: 'moduleDesc_BowlingMinigameProperties',
      icon: Icons.sports_esports,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'BowlingBulbMinigame',
      initialDataFactory: () => BowlingMinigamePropertiesData(),
      routeId: 'BowlingMinigameModule',
    ),
    'NewBowlingMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_NewBowlingMinigameProperties',
      descriptionKey: 'moduleDesc_NewBowlingMinigameProperties',
      icon: Icons.sports_esports,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'NewBowlingBulbMinigame',
      initialDataFactory: () => NewBowlingMinigamePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerPresetProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerPresetProperties',
      descriptionKey: 'moduleDesc_VaseBreakerPresetProperties',
      icon: Icons.grid_4x4,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerProps',
      initialDataFactory: () => VaseBreakerPresetData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerArcadeModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerArcadeModuleProperties',
      descriptionKey: 'moduleDesc_VaseBreakerArcadeModuleProperties',
      icon: Icons.sports_esports,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerArcade',
      defaultSource: 'LevelModules',
      initialDataFactory: () => VaseBreakerArcadeModuleData(),
      routeId: 'UnknownDetail',
    ),
    'VaseBreakerFlowModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_VaseBreakerFlowModuleProperties',
      descriptionKey: 'moduleDesc_VaseBreakerFlowModuleProperties',
      icon: Icons.next_plan,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'VaseBreakerFlow',
      defaultSource: 'LevelModules',
      initialDataFactory: () => VaseBreakerFlowModuleData(),
      routeId: 'UnknownDetail',
    ),
    'EvilDaveProperties': ModuleMetadata(
      titleKey: 'moduleTitle_EvilDaveProperties',
      descriptionKey: 'moduleDesc_EvilDaveProperties',
      icon: Icons.emoji_people,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'EvilDave',
      initialDataFactory: () => EvilDavePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'ZombossBattleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombossBattleModuleProperties',
      descriptionKey: 'moduleDesc_ZombossBattleModuleProperties',
      icon: Icons.dangerous,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombossBattle',
      initialDataFactory: () => ZombossBattleModuleData(),
      routeId: 'ZombossSelection',
    ),
    'ZombossBattleIntroProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombossBattleIntroProperties',
      descriptionKey: 'moduleDesc_ZombossBattleIntroProperties',
      icon: Icons.movie_filter,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombossBattleIntro',
      initialDataFactory: () => ZombossBattleIntroData(),
      routeId: 'UnknownDetail',
    ),
    'SeedRainProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SeedRainProperties',
      descriptionKey: 'moduleDesc_SeedRainProperties',
      icon: Icons.thunderstorm,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'SeedRain',
      initialDataFactory: () => SeedRainPropertiesData(),
      routeId: 'SeedRainModule',
    ),
    'LastStandMinigameProperties': ModuleMetadata(
      titleKey: 'moduleTitle_LastStandMinigameProperties',
      descriptionKey: 'moduleDesc_LastStandMinigameProperties',
      icon: Icons.shield,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'LastStand',
      initialDataFactory: () => LastStandMinigamePropertiesData(),
      routeId: 'LastStandMinigame',
    ),
    'PVZ1OverwhelmModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1OverwhelmModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1OverwhelmModuleProperties',
      icon: Icons.local_florist,
      isCore: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PVZ1Overwhelm',
      initialDataFactory: () => PVZ1OverwhelmModulePropertiesData(),
      routeId: 'UnknownDetail',
    ),
    'SunBombChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SunBombChallengeProperties',
      descriptionKey: 'moduleDesc_SunBombChallengeProperties',
      icon: Icons.brightness_high,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'SunBombs',
      initialDataFactory: () => SunBombChallengeData(),
      routeId: 'SunBombChallenge',
    ),
    'IncreasedCostModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_IncreasedCostModuleProperties',
      descriptionKey: 'moduleDesc_IncreasedCostModuleProperties',
      icon: Icons.trending_up,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'IncreasedCostModule',
      initialDataFactory: () => IncreasedCostModulePropertiesData(),
      routeId: 'IncreasedCostModule',
    ),
    'DeathHoleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_DeathHoleModuleProperties',
      descriptionKey: 'moduleDesc_DeathHoleModuleProperties',
      icon: Icons.trip_origin,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'DeathHoleModule',
      initialDataFactory: () => DeathHoleModuleData(),
      routeId: 'DeathHoleModule',
    ),
    'ZombieMoveFastModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombieMoveFastModuleProperties',
      descriptionKey: 'moduleDesc_ZombieMoveFastModuleProperties',
      icon: Icons.fast_forward,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'FastSpeed',
      initialDataFactory: () => ZombieMoveFastModulePropertiesData(),
      routeId: 'ZombieMoveFastModule',
    ),
    'InitialPlantProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialPlantProperties',
      descriptionKey: 'moduleDesc_InitialPlantProperties',
      icon: Icons.ac_unit,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'FrozenPlantPlacement',
      initialDataFactory: () => InitialPlantPropertiesData(),
      routeId: 'InitialPlantProperties',
    ),
    'InitialPlantEntryProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialPlantEntryProperties',
      descriptionKey: 'moduleDesc_InitialPlantEntryProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'InitialPlants',
      initialDataFactory: () => InitialPlantEntryData(),
      routeId: 'InitialPlantEntry',
    ),
    'InitialZombieProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialZombieProperties',
      descriptionKey: 'moduleDesc_InitialZombieProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'FrozenZombiePlacement',
      initialDataFactory: () => InitialZombieEntryData(),
      routeId: 'InitialZombieEntry',
    ),
    'InitialGridItemProperties': ModuleMetadata(
      titleKey: 'moduleTitle_InitialGridItemProperties',
      descriptionKey: 'moduleDesc_InitialGridItemProperties',
      icon: Icons.widgets,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'GridItemPlacement',
      initialDataFactory: () => InitialGridItemEntryData(),
      routeId: 'InitialGridItemEntry',
    ),
    'ProtectThePlantChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ProtectThePlantChallengeProperties',
      descriptionKey: 'moduleDesc_ProtectThePlantChallengeProperties',
      icon: Icons.security,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ProtectThePlant',
      initialDataFactory: () => ProtectThePlantChallengePropertiesData(),
      routeId: 'ProtectThePlant',
    ),
    'ProtectTheGridItemChallengeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ProtectTheGridItemChallengeProperties',
      descriptionKey: 'moduleDesc_ProtectTheGridItemChallengeProperties',
      icon: Icons.security,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ProtectTheGridItem',
      initialDataFactory: () => ProtectTheGridItemChallengePropertiesData(),
      routeId: 'ProtectTheGridItem',
    ),
    'ZombiePotionModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombiePotionModuleProperties',
      descriptionKey: 'moduleDesc_ZombiePotionModuleProperties',
      icon: Icons.science,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'ZombiePotions',
      initialDataFactory: () => ZombiePotionModulePropertiesData(),
      routeId: 'ZombiePotionModuleProperties',
    ),
    'PiratePlankProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PiratePlankProperties',
      descriptionKey: 'moduleDesc_PiratePlankProperties',
      icon: Icons.edit_road,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'PiratePlanks',
      initialDataFactory: () => PiratePlankPropertiesData(),
      routeId: 'PiratePlank',
    ),
    'RailcartProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RailcartProperties',
      descriptionKey: 'moduleDesc_RailcartProperties',
      icon: Icons.edit_road,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'Railcarts',
      initialDataFactory: () => RailcartPropertiesData(),
      routeId: 'Railcart',
    ),
    'PowerTileProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PowerTileProperties',
      descriptionKey: 'moduleDesc_PowerTileProperties',
      icon: Icons.bolt,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'FutureLinkedTileGroups',
      initialDataFactory: () => PowerTilePropertiesData(),
      routeId: 'PowerTile',
    ),
    'ManholePipelineModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ManholePipelineModuleProperties',
      descriptionKey: 'moduleDesc_ManholePipelineModuleProperties',
      icon: Icons.timeline,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'ManholePipeline',
      initialDataFactory: () => ManholePipelineModuleData(),
      routeId: 'ManholePipelineModule',
    ),
    'RoofProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RoofProperties',
      descriptionKey: 'moduleDesc_RoofProperties',
      icon: Icons.local_florist,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'RoofProps',
      initialDataFactory: () => RoofPropertiesData(),
      routeId: 'RoofProperties',
    ),
    'TideProperties': ModuleMetadata(
      titleKey: 'moduleTitle_TideProperties',
      descriptionKey: 'moduleDesc_TideProperties',
      icon: Icons.water_drop,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'Tide',
      initialDataFactory: () => TidePropertiesData(),
      routeId: 'Tide',
    ),
    'BombProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BombProperties',
      descriptionKey: 'moduleDesc_BombProperties',
      icon: Icons.local_fire_department,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'Bombs',
      initialDataFactory: () => BombPropertiesData(),
      routeId: 'Bombs',
    ),
    'BronzeProperties': ModuleMetadata(
      titleKey: 'moduleTitle_BronzeProperties',
      descriptionKey: 'moduleDesc_BronzeProperties',
      icon: Icons.fitness_center,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'Bronze',
      initialDataFactory: () => BronzePropertiesData(),
      routeId: 'Bronze',
    ),
    'WarMistProperties': ModuleMetadata(
      titleKey: 'moduleTitle_WarMistProperties',
      descriptionKey: 'moduleDesc_WarMistProperties',
      icon: Icons.cloud,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'WarMist',
      initialDataFactory: () => WarMistPropertiesData(),
      routeId: 'WarMistProperties',
    ),
    'RainDarkProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_RainDarkProperties',
      descriptionKey: 'moduleDesc_RainDarkProperties',
      icon: Icons.ac_unit,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'DefaultSnow',
      defaultSource: 'LevelModules',
      routeId: 'RainDarkProperties',
    ),
    'LawnMowerProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_LawnMowerProperties',
      descriptionKey: 'moduleDesc_LawnMowerProperties',
      icon: Icons.cleaning_services,
      isCore: true,
      category: ModuleCategory.base,
      defaultAlias: 'FrontLawnMowers',
      defaultSource: 'LevelModules',
      routeId: 'LawnMower',
    ),
    'TunnelDefendModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_TunnelDefendModuleProperties',
      descriptionKey: 'moduleDesc_TunnelDefendModuleProperties',
      icon: Icons.landscape,
      isCore: true,
      category: ModuleCategory.scene,
      defaultAlias: 'TunnelDefend',
      initialDataFactory: () => TunnelDefendModuleData(),
      routeId: 'TunnelDefendModule',
    ),
    'ZombieRushModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_ZombieRushModuleProperties',
      descriptionKey: 'moduleDesc_ZombieRushModuleProperties',
      icon: Icons.timer,
      isCore: true,
      category: ModuleCategory.mode,
      defaultAlias: 'ZombieRushModule',
      initialDataFactory: () => ZombieRushModuleData(),
      routeId: 'ZombieRushModule',
    ),
    'RenaiModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_RenaiModuleProperties',
      descriptionKey: 'moduleDesc_RenaiModuleProperties',
      icon: Icons.architecture,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.scene,
      defaultAlias: 'RenaiModule',
      initialDataFactory: () => RenaiModulePropertiesData(),
      routeId: 'RenaiModule',
    ),
    'DropShipProperties': ModuleMetadata(
      titleKey: 'moduleTitle_DropShipProperties',
      descriptionKey: 'moduleDesc_DropShipProperties',
      icon: Icons.flight_land,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'DropShip',
      initialDataFactory: () => DropShipPropertiesData(),
      routeId: 'DropShip',
    ),
    'HeianWindModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_HeianWindModuleProperties',
      descriptionKey: 'moduleDesc_HeianWindModuleProperties',
      icon: Icons.air,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'HeianWindModule',
      initialDataFactory: () => HeianWindModulePropertiesData(),
      routeId: 'HeianWindModule',
    ),
    'SpermWhaleModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_SpermWhaleModuleProperties',
      descriptionKey: 'moduleDesc_SpermWhaleModuleProperties',
      icon: Icons.water,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'SpermWhaleModule',
      initialDataFactory: () => SpermWhaleModulePropertiesData(),
      routeId: 'SpermWhaleModule',
    ),
    'RocketZombieFlickModuleProperties': const ModuleMetadata(
      titleKey: 'moduleTitle_RocketZombieFlickModuleProperties',
      descriptionKey: 'moduleDesc_RocketZombieFlickModuleProperties',
      icon: Icons.swipe_vertical,
      isCore: false,
      allowMultiple: false,
      category: ModuleCategory.gimmick,
      defaultAlias: 'RocketZombieFlick',
      routeId: 'UnknownDetail',
    ),
    'PVZ1PassageModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1PassageModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1PassageModuleProperties',
      icon: Icons.swap_horiz,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PassageModule',
      initialDataFactory: () => PVZ1PassageModulePropertiesData(),
      routeId: 'PVZ1PassageModule',
    ),
    'PVZ1CopycatsModuleProperties': ModuleMetadata(
      titleKey: 'moduleTitle_PVZ1CopycatsModuleProperties',
      descriptionKey: 'moduleDesc_PVZ1CopycatsModuleProperties',
      icon: Icons.auto_awesome,
      isCore: true,
      allowMultiple: false,
      category: ModuleCategory.mode,
      defaultAlias: 'PVZ1CopycatsModule',
      initialDataFactory: () => PVZ1CopycatsModulePropertiesData(),
      routeId: 'PVZ1CopycatsModule',
    ),
  };

  static List<ModuleMetadata> get all {
    return registry.entries
        .map((e) => e.value.copyWith(objClass: e.key))
        .toList();
  }
}

extension ModuleMetadataCopyWith on ModuleMetadata {
  ModuleMetadata copyWith({
    String? titleKey,
    String? descriptionKey,
    IconData? icon,
    bool? isCore,
    ModuleCategory? category,
    String? defaultAlias,
    String? defaultSource,
    bool? allowMultiple,
    dynamic Function()? initialDataFactory,
    String? routeId,
    String? objClass,
  }) {
    return ModuleMetadata(
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      icon: icon ?? this.icon,
      isCore: isCore ?? this.isCore,
      category: category ?? this.category,
      defaultAlias: defaultAlias ?? this.defaultAlias,
      defaultSource: defaultSource ?? this.defaultSource,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      initialDataFactory: initialDataFactory ?? this.initialDataFactory,
      routeId: routeId ?? this.routeId,
      objClass: objClass ?? this.objClass,
    );
  }
}

extension ModuleCategoryTitle on ModuleCategory {
  String get title {
    switch (this) {
      case ModuleCategory.base:
        return 'Base';
      case ModuleCategory.mode:
        return 'Mode';
      case ModuleCategory.scene:
        return 'Scene';
      case ModuleCategory.gimmick:
        return 'Gimmick';
    }
  }
}
