import 'package:flutter_test/flutter_test.dart';
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
}
