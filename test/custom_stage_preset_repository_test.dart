import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    CustomStagePresetRepository.resetForTest();
    await CustomStagePresetRepository.init();
  });

  test(
    'distinguishes preset, preset-derived, and user-created custom lawns',
    () {
      final preset = CustomStagePresetRepository.presets.first;
      final presetObject = PvzObject(
        aliases: CustomStagePresetRepository.aliasesForPresetInstance(
          primaryAlias: preset.alias,
          preset: preset,
        ),
        objClass: preset.objclass,
        objData: CustomStageLevelUtils.cloneJson(preset.objdata),
      );

      expect(
        CustomStagePresetRepository.originForObject(presetObject),
        CustomStageOrigin.presetTemplate,
      );

      final derivedData =
          CustomStageLevelUtils.cloneJson(preset.objdata)
              as Map<String, dynamic>;
      derivedData['MusicSuffix'] = 'custom_test_suffix';
      final derivedObject = PvzObject(
        aliases: CustomStagePresetRepository.aliasesForPresetInstance(
          primaryAlias: preset.alias,
          preset: preset,
        ),
        objClass: preset.objclass,
        objData: derivedData,
      );

      expect(
        CustomStagePresetRepository.originForObject(derivedObject),
        CustomStageOrigin.presetDerived,
      );

      final userObject = PvzObject(
        aliases: const ['CustomStageFromBuiltin'],
        objClass: preset.objclass,
        objData: CustomStageLevelUtils.cloneJson(preset.objdata),
      );

      expect(
        CustomStagePresetRepository.originForObject(userObject),
        CustomStageOrigin.userCreated,
      );
    },
  );

  test('does not serialize editor metadata aliases for preset lawns', () {
    final preset = CustomStagePresetRepository.presets.first;
    final aliases = CustomStagePresetRepository.aliasesForPresetInstance(
      primaryAlias: preset.alias,
      preset: preset,
    );

    expect(aliases, [preset.alias]);
    expect(
      CustomStagePresetRepository.preservePresetMarkerAliases(
        primaryAlias: 'RenamedStage',
        existingAliases: aliases,
      ),
      ['RenamedStage'],
    );
  });
}
