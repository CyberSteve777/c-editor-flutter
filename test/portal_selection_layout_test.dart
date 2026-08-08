import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/select/stage_selection_screen.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';
import 'package:c_editor/widgets/zomboss_mech_weighted_zombie_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
