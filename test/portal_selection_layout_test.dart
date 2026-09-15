import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
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

  testWidgets('selected portal and create action use distinct card colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PortalTypeSelectionScreen(
          currentPortalType: 'egypt',
          levelFile: PvzLevelFile(objects: []),
        ),
      ),
    );
    await tester.pump();

    final selectedCard = tester.widget<Card>(
      find.ancestor(of: find.text('Egypt'), matching: find.byType(Card)).first,
    );
    final createCard = tester.widget<Card>(
      find.ancestor(
        of: find.text('New custom portal'),
        matching: find.byType(Card),
      ),
    );
    final colorScheme = Theme.of(
      tester.element(find.byType(PortalTypeChooserGrid)),
    ).colorScheme;

    expect(selectedCard.color, colorScheme.primaryContainer);
    expect(createCard.color, colorScheme.surface);
    expect(createCard.color, isNot(selectedCard.color));
    expect(createCard.elevation, 0);
    final createShape = createCard.shape! as RoundedRectangleBorder;
    expect(createShape.side.width, 1.5);
    expect(createShape.side.color.a, closeTo(0.72, 0.01));
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('portal info icon is labelled as zombie preview in Chinese', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PortalTypeSingleSelectField(
            label: 'PortalType',
            value: 'egypt',
            editable: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.info_outline),
    );
    expect(button.tooltip, '僵尸预览');
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

  testWidgets('weighted zombie rows can be copied and use trash delete', (
    tester,
  ) async {
    List<String>? changedIds;
    List<int>? changedWeights;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ZombossMechWeightedZombieListEditor(
            fieldLabel: 'Zombies',
            weightLabel: 'Weight',
            zombieIds: const ['mummy'],
            weights: const [7],
            editable: true,
            onChanged: (ids, weights) {
              changedIds = ids;
              changedWeights = weights;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.copy_outlined));
    expect(changedIds, ['mummy', 'mummy']);
    expect(changedWeights, [7, 7]);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test(
    'boss portal catalog uses exact suffixes and Danger Room zombie data',
    () {
      const expectedDangerRoomCodes = <String, String>{
        'egypt': 'dangerroom_egypt',
        'pirate': 'dangerroom_pirate',
        'west': 'dangerroom_west',
        'Kongfu': 'dangerroom_Kongfu',
        'future': 'dangerroom_future',
        'dark': 'dangerroom_dark',
        'beach': 'dangerroom_beach',
        'iceage': 'dangerroom_iceage',
        'skycity': 'dangerroom_skycity',
        'lostcity': 'dangerroom_lostcity',
        'eighties': 'dangerroom_eighties',
        'dino': 'dangerroom_dino',
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
    expect(find.byIcon(Icons.chevron_right), findsNothing);
    await tester.tap(find.byIcon(Icons.info_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('This portal spawns:'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
