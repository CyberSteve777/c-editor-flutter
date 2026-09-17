import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/glacier_module_presets.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// How serious a level warning is. Errors use the red conflict styling,
/// warnings use the yellow [EditorWarningBanner] styling.
enum LevelWarningSeverity { warning, error }

/// One entry of `LevelDefinition.Modules`, resolved to its object class.
class LevelModuleRef {
  const LevelModuleRef({
    required this.rtid,
    required this.alias,
    required this.objClass,
    required this.objData,
    required this.isCurrentLevel,
  });

  final String rtid;
  final String alias;
  final String objClass;
  final dynamic objData;
  final bool isCurrentLevel;

  /// "Expedition Tiles" is a Tunnel Defend preset with `BrickMapIndex == 3`
  /// (or the stock SouDaChe aliases) and behaves like its own module.
  bool get isExpeditionTiles => isExpeditionTilesModule(
    alias: alias,
    objClass: objClass,
    objData: objData,
  );
}

bool isExpeditionTilesModule({
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

/// Everything a [LevelWarningRule] may inspect. Build one per evaluation with
/// [LevelWarningContext.fromLevel] so the module list is resolved only once.
class LevelWarningContext {
  LevelWarningContext._({
    required this.levelFile,
    required this.parsed,
    required this.modules,
  }) : moduleObjClasses = modules.map((m) => m.objClass).toSet(),
       objectObjClasses = levelFile.objects.map((o) => o.objClass).toSet();

  factory LevelWarningContext.fromLevel(
    PvzLevelFile levelFile, {
    ParsedLevelData? parsed,
  }) {
    final data = parsed ?? LevelParser.parseLevel(levelFile);
    final modules = <LevelModuleRef>[];
    for (final rtid in data.levelDef?.modules ?? const <String>[]) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      if (info.source == 'CurrentLevel') {
        final obj =
            data.objectMap[info.alias] ??
            levelFile.objects.firstWhereOrNull(
              (o) => o.aliases?.contains(info.alias) == true,
            );
        if (obj == null) continue;
        modules.add(
          LevelModuleRef(
            rtid: rtid,
            alias: info.alias,
            objClass: obj.objClass,
            objData: obj.objData,
            isCurrentLevel: true,
          ),
        );
      } else {
        final ref = ReferenceRepository.instance.objectForAlias(info.alias);
        final objClass = ref?.objClass ?? _objClassForStockAlias(info.alias);
        if (objClass == null) continue;
        modules.add(
          LevelModuleRef(
            rtid: rtid,
            alias: info.alias,
            objClass: objClass,
            objData: ref?.objData,
            isCurrentLevel: false,
          ),
        );
      }
    }
    return LevelWarningContext._(
      levelFile: levelFile,
      parsed: data,
      modules: modules,
    );
  }

  /// Falls back to the module registry when the reference catalog has not
  /// been loaded yet (e.g. widget tests), so stock aliases such as
  /// `ZombiesDeadWinCon` still resolve to their object class.
  static String? _objClassForStockAlias(String alias) {
    for (final entry in ModuleRegistry.registry.entries) {
      if (entry.value.defaultAlias == alias) return entry.key;
    }
    return null;
  }

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final List<LevelModuleRef> modules;

  /// Object classes referenced from `LevelDefinition.Modules`.
  final Set<String> moduleObjClasses;

  /// Object classes of every object in the file, whether or not it is wired
  /// into the module list.
  final Set<String> objectObjClasses;

  LevelDefinitionData? get levelDef => parsed.levelDef;

  bool hasModule(String objClass) => moduleObjClasses.contains(objClass);

  bool hasModuleOrObject(String objClass) =>
      moduleObjClasses.contains(objClass) ||
      objectObjClasses.contains(objClass);

  bool get hasTunnelDefend => modules.any(
    (m) => m.objClass == 'TunnelDefendModuleProperties' && !m.isExpeditionTiles,
  );

  bool get hasExpeditionTiles => modules.any((m) => m.isExpeditionTiles);

  PvzObject? firstObject(String objClass) =>
      levelFile.objects.firstWhereOrNull((o) => o.objClass == objClass) ??
      parsed.objectMap.values.firstWhereOrNull((o) => o.objClass == objClass);

  String get stageAlias =>
      RtidParser.parse(levelDef?.stageModule ?? '')?.alias ?? '';
}

typedef LevelWarningPredicate = bool Function(LevelWarningContext ctx);
typedef LevelWarningText =
    String Function(BuildContext context, AppLocalizations l10n);

/// A declarative level warning: when [isActive] holds for the level, the
/// localized [title] / [message] are shown wherever warnings are surfaced.
class LevelWarningRule {
  const LevelWarningRule({
    required this.id,
    required this.isActive,
    required this.title,
    required this.message,
    this.severity = LevelWarningSeverity.warning,
    this.showInEditor = true,
  });

  /// Stable identifier; also used as the widget key in the settings tab.
  final String id;
  final LevelWarningSeverity severity;
  final LevelWarningPredicate isActive;
  final LevelWarningText title;
  final LevelWarningText message;

  /// False for checks that are only meaningful on export (heavy scans, or
  /// situations the editor already confirms interactively).
  final bool showInEditor;
}

/// A resolved, localized warning ready for display.
class LevelWarning {
  const LevelWarning({
    required this.id,
    required this.severity,
    required this.title,
    required this.message,
  });

  final String id;
  final LevelWarningSeverity severity;
  final String title;
  final String message;

  bool get isError => severity == LevelWarningSeverity.error;
}

/// Level-wide advisories that are not hard module conflicts (those live in
/// `ConflictRegistry`): missing companions, risky combinations, lawn
/// mismatches, and modules that duplicate each other's behaviour.
class WarningRegistry {
  static const glacierModule = 'GlacierModuleProperties';
  static const zombossBattleModule = 'ZombossBattleModuleProperties';
  static const seeingStarsModule = 'PVZ1SeeingStarsModuleProperties';
  static const zombiesDeadWinCon = 'ZombiesDeadWinConProperties';

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
}
