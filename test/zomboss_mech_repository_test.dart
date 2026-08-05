import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';

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
}
