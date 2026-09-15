import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_action_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const jumpGroup = ZombossMechObjclassGroup(
    objclass: 'ZombossJumpActionDefinition',
    tag: 'movement',
    fields: [],
    implementations: {
      'ZombossSpawnJump': {
        'JumpHeight': 150,
        'JumpHangTime': 1.2,
        'JumpAnimRateModifier': 1,
      },
      'ZombossRetreatJump': {
        'JumpHeight': 400,
        'JumpHangTime': 0.8,
        'JumpAnimRateModifier': 2,
      },
    },
  );

  final catalog = ZombossMechCatalogEntry(
    id: 'ZombieZombossMech_Egypt',
    icon: 'unknown.webp',
    defaultPhaseCount: 3,
    variations: const [],
    editableInstance: 'zombossmech_egypt_memo',
    editableInstancePropsName: 'ZombossEgyptProps',
    actions: const [jumpGroup],
    properties: const [],
  );

  test('jump actions appear in regular phase picker', () {
    expect(
      catalog.catalogActions.any((action) => action.alias == 'ZombossSpawnJump'),
      isTrue,
    );
    expect(
      ZombossMechActionOrdering.sortedCatalogActions(catalog)
          .any((action) => action.alias == 'ZombossSpawnJump'),
      isTrue,
    );
    expect(
      catalog.actionsByTag('movement')
          .any((action) => action.alias == 'ZombossSpawnJump'),
      isTrue,
    );
  });

  test('jump actions also appear in retreat picker', () {
    expect(
      catalog.retreatCatalogActions
          .any((action) => action.alias == 'ZombossRetreatJump'),
      isTrue,
    );
    expect(
      catalog.retreatCatalogActions
          .any((action) => action.alias == 'ZombossSpawnJump'),
      isTrue,
    );
  });

  test('legacy retreat-tagged jump groups still work in both pickers', () {
    const legacyJump = ZombossMechObjclassGroup(
      objclass: 'ZombossJumpActionDefinition',
      tag: 'retreat',
      fields: [],
      implementations: {
        'ZombossRetreatJump': {
          'JumpHeight': 400,
          'JumpHangTime': 0.8,
          'JumpAnimRateModifier': 2,
        },
      },
    );

    expect(isRetreatPhaseActionGroup(legacyJump), isTrue);
    expect(isRegularPhaseActionGroup(legacyJump), isFalse);
  });

  group('generated catalog jump visibility', () {
    setUp(() async {
      ZombossMechRepository.resetForTest();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
      await ZombossMechRepository.init();
    });

    test('Lost City jump aliases stay off other mechs and vice versa', () {
      final egypt = ZombossMechRepository.getCatalog('ZombieZombossMech_Egypt');
      final lostCity =
          ZombossMechRepository.getCatalog('ZombieZombossMech_LostCity');
      expect(egypt, isNotNull);
      expect(lostCity, isNotNull);

      final egyptAliases =
          egypt!.catalogActions.map((action) => action.alias).toSet();
      final lostAliases =
          lostCity!.catalogActions.map((action) => action.alias).toSet();

      expect(egyptAliases, isNot(contains('ZombossLostCityRetreatJump')));
      expect(egyptAliases, isNot(contains('ZombossRiftLostCityRetreatJump')));
      expect(egyptAliases, contains('ZombossRetreatJump'));
      expect(egyptAliases, contains('ZombossSpawnJump'));

      expect(lostAliases, isNot(contains('ZombossRetreatJump')));
      expect(lostAliases, contains('ZombossLostCityRetreatJump'));
      expect(lostAliases, contains('ZombossRiftLostCityRetreatJump'));
      expect(lostAliases, contains('ZombossSpawnJump'));
    });
  });
}
