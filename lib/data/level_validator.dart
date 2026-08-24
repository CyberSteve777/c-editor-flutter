import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/registry/conflict_registry.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ValidationIssue {
  final String title;
  final String message;
  final bool isError;
  final List<String> bulletPoints;

  ValidationIssue({
    required this.title,
    required this.message,
    this.isError = false,
    this.bulletPoints = const [],
  });
}

class LevelValidator {
  static const _internalTagToModule = {
    'parallel': 'UnchartedModeNo42UniverseModule',
    'mausoleum': 'PVZ2MausoleumModuleUnchartedMode',
    '_internal_copycats': 'PVZ1CopycatsModuleProperties',
  };

  static List<ValidationIssue> validate(BuildContext context, PvzLevelFile levelFile) {
    final l10n = AppLocalizations.of(context)!;
    final issues = <ValidationIssue>[];
    
    final parsedData = LevelParser.parseLevel(levelFile);
    final levelDef = parsedData.levelDef;
    if (levelDef == null) return issues;

    final existingObjClasses = _getModuleObjClasses(parsedData);

    // 1. Module Conflicts (Errors)
    final conflicts = ConflictRegistry.getActiveConflicts(context, existingObjClasses);
    for (final pair in conflicts) {
      issues.add(ValidationIssue(
        title: pair.first,
        message: pair.second,
        isError: true,
      ));
    }

    // 2. Missing module for parallel/initial plants (Errors)
    final plantModuleWarnings = _getMissingModuleWarnings(levelFile, parsedData, existingObjClasses);
    for (final entry in plantModuleWarnings.entries) {
      final meta = ModuleRegistry.getMetadata(entry.key);
      final moduleName = meta.getTitle(context);
      final repo = PlantRepository();
      final plantList = entry.value
          .map((id) => _plantDisplayName(context, repo, id))
          .join(', ');
      
      issues.add(ValidationIssue(
        title: l10n.missingPlantModuleWarningTitle,
        message: l10n.missingModuleForPlantsWarning(moduleName, plantList),
        isError: true,
      ));
    }

    // 3. Missing Essentials (Warnings)
    final missingEssentials = _calculateMissingModules(existingObjClasses);
    if (missingEssentials.isNotEmpty) {
      issues.add(ValidationIssue(
        title: l10n.missingModules,
        message: l10n.missingModulesRecommended,
        isError: false,
        bulletPoints: missingEssentials.map((m) => m.getTitle(context)).toList(),
      ));
    }

    // 4. Glacier Module Compatibility (Warning)
    if (GlacierModulePropertiesData.shouldShowCompatibilityWarning(
      levelFile: levelFile,
      moduleObjClasses: existingObjClasses,
    )) {
      issues.add(ValidationIssue(
        title: ModuleRegistry.getMetadata('GlacierModuleProperties').getTitle(context),
        message: l10n.glacierModuleCompatibilityWarning,
        isError: false,
      ));
    }

    // 5. Tunnel Defend / Expedition Tiles recommendations (Warnings)
    final hasTunnelDefend = _hasTunnelDefendModule(parsedData);
    if (_shouldRecommendTunnelDefendModule(levelDef, hasTunnelDefend)) {
      issues.add(ValidationIssue(
        title: l10n.recommendedTunnelDefendTitle,
        message: l10n.recommendedTunnelDefendBody,
        isError: false,
      ));
    }

    final hasExpeditionTiles = _hasExpeditionTilesModule(parsedData);
    if (!hasExpeditionTiles &&
        LevelParser.isSouDaCheLawn(levelDef, levelFile)) {
      issues.add(
        ValidationIssue(
          title: l10n.recommendedExpeditionTilesTitle,
          message: l10n.recommendedExpeditionTilesBody,
          isError: false,
        ),
      );
    }
    if (hasTunnelDefend && hasExpeditionTiles) {
      issues.add(
        ValidationIssue(
          title: l10n.tunnelExpeditionCompatibilityWarningTitle,
          message: l10n.tunnelExpeditionCompatibilityWarningBody,
          isError: false,
        ),
      );
    }
    if (hasExpeditionTiles &&
        LevelParser.isUnderwaterWorldSixRowLawn(levelDef, levelFile)) {
      issues.add(
        ValidationIssue(
          title: l10n.stageMismatch,
          message: l10n.expeditionTilesUnderwaterMismatchWarning,
          isError: true,
        ),
      );
    }

    // 6. 6-Row Data Warning (Warning)
    if (_check6RowDataIn5RowStage(levelFile, parsedData)) {
      issues.add(ValidationIssue(
        title: l10n.warning,
        message: l10n.warningStageSwitchedTo5Rows,
        isError: false,
      ));
    }

    return issues;
  }

  static Set<String> _getModuleObjClasses(ParsedLevelData parsedData) {
    if (parsedData.levelDef == null) return {};
    return parsedData.levelDef!.modules.map((rtid) {
      final info = RtidParser.parse(rtid);
      if (info == null) return '';
      if (info.source == 'CurrentLevel') {
        return parsedData.objectMap[info.alias]?.objClass ?? '';
      }
      return ReferenceRepository.instance.getObjClass(info.alias) ?? '';
    }).where((e) => e.isNotEmpty).toSet();
  }

