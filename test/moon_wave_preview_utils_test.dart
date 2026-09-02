import 'package:c_editor/data/moon_wave_preview_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('lunarMineVein wave preview', () {
    final data = LunarMineVeinModulePropertiesData(
      placements: [
        LunarMineVeinPlacementData(gridX: 0, gridY: 0, emergenceWave: 1),
        LunarMineVeinPlacementData(gridX: 1, gridY: 2, emergenceWave: 3),
      ],
    );

    test('matches 1-based emergence waves to timeline wave index', () {
      expect(lunarMineVeinWaveHasPreviewActivity(data, 1), isTrue);
      expect(lunarMineVeinWaveHasPreviewActivity(data, 2), isFalse);
      expect(lunarMineVeinWaveHasPreviewActivity(data, 3), isTrue);

      expect(
        lunarMineVeinEmergingPlacementsForWave(data, 1),
        hasLength(1),
      );
      expect(
        lunarMineVeinEmergingPlacementsForWave(data, 3).first.gridX,
        1,
      );
    });
  });

  group('radiationMeteor wave preview', () {
    final data = RadiationMeteorModulePropertiesData(
      spawnSchedule: [
        RadiationMeteorSpawnData(wave: 0, gridX: 2, gridY: 1),
        RadiationMeteorSpawnData(wave: 2, gridX: 4, gridY: 0),
      ],
    );

    test('maps 0-based stored waves to 1-based timeline wave index', () {
      expect(radiationMeteorWaveHasPreviewActivity(data, 1), isTrue);
      expect(radiationMeteorWaveHasPreviewActivity(data, 2), isFalse);
      expect(radiationMeteorWaveHasPreviewActivity(data, 3), isTrue);

      expect(radiationMeteorSpawnsForWave(data, 1).first.gridX, 2);
      expect(radiationMeteorSpawnsForWave(data, 3).first.gridX, 4);
    });
  });
}
