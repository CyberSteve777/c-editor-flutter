import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/pvz_models.dart';

void main() {
  test('createDefault provides the Moon Grapple gameplay configuration', () {
    final module = MoonGrappleModulePropertiesData.createDefault();

    expect(module.shipPosition.x, 400.0);
    expect(module.shipPosition.y, 570.0);
    expect(module.rounds, hasLength(3));
    expect(module.rounds[0].targetScore, 650);
    expect(module.rounds[1].targetScore, 950);
    expect(module.rounds[2].targetScore, 1300);
    expect(module.rounds[0].items, hasLength(5));
    expect(module.rounds[0].items[0].spawnWeight, 0.55);
    expect(module.rounds[2].items[3].score, 160);
    expect(module.backgroundObjects, hasLength(3));
    expect(module.experienceRequirements, [10, 12, 14, 16, 18, 21, 24, 27, 31]);
  });

  test(
    'rendering definitions are fixed while gameplay values are editable',
    () {
      final module = MoonGrappleModulePropertiesData.fromJson({
        'ShipPopAnimName': 'invalid',
        'HookBodyStartArtOffset': {'x': 999.0, 'y': 999.0},
        'Rounds': [
          {
            'TargetScore': 700,
            'Items': [
              {
                'Type': 'SmallCrystal',
                'PopAnimName': 'invalid',
                'AttachedPAMOffset': {'x': 999.0, 'y': 999.0},
                'SpawnWeight': 0.8,
                'Score': 40,
                'Experience': 3,
                'CollisionRadius': 31.0,
              },
            ],
          },
        ],
        'BackgroundObjects': [
          {
            'PopAnimName': 'POPANIM_EFFECTS_GRAPPLE_JACKFRUIT',
            'ArtCenter': {'x': 999.0, 'y': 999.0},
            'Speed': 180.0,
          },
        ],
      });

      final item = module.rounds.single.items.single;
      expect(module.shipPopAnimName, 'POPANIM_EFFECTS_GRAPPLE_CONSOLE');
      expect(module.hookBodyStartArtOffset.x, 0.0);
      expect(module.hookBodyStartArtOffset.y, 99.5);
      expect(item.popAnimName, 'POPANIM_EFFECTS_GRAPPLE_SMALL_CRYSTAL');
      expect(item.attachedPamOffset.x, -112.5);
      expect(item.spawnWeight, 0.8);
      expect(item.score, 40);
      expect(item.experience, 3);
      expect(item.collisionRadius, 31.0);
      expect(module.backgroundObjects.single.artCenter.x, 97.0);
      expect(module.backgroundObjects.single.artCenter.y, 119.0);
      expect(module.backgroundObjects.single.speed, 180.0);
    },
  );

  test('only supported spawn objects can be configured', () {
    expect(
      () => MoonGrappleItemData(type: 'UnknownObject'),
      throwsArgumentError,
    );
    expect(MoonGrappleItemData.supportedTypes, hasLength(5));
    expect(MoonGrappleBackgroundObjectData.supportedPopAnimNames, hasLength(3));
  });

  test('module gameplay settings round-trip through JSON', () {
    final original = MoonGrappleModulePropertiesData.createDefault();
    original.rounds[1].items[0].spawnWeight = 0.73;
    original.rounds[2].targetScore = 1500;
    original.magnetCapacities[2] = 3;

    final restored = MoonGrappleModulePropertiesData.fromJson(
      original.toJson(),
    );

    expect(restored.rounds[1].items[0].spawnWeight, 0.73);
    expect(restored.rounds[2].targetScore, 1500);
    expect(restored.magnetCapacities[2], 3);
    expect(
      restored.rounds[1].items[0].popAnimName,
      'POPANIM_EFFECTS_GRAPPLE_SMALL_CRYSTAL',
    );
  });
}
