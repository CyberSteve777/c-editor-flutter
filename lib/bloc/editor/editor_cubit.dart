import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/fish_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/final_stage_time_limited_module_utils.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/bloc/editor/editor_tab_type.dart';

export 'package:c_editor/bloc/editor/editor_tab_type.dart';

part 'editor_state.dart';

class EditorCubit extends Cubit<EditorState> {
  EditorCubit({
    required this.fileName,
    required this.filePath,
  }) : super(const EditorState());

  final String fileName;
  final String filePath;

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
    await ReferenceRepository.init();
    await ZombiePropertiesRepository.init();
    await ResilienceConfigRepository.init();
    await PlantRepository().init();
    await ZombieRepository().init();
    await FishTypeRepository().init();
    await FishPropertiesRepository.init();
    if (isClosed) return;
    var level = await LevelRepository.loadLevel(fileName);
    if (level == null && filePath.isNotEmpty) {
      level = await LevelRepository.loadLevelFromPath(filePath);
      if (level != null) {
        await LevelRepository.prepareInternalCache(filePath, fileName);
      }
    }
    if (isClosed) return;
    if (level != null) {
      FinalStageTimeLimitedModuleUtils.normalizeForLevelModulesOnly(level);
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
      if (isClosed) return;
      emit(
        const EditorState(
          isLoading: false,
          hasChanges: false,
        ),
      );
    }
  }

  List<EditorTabType> _computeAvailableTabs(
    PvzLevelFile levelFile,
    ParsedLevelData parsedData,
  ) {
    final classes = <String>{
      ...levelFile.objects.map((o) => o.objClass),
      ...?parsedData.levelDef?.modules.map((rtid) {
        final info = RtidParser.parse(rtid);
        if (info == null) return '';
        if (info.source == 'CurrentLevel') {
          return parsedData.objectMap[info.alias]?.objClass ?? '';
        }
        return ReferenceRepository.instance.getObjClass(info.alias) ?? '';
      }),
    };
    final tabs = <EditorTabType>[EditorTabType.settings];
    if (classes.contains('WaveManagerModuleProperties')) {
      tabs.add(EditorTabType.timeline);
    }
    if (classes.contains('EvilDaveProperties')) tabs.add(EditorTabType.iZombie);
    if (classes.contains('VaseBreakerPresetProperties') ||
        classes.contains('VaseBreakerArcadeModuleProperties')) {
      tabs.add(EditorTabType.vaseBreaker);
    }
    if (classes.contains('ZombossBattleModuleProperties')) {
      tabs.add(EditorTabType.zombossMech);
    }
    if (classes.contains('ZombossLastStandMinigameProperties')) {
      tabs.add(EditorTabType.zombossBattle);
    }
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
        hasChanges: true,
        parsedData: parsed,
      ),
    );
  }

  Future<void> save() async {
    final lf = state.levelFile;
    if (lf == null) return;
    await LevelRepository.saveAndExport(filePath, lf);
    emit(state.copyWith(hasChanges: false));
  }

  /// After external JSON edit; marks dirty and refreshes parsed data and tabs.
  void onJsonViewerSaved() {
    final lf = state.levelFile;
    if (lf == null) return;
    final parsed = LevelParser.parseLevel(lf);
    emit(
      state.copyWith(
        hasChanges: true,
        parsedData: parsed,
        availableTabs: _computeAvailableTabs(lf, parsed),
      ),
    );
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
