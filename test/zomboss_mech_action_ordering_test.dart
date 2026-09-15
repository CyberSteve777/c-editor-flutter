import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    ZombossMechRepository.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    await ZombossMechRepository.init();
    await ZombiePropertiesRepository.init();
  });

  test('classifies Spawn and PortalsEvent actions as summon', () {
    final skyCity = ZombossMechRepository.getCatalog(
      'ZombieZombossMech_SkyCity',
    );
    expect(skyCity, isNotNull);

    final spawn = skyCity!.catalogActionForAlias('PortalsEvent_skycity');
    expect(spawn, isNotNull);
    expect(
      ZombossMechActionOrdering.categoryForCatalogAction(spawn!),
      ZombossMechActionMainCategory.summon,
    );
  });

  test('allows custom summon actions in summon and custom filters', () {
    const category = ZombossMechActionMainCategory.summon;

    expect(
      ZombossMechActionOrdering.matchesFilter(
        filter: ZombossMechActionOrdering.summonFilter,
        isCustom: true,
        category: category,
      ),
      isTrue,
    );
    expect(
      ZombossMechActionOrdering.matchesFilter(
        filter: ZombossMechActionOrdering.customFilter,
        isCustom: true,
        category: category,
      ),
      isTrue,
    );
    expect(
      ZombossMechActionOrdering.matchesFilter(
        filter: 'attack',
        isCustom: true,
        category: category,
      ),
      isFalse,
    );
  });

  test('sorts the first variation by variation and category order', () {
    final egypt = ZombossMechRepository.getCatalog('ZombieZombossMech_Egypt');
    expect(egypt, isNotNull);

    final aliases = ZombossMechActionOrdering.sortedCatalogActions(
      egypt!,
    ).map((action) => action.alias).toList();

    final walk = aliases.indexOf('ZombossEgyptWalk1');
    final spawn = aliases.indexOf('ZombossEgyptSpawn1');
    final rush = aliases.indexOf('ZombossEgyptRush1');
    final fire = aliases.indexOf('ZombossEgyptFire1');

    expect(walk, isNonNegative);
    expect(spawn, isNonNegative);
    expect(rush, isNonNegative);
    expect(fire, isNonNegative);
    expect(walk, lessThan(spawn));
    expect(spawn, lessThan(rush));
    expect(rush, lessThan(fire));
  });

  test('keeps Eighties phases in variation order instead of alias order', () {
    final eighties = ZombossMechRepository.getCatalog(
      'ZombieZombossMech_Eighties',
    );
    expect(eighties, isNotNull);

    final aliases = ZombossMechActionOrdering.sortedCatalogActions(
      eighties!,
    ).map((action) => action.alias).toList();

    expect(
      aliases.indexOf('ZombossEightiesDropSpeaker_Punk'),
      lessThan(aliases.indexOf('ZombossEightiesDropSpeaker_8bit')),
    );
    expect(
      aliases.indexOf('ZombossEightiesFireSpeakerRay_Punk'),
      lessThan(aliases.indexOf('ZombossEightiesFireSpeakerRay_Metal')),
    );
  });
}
