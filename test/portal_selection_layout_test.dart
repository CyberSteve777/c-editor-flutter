import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/screens/select/stage_selection_screen.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(ResourceNames.ensureLoaded);

  Future<void> setNarrowView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('lawn picker controls start directly below the app bar', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: StageSelectionScreen(
          currentStageRtid: 'RTID(EgyptStage@LevelModules)',
          levelFile: PvzLevelFile(objects: []),
          onStageSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    expect(tester.getTopLeft(find.text('Built-in')).dy, lessThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'portal cards and create card share dimensions on narrow screens',
    (tester) async {
      await setNarrowView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: PortalTypeSelectionScreen(
            currentPortalType: 'egypt',
            levelFile: PvzLevelFile(objects: []),
          ),
        ),
      );
      await tester.pump();

      final cards = find.byType(Card);
      expect(cards, findsWidgets);
      final firstSize = tester.getSize(cards.first);
      final lastSize = tester.getSize(cards.last);
      expect(lastSize, firstSize);
      expect(firstSize.height, 72);

      final gridRect = tester.getRect(find.byType(PortalTypeChooserGrid));
      expect(gridRect.right, closeTo(304, 0.1));
      expect(find.text('New custom portal'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('read-only portal fields expose the zombie preview', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PortalTypeSingleSelectField(
            label: 'Portal type (PortalType)',
            value: 'egypt',
            editable: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('This portal spawns:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('existing memo portal replaces the new portal card', (
    tester,
  ) async {
    await setNarrowView(tester);
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['GridItemZombiePortalMemo'],
          objClass: 'GridItemZombiePortalProps',
          objData: PortalRepository.blankPropertiesData(),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: PortalTypeSelectionScreen(
          currentPortalType: 'memo',
          levelFile: level,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New custom portal'), findsNothing);
    expect(find.text('Custom Portal'), findsOneWidget);
    expect(find.text('Custom Portal 1'), findsNothing);
    expect(find.text('C'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom portal zombie additions default to weight one', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: CustomPortalPropertiesScreen(
          levelFile: PvzLevelFile(objects: []),
        ),
      ),
    );
    await tester.pump();

    final editor = tester.widget<ZombossMechWeightedZombieListEditor>(
      find.byType(ZombossMechWeightedZombieListEditor),
    );
    expect(editor.defaultWeight, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'weighted zombie editor stacks its weight field on narrow cards',
    (tester) async {
      await setNarrowView(tester);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: ZombossMechWeightedZombieListEditor(
                fieldLabel: 'Spawnable zombies (ZombieTypesToSpawn)',
                weightLabel: 'Zombie weight (Weight)',
                zombieIds: const ['mummy_armor1'],
                weights: const [100],
                editable: true,
                onChanged: (_, _) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final idRect = tester.getRect(find.text('mummy_armor1').last);
      final fieldRect = tester.getRect(find.byType(TextFormField));
      expect(fieldRect.top, greaterThan(idRect.bottom));
      expect(find.text('Zombie weight (Weight)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'boss portal catalog uses exact suffixes and Danger Room zombie data',
    () {
      const expectedDangerRoomCodes = <String, String>{
        'egypt': 'dangerroom_egypt',
        'pirate': 'dangerroom_pirate',
        'west': 'dangerroom_west',
        'future': 'dangerroom_future',
        'dark': 'dangerroom_dark',
        'beach': 'dangerroom_beach',
        'iceage': 'dangerroom_iceage',
        'eighties': 'dangerroom_eighties',
        'lostcity': 'dangerroom_lostcity',
        'dino': 'dangerroom_dino',
        'skycity': 'dangerroom_skycity',
        'Kongfu': 'dangerroom_Kongfu',
        'Modern': 'dangerroom_modern',
      };

      expect(
        PortalRepository.bossPortalDefinitions.map((item) => item.typeCode),
        expectedDangerRoomCodes.keys,
      );
      for (final entry in expectedDangerRoomCodes.entries) {
        final boss = PortalRepository.bossPortalDefinitionForType(entry.key)!;
        final dangerRoom = PortalRepository.portalDefinitions.firstWhere(
          (item) => item.typeCode == entry.value,
        );
        expect(boss.representativeZombies, dangerRoom.representativeZombies);
      }
      expect(PortalRepository.bossPortalDefinitionForType('memo'), isNull);
    },
  );

  testWidgets('boss portal chooser uses world cards without custom portals', (
    tester,
  ) async {
    await setNarrowView(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        home: ZombossPortalTypeSelectionScreen(currentPortalType: 'egypt'),
      ),
    );
    await tester.pump();

    expect(find.text('Ancient Egypt'), findsOneWidget);
    expect(find.text('egypt'), findsOneWidget);
    expect(find.text('New custom portal'), findsNothing);
    expect(find.byType(PortalTypeChooserGrid), findsNothing);
    expect(find.byIcon(Icons.info_outline), findsWidgets);
    await tester.tap(find.byIcon(Icons.info_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('This portal spawns:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
