import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_properties_view_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    ZombossMechRepository.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  test('loads ZombossMechs.json with base groups and variations', () async {
    await ZombossMechRepository.init();
    expect(ZombossMechRepository.loadError, isNull);
    expect(ZombossMechRepository.allZombossMechs, isNotEmpty);

    final beach = ZombossMechRepository.getBase('ZombieZombossMech_Beach');
    expect(beach, isNotNull);
    expect(beach!.variations, contains('zombossmech_beach'));
    expect(
      ZombossMechRepository.findBaseForVariation('zombossmech_future')?.id,
      'ZombieZombossMech_Future',
    );
  });

  test('resolves built-in property data for read-only details', () async {
    await ZombossMechRepository.init();
    await ZombiePropertiesRepository.init();

    final propsData = ZombossMechRepository.propertiesDataForVariation(
      'zombossmech_egypt',
    );

    expect(propsData, isNotNull);
    expect(propsData!['Stages'], isA<List>());
    expect(propsData['Stages'], isNotEmpty);
    expect((propsData['Stages'] as List).first['Actions'], isA<List>());
  });

  test('resolves memo editable instances to their owning base mech', () async {
    await ZombossMechRepository.init();

    expect(
      ZombossMechRepository.findBaseForVariation('zombossmech_iceage_memo')?.id,
      'ZombieZombossMech_IceAge',
    );
    expect(
      ZombossMechRepository.resolveBaseId(null, 'zombossmech_future_memo'),
      'ZombieZombossMech_Future',
    );
  });

  test(
    'squash fields use mech template defaults and persist on custom props',
    () async {
      await ZombossMechRepository.init();
      await ZombiePropertiesRepository.init();
      final catalog = ZombossMechRepository.getCatalog(
        'ZombieZombossMech_Egypt',
      )!;

      expect(
        ZombossMechRepository.boolPropertyWithTemplateFallback(
          data: const {},
          catalog: catalog,
          key: 'SquashZombies',
        ),
        isTrue,
      );
      expect(
        ZombossMechRepository.boolPropertyWithTemplateFallback(
          data: const {},
          catalog: catalog,
          key: 'SquashGridItems',
        ),
        isFalse,
      );

      final levelFile = PvzLevelFile(objects: []);
      final custom = ZombossMechRepository.ensureCustomPropertiesInLevel(
        catalog: catalog,
        levelFile: levelFile,
        sourceVariation: 'zombossmech_egypt',
      );
      expect(custom.objData['SquashZombies'], isTrue);
      expect(custom.objData['SquashGridItems'], isFalse);

      custom.objData['SquashZombies'] = false;
      custom.objData['SquashGridItems'] = true;
      final reloaded = PvzLevelFile.fromJson(levelFile.toJson());
      expect(reloaded.objects.single.objData['SquashZombies'], isFalse);
      expect(reloaded.objects.single.objData['SquashGridItems'], isTrue);
    },
  );

  testWidgets('read-only squash labels stay enabled while switches are grey', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ZombossMechReadOnlyBoolRow(
            key: ValueKey('readOnlySquashZombies'),
            label: 'Can squash zombies',
            value: true,
          ),
        ),
      ),
    );
    await tester.pump();

    final row = find.byKey(const ValueKey('readOnlySquashZombies'));
    final label = find.descendant(
      of: row,
      matching: find.text('Can squash zombies'),
    );
    final labelContext = tester.element(label);
    expect(
      DefaultTextStyle.of(labelContext).style.color,
      isNot(Theme.of(labelContext).disabledColor),
    );
    final toggle = tester.widget<Switch>(
      find.descendant(of: row, matching: find.byType(Switch)),
    );
    expect(toggle.onChanged, isNull);
  });
}
