import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/fish_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/app_bootstrap.dart';
import 'package:c_editor/data/final_stage_time_limited_module_utils.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/utils/3rdParty/pyvz2/pyvz2_rton_codec.dart';
import 'package:c_editor/bloc/editor/editor_tab_type.dart';

export 'package:c_editor/bloc/editor/editor_tab_type.dart';

part 'editor_state.dart';

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({required this.fileName, required this.filePath})
    : super(const EditorState());

  final String fileName;
  final String filePath;
  Map<String, dynamic>? _savedLevelSnapshot;

  static const _levelEquality = DeepCollectionEquality();

  final ValueNotifier<({int waveIndex, String? rtid})?> openWaveSheetNotifier =
      ValueNotifier<({int waveIndex, String? rtid})?>(null);

  @override
  Future<void> close() {
    openWaveSheetNotifier.dispose();
    return super.close();
  }

  Future<void> loadLevel() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));
    if (!AppBootstrap.isComplete) {
      await ReferenceRepository.init();
      await ZombiePropertiesRepository.init();
      await ResilienceConfigRepository.init();
      await ZombieTitleCatalogRepository.init();
      await PlantRepository().init();
      await ZombieRepository().init();
      await FishTypeRepository().init();
      await FishPropertiesRepository.init();
    }
    if (isClosed) return;
    PvzLevelFile? level;
    RtonErrorKind? loadErrorKind;
    try {
      level = await LevelRepository.loadLevel(fileName);
      if (level == null && filePath.isNotEmpty) {
        level = await LevelRepository.loadLevelFromPath(filePath);
        if (level != null) {
          await LevelRepository.prepareInternalCache(filePath, fileName);
        }
      }
    } on RtonFormatException catch (e) {
      level = null;
      loadErrorKind = e.kind;
    }
    if (isClosed) return;
    if (level != null) {
      FinalStageTimeLimitedModuleUtils.normalizeForLevelModulesOnly(level);
      _normalizeDeepSeaBoardType(level);
      _savedLevelSnapshot = _snapshotLevel(level);
      final parsed = LevelParser.parseLevel(level);
      final tabs = _computeAvailableTabs(level, parsed);
      if (isClosed) return;
      emit(
        EditorState(
          levelFile: level,
          parsedData: parsed,
          isLoading: false,
          hasChanges: false,
          availableTabs: tabs,
        ),
      );
    } else {
      _savedLevelSnapshot = null;
      if (isClosed) return;
      emit(
        EditorState(
          isLoading: false,
          hasChanges: false,
          loadErrorKind: loadErrorKind,
        ),
      );
    }
  }

  List<EditorTabType> _computeAvailableTabs(
    PvzLevelFile levelFile,
    ParsedLevelData parsedData,
  ) {
    final referencedModuleClasses = <String>[];
    for (final rtid in parsedData.levelDef?.modules ?? const <String>[]) {
      final info = RtidParser.parse(rtid);
      if (info == null) continue;
      final objClass = info.source == 'CurrentLevel'
          ? parsedData.objectMap[info.alias]?.objClass
          : ReferenceRepository.instance.getObjClass(info.alias);
      if (objClass != null && objClass.isNotEmpty) {
        referencedModuleClasses.add(objClass);
      }
    }
    final classes = <String>{
      ...levelFile.objects.map((o) => o.objClass),
      ...referencedModuleClasses,
    };
    final tabs = <EditorTabType>[EditorTabType.settings];
    if (classes.contains('WaveManagerModuleProperties')) {
      tabs.add(EditorTabType.timeline);
    }
    if (classes.contains('WaveGeneratorProperties')) {
      tabs.add(EditorTabType.waveGenerator);
    }
    if (classes.contains('EvilDaveProperties')) tabs.add(EditorTabType.iZombie);
    if (classes.contains('VaseBreakerPresetProperties') ||
        classes.contains('VaseBreakerArcadeModuleProperties')) {
      tabs.add(EditorTabType.vaseBreaker);
    }
    if (classes.contains('SingleHandedProperties')) {
      tabs.add(EditorTabType.singleHanded);
    }
    final zombossMechCount = referencedModuleClasses
        .where((objClass) => objClass == 'ZombossBattleModuleProperties')
        .length;
    tabs.addAll(
      List<EditorTabType>.filled(zombossMechCount, EditorTabType.zombossMech),
    );
    final zombossLastStandCount = referencedModuleClasses
        .where((objClass) => objClass == 'ZombossLastStandMinigameProperties')
        .length;
    tabs.addAll(
      List<EditorTabType>.filled(
        zombossLastStandCount,
        EditorTabType.zombossBattle,
      ),
    );
    return tabs;
  }

  void recalculateTabs() {
    final lf = state.levelFile;
    final pd = state.parsedData;
    if (lf == null || pd == null) return;
    emit(state.copyWith(availableTabs: _computeAvailableTabs(lf, pd)));
  }

  void markDirty() {
    final lf = state.levelFile;
    if (lf == null) return;
    final parsed = LevelParser.parseLevel(lf);
    emit(
      state.copyWith(
        hasChanges: _levelDiffersFromSaved(lf),
        parsedData: parsed,
      ),
    );
  }

  /// Rebuilds parsed indexes after derived editor data is synchronized without
  /// turning that synchronization into a user-visible unsaved change.
  void refreshParsedData() {
    final lf = state.levelFile;
    if (lf != null && !state.hasChanges) {
      _savedLevelSnapshot = _snapshotLevel(lf);
    }
    _refreshLevelState(hasChanges: state.hasChanges);
  }

  Future<void> save() async {
    final lf = state.levelFile;
    if (lf == null) return;
    await LevelRepository.saveAndExport(filePath, lf);
    _savedLevelSnapshot = _snapshotLevel(lf);
    emit(state.copyWith(hasChanges: false));
  }

  /// Refreshes editor state after the JSON viewer has already saved to disk.
  void onJsonViewerSaved() {
    final lf = state.levelFile;
    if (lf != null) {
      _savedLevelSnapshot = _snapshotLevel(lf);
    }
    _refreshLevelState(hasChanges: false);
  }

  static Map<String, dynamic> _snapshotLevel(PvzLevelFile level) =>
      jsonDecode(jsonEncode(level.toJson())) as Map<String, dynamic>;

  static void _normalizeDeepSeaBoardType(PvzLevelFile level) {
    final def = LevelParser.parseLevel(level).levelDef;
    if (def == null) return;
    LevelParser.syncDeepSeaBoardType(def, level);
  }

  bool _levelDiffersFromSaved(PvzLevelFile level) {
    final saved = _savedLevelSnapshot;
    return saved == null || !_levelEquality.equals(level.toJson(), saved);
  }

  void _refreshLevelState({required bool hasChanges}) {
    final lf = state.levelFile;
    if (lf == null) return;
    final parsed = LevelParser.parseLevel(lf);
    emit(
      state.copyWith(
        hasChanges: hasChanges,
        parsedData: parsed,
        availableTabs: _computeAvailableTabs(lf, parsed),
      ),
    );
  }

  /// Replaces the in-memory level from [newLevel].
  ///
  /// When [markDirty] is true (default), the editor is marked unsaved.
  /// Pass false after a successful disk write that already matches [newLevel].
  void applyLevelFile(PvzLevelFile newLevel, {bool markDirty = true}) {
    if (isClosed) return;
    _normalizeDeepSeaBoardType(newLevel);
    final lf = state.levelFile;
    if (lf == null) {
      final parsed = LevelParser.parseLevel(newLevel);
      if (!markDirty) {
        _savedLevelSnapshot = _snapshotLevel(newLevel);
      }
      emit(
        EditorState(
          levelFile: newLevel,
          parsedData: parsed,
          isLoading: false,
          hasChanges: markDirty,
          availableTabs: _computeAvailableTabs(newLevel, parsed),
        ),
      );
      return;
    }
    lf.objects
      ..clear()
      ..addAll(newLevel.objects);
    lf.version = newLevel.version;
    if (markDirty) {
      _refreshLevelState(hasChanges: _levelDiffersFromSaved(lf));
    } else {
      _savedLevelSnapshot = _snapshotLevel(lf);
      _refreshLevelState(hasChanges: false);
    }
  }

  static const String _rocketZombieFlickObjClass =
      'RocketZombieFlickModuleProperties';

  bool get hasRocketZombieFlickModule {
    final pd = state.parsedData;
    final def = pd?.levelDef;
    if (pd == null || def == null) return false;
    final map = pd.objectMap;
    for (final rtid in def.modules) {
      final info = RtidParser.parse(rtid);
      if (info == null || info.source != 'CurrentLevel') continue;
      if (map[info.alias]?.objClass == _rocketZombieFlickObjClass) {
        return true;
      }
    }
    return false;
  }

  /// Adds [RocketZombieFlickModuleProperties] with empty objdata if not already present.
  void addRocketZombieFlickModuleSilently() {
    final lf = state.levelFile;
    final def = state.parsedData?.levelDef;
    if (lf == null || def == null) return;
    if (hasRocketZombieFlickModule) return;

    final meta = ModuleRegistry.getMetadata(_rocketZombieFlickObjClass);
    var alias = meta.effectiveAlias;
    var count = 0;
    while (lf.objects.any((o) => o.aliases?.contains(alias) == true)) {
      count++;
      alias = '${meta.effectiveAlias}_$count';
    }
    final rtid = RtidParser.build(alias, meta.defaultSource);
    def.modules.add(rtid);
    lf.objects.add(
      PvzObject(
        aliases: [alias],
        objClass: meta.objClass,
        objData: Map<String, dynamic>.from(meta.initialData ?? {}),
      ),
    );
    markDirty();
    recalculateTabs();
  }
}
