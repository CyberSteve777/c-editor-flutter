import 'package:c_editor/data/ambient_audio_catalog.dart';
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
import 'package:c_editor/data/asset_image_preloader.dart';
import 'package:c_editor/l10n/resource_names.dart';

typedef BootstrapProgressCallback = void Function(double progress, String? label);

/// Loads app data and image assets once before the main UI is shown.
abstract final class AppBootstrap {
  static bool _complete = false;

  static bool get isComplete => _complete;

  static Future<void> load({BootstrapProgressCallback? onProgress}) async {
    if (_complete) return;

    const dataSteps = 16;
    var dataStep = 0;
    void dataTick(String label) {
      dataStep++;
      onProgress?.call((dataStep / dataSteps) * 0.25, label);
    }

    await ResourceNames.ensureLoaded();
    dataTick('Resources');
    await StageRepository.init();
    dataTick('Stages');
    await CustomStagePresetRepository.init();
    dataTick('Stage presets');
    await MusicSuffixCatalog.init();
    dataTick('Music');
    await AmbientAudioCatalog.init();
    dataTick('Audio');
    await GridItemRepository.init();
    dataTick('Grid items');
    await ZombossMechRepository.init();
    dataTick('Zomboss mechs');
    await ZombossBattleRepository.init();
    dataTick('Zomboss battles');
    await ReferenceRepository.init();
    dataTick('Reference data');
    await ZombiePropertiesRepository.init();
    dataTick('Zombie properties');
    await ResilienceConfigRepository.init();
    dataTick('Resilience');
    await ZombieTitleCatalogRepository.init();
    dataTick('Zombie titles');
    await PlantRepository().init();
    dataTick('Plants');
    await ZombieRepository().init();
    dataTick('Zombies');
    await FishTypeRepository().init();
    dataTick('Fish types');
    await FishPropertiesRepository.init();
    dataTick('Fish properties');

    await AssetImagePreloader.preloadAll(
      onProgress: (progress, label) {
        onProgress?.call(0.25 + progress * 0.75, label);
      },
    );

    _complete = true;
    onProgress?.call(1, null);
  }
}
