import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_selection_screen.dart';
import 'package:c_editor/widgets/animated_extended_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ZombossMechCatalogEntry makeCatalog() {
    return ZombossMechCatalogEntry(
      id: 'SelectionStateMech',
      icon: 'unknown.webp',
      defaultPhaseCount: 1,
      variations: const [],
      editableInstance: 'selection_state_mech',
      editableInstancePropsName: 'SelectionStateProps',
      actions: [
        ZombossMechObjclassGroup(
          objclass: 'SelectionStateActionDefinition',
          tag: 'attack',
          fields: const [],
          implementations: {
            for (var i = 0; i < 40; i++)
              'SelectionStateAction$i': {'Weight': i},
          },
        ),
      ],
      properties: const [],
    );
  }

  Widget buildPicker(PvzLevelFile levelFile, ZombossMechCatalogEntry catalog) {
    return MaterialApp(
      home: ZombossMechActionSelectionScreen(
        catalog: catalog,
        levelFile: levelFile,
      ),
    );
  }

  testWidgets('switching category resets the list and reveals the create FAB', (
    tester,
  ) async {
    final levelFile = PvzLevelFile(objects: []);
    final catalog = makeCatalog();
    await tester.pumpWidget(buildPicker(levelFile, catalog));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AnimatedExtendedFab>(find.byType(AnimatedExtendedFab))
          .visible,
      isFalse,
    );

    await tester.tap(find.widgetWithText(ChoiceChip, 'Attack'));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<AnimatedExtendedFab>(find.byType(AnimatedExtendedFab))
          .visible,
      isTrue,
    );
    expect(
      tester
          .state<ScrollableState>(find.byType(Scrollable).last)
          .position
          .pixels,
      0,
    );
  });

  testWidgets('reopening for the same level restores category and scroll', (
    tester,
  ) async {
    final levelFile = PvzLevelFile(objects: []);
    final catalog = makeCatalog();
    await tester.pumpWidget(buildPicker(levelFile, catalog));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Attack'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    final offsetBefore = tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .pixels;
    expect(offsetBefore, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildPicker(levelFile, catalog));
    await tester.pumpAndSettle();

    final attackChip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Attack'),
    );
    expect(attackChip.selected, isTrue);
    final offsetAfter = tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .pixels;
    expect(offsetAfter, greaterThan(0));
  });
}
