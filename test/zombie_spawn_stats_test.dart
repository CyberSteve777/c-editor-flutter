import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  test('drop fractions preserve integers and fractional values', () {
    for (final value in <num>[-1, -1.0, 0, 0.25, 0.5]) {
      final sheet = ZombiePropertySheetData.fromJson({
        'ArmDropFraction': value,
        'HeadDropFraction': value,
        'WavePointCost': 400.0,
        'Weight': 3000.0,
      });
      expect(sheet.armDropFraction, value);
      expect(sheet.headDropFraction, value);
      expect(sheet.toJson()['ArmDropFraction'], value);
      expect(sheet.toJson()['HeadDropFraction'], value);
      expect(sheet.wavePointCost, 400);
      expect(sheet.weight, 3000);
    }
    final absent = ZombiePropertySheetData.fromJson({}).toJson();
    expect(absent, isNot(contains('ArmDropFraction')));
    expect(absent, isNot(contains('HeadDropFraction')));
  });

  test('optional geometry and behavior cannot discard valid spawn stats', () {
    final stats = ZombieStats.fromPropertySheet('test', {
      'WavePointCost': 400.0,
      'Weight': 3000,
      'Hitpoints': 250,
      'ArmDropFraction': -1.0,
      'HitRect': {'mX': 0.5},
      'ArtCenter': {'x': 12.5},
      'Resilience': {'Amount': 'unknown'},
      'SizeType': 1,
    });
    expect(stats.cost, 400);
    expect(stats.weight, 3000);
    expect(stats.hp, 250);
    expect(stats.sizeType, 'unknown');
  });

  test('absent or invalid statistics remain unavailable', () {
    final stats = ZombieStats.fromPropertySheet('test', {
      'WavePointCost': 'unknown',
      'Weight': double.nan,
    });
    expect(stats.cost, 0);
    expect(stats.weight, 0);
    expect(ZombieStats.fromPropertySheet('test', {}).cost, 0);
  });

  test(
    'bundled Balloon Zombie retains its full property template and stats',
    () {
      final stats = ZombiePropertiesRepository.getStats('modern_balloon');
      expect(stats.cost, 400);
      expect(stats.weight, 3000);
      final original = ZombiePropertiesRepository.cloneOriginalPropertyData(
        'modern_balloon',
      );
      expect(original, isNotNull);
      final sheet = ZombiePropertySheetData.fromJson(original!);
      expect(sheet.armDropFraction, -1);
      expect(sheet.headDropFraction, -1);
      expect(sheet.wavePointCost, stats.cost);
    },
  );

  test('wave 9 with 1700 points can preview Balloon Zombies', () {
    final data = WaveGeneratorPropertiesData(
      waveSpendingPoints: 100,
      waveSpendingPointIncrement: 200,
      addToZombiePool: [
        WaveGeneratorPoolEntryData(type: 'RTID(modern_balloon@ZombieTypes)'),
      ],
      waves: List.generate(
        9,
        (_) => WaveGeneratorWaveData(disableRandomSpawns: false),
      ),
    );
    final preview = WaveGeneratorPointAnalysis.calculatePreview(data, 9);
    expect(preview.points, 1700);
    expect(preview.missingDataTypes, isEmpty);
    expect(preview.canCalculate, isTrue);
    expect(preview.entries.single.id, 'modern_balloon');
    expect(preview.averageTotal, 4);
  });

  test('a no-data pool zombie does not hide the other previews', () {
    final data = WaveGeneratorPropertiesData(
      waveSpendingPoints: 400,
      addToZombiePool: [
        WaveGeneratorPoolEntryData(type: 'RTID(modern_balloon@ZombieTypes)'),
        WaveGeneratorPoolEntryData(type: 'RTID(mummy_flag@ZombieTypes)'),
        WaveGeneratorPoolEntryData(type: 'RTID(my_custom@CurrentLevel)'),
      ],
      waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
    );
    final preview = WaveGeneratorPointAnalysis.calculatePreview(data, 1);

    expect(preview.missingDataTypes, ['my_custom']);
    // The flag carrier has WavePointCost data, so it takes part in the
    // simulation despite its Weight = 0.
    expect(
      preview.entries.map((entry) => entry.id),
      containsAll(['modern_balloon', 'mummy_flag']),
    );
    expect(
      preview.entries.map((entry) => entry.id),
      isNot(contains('my_custom')),
    );
    expect(preview.canCalculate, isTrue);
  });

  test('canSpawnFromPoints accepts flag carriers and rejects no-cost '
      'zombies', () {
    expect(
      ZombiePropertiesRepository.canSpawnFromPoints('modern_balloon'),
      isTrue,
    );
    expect(
      ZombiePropertiesRepository.canSpawnFromPoints(
        'RTID(modern_balloon@ZombieTypes)',
      ),
      isTrue,
    );
    // Flag carrier: WavePointCost is known but Weight is 0. The point
    // purchase ignores Weight, so it is still eligible.
    expect(ZombiePropertiesRepository.canSpawnFromPoints('mummy_flag'), isTrue);
    expect(
      ZombiePropertiesRepository.canSpawnFromPoints('pirate_flag'),
      isTrue,
    );
    // Custom/unknown zombies have no point cost data.
    expect(ZombiePropertiesRepository.canSpawnFromPoints('my_custom'), isFalse);
    // Listed zombies whose property sheet lacks WavePointCost data.
    expect(ZombiePropertiesRepository.canSpawnFromPoints('catapult'), isFalse);
  });
}
