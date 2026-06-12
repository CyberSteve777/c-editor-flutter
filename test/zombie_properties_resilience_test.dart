import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('supportsResilienceShield', () {
    setUpAll(() async {
      await ZombiePropertiesRepository.init();
    });

    test('returns false for zombies without a default Resilience field', () {
      expect(ZombiePropertiesRepository.supportsResilienceShield('tutorial'),
          isFalse);
    });

    test('returns true for zombies whose default sheet defines Resilience', () {
      expect(
        ZombiePropertiesRepository.supportsResilienceShield(
          'iceage_hunter_elite',
        ),
        isTrue,
      );
    });
  });
}
