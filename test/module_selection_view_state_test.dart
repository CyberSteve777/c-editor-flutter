import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Finder _moduleListScrollable() => find.descendant(
  of: find.byKey(const ValueKey('moduleSelectionList')),
  matching: find.byType(Scrollable),
);

void main() {
  testWidgets('module picker restores category and scroll per level', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const bucket = 'module-picker-level-a';
    await tester.pumpWidget(
      _localizedApp(
        const ModuleSelectionScreen(
          existingObjClasses: {},
          stateBucketId: bucket,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('moduleCategory_scene')));
    await tester.pumpAndSettle();
    await tester.drag(_moduleListScrollable(), const Offset(0, -500));
    await tester.pumpAndSettle();
    final savedOffset = tester
        .state<ScrollableState>(_moduleListScrollable())
        .position
        .pixels;
    expect(savedOffset, greaterThan(100));

    await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _localizedApp(
        const ModuleSelectionScreen(
          existingObjClasses: {},
          stateBucketId: bucket,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final sceneChip = tester.widget<AccentBarChoiceChip>(
      find.byKey(const ValueKey('moduleCategory_scene')),
    );
    expect(sceneChip.selected, isTrue);
    final restoredOffset = tester
        .state<ScrollableState>(_moduleListScrollable())
        .position
        .pixels;
    expect(restoredOffset, closeTo(savedOffset, 1));

    await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      _localizedApp(
        const ModuleSelectionScreen(
          existingObjClasses: {},
          stateBucketId: 'module-picker-level-b',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final allChip = tester.widget<AccentBarChoiceChip>(
      find.byKey(const ValueKey('moduleCategory_all')),
    );
    expect(allChip.selected, isTrue);
    expect(
      tester.state<ScrollableState>(_moduleListScrollable()).position.pixels,
      0,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('module picker restores the horizontal category position', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const bucket = 'module-picker-tag-scroll';
    Widget picker() => _localizedApp(
      const ModuleSelectionScreen(
        existingObjClasses: {},
        stateBucketId: bucket,
      ),
    );
    Finder tagScrollable() => find.descendant(
      of: find.byType(HorizontalTagScroller),
      matching: find.byType(Scrollable),
    );

    await tester.pumpWidget(picker());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(HorizontalTagScroller),
      const Offset(-240, 0),
    );
    await tester.pumpAndSettle();
    final savedOffset = tester
        .state<ScrollableState>(tagScrollable())
        .position
        .pixels;
    expect(savedOffset, greaterThan(50));

    await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(picker());
    await tester.pumpAndSettle();

    expect(
      tester.state<ScrollableState>(tagScrollable()).position.pixels,
      closeTo(savedOffset, 1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('placement grid uses full card width on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EditorPlacementGridCard(
              header: Container(
                key: const ValueKey('placementHeader'),
                height: 40,
                color: Colors.red,
              ),
              grid: Container(
                key: const ValueKey('placementGrid'),
                height: 120,
                color: Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final gridWidth = tester
        .getSize(find.byKey(const ValueKey('placementGrid')))
        .width;
    final headerWidth = tester
        .getSize(find.byKey(const ValueKey('placementHeader')))
        .width;
    expect(gridWidth - headerWidth, closeTo(32, 0.1));
    expect(gridWidth, greaterThan(300));
    expect(tester.takeException(), isNull);
  });
}
