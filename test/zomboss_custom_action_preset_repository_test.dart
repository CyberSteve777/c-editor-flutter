import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    ZombossCustomActionPresetRepository.resetForTest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
    await ZombossCustomActionPresetRepository.init();
  });

  test('loads presets for the matching memo mechs only', () {
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_egypt_memo',
      ).map((preset) => preset.id),
      contains('nightmare_stomp_spawn'),
    );
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_iceage_memo',
      ).map((preset) => preset.id).toList(),
      ['sport_tank_spawn', 'sport_wind_spawn'],
    );
    expect(
      ZombossCustomActionPresetRepository.presetsForMech(
        'zombossmech_modern_memo',
      ),
      isEmpty,
    );
  });

  test('instantiates tank preset with collision-safe dependency rtid', () {
    final preset = ZombossCustomActionPresetRepository.presetById(
      'sport_tank_spawn',
    );
    expect(preset, isNotNull);

    final level = PvzLevelFile(
      objects: [
        PvzObject(aliases: ['SpawnBall'], objClass: 'Other', objData: {}),
      ],
    );
    final creation = ZombossCustomActionPresetRepository.instantiatePreset(
      level,
      preset!,
    );

    final main = level.objects.firstWhere(
      (object) =>
          object.aliases?.contains('ZombieIceAgeSpawnBallAction') == true,
    );
    final data = Map<String, dynamic>.from(main.objData as Map);
    expect(data['AwardDrop'], 'RTID(SpawnBall_2@CurrentLevel)');
    expect(
      level.objects.any(
        (object) =>
            object.aliases?.contains('SpawnBall_2') == true &&
            object.objClass == 'ZombieDropProps',
      ),
      isTrue,
    );
    expect(
      ZombossCustomActionPresetRepository.originForRtid(level, creation.rtid),
      ZombossCustomActionOrigin.presetTemplate,
    );
    expect(level.toJson().toString(), isNot(contains('__c_editor_')));
  });

  test(
    'derives a blue action and can remove the temporary object references',
    () {
      final preset = ZombossCustomActionPresetRepository.presetById(
        'sport_tank_spawn',
      );
      expect(preset, isNotNull);

      final level = PvzLevelFile(objects: []);
      final green = ZombossCustomActionPresetRepository.instantiatePreset(
        level,
        preset!,
      );
      final blue = ZombossCustomActionPresetRepository.deriveFromPresetInstance(
        level,
        green.rtid,
      );

      expect(blue, isNotNull);
      expect(
        ZombossCustomActionPresetRepository.originForRtid(level, blue!.rtid),
        ZombossCustomActionOrigin.presetDerived,
      );
      final blueMain = level.objects.firstWhere(
        (object) =>
            object.aliases?.contains('ZombieIceAgeSpawnBallAction_2') == true,
      );
      expect(
        Map<String, dynamic>.from(blueMain.objData as Map)['AwardDrop'],
        'RTID(SpawnBall_2@CurrentLevel)',
      );

      final blueDependency = level.objects.firstWhere(
        (object) => object.aliases?.contains('SpawnBall_2') == true,
      );
      final dependencyData = Map<String, dynamic>.from(
        blueDependency.objData as Map,
      );
      dependencyData['Collectables'] = <String>[];
      blueDependency.objData = dependencyData;
      expect(
        ZombossCustomActionPresetRepository.originForRtid(level, blue.rtid),
        ZombossCustomActionOrigin.presetDerived,
      );
      final reopened = PvzLevelFile.fromJson(level.toJson());
      expect(
        ZombossCustomActionPresetRepository.originForRtid(reopened, blue.rtid),
        ZombossCustomActionOrigin.presetDerived,
      );

      ZombossCustomActionPresetRepository.removeCreatedObjects(level, blue);

      expect(
        level.objects.any(
          (object) =>
              object.aliases?.contains('ZombieIceAgeSpawnBallAction_2') == true,
        ),
        isFalse,
      );
      expect(
        ZombossCustomActionPresetRepository.originForRtid(level, green.rtid),
        ZombossCustomActionOrigin.presetTemplate,
      );
    },
  );

  test('accepts a manually redirected valid SpawnBall dependency', () {
    final preset = ZombossCustomActionPresetRepository.presetById(
      'sport_tank_spawn',
    )!;
    final manualDependency = PvzObject(
      aliases: ['ManualSpawnBall'],
      objClass: 'ZombieDropProps',
      objData: {
        'ZombieHordes': [
          {'Type': 'cowboy'},
        ],
        'Collectables': ['spacetime_plantfood'],
        'UnknownField': true,
      },
    );
    final action = PvzObject(
      aliases: [preset.sourceAlias],
      objClass: preset.objclass,
      objData: {
        ...preset.objdata,
        'AwardDrop': 'RTID(ManualSpawnBall@CurrentLevel)',
      },
    );
    final level = PvzLevelFile(objects: [action, manualDependency]);
    final spec = ZombossCustomActionPresetRepository.dependencySpecForField(
      action,
      'AwardDrop',
    )!;
    expect(spec.fields.map((field) => field.name), [
      'ZombieHordes',
      'Collectables',
    ]);

    expect(
      ZombossCustomActionPresetRepository.dependencyObjectForField(
        level,
        action,
        'AwardDrop',
      ),
      same(manualDependency),
    );
    expect(
      ZombossCustomActionPresetRepository.isValidDependencyObject(
        manualDependency,
        spec,
      ),
      isTrue,
    );
    expect(
      ZombossCustomActionPresetRepository.isValidDependencyObject(
        PvzObject(
          aliases: ['Broken'],
          objClass: 'ZombieDropProps',
          objData: {'ZombieHordes': 'not-a-list', 'Collectables': []},
        ),
        spec,
      ),
      isFalse,
    );
  });

  test('uses decimal editors for SpawnBall offsets and toss duration', () {
    final preset = ZombossCustomActionPresetRepository.presetById(
      'sport_tank_spawn',
    )!;
    final dependency = preset.dependencies.single;
    final hordes = dependency.fields.singleWhere(
      (field) => field.name == 'ZombieHordes',
    );
    final byName = {for (final field in hordes.objectFields) field.name: field};
    final xDelta = byName['SpawnGridXDelta']!;

    expect(xDelta.objectFields.map((field) => field.type), ['float', 'float']);
    expect(byName['SpawnGridZDelta']!.type, 'float');
    expect(byName['TossDuration']!.type, 'float');
  });

  test('keeps a newly created action yellow without a JSON marker', () {
    final preset = ZombossCustomActionPresetRepository.presetById(
      'nightmare_stomp_spawn',
    )!;
    final object = PvzObject(
      aliases: [preset.sourceAlias],
      objClass: preset.objclass,
      objData: Map<String, dynamic>.from(preset.objdata),
    );

    ZombossCustomActionPresetRepository.markUserCreated(object);

    expect(
      ZombossCustomActionPresetRepository.originForObject(object),
      ZombossCustomActionOrigin.userCreated,
    );
    expect(object.aliases, [preset.sourceAlias]);
    expect(object.toJson().toString(), isNot(contains('__c_editor_')));
  });
}
