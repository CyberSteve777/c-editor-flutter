import 'package:c_editor/data/pvz_models/ZombieSpawnData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ZombieSpawnData round-trips Titles', () {
    final data = ZombieSpawnData(
      type: 'RTID(basic@ZombieTypes)',
      row: 2,
      level: 3,
      titles: ['ZTSpeed1', 'ZTAttack1'],
    );

    final json = data.toJson();
    expect(json['Titles'], ['ZTSpeed1', 'ZTAttack1']);

    final restored = ZombieSpawnData.fromJson(json);
    expect(restored.titles, ['ZTSpeed1', 'ZTAttack1']);
  });

  test('ZombieSpawnData omits empty Titles from json', () {
    final data = ZombieSpawnData(type: 'RTID(basic@ZombieTypes)', titles: []);
    expect(data.toJson().containsKey('Titles'), isFalse);
  });

  test('ZombieSpawnData copyWith preserves titles', () {
    final data = ZombieSpawnData(
      type: 'RTID(basic@ZombieTypes)',
      titles: ['ZTShield1'],
    );

    final updated = data.copyWith(level: 4);
    expect(updated.titles, ['ZTShield1']);
    expect(updated.level, 4);
  });
}
