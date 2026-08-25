import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('KongfuBossStage catalog entry', () {
    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
    });

    test('appears between Arbor Day and Theatre Dark as a special stage', () {
      final options = StageCatalogRepository.stageBaseOptions();
      final aliases = options.map((option) => option.alias).toList();
      final kongfuBoss = options.firstWhere(
        (option) => option.alias == 'KongfuBossStage',
      );

      expect(
        aliases.indexOf('UnchartedArbordayStage'),
        lessThan(aliases.indexOf('KongfuBossStage')),
      );
      expect(
        aliases.indexOf('KongfuBossStage'),
        lessThan(aliases.indexOf('TheatreDarkStage')),
      );
      expect(kongfuBoss.type, 'special');
      expect(kongfuBoss.iconName, 'Stage_KongfuBoss.webp');
    });

    test('uses the existing built-in stage implementation data', () {
      final impl = StageCatalogRepository.catalogImplementation(
        'KongfuBossStage',
      );

      expect(impl, isNotNull);
      expect(impl!.objclass, 'KongFuStageProperties');
      expect(impl.objdata['BackgroundImageRight'], 'TEXTURE_RIGHT_BOSS');
      expect(impl.objdata['ResourceGroupNames'], contains('Music_Boss_Kongfu'));
    });

    test('is exposed through the built-in stage repository', () {
      final item = StageRepository.allItems.firstWhere(
        (stage) => stage.alias == 'KongfuBossStage',
      );

      expect(item.type, StageType.special);
      expect(item.iconName, 'Stage_KongfuBoss.webp');
    });

    test('keeps its own custom-stage appearance display', () {
      final impl = StageCatalogRepository.catalogImplementation(
        'KongfuBossStage',
      )!;

      expect(
        CustomStageLevelUtils.displayLawnAppearanceNameKey(
          objclass: impl.objclass,
          objdata: impl.objdata,
        ),
        'stage_KongfuBossStage',
      );
      expect(
        CustomStageLevelUtils.displayLawnAppearanceIconFileName(
          objclass: impl.objclass,
          objdata: impl.objdata,
        ),
        'Stage_KongfuBoss.webp',
      );
    });
  });

  group('MoonStage catalog entry', () {
    setUpAll(() async {
      await StageCatalogRepository.init();
      await StageRepository.init();
    });

    test('appears after Heian Ages in the main stage list', () {
      final options = StageCatalogRepository.stageBaseOptions();
      final aliases = options.map((option) => option.alias).toList();
      final moon = options.firstWhere((option) => option.alias == 'MoonStage');

      expect(
        aliases.indexOf('HeianStage'),
        lessThan(aliases.indexOf('MoonStage')),
      );
      expect(
        aliases.indexOf('MoonStage'),
        lessThan(aliases.indexOf('FairyTaleStage')),
      );
      expect(moon.type, 'main');
      expect(moon.iconName, 'Stage_Moon.webp');
    });

    test('keeps the Moon-specific custom-stage setting', () {
      final impl = StageCatalogRepository.catalogImplementation('MoonStage');
      final moonBase = StageCatalogRepository.stageBaseOptions().firstWhere(
        (option) => option.alias == 'MoonStage',
      );
      final resourceGroupField = StageCatalogRepository.sectionForObjclass(
        'MoonStageProperties',
      )!.fields.firstWhere((field) => field.name == 'ResourceGroupNames');

      expect(impl, isNotNull);
      expect(impl!.objclass, 'MoonStageProperties');
      expect(impl.objdata['MusicSuffix'], 'Moon');
      expect(impl.objdata['CosmicPlantfoodFillSeconds'], 50.0);
      expect(impl.objdata['ResourceGroupNames'], contains('AudioMoon'));
      expect(moonBase.objdata['ResourceGroupNames'], contains('AudioMoon'));
      expect(resourceGroupField.defaultValue, contains('AudioMoon'));
    });
  });

  test(
    'global resource-group list includes every custom lawn preset',
    () async {
      await StageCatalogRepository.init();
      await CustomStagePresetRepository.init();

      expect(
        StageCatalogRepository.knownResourceGroups,
        containsAll(CustomStagePresetRepository.resourceGroups),
      );
      expect(
        StageCatalogRepository.knownResourceGroups,
        contains('Modern_Gravestone'),
      );
    },
  );
}
