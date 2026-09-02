import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';

class ModuleConflictRule {
  final Set<String> conflictingClasses;
  final String? titleKey;
  final String? descriptionKey;

  const ModuleConflictRule({
    required this.conflictingClasses,
    this.titleKey,
    this.descriptionKey,
  });
}

class ConflictRegistry {
  static const List<ModuleConflictRule> rules = [
    ModuleConflictRule(
      conflictingClasses: {'SeedBankProperties', 'ConveyorSeedBankProperties'},
      descriptionKey: 'conflictDesc_SeedBankConveyor',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'VaseBreakerPresetProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_VaseBreakerIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'LastStandMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_LastStandIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CowboyMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_CowboyIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'SingleHandedProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_SingleHandedIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'IntroSingleHandedProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_SingleHandedTutorialIntro',
    ),
    ModuleConflictRule(
      conflictingClasses: {'EvilDaveProperties', 'ZombiesDeadWinConProperties'},
      descriptionKey: 'conflictDesc_EvilDaveZombieDrop',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'EvilDaveProperties',
        'ZombiesAteYourBrainsProperties',
      },
      descriptionKey: 'conflictDesc_EvilDaveVictory',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ZombossBattleModuleProperties',
        'ZombiesDeadWinConProperties',
      },
      descriptionKey: 'conflictDesc_ZombossDeathDrop',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ZombossBattleIntroProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_ZombossTwoIntros',
    ),
    ModuleConflictRule(
      conflictingClasses: {'InitialPlantEntryProperties', 'RoofProperties'},
      descriptionKey: 'conflictDesc_InitialPlantEntryRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {'InitialPlantProperties', 'RoofProperties'},
      descriptionKey: 'conflictDesc_InitialPlantRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'ProtectThePlantChallengeProperties',
        'RoofProperties',
      },
      descriptionKey: 'conflictDesc_ProtectPlantRoof',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CustomLevelModuleProperties',
        'LawnMowerProperties',
      },
      descriptionKey: 'conflictDesc_LawnMowerYard',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'WaveGeneratorProperties',
        'WaveManagerModuleProperties',
      },
      descriptionKey: 'conflictDesc_WaveGeneratorWaveManagerModule',
    ),
    ModuleConflictRule(
      conflictingClasses: {'WaveGeneratorProperties', 'WaveManagerProperties'},
      descriptionKey: 'conflictDesc_WaveGeneratorWaveManager',
    ),
    ModuleConflictRule(
      conflictingClasses: {'WaveGeneratorProperties', 'RenaiModuleProperties'},
      descriptionKey: 'conflictDesc_WaveGeneratorRenai',
    ),
    ModuleConflictRule(
      conflictingClasses: {'WaveGeneratorProperties', 'WitchModuleProperties'},
      descriptionKey: 'conflictDesc_WaveGeneratorWitch',
    ),
  ];

  /// Returns list of (localized title, localized description) for active conflicts.
  static List<Pair<String, String>> getActiveConflicts(
    BuildContext context,
    Set<String> existingObjClasses,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final title = l10n.conflictTitle_ModuleLogic;
    final result = rules
        .where((rule) {
          return rule.conflictingClasses.every(
            (cls) => existingObjClasses.contains(cls),
          );
        })
        .map((rule) {
          final desc = rule.descriptionKey != null
              ? _getLocalizedConflictDescription(l10n, rule.descriptionKey!)
              : _generateDefaultDescription(context, rule);
          return Pair(title, desc);
        })
        .toList();

    // Player win modules use objClass names ending in `WinConProperties` (not
    // `WinCondition…`). Only one such module may be present at a time.
    final winConCount = existingObjClasses
        .where((c) => c.endsWith('WinConProperties'))
        .length;
    if (winConCount > 1) {
      result.add(Pair(title, l10n.conflictDesc_WinConditionExclusive));
    }

    return result;
  }

  static String _getLocalizedConflictDescription(
    AppLocalizations l10n,
    String key,
  ) {
    switch (key) {
      case 'conflictDesc_SeedBankConveyor':
        return l10n.conflictDesc_SeedBankConveyor;
      case 'conflictDesc_VaseBreakerIntro':
        return l10n.conflictDesc_VaseBreakerIntro;
      case 'conflictDesc_LastStandIntro':
        return l10n.conflictDesc_LastStandIntro;
      case 'conflictDesc_CowboyIntro':
        return l10n.conflictDesc_CowboyIntro;
      case 'conflictDesc_SingleHandedIntro':
        return l10n.conflictDesc_SingleHandedIntro;
      case 'conflictDesc_SingleHandedTutorialIntro':
        return l10n.conflictDesc_SingleHandedTutorialIntro;
      case 'conflictDesc_EvilDaveZombieDrop':
        return l10n.conflictDesc_EvilDaveZombieDrop;
      case 'conflictDesc_EvilDaveVictory':
        return l10n.conflictDesc_EvilDaveVictory;
      case 'conflictDesc_ZombossDeathDrop':
        return l10n.conflictDesc_ZombossDeathDrop;
      case 'conflictDesc_ZombossTwoIntros':
        return l10n.conflictDesc_ZombossTwoIntros;
      case 'conflictDesc_WinConditionExclusive':
        return l10n.conflictDesc_WinConditionExclusive;
      case 'conflictDesc_InitialPlantEntryRoof':
        return l10n.conflictDesc_InitialPlantEntryRoof;
      case 'conflictDesc_InitialPlantRoof':
        return l10n.conflictDesc_InitialPlantRoof;
      case 'conflictDesc_ProtectPlantRoof':
        return l10n.conflictDesc_ProtectPlantRoof;
      case 'conflictDesc_LawnMowerYard':
        return l10n.conflictDesc_LawnMowerYard;
      case 'conflictDesc_WaveGeneratorWaveManagerModule':
        return l10n.conflictDesc_WaveGeneratorWaveManagerModule;
      case 'conflictDesc_WaveGeneratorWaveManager':
        return l10n.conflictDesc_WaveGeneratorWaveManager;
      case 'conflictDesc_WaveGeneratorRenai':
        return l10n.conflictDesc_WaveGeneratorRenai;
      case 'conflictDesc_WaveGeneratorWitch':
        return l10n.conflictDesc_WaveGeneratorWitch;
      default:
        return key;
    }
  }

  static String _generateDefaultDescription(
    BuildContext context,
    ModuleConflictRule rule,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final names = rule.conflictingClasses.map((cls) {
      return ModuleRegistry.getMetadata(cls).getTitle(context);
    }).toList();
    return l10n.conflictDefaultDescription(
      names[0],
      names.length > 1 ? names[1] : names[0],
    );
  }
}

class Pair<A, B> {
  final A first;
  final B second;
  const Pair(this.first, this.second);
}
