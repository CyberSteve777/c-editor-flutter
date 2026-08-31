import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
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
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('horizontalTagScrollerScrollView')),
    );
    expect(scrollView.padding, const EdgeInsets.fromLTRB(12, 8, 12, 16));
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
    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('horizontalTagScrollerScrollView')),
    );
    expect(
      scrollView.padding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  });

  testWidgets('wide overflowing tag row also keeps its scrollbar visible', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 240);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HorizontalTagScroller(
            children: List.generate(
              8,
              (index) => SizedBox(width: 160, child: Text('Tag $index')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollbar = tester.widget<Scrollbar>(
      find.byKey(const ValueKey('horizontalTagScrollerScrollbar')),
    );
    expect(scrollbar.thumbVisibility, isTrue);
  });

  testWidgets('light accent bars use a dark, six-pixel scrollbar', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 240);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Scaffold(
          body: HorizontalTagScroller(
            onAccentBar: true,
            children: List.generate(
              6,
              (index) => SizedBox(width: 100, child: Text('Tag $index')),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final scrollbarTheme = tester.widget<ScrollbarTheme>(
      find.byType(ScrollbarTheme),
    );
    final thumbColor = scrollbarTheme.data.thumbColor?.resolve({});
    final trackColor = scrollbarTheme.data.trackColor?.resolve({});
    expect(scrollbarTheme.data.thickness?.resolve({}), 6);
    expect(thumbColor, isNotNull);
    expect(trackColor, isNotNull);
    expect(thumbColor!.computeLuminance(), lessThan(0.3));
    expect(trackColor!.a, greaterThan(0));
  });

  testWidgets('horizontal tag rows restore an explicit scroll offset', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 260);
    addTearDown(tester.view.reset);

    double savedOffset = 0;
    Widget buildScroller(double initialOffset) => MaterialApp(
      home: Scaffold(
        body: HorizontalTagScroller(
          initialScrollOffset: initialOffset,
          onScrollOffsetChanged: (offset) => savedOffset = offset,
          children: List.generate(
            8,
            (index) => SizedBox(width: 100, child: Text('Tag $index')),
          ),
        ),
      ),
    );

    await tester.pumpWidget(buildScroller(0));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byType(HorizontalTagScroller),
      const Offset(-280, 0),
    );
    await tester.pumpAndSettle();
    expect(savedOffset, greaterThan(100));

    final offsetToRestore = savedOffset;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(buildScroller(offsetToRestore));
    await tester.pumpAndSettle();

    final scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byType(HorizontalTagScroller),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.pixels, closeTo(offsetToRestore, 1));
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

  testWidgets(
    'top tab strip keeps a visible scrollbar and follows controller',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 260);
      addTearDown(tester.view.reset);

      TabController? controller;
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 4,
            child: Builder(
              builder: (context) {
                controller = DefaultTabController.of(context);
                return Scaffold(
                  body: PersistentScrollableTabBar(
                    controller: controller!,
                    tabs: const [
                      Tab(icon: Icon(Icons.settings), text: 'Settings'),
                      Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
                      Tab(icon: Icon(Icons.waves), text: 'Wave generator'),
                      Tab(icon: Icon(Icons.sledding), text: 'All by Oneself'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tabStrip = find.byType(PersistentScrollableTabBar);
      final scrollable = tester.state<ScrollableState>(
        find.descendant(of: tabStrip, matching: find.byType(Scrollable)),
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
      final scrollbar = tester.widget<Scrollbar>(
        find.descendant(
          of: tabStrip,
          matching: find.byKey(const ValueKey('accentBarFilterScrollbar')),
        ),
      );
      expect(scrollbar.thumbVisibility, isTrue);

      controller!.animateTo(3);
      await tester.pumpAndSettle();
      expect(controller!.index, 3);
      expect(scrollable.position.pixels, greaterThan(0));
    },
  );

  testWidgets('module and event category tags leave a clear scrollbar lane', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);

    Widget localized(Widget home) => MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    );

    Future<void> expectScrollbarGap() async {
      await tester.pumpAndSettle();
      final scroller = find.byType(HorizontalTagScroller);
      final firstTag = find
          .descendant(of: scroller, matching: find.byType(AccentBarChoiceChip))
          .first;
      final gap =
          tester.getBottomLeft(scroller).dy - tester.getBottomLeft(firstTag).dy;
      expect(gap, greaterThanOrEqualTo(14));
      expect(
        tester.widget<HorizontalTagScroller>(scroller).padding,
        const EdgeInsets.fromLTRB(8, 8, 8, 14),
      );
    }

    await tester.pumpWidget(
      localized(
        const ModuleSelectionScreen(
          existingObjClasses: {},
          stateBucketId: 'scrollbar-gap-test',
        ),
      ),
    );
    await expectScrollbarGap();

    final levelDef = LevelDefinitionData();
    await tester.pumpWidget(
      localized(
        EventSelectionScreen(
          waveIndex: 1,
          levelFile: PvzLevelFile(
            objects: [
              PvzObject(
                aliases: const ['LevelDefinition'],
                objClass: 'LevelDefinition',
                objData: levelDef.toJson(),
              ),
            ],
          ),
          onEventSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await expectScrollbarGap();
    expect(tester.takeException(), isNull);
  });
}
