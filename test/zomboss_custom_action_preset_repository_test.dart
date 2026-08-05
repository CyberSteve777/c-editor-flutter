import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    ZombossCustomActionPresetRepository.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    await ZombossCustomActionPresetRepository.init();
  });

  test('loads presets for the matching memo mechs only', () {
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_egypt_memo',
      ).map((preset) => preset.id),
      contains('nightmare_stomp_spawn'),
    );
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_iceage_memo',
      ).map((preset) => preset.id).toList(),
      ['sport_tank_spawn', 'sport_wind_spawn'],
    );
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_modern_memo',
      ),
      isEmpty,
    );
  });

  test('instantiates tank preset with collision-safe dependency rtid', () {
    final preset = ZombossCustomActionPresetRepository.presetById(
      'sport_tank_spawn',
    );
    expect(preset, isNotNull);

    final level = PvzLevelFile(
      objects: [
        PvzObject(aliases: ['SpawnBall'], objClass: 'Other', objData: {}),
      ],
    );
    final creation = ZombossCustomActionPresetRepository.instantiatePreset(
      level,
      preset!,
    );

    final main = level.objects.firstWhere(
      (object) =>
          object.aliases?.contains('ZombieIceAgeSpawnBallAction') == true,
    );
    final data = Map<String, dynamic>.from(main.objData as Map);
    expect(data['AwardDrop'], 'RTID(SpawnBall_2@CurrentLevel)');
    expect(
      level.objects.any(
        (object) =>
            object.aliases?.contains('SpawnBall_2') == true &&
            object.objClass == 'ZombieDropProps',
      ),
      isTrue,
    );
    expect(
      ZombossCustomActionPresetRepository.originForRtid(level, creation.rtid),
      ZombossCustomActionOrigin.presetTemplate,
    );
  });

  test(
    'derives a blue action and can remove the temporary object references',
    () {
      final preset = ZombossCustomActionPresetRepository.presetById(
        'sport_tank_spawn',
      );
      expect(preset, isNotNull);

      final level = PvzLevelFile(objects: []);
      final green = ZombossCustomActionPresetRepository.instantiatePreset(
        level,
        preset!,
      );
      final blue = ZombossCustomActionPresetRepository.deriveFromPresetInstance(
        level,
        green.rtid,
      );

      expect(blue, isNotNull);
      expect(
        ZombossCustomActionPresetRepository.originForRtid(level, blue!.rtid),
        ZombossCustomActionOrigin.presetDerived,
      );
      final blueMain = level.objects.firstWhere(
        (object) =>
            object.aliases?.contains('ZombieIceAgeSpawnBallAction_2') == true,
      );
      expect(
        Map<String, dynamic>.from(blueMain.objData as Map)['AwardDrop'],
        'RTID(SpawnBall_2@CurrentLevel)',
      );

      ZombossCustomActionPresetRepository.removeCreatedObjects(level, blue);

      expect(
        level.objects.any(
          (object) =>
              object.aliases?.contains('ZombieIceAgeSpawnBallAction_2') == true,
        ),
        isFalse,
      );
      expect(
        ZombossCustomActionPresetRepository.originForRtid(level, green.rtid),
        ZombossCustomActionOrigin.presetTemplate,
      );
    },
  );
}
