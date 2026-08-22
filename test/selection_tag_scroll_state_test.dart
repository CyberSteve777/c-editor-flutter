import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
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

Finder _tagScrollable() => find.descendant(
  of: find.byType(AccentBarFilterTabRow),
  matching: find.byType(Scrollable),
);

Future<double> _scrollTagRow(WidgetTester tester) async {
  await tester.drag(find.byType(AccentBarFilterTabRow), const Offset(-300, 0));
  await tester.pump(const Duration(milliseconds: 300));
  return tester.state<ScrollableState>(_tagScrollable()).position.pixels;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plant picker restores the tag strip position', (tester) async {
    tester.view.physicalSize = const Size(420, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget picker() => _localizedApp(
      PlantSelectionScreen(
        stateBucketId: 'plant-tag-scroll-test',
        onPlantSelected: (_) {},
        onBack: () {},
      ),
    );

    await tester.pumpWidget(picker());
    await tester.pump();
    final savedOffset = await _scrollTagRow(tester);
    expect(savedOffset, greaterThan(50));

    await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
    await tester.pump();
    await tester.pumpWidget(picker());
    await tester.pump();

    expect(
      tester.state<ScrollableState>(_tagScrollable()).position.pixels,
      closeTo(savedOffset, 1),
    );
  });

  testWidgets('zombie picker restores the tag strip position', (tester) async {
    tester.view.physicalSize = const Size(420, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Widget picker() => _localizedApp(
      ZombieSelectionScreen(
        stateBucketId: 'zombie-tag-scroll-test',
        onZombieSelected: (_) {},
        onBack: () {},
      ),
    );

    await tester.pumpWidget(picker());
    await tester.pump();
    final savedOffset = await _scrollTagRow(tester);
    expect(savedOffset, greaterThan(50));

    await tester.pumpWidget(_localizedApp(const SizedBox.shrink()));
    await tester.pump();
    await tester.pumpWidget(picker());
    await tester.pump();

    expect(
      tester.state<ScrollableState>(_tagScrollable()).position.pixels,
      closeTo(savedOffset, 1),
    );
  });
}
