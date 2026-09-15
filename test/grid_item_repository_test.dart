import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';

void main() {
  setUp(GridItemRepository.staticItems.clear);
  tearDown(GridItemRepository.staticItems.clear);

  test('builds default grid item references against GridItemTypes', () {
    GridItemRepository.staticItems.add(
      const GridItemInfo(
        typeName: 'gravestone_egypt',
        category: GridItemCategory.scene,
      ),
    );
    final levelFile = PvzLevelFile(objects: []);

    final rtid = GridItemRepository.buildGridItemTypeRtid(
      'gravestone_egypt',
      levelFile,
    );

    expect(rtid, 'RTID(gravestone@GridItemTypes)');
    expect(levelFile.objects, isEmpty);
  });

  test('uses the WebP icon for pumpkin houses', () {
    expect(
      GridItemRepository.getIconPath('pumpkin_house'),
      'assets/images/griditems/pumpkin_house.webp',
    );
  });

  test('builds custom grid item references against CurrentLevel once', () {
    GridItemRepository.staticItems.add(
      GridItemInfo(
        typeName: 'armrack',
        category: GridItemCategory.scene,
        source: GridItemSource.custom,
        gridItemType: PvzObject(
          aliases: ['armrack'],
          objClass: 'GridItemType',
          objData: {
            'TypeName': 'armrack',
            'GridItemClass': 'GridItemArmrack',
            'Properties': 'RTID(GridItemArmrackDefault@PropertySheets)',
          },
        ),
      ),
    );
    final levelFile = PvzLevelFile(objects: []);

    final firstRtid = GridItemRepository.buildGridItemTypeRtid(
      'armrack',
      levelFile,
    );
    final secondRtid = GridItemRepository.buildGridItemTypeRtid(
      'armrack',
      levelFile,
    );

    expect(firstRtid, 'RTID(armrack@CurrentLevel)');
    expect(secondRtid, firstRtid);
    expect(levelFile.objects, hasLength(1));
    expect(levelFile.objects.single.aliases, ['armrack']);
    expect(levelFile.objects.single.objClass, 'GridItemType');
    expect(levelFile.objects.single.objData, {
      'TypeName': 'armrack',
      'GridItemClass': 'GridItemArmrack',
      'Properties': 'RTID(GridItemArmrackDefault@PropertySheets)',
    });
  });

  test('keeps custom GridItemType while a CurrentLevel reference exists', () {
    GridItemRepository.staticItems.add(_customGridItem('armrack'));
    final levelFile = PvzLevelFile(
      objects: [
        _gridItemType('armrack'),
        PvzObject(
          aliases: ['SpawnFromGridItem'],
          objClass: 'SpawnZombiesFromGridItemSpawnerProps',
          objData: {
            'GridTypes': ['RTID(armrack@CurrentLevel)'],
          },
        ),
      ],
    );

    final removed = GridItemRepository.cleanupUnusedCustomGridItemTypes(
      levelFile,
    );

    expect(removed, 0);
    expect(_hasGridItemType(levelFile, 'armrack'), isTrue);
  });

  test(
    'removes custom GridItemType when no CurrentLevel references remain',
    () {
      GridItemRepository.staticItems.add(_customGridItem('armrack'));
      final levelFile = PvzLevelFile(
        objects: [
          _gridItemType('armrack'),
          PvzObject(
            aliases: ['SpawnFromGridItem'],
            objClass: 'SpawnZombiesFromGridItemSpawnerProps',
            objData: {
              'GridTypes': ['RTID(armrack@GridItemTypes)'],
            },
          ),
        ],
      );

      final removed = GridItemRepository.cleanupUnusedCustomGridItemTypes(
        levelFile,
      );

      expect(removed, 1);
      expect(_hasGridItemType(levelFile, 'armrack'), isFalse);
      expect((levelFile.objects.single.objData as Map)['GridTypes'], [
        'RTID(armrack@GridItemTypes)',
      ]);
    },
  );

  test('preserves unrelated custom GridItemType objects', () {
    GridItemRepository.staticItems.addAll([
      _customGridItem('armrack'),
      _customGridItem('energyGrid', gridItemClass: 'GridItemEnergyGrid'),
    ]);
    final levelFile = PvzLevelFile(
      objects: [
        _gridItemType('armrack'),
        _gridItemType('energyGrid', gridItemClass: 'GridItemEnergyGrid'),
        _gridItemType('otherCustom'),
        PvzObject(
          aliases: ['SpawnFromGridItem'],
          objClass: 'SpawnZombiesFromGridItemSpawnerProps',
          objData: {
            'GridTypes': ['RTID(energyGrid@CurrentLevel)'],
          },
        ),
      ],
    );

    final removed = GridItemRepository.cleanupUnusedCustomGridItemTypes(
      levelFile,
    );

    expect(removed, 1);
    expect(_hasGridItemType(levelFile, 'armrack'), isFalse);
    expect(_hasGridItemType(levelFile, 'energyGrid'), isTrue);
    expect(_hasGridItemType(levelFile, 'otherCustom'), isTrue);
  });
}

GridItemInfo _customGridItem(
  String typeName, {
  String gridItemClass = 'GridItemArmrack',
}) {
  return GridItemInfo(
    typeName: typeName,
    category: GridItemCategory.scene,
    source: GridItemSource.custom,
    gridItemType: _gridItemType(typeName, gridItemClass: gridItemClass),
  );
}

PvzObject _gridItemType(
  String alias, {
  String gridItemClass = 'GridItemArmrack',
}) {
  return PvzObject(
    aliases: [alias],
    objClass: 'GridItemType',
    objData: {
      'TypeName': alias,
      'GridItemClass': gridItemClass,
      'Properties': 'RTID(${gridItemClass}Default@PropertySheets)',
    },
  );
}

bool _hasGridItemType(PvzLevelFile levelFile, String alias) {
  return levelFile.objects.any(
    (object) =>
        object.objClass == 'GridItemType' &&
        (object.aliases ?? const <String>[]).contains(alias),
  );
}
