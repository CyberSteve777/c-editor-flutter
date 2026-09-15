import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/l10n/app_localizations_zh.dart';
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

  test('Crystallization describes hit count and damage per hit separately', () {
    final english = AppLocalizationsEn();
    final chinese = AppLocalizationsZh();

    expect(
      english.ztPerkDescCrystal('0.1', '2', '1', '25%'),
      contains('only 2 times every 0.1 seconds'),
    );
    expect(
      english.ztPerkDescCrystal('0.1', '2', '1', '25%'),
      contains('each instance of damage taken to 1'),
    );
    expect(english.ztPerkCategoryDescCrystal, contains('N times every A'));
    expect(
      chinese.ztPerkDescCrystal('0.1', '2', '1', '25%'),
      contains('在0.1秒内只会受到2次伤害'),
    );
    expect(chinese.ztPerkPropDamageTotalTaken, '累计承受伤害次数');
  });
}
