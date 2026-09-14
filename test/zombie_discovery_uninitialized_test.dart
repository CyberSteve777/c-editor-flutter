import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('missing resource catalogs do not erase explicit zombie resources', () {
    expect(ReferenceRepository.instance.isLoaded, isFalse);
    expect(GridItemRepository.allItems, isEmpty);

    final spawn = PvzObject(
      aliases: const ['Spawn'],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: const {
        'Zombies': [
          {'Type': 'unknown_bare_zombie'},
          {'Type': 'RTID(unknown_zombie@ZombieTypes)'},
          {'Type': 'RTID(unknown_obstacle@GridItemTypes)'},
        ],
      },
    );
    final level = PvzLevelFile(
      objects: [
        spawn,
        PvzObject(
          aliases: const ['WaveManager'],
          objClass: 'WaveManagerProperties',
          objData: WaveManagerData(
            waves: const [
              ['RTID(Spawn@CurrentLevel)'],
            ],
          ).toJson(),
        ),
      ],
    );

    expect(
      ZombieDiscovery.discoverZombies(level, LevelParser.parseLevel(level)),
      {'unknown_bare_zombie', 'unknown_zombie'},
    );
  });
}
