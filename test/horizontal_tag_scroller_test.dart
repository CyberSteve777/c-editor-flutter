import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('narrow overflowing tag row keeps its scrollbar visible', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HorizontalTagScroller(
            children: List.generate(
              6,
              (index) => SizedBox(width: 100, child: Text('Tag $index')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollerContext = tester.element(find.byType(HorizontalTagScroller));
    final scrollableState = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(HorizontalTagScroller),
        matching: find.byType(Scrollable),
      ),
    );
    expect(MediaQuery.sizeOf(scrollerContext).width, 320);
    expect(scrollableState.position.maxScrollExtent, greaterThan(0));

    final scrollbar = tester.widget<Scrollbar>(
      find.byKey(const ValueKey('horizontalTagScrollerScrollbar')),
    );
    expect(scrollbar.thumbVisibility, isTrue);
  });

  testWidgets('tag row does not force a thumb when all tags fit', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HorizontalTagScroller(
            children: [SizedBox(width: 100, child: Text('Only tag'))],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollbar = tester.widget<Scrollbar>(
      find.byKey(const ValueKey('horizontalTagScrollerScrollbar')),
    );
    expect(scrollbar.thumbVisibility, isFalse);
  });

  testWidgets('accent filter leaves space below the selected underline', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.windows),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 320,
              child: AccentBarFilterTabRow(
                tabs: const [
                  Text('All plants'),
                  Text('White quality'),
                  Text('Green quality'),
                  Text('Blue quality'),
                ],
                selectedIndex: 0,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final rowBottom = tester
        .getBottomLeft(find.byType(AccentBarFilterTabRow))
        .dy;
    final indicatorBottom = tester
        .getBottomLeft(
          find.byKey(const ValueKey('accentBarFilterSelectedIndicator')),
        )
        .dy;

    // Six pixels are occupied by the scrollbar; the remaining four pixels
    // are the visual gap requested between it and the active underline.
    expect(rowBottom - indicatorBottom, greaterThanOrEqualTo(10));
  });
}
