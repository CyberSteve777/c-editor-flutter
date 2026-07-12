import 'package:c_editor/data/ambient_audio_catalog.dart';
import 'package:c_editor/data/asset_image_preloader.dart';
import 'package:c_editor/data/bootstrap_loading_category.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/fish_properties_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';

export 'package:c_editor/data/bootstrap_loading_category.dart'
    show BootstrapLoadingCategory, BootstrapProgressCallback;

/// Loads app data and image assets once before the main UI is shown.
abstract final class AppBootstrap {
  static bool _complete = false;

  static bool get isComplete => _complete;

  static Future<void> load({BootstrapProgressCallback? onProgress}) async {
    if (_complete) return;

    const dataSteps = 16;
    var dataStep = 0;
    void dataTick(BootstrapLoadingCategory category) {
      dataStep++;
      onProgress?.call((dataStep / dataSteps) * 0.25, category);
    }

    onProgress?.call(0, BootstrapLoadingCategory.localization);
    await ResourceNames.ensureLoaded();
    dataTick(BootstrapLoadingCategory.localization);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.stages);
    await StageRepository.init();
    dataTick(BootstrapLoadingCategory.stages);

    await CustomStagePresetRepository.init();
    dataTick(BootstrapLoadingCategory.stages);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.audio);
    await MusicSuffixCatalog.init();
    dataTick(BootstrapLoadingCategory.audio);

    await AmbientAudioCatalog.init();
    dataTick(BootstrapLoadingCategory.audio);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.gridItems);
    await GridItemRepository.init();
    dataTick(BootstrapLoadingCategory.gridItems);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.zomboss);
    await ZombossMechRepository.init();
    dataTick(BootstrapLoadingCategory.zomboss);

    await ZombossBattleRepository.init();
    dataTick(BootstrapLoadingCategory.zomboss);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.reference);
    await ReferenceRepository.init();
    dataTick(BootstrapLoadingCategory.reference);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.zombies);
    await ZombiePropertiesRepository.init();
    dataTick(BootstrapLoadingCategory.zombies);

    await ResilienceConfigRepository.init();
    dataTick(BootstrapLoadingCategory.reference);

    await ZombieTitleCatalogRepository.init();
    dataTick(BootstrapLoadingCategory.zombies);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.plants);
    await PlantRepository().init();
    dataTick(BootstrapLoadingCategory.plants);

    await ZombieRepository().init();
    dataTick(BootstrapLoadingCategory.zombies);

    onProgress?.call((dataStep / dataSteps) * 0.25, BootstrapLoadingCategory.fish);
    await FishTypeRepository().init();
    dataTick(BootstrapLoadingCategory.fish);

    await FishPropertiesRepository.init();
    dataTick(BootstrapLoadingCategory.fish);

    await AssetImagePreloader.preloadAll(
      onProgress: (progress, category) {
        onProgress?.call(0.25 + progress * 0.75, category);
      },
    );

    _complete = true;
    onProgress?.call(1, null);
  }
}
