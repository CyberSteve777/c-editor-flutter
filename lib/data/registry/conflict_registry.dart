import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
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
        'CustomLevelModuleProperties',
        'MoonExpertProperties',
      },
      descriptionKey: 'conflictDesc_MoonExpertYard',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'WaveGeneratorProperties',
        'WaveManagerModuleProperties',
      },
      descriptionKey: 'conflictDesc_WaveGeneratorWaveManagerModule',
    ),
    ModuleConflictRule(
      conflictingClasses: {
        'CamelMinigameProperties',
        'StandardLevelIntroProperties',
      },
      descriptionKey: 'conflictDesc_CamelMinigameIntro',
    ),
  ];

  /// Returns list of (localized title, localized description) for active conflicts.
  static List<Pair<String, String>> getActiveConflicts(
    BuildContext context,
    Set<String> existingObjClasses, {
    PvzLevelFile? levelFile,
  }) {
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

    // Statue Maze is only compatible with a small safe list of modules.
    if (existingObjClasses.contains('StatueMazeModuleProperties')) {
      const safeModules = {
        'CustomLevelModuleProperties',
        'StandardLevelIntroProperties',
        'ZombiesAteYourBrainsProperties',
        'ZombiesDeadWinConProperties',
        'BronzeDeadWinConProperties',
        'PennyClassroomModuleProperties',
        'MoonExpertProperties',
        'ZombieMoveFastModuleProperties',
        'ZombieRushModuleProperties',
        'RiftThemeDemoModuleProperties',
        'RainDarkProperties',
        'StarChallengeModuleProperties',
        'StatueMazeModuleProperties',
      };
      for (final cls in existingObjClasses) {
        if (!safeModules.contains(cls)) {
          final meta = ModuleRegistry.getMetadata(cls);
          final moduleName = meta.getTitle(context);
          result.add(Pair(
            l10n.conflictTitle_ModuleLogic,
            l10n.conflictDesc_StatueMazeIncompatible(moduleName),
          ));
        }
      }
    }

    // Camel Minigame only works with camel touch zombies.
    if (existingObjClasses.contains('CamelMinigameProperties') &&
        levelFile != null) {
      final nonTouch = _findNonCamelTouchZombies(levelFile);
      if (nonTouch.isNotEmpty) {
        final names = nonTouch.take(5).join(', ');
        final suffix = nonTouch.length > 5
            ? ' (+${nonTouch.length - 5} more)'
            : '';
        result.add(Pair(
          title,
          l10n.conflictDesc_CamelMinigameNonTouchZombies('$names$suffix'),
        ));
      }
    }

    return result;
  }

  /// Scans zombie type references in WaveGenerator waves only and returns
  /// entries like "zombie_x (wave 3)" for any that are NOT camel touch zombies.
  static List<String> _findNonCamelTouchZombies(PvzLevelFile levelFile) {
    final nonTouch = <String>{};
    // Build custom zombie alias → base TypeName map.
    final customBaseTypes = <String, String>{};
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'ZombieType') continue;
      final aliases = obj.aliases;
      if (aliases == null || aliases.isEmpty) continue;
      final data = obj.objData;
      if (data is! Map<String, dynamic>) continue;
      final baseType = data['TypeName'] as String?;
      if (baseType != null) {
        customBaseTypes[aliases.first] = baseType;
      }
    }
    // Only scan WaveGeneratorProperties objects, tracking wave indices.
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'WaveGeneratorProperties') continue;
      if (obj.objData is! Map) continue;
      final data = obj.objData as Map<String, dynamic>;
      final waves = data['waves'];
      if (waves is List) {
        for (var i = 0; i < waves.length; i++) {
          final wave = waves[i];
          if (wave is! Map) continue;
          final found = <String>{};
          _scanZombieRefs(wave, found, customBaseTypes);
          for (final alias in found) {
            nonTouch.add('$alias (wave ${i + 1})');
          }
        }
      }
      // Also scan non-wave top-level zombie refs (e.g. initial pools).
      final found = <String>{};
      final nonWaves = Map<String, dynamic>.from(data)
        ..remove('waves');
      _scanZombieRefs(nonWaves, found, customBaseTypes);
      for (final alias in found) {
        nonTouch.add('$alias (WaveGenerator)');
      }
    }
    return nonTouch.toList()..sort();
  }

  static final _camelTouchPattern = RegExp(r'camel_.*_touch');
  static final _rtidRegex = RegExp(r'^RTID\(([^@()]+)@([^@()]+)\)$');

  static bool _isCamelTouchAlias(String alias) =>
      _camelTouchPattern.hasMatch(alias);

  static void _addZombieRef(
    String value,
    Set<String> result,
    Map<String, String> customBaseTypes,
  ) {
    final v = value.trim();
    if (v.isEmpty) return;
    final m = _rtidRegex.firstMatch(v);
    if (m != null) {
      final alias = m.group(1)!;
      final source = m.group(2)!;
      if (source == 'ZombieTypes') {
        if (!_isCamelTouchAlias(alias)) result.add(alias);
      } else if (source == 'CurrentLevel') {
        final base = customBaseTypes[alias];
        if (base != null && !_isCamelTouchAlias(base)) {
          result.add(alias);
        }
      }
    } else if (!v.startsWith('RTID(')) {
      // Bare alias.
      if (!_isCamelTouchAlias(v)) result.add(v);
    }
  }

  static void _scanZombieRefs(
    dynamic d,
    Set<String> result,
    Map<String, String> customBaseTypes, {
    bool isZombieEntry = false,
  }) {
    if (d is Map<String, dynamic>) {
      const zombieTypeKeys = {
        'ZombieType',
        'ZombieName',
        'ZombieTypeName',
        'SpiderZombieName',
        'ZombieInsideBallType',
      };
      for (final key in zombieTypeKeys) {
        final value = d[key];
        if (value is String && value.isNotEmpty) {
          _addZombieRef(value, result, customBaseTypes);
        }
      }
      for (final key in const ['Type', 'TypeName']) {
        final value = d[key];
        if (value is String && value.isNotEmpty) {
          if (isZombieEntry || _looksLikeZombieRef(value)) {
            _addZombieRef(value, result, customBaseTypes);
          }
        }
      }
      const zombieCollections = {
        'Zombies',
        'ZombiePool',
        'AddToZombiePool',
        'InitialZombiePlacements',
        'ZombieSpawnData',
        'ZombieTypesToSpawn',
        'InitialZombie',
      };
      for (final entry in d.entries) {
        _scanZombieRefs(
          entry.value,
          result,
          customBaseTypes,
          isZombieEntry: zombieCollections.contains(entry.key),
        );
      }
    } else if (d is List) {
      for (final e in d) {
        _scanZombieRefs(e, result, customBaseTypes, isZombieEntry: isZombieEntry);
      }
    } else if (isZombieEntry && d is String) {
      _addZombieRef(d, result, customBaseTypes);
    }
  }

  static bool _looksLikeZombieRef(String value) {
    final m = _rtidRegex.firstMatch(value.trim());
    if (m == null) return false;
    return m.group(2) == 'ZombieTypes' || m.group(2) == 'CurrentLevel';
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
      case 'conflictDesc_MoonExpertYard':
        return l10n.conflictDesc_MoonExpertYard;
      case 'conflictDesc_WaveGeneratorWaveManagerModule':
        return l10n.conflictDesc_WaveGeneratorWaveManagerModule;
      case 'conflictDesc_WaveGeneratorWaveManager':
        return l10n.conflictDesc_WaveGeneratorWaveManager;
      case 'conflictDesc_CamelMinigameIntro':
        return l10n.conflictDesc_CamelMinigameIntro;
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