  static bool _hasExpeditionTilesModule(ParsedLevelData parsedData) {
    final levelDef = parsedData.levelDef;
    if (levelDef == null) return false;
    for (final rtid in levelDef.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      String? objClass;
      dynamic objData;
      if (info.source == 'CurrentLevel') {
        final obj = parsedData.objectMap[info.alias];
        objClass = obj?.objClass;
        objData = obj?.objData;
      } else {
        final obj = ReferenceRepository.instance.objectForAlias(info.alias);
        objClass = obj?.objClass;
        objData = obj?.objData;
      }
      if (_isExpeditionTilesModule(
        alias: info.alias,
        objClass: objClass,
        objData: objData,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _hasTunnelDefendModule(ParsedLevelData parsedData) {
    final levelDef = parsedData.levelDef;
    if (levelDef == null) return false;
    for (final rtid in levelDef.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      String? objClass;
      dynamic objData;
      if (info.source == 'CurrentLevel') {
        final obj = parsedData.objectMap[info.alias];
        objClass = obj?.objClass;
        objData = obj?.objData;
      } else {
        final obj = ReferenceRepository.instance.objectForAlias(info.alias);
        objClass = obj?.objClass;
        objData = obj?.objData;
      }
      if (objClass != 'TunnelDefendModuleProperties') continue;
      if (!_isExpeditionTilesModule(
        alias: info.alias,
        objClass: objClass,
        objData: objData,
      )) {
        return true;
      }
    }
    return false;
  }

  static bool _isExpeditionTilesModule({
    required String alias,
    required String? objClass,
    required dynamic objData,
  }) {
    if (objClass != 'TunnelDefendModuleProperties') return false;
    if (alias == 'SouDaCheTunnelDefendDefault' ||
        alias.startsWith('SoudacheTunnelDefendStage')) {
      return true;
    }
    if (objData is Map) {
      return (objData['BrickMapIndex'] as num?)?.toInt() == 3;
    }
    return false;
  }

  static Map<String, List<String>> _getMissingModuleWarnings(
    PvzLevelFile levelFile,
    ParsedLevelData parsedData,
    Set<String> levelModules,
  ) {
    final plantIds = _collectPlantIdsInLevel(levelFile);
    final repo = PlantRepository();
    final warnings = <String, Set<String>>{};
    for (final plantId in plantIds) {
      final info = repo.getPlantInfoById(plantId);
      if (info == null) continue;
      for (final entry in _internalTagToModule.entries) {
        if (!info.hasInternalTag(entry.key)) continue;
        final moduleClass = entry.value;
        if (levelModules.contains(moduleClass)) continue;
        warnings.putIfAbsent(moduleClass, () => {}).add(plantId);
      }
    }
    return warnings.map((k, v) => MapEntry(k, v.toList()..sort()));
  }

  static Set<String> _collectPlantIdsInLevel(PvzLevelFile levelFile) {
    final plantIds = <String>{};
    for (final obj in levelFile.objects) {
      _collectPlantIdsFromDynamic(obj.objData, plantIds);
    }
    return plantIds;
  }

  static void _collectPlantIdsFromDynamic(dynamic data, Set<String> out) {
    if (data is Map) {
      for (final entry in data.entries) {
        final k = entry.key as String;
        final v = entry.value;
        if (k == 'PresetPlantList' ||
            k == 'PlantWhiteList' ||
            k == 'PlantBlackList') {
          if (v is List) {
            for (final e in v) {
              if (e is String && e.isNotEmpty) out.add(e);
            }
          }
        } else if (k == 'PlantMap' && v is Map) {
          for (final key in v.keys) {
            if (key is String && key.isNotEmpty) out.add(key);
          }
        } else if (k == 'InitialPlantList' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final pt = e['PlantType'];
              if (pt is String && pt.isNotEmpty) out.add(pt);
            }
          }
        } else if ((k == 'InitialPlantPlacements' || k == 'Placements') &&
            v is List) {
          for (final e in v) {
            if (e is Map) {
              final tn = e['TypeName'];
              if (tn is String && tn.isNotEmpty) out.add(tn);
            }
          }
        } else if (k == 'Plants' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final pt = e['PlantType'];
              if (pt is String && pt.isNotEmpty) out.add(pt);
              final pts = e['PlantTypes'];
              if (pts is List) {
                for (final p in pts) {
                  if (p is String && p.isNotEmpty) out.add(p);
                }
              }
            }
          }
        } else if (k == 'Vases' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final ptn = e['PlantTypeName'];
              if (ptn is String && ptn.isNotEmpty) out.add(ptn);
            }
          }
        } else if (k == 'SeedRains' && v is List) {
          for (final e in v) {
            if (e is Map) {
              final ptn = e['PlantTypeName'];
              if (ptn is String && ptn.isNotEmpty) out.add(ptn);
            }
          }
        } else if (k == 'SpawnPlantName') {
          if (v is List) {
            for (final p in v) {
              if (p is String && p.isNotEmpty) out.add(p);
            }
          } else if (v is String && v.isNotEmpty) {
            out.add(v);
          }
        } else if (k == 'PlantTypeName' && v is String && v.isNotEmpty) {
          out.add(v);
        }
        _collectPlantIdsFromDynamic(v, out);
      }
    } else if (data is List) {
      for (final e in data) {
        _collectPlantIdsFromDynamic(e, out);
      }
    }
  }

  static String _plantDisplayName(
    BuildContext context,
    PlantRepository repo,
    String plantId,
  ) {
    final key = repo.getName(plantId);
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    return plantId
        .split('_')
        .map(
          (s) => s.isEmpty
              ? ''
              : s[0].toUpperCase() + s.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  static List<ModuleMetadata> _calculateMissingModules(Set<String> existingClasses) {
    final isVaseBreaker =
        existingClasses.contains('VaseBreakerPresetProperties') ||
        existingClasses.contains('VaseBreakerArcadeModuleProperties') ||
        existingClasses.contains('VaseBreakerFlowModuleProperties');
    final isZombossMechBattle =
        existingClasses.contains('ZombossBattleModuleProperties') ||
        existingClasses.contains('ZombossBattleIntroProperties');
    final isZombossBattle = existingClasses.contains(
      'ZombossLastStandMinigameProperties',
    );
    final isLastStand = existingClasses.contains('LastStandMinigameProperties');
    final isCowboyMinigame = existingClasses.contains('CowboyMinigameProperties');
    final isEvilDave = existingClasses.contains('EvilDaveProperties');

    final missingList = <String>[];
    if (!existingClasses.contains('CustomLevelModuleProperties')) {
      missingList.add('CustomLevelModuleProperties');
    }
    if (!existingClasses.contains('ZombiesAteYourBrainsProperties')) {
      if (!isEvilDave) missingList.add('ZombiesAteYourBrainsProperties');
    }
    if (!existingClasses.contains('ZombiesDeadWinConProperties') &&
        !existingClasses.contains('BronzeDeadWinConProperties')) {
      if (!isEvilDave && !isZombossMechBattle && !isZombossBattle) {
        missingList.add('ZombiesDeadWinConProperties');
      }
    }
    if (!existingClasses.contains('StandardLevelIntroProperties')) {
      if (!isVaseBreaker &&
          !isLastStand &&
          !isCowboyMinigame &&
          !isZombossMechBattle &&
          !isZombossBattle) {
        missingList.add('StandardLevelIntroProperties');
      }
    }
    if (isVaseBreaker) {
      if (!existingClasses.contains('VaseBreakerPresetProperties')) {
        missingList.add('VaseBreakerPresetProperties');
      }
      if (!existingClasses.contains('VaseBreakerArcadeModuleProperties')) {
        missingList.add('VaseBreakerArcadeModuleProperties');
      }
      if (!existingClasses.contains('VaseBreakerFlowModuleProperties')) {
        missingList.add('VaseBreakerFlowModuleProperties');
      }
    }
    if (isEvilDave) {
      if (!existingClasses.contains('InitialPlantEntryProperties')) {
        missingList.add('InitialPlantEntryProperties');
      }
      if (!existingClasses.contains('SeedBankProperties')) {
        missingList.add('SeedBankProperties');
      }
    }
    if (isZombossMechBattle) {
      if (!existingClasses.contains('ZombossBattleModuleProperties')) {
        missingList.add('ZombossBattleModuleProperties');
      }
      if (!existingClasses.contains('ZombossBattleIntroProperties')) {
        missingList.add('ZombossBattleIntroProperties');
      }
    }
    if (isZombossBattle) {
      if (!existingClasses.contains('ZombossLastStandMinigameProperties')) {
        missingList.add('ZombossLastStandMinigameProperties');
      }
    }
    if (isLastStand) {
      if (!existingClasses.contains('SeedBankProperties')) {
        missingList.add('SeedBankProperties');
      }
    }

    return missingList
        .map((cls) => ModuleRegistry.getMetadata(cls))
        .where((m) => m.titleKey != ModuleRegistry.defaultMetadataKey)
        .toList();
  }

  static bool _shouldRecommendTunnelDefendModule(
    LevelDefinitionData levelDef,
    bool hasTunnelDefendModule,
  ) {
    final stageInfo = RtidParser.parse(levelDef.stageModule);
    final alias = stageInfo?.alias ?? '';
    if (alias != 'UnchartedMausoleumStage' &&
        alias != 'UnchartedMausoleum2Stage') {
      return false;
    }
    return !hasTunnelDefendModule;
  }

  static bool _check6RowDataIn5RowStage(PvzLevelFile levelFile, ParsedLevelData parsedData) {
    final (rows, _) = LevelParser.getGridDimensions(parsedData.levelDef, levelFile);
    if (rows >= 6) return false;
    return LevelParser.has6RowDataInLevel(levelFile);
  }
}
