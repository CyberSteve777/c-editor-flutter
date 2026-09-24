import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/issue_registry.dart';

export 'package:c_editor/data/registry/issue_registry.dart'
    show
        LevelIssueSeverity,
        LevelIssue,
        LevelIssueContext,
        LevelModuleRef,
        isExpeditionTilesModule,
        LevelIssueRegistry;

/// Back-compat aliases for the renamed issue types.
typedef LevelWarningSeverity = LevelIssueSeverity;
typedef LevelWarning = LevelIssue;
typedef LevelWarningContext = LevelIssueContext;

/// Compatibility wrapper — prefer [LevelIssueRegistry].
class WarningRegistry {
  static const seeingStarsModule = LevelIssueRegistry.seeingStarsModule;
  static const zombiesDeadWinCon = LevelIssueRegistry.zombiesDeadWinCon;
  static const bronzeDeadWinCon = LevelIssueRegistry.bronzeDeadWinCon;
  static const glacierModule = LevelIssueRegistry.glacierModule;
  static const zombossBattleModule = LevelIssueRegistry.zombossBattleModule;

  static final List<LevelWarningRule> rules = [
    LevelWarningRule(
      id: 'cowboyMinigameConveyorWarning',
      isActive: (ctx) =>
          ctx.hasModule('CowboyMinigameProperties') &&
          !ctx.hasModule('ConveyorSeedBankProperties'),
      title: (_, l10n) => l10n.cowboyMinigameDependencyWarningTitle,
      message: (_, l10n) => l10n.cowboyMinigameConveyorWarning,
    ),
    LevelWarningRule(
      id: 'seeingStarsWinConWarning',
      isActive: (ctx) =>
          ctx.hasModule(seeingStarsModule) && ctx.hasModule(zombiesDeadWinCon),
      title: (_, l10n) => l10n.seeingStarsWinConWarningTitle,
      message: (_, l10n) => l10n.seeingStarsWinConWarning,
    ),
    LevelWarningRule(
      id: 'glacierModuleCompatibilityWarning',
      isActive: (ctx) => GlacierModulePropertiesData.shouldShowCompatibilityWarning(
        levelFile: ctx.levelFile,
        moduleObjClasses: ctx.moduleObjClasses,
      ),
      title: (_, l10n) => l10n.glacierModuleCompatibilityWarningTitle,
      message: (_, l10n) => l10n.glacierModuleCompatibilityWarning,
    ),
    LevelWarningRule(
      id: 'glacierModuleUnderwaterWarning',
      isActive: (ctx) =>
          ctx.hasModuleOrObject(glacierModule) &&
          LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.glacierModuleUnderwaterWarningTitle,
      message: (_, l10n) => l10n.glacierModuleUnderwaterWarning,
    ),
    LevelWarningRule(
      id: 'iceAgePlantPuzzleWarning',
      isActive: (ctx) {
        if (!ctx.hasModuleOrObject(glacierModule)) return false;
        final battle = ctx.firstObject(zombossBattleModule);
        if (battle?.objData is! Map) return false;
        final variation =
            (battle!.objData as Map)['ZombossMechType'] as String?;
        return GlacierModulePresets.isPlantPuzzleVariation(variation);
      },
      title: (_, l10n) => l10n.iceAgePlantPuzzleVariationWarningTitle,
      message: (_, l10n) => l10n.iceAgePlantPuzzleVariationWarning,
    ),
    LevelWarningRule(
      id: 'recommendedTunnelDefend',
      isActive: (ctx) {
        final alias = ctx.stageAlias;
        if (alias != 'UnchartedMausoleumStage' &&
            alias != 'UnchartedMausoleum2Stage') {
          return false;
        }
        return !ctx.hasTunnelDefend;
      },
      title: (_, l10n) => l10n.recommendedTunnelDefendTitle,
      message: (_, l10n) => l10n.recommendedTunnelDefendBody,
    ),
    LevelWarningRule(
      id: 'recommendedExpeditionTiles',
      isActive: (ctx) =>
          !ctx.hasExpeditionTiles &&
          LevelParser.isSouDaCheLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.recommendedExpeditionTilesTitle,
      message: (_, l10n) => l10n.recommendedExpeditionTilesBody,
    ),
    LevelWarningRule(
      id: 'tunnelExpeditionCompatibilityWarning',
      isActive: (ctx) => ctx.hasTunnelDefend && ctx.hasExpeditionTiles,
      title: (_, l10n) => l10n.tunnelExpeditionCompatibilityWarningTitle,
      message: (_, l10n) => l10n.tunnelExpeditionCompatibilityWarningBody,
    ),
    LevelWarningRule(
      id: 'expeditionTilesUnderwaterMismatch',
      severity: LevelWarningSeverity.error,
      isActive: (ctx) =>
          ctx.hasExpeditionTiles &&
          LevelParser.isUnderwaterWorldSixRowLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.stageMismatch,
      message: (_, l10n) => l10n.expeditionTilesUnderwaterMismatchWarning,
    ),
    LevelWarningRule(
      id: 'sixRowDataInFiveRowStage',
      // The editor confirms this interactively when the stage changes; the
      // scan is only repeated on export.
      showInEditor: false,
      isActive: (ctx) {
        final (rows, _) = LevelParser.getGridDimensions(
          ctx.levelDef,
          ctx.levelFile,
        );
        if (rows >= 6) return false;
        return LevelParser.has6RowDataInLevel(ctx.levelFile);
      },
      title: (_, l10n) => l10n.warning,
      message: (_, l10n) => l10n.warningStageSwitchedTo5Rows,
    ),
    LevelWarningRule(
      id: 'targetZombieWithoutOakTrain',
      isActive: (ctx) {
        if (ctx.hasModule('OakTrainProperties')) return false;
        return _hasTargetZombies(ctx.levelFile);
      },
      severity: LevelWarningSeverity.error,
      title: (_, l10n) => l10n.conflictTitle_ModuleLogic,
      message: (_, l10n) => l10n.targetZombieWithoutOakTrainWarning,
    ),
    LevelWarningRule(
      id: 'oakTrainUnderwaterWarning',
      isActive: (ctx) =>
          ctx.hasModule('OakTrainProperties') &&
          LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile),
      severity: LevelWarningSeverity.warning,
      title: (_, l10n) => l10n.oakTrainUnderwaterWarningTitle,
      message: (_, l10n) => l10n.oakTrainUnderwaterWarning,
    ),
    LevelWarningRule(
      id: 'targetZombieInWaveManager',
      isActive: (ctx) {
        if (ctx.hasModule('OakTrainProperties')) return false;
        if (!ctx.hasModule('WaveManagerModuleProperties')) return false;
        return _hasTargetZombies(ctx.levelFile);
      },
      severity: LevelWarningSeverity.warning,
      title: (_, l10n) => l10n.targetZombieInWaveManagerWarningTitle,
      message: (_, l10n) => l10n.targetZombieInWaveManagerWarning,
    ),
    LevelWarningRule(
      id: 'camelMinigameWaveManagerHint',
      isActive: (ctx) =>
          ctx.hasModule('CamelMinigameProperties') &&
          ctx.hasModule('WaveManagerModuleProperties'),
      severity: LevelWarningSeverity.warning,
      title: (_, l10n) => l10n.camelMinigameWaveManagerHintTitle,
      message: (_, l10n) => l10n.camelMinigameWaveManagerHint,
    ),
    LevelWarningRule(
      id: 'waveGeneratorRiseFromGroundWarning',
      isActive: (ctx) {
        if (!ctx.hasModule('WaveGeneratorProperties')) return false;
        final waveGenerator = ctx.firstObject('WaveGeneratorProperties');
        if (waveGenerator?.objData is! Map) return false;
        final waveData = waveGenerator!.objData as Map<String, dynamic>;
        if ((waveData['isRiseFromGroundMode'] as bool?) == true) return true;
        final waves = waveData['waves'];
        if (waves is List) {
          for (final wave in waves) {
            if (wave is Map &&
                (wave['riseFromGroundMode'] as bool?) == true) {
              return true;
            }
          }
        }
        return false;
      },
      severity: LevelWarningSeverity.warning,
      title: (_, l10n) => l10n.waveGeneratorRiseFromGroundWarningTitle,
      message: (_, l10n) => l10n.waveGeneratorRiseFromGroundWarning,
    ),
    LevelWarningRule(
      id: 'goldRoadNonLostCityLawnWarning',
      isActive: (ctx) {
        if (!ctx.hasModule('GoldRoadProperties')) return false;
        if (LevelParser.isNativeLostCityLawn(ctx.levelDef, ctx.levelFile)) {
          return false;
        }
        if (LevelParser.usesLostCityBackground(ctx.levelDef, ctx.levelFile)) {
          return false;
        }
        if (LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile)) return false;
        return true;
      },
      title: (_, l10n) => l10n.goldRoadNonLostCityLawnWarningTitle,
      message: (_, l10n) => l10n.goldRoadNonLostCityLawnWarning,
    ),
    LevelWarningRule(
      id: 'goldRoadCustomLostCityLawnWarning',
      isActive: (ctx) {
        if (!ctx.hasModule('GoldRoadProperties')) return false;
        if (LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile)) return false;
        if (LevelParser.isNativeLostCityLawn(ctx.levelDef, ctx.levelFile)) {
          return false;
        }
        return LevelParser.usesLostCityBackground(ctx.levelDef, ctx.levelFile);
      },
      title: (_, l10n) => l10n.goldRoadCustomLostCityLawnWarningTitle,
      message: (_, l10n) => l10n.goldRoadCustomLostCityLawnWarning,
    ),
    LevelWarningRule(
      id: 'goldRoadDeepseaLawnWarning',
      isActive: (ctx) =>
          ctx.hasModule('GoldRoadProperties') &&
          LevelParser.isDeepSeaLawn(ctx.levelDef, ctx.levelFile),
      title: (_, l10n) => l10n.goldRoadDeepseaLawnWarningTitle,
      message: (_, l10n) => l10n.goldRoadDeepseaLawnWarning,
    ),
  ];

  /// Evaluates every rule against [ctx] and returns the localized results in
  /// declaration order.
  static List<LevelWarning> getActiveWarnings(
    BuildContext context,
    LevelWarningContext ctx, {
    bool editorOnly = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return rules
        .where((rule) => !editorOnly || rule.showInEditor)
        .where((rule) => rule.isActive(ctx))
        .map(
          (rule) => LevelWarning(
            id: rule.id,
            severity: rule.severity,
            title: rule.title(context, l10n),
            message: rule.message(context, l10n),
          ),
        )
        .toList();
  }

  /// Convenience for callers that only hold a level file.
  static List<LevelWarning> forLevel(
  static List<LevelIssue> forLevel(
    BuildContext context,
    PvzLevelFile levelFile, {
    ParsedLevelData? parsed,
    bool editorOnly = false,
  }) {
    return getActiveWarnings(
      context,
      LevelWarningContext.fromLevel(levelFile, parsed: parsed),
      editorOnly: editorOnly,
    );
  }

  static bool _isTargetZombieAlias(String alias) {
    return alias.startsWith('zombie_target_arrow') ||
        alias.startsWith('zombie_target_bottle') ||
        alias.startsWith('zombie_target_wizard') ||
        alias.startsWith('zombie_target_archmage') ||
        alias.startsWith('zombie_target_gargantuar');
  }

  static bool _hasTargetZombies(PvzLevelFile levelFile) {
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
    for (final obj in levelFile.objects) {
      if (obj.objData is! Map) continue;
      if (_scanForTargetZombies(obj.objData, customBaseTypes)) {
        return true;
      }
    }
    return false;
  }

  static final _rtidRegex = RegExp(r'^RTID\(([^@()]+)@([^@()]+)\)$');

  static bool _scanForTargetZombies(
    dynamic d,
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
          if (_isTargetZombieString(value, customBaseTypes)) return true;
        }
      }
      for (final key in const ['Type', 'TypeName']) {
        final value = d[key];
        if (value is String && value.isNotEmpty) {
          if (isZombieEntry || _looksLikeZombieRef(value)) {
            if (_isTargetZombieString(value, customBaseTypes)) return true;
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
        if (_scanForTargetZombies(
          entry.value,
          customBaseTypes,
          isZombieEntry: zombieCollections.contains(entry.key),
        )) {
          return true;
        }
      }
    } else if (d is List) {
      for (final e in d) {
        if (_scanForTargetZombies(
          e,
          customBaseTypes,
          isZombieEntry: isZombieEntry,
        )) {
          return true;
        }
      }
    } else if (isZombieEntry && d is String) {
      if (_isTargetZombieString(d, customBaseTypes)) return true;
    }
    return false;
  }

  static bool _isTargetZombieString(
    String value,
    Map<String, String> customBaseTypes,
  ) {
    final v = value.trim();
    if (v.isEmpty) return false;
    final m = _rtidRegex.firstMatch(v);
    if (m != null) {
      final alias = m.group(1)!;
      final source = m.group(2)!;
      if (source == 'ZombieTypes') {
        return _isTargetZombieAlias(alias);
      } else if (source == 'CurrentLevel') {
        final base = customBaseTypes[alias];
        return base != null && _isTargetZombieAlias(base);
      }
    } else if (!v.startsWith('RTID(')) {
      return _isTargetZombieAlias(v);
    }
    return false;
  }

  static bool _looksLikeZombieRef(String value) {
    final m = _rtidRegex.firstMatch(value.trim());
    if (m == null) return false;
    return m.group(2) == 'ZombieTypes' || m.group(2) == 'CurrentLevel';
  }
  }) => LevelIssueRegistry.forLevel(
    context,
    levelFile,
    parsed: parsed,
    editorOnly: editorOnly,
  );
}
