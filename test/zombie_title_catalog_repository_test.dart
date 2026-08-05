import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sorts ztalemate perks by category and tier', () async {
    await ZombieTitleCatalogRepository.init();

    final aliases = ZombieTitleCatalogRepository.getAll()
        .map((entry) => entry.alias)
        .toList();

    expect(aliases.take(8).toList(), [
      'ZTSpeed1',
      'ZTAttack1',
      'ZTImmuneControl1',
      'ZTAntiControl1',
      'ZTShield1',
      'ZTShield2',
      'ZTShield3',
      'ZTGravity1',
    ]);
    expect(
      aliases.indexOf('ZTCrystal2'),
      lessThan(aliases.indexOf('ZTCrystal10')),
    );
  });
}
