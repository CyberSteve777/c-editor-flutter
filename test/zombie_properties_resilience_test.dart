import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/custom_zombie_property_sync.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/resilience_weak_type.dart';
import 'package:c_editor/data/rtid_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('supportsResilienceShield', () {
    setUpAll(() async {
      await ZombiePropertiesRepository.init();
      await ResilienceConfigRepository.init();
    });

    test('returns false for zombies without a default Resilience field', () {
      expect(
        ZombiePropertiesRepository.supportsResilienceShield('tutorial'),
        isFalse,
      );
    });

    test('returns true for zombies whose default sheet defines Resilience', () {
      expect(
        ZombiePropertiesRepository.supportsResilienceShield(
          'iceage_hunter_elite',
        ),
        isTrue,
      );
    });

    test('preset switch preserves full elite type and property data', () {
      final objects = _croppedEliteObjects(
        resilience: 'RTID(ResilienceFire8@ResilienceConfig)',
      );
      final typeObj = objects.$1;
      final propsObj = objects.$2;
      final typeData = ZombieTypeData.fromJson(
        Map<String, dynamic>.from(typeObj.objData as Map),
      );
      final propsData = ZombiePropertySheetData.fromJson(
        Map<String, dynamic>.from(propsObj.objData as Map),
      )..resilience = 'RTID(ResilienceLightning1@ResilienceConfig)';

      CustomZombiePropertySync.sync(
        typeObj: typeObj,
        propsObj: propsObj,
        typeData: typeData,
        propsData: propsData,
        resistances: const [0, 0, 0, 0, 0, 0, 0],
      );

      final typeRaw = Map<String, dynamic>.from(typeObj.objData as Map);
      final propsRaw = Map<String, dynamic>.from(propsObj.objData as Map);
      expect(typeRaw['ZombieClass'], 'ZombieIceAgeHunterElite');
      expect(typeRaw['ResourceGroups'], contains('ZombieIceAgeHunterGroup'));
      expect(typeRaw['AnimRigClass'], 'ZombieAnimRig_Hunter');
      expect(typeRaw['PopAnim'], 'POPANIM_ZOMBIE_ZOMBIE_ICEAGE_HUNTER_ELITE');
      expect(typeRaw['Resistences'], isA<List>());
      expect(
        propsRaw['Resilience'],
        'RTID(ResilienceLightning1@ResilienceConfig)',
      );
      expect(
        propsRaw['Actions'],
        contains('RTID(ZombieIceAgeEliteProjectileAction@ZombieActions)'),
      );
      expect(propsRaw['NearAttackRange'], 1);
      expect(propsRaw['FarAttackRange'], 4);
      expect(propsRaw['SnowballsPerBarrage'], 3);
      expect(propsRaw['ZombieStats'], isA<List>());
      expect(propsRaw['ZombieLevelStats'], isA<List>());
    });

    test('disabling resilience removes only Resilience from full sheet', () {
      final objects = _croppedEliteObjects(
        resilience: 'RTID(ResilienceFire8@ResilienceConfig)',
      );
      final typeObj = objects.$1;
      final propsObj = objects.$2;
      final typeData = ZombieTypeData.fromJson(
        Map<String, dynamic>.from(typeObj.objData as Map),
      );
      final propsData = ZombiePropertySheetData.fromJson(
        Map<String, dynamic>.from(propsObj.objData as Map),
      )..resilience = null;

      CustomZombiePropertySync.sync(
        typeObj: typeObj,
        propsObj: propsObj,
        typeData: typeData,
        propsData: propsData,
        resistances: const [0, 0, 0, 0, 0, 0, 0],
      );

      final propsRaw = Map<String, dynamic>.from(propsObj.objData as Map);
      expect(propsRaw.containsKey('Resilience'), isFalse);
      expect(
        propsRaw['Actions'],
        contains('RTID(ZombieIceAgeEliteProjectileAction@ZombieActions)'),
      );
      expect(propsRaw['ZombieStats'], isA<List>());
      expect(propsRaw['ZombieLevelStats'], isA<List>());
    });

    test('custom resilience payload keeps official break animation labels', () {
      final data = ZombieResilienceData(weakType: 4);
      final payload = data.toLevelJson();
      expect(payload['WeakType'], 4);
      expect(payload['Amount'], 300.0);
      expect(payload['AnimLabels'], [
        'break_enter',
        'break_loop',
        'break_recover',
      ]);
    });

    test('WeakType labels follow JSON values', () {
      final labels = resilienceWeakTypeJsonValues
          .map((value) => resilienceWeakTypeLabelForValue(null, value))
          .toList();

      expect(labels, [
        'Physics',
        'Poison',
        'Electric',
        'Magic',
        'Ice',
        'Fire',
      ]);
    });

    test('WeakType save mapping uses explicit JSON values', () {
      for (final entry in weakTypeToJsonValue.entries) {
        final jsonValue = resilienceWeakTypeToJson(entry.key);
        final payload = ZombieResilienceData(weakType: jsonValue).toLevelJson();

        expect(payload['WeakType'], entry.value);
      }
    });

    test('WeakType survives round-trip for all known values', () {
      for (final value in resilienceWeakTypeJsonValues) {
        final data = ZombieResilienceData.fromJson({'WeakType': value});

        expect(data.toLevelJson()['WeakType'], value);
      }
    });

    test('WeakType survives partial edits', () {
      final data = ZombieResilienceData.fromJson({
        'Amount': 300,
        'WeakType': 4,
        'RecoverSpeed': 25,
      });

      data.amount = 500;

      final payload = data.toLevelJson();
      expect(payload['Amount'], 500.0);
      expect(payload['WeakType'], 4);
    });

    test('unknown WeakType is displayed as unknown and preserved', () {
      final data = ZombieResilienceData.fromJson({'WeakType': 9});

      expect(
        resilienceWeakTypeLabelForValue(null, 9),
        'Unknown type (value: 9)',
      );
      expect(data.toLevelJson()['WeakType'], 9);
    });

    test('preset WeakType values come from ResilienceConfig data', () {
      final lightning = ResilienceConfigRepository.getByAlias(
        'ResilienceLightning1',
      )!;
      final fire = ResilienceConfigRepository.getByAlias('ResilienceFire8')!;

      expect(lightning.data.weakType, 3);
      expect(
        resilienceWeakTypeLabelForValue(null, lightning.data.weakType),
        'Electric',
      );
      expect(fire.data.weakType, 6);
      expect(resilienceWeakTypeLabelForValue(null, fire.data.weakType), 'Fire');
      expect(resilienceWeakTypeLabelForValue(null, 1), 'Physics');
      expect(resilienceWeakTypeLabelForValue(null, 4), 'Magic');
    });
  });
}

(PvzObject, PvzObject) _croppedEliteObjects({required String resilience}) {
  final originalProps = ZombiePropertiesRepository.getOriginalPropertyObject(
    'iceage_hunter_elite',
  )!;
  final propsAlias = 'ZombieIceAgeHunterEliteCustomProps';
  final typeObj = PvzObject(
    aliases: const ['iceage_hunter_elite_custom'],
    objClass: 'ZombieType',
    objData: {
      'TypeName': 'iceage_hunter_elite',
      'Properties': RtidParser.build(propsAlias, 'CurrentLevel'),
    },
  );
  final originalPropsData = ZombiePropertySheetData.fromJson(
    Map<String, dynamic>.from(originalProps.objData as Map),
  );
  final propsObj = PvzObject(
    aliases: [propsAlias],
    objClass: originalProps.objClass,
    objData: {
      'Hitpoints': originalPropsData.hitpoints,
      'Speed': originalPropsData.speed,
      'EatDPS': originalPropsData.eatDPS,
      'Weight': originalPropsData.weight,
      'WavePointCost': originalPropsData.wavePointCost,
      'Resilience': resilience,
    },
  );
  return (typeObj, propsObj);
}
