import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const objclass = 'ExampleActionDefinition';
  final catalog = ZombossMechCatalogEntry(
    id: 'ExampleMech',
    icon: 'unknown.webp',
    defaultPhaseCount: 1,
    variations: const [],
    editableInstance: 'example_mech',
    editableInstancePropsName: 'ExampleProps',
    actions: const [
      ZombossMechObjclassGroup(
        objclass: objclass,
        tag: 'attack',
        fields: [],
        implementations: {
          'BaseAction1': {'Weight': 10, 'Damage': 100, 'Animation': 'first'},
          'BaseAction2': {'Weight': 20, 'Damage': 200, 'Animation': 'second'},
        },
      ),
    ],
    properties: const [],
  );

  test('exact action data wins over a stale custom alias hint', () {
    final action = ZombossMechActionUtils.inferBaseCatalogAction(
      catalog: catalog,
      customAlias: 'BaseAction1_2',
      objclass: objclass,
      data: const {'Weight': 20, 'Damage': 200, 'Animation': 'second'},
    );

    expect(action?.alias, 'BaseAction2');
  });

  test('edited action data resolves to the nearest implementation', () {
    final action = ZombossMechActionUtils.inferBaseCatalogAction(
      catalog: catalog,
      customAlias: 'MyCustomAction',
      objclass: objclass,
      data: const {'Weight': 99, 'Damage': 200, 'Animation': 'second'},
    );

    expect(action?.alias, 'BaseAction2');
  });

  test('returns null when the objclass has no catalog implementation', () {
    final action = ZombossMechActionUtils.inferBaseCatalogAction(
      catalog: catalog,
      customAlias: 'UnknownAction',
      objclass: 'UnknownActionDefinition',
      data: const {},
    );

    expect(action, isNull);
  });
}
