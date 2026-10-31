import 'package:c_editor/widgets/persistent_scrollbar_scroll_behavior.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required TargetPlatform platform, required Widget child}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      scrollBehavior: const PersistentScrollbarScrollBehavior(),
      home: Scaffold(body: SizedBox(width: 320, height: 240, child: child)),
    );

ListView _longVerticalList({ScrollController? controller}) => ListView.builder(
  controller: controller,
  itemCount: 30,
  itemBuilder: (_, index) => SizedBox(height: 48, child: Text('Item $index')),
);

Finder get _persistentBar => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollbar &&
      widget.thumbVisibility == true &&
      widget.scrollbarOrientation == ScrollbarOrientation.right,
);

void main() {
  for (final platform in <TargetPlatform>[
    TargetPlatform.android,
    TargetPlatform.iOS,
    TargetPlatform.macOS,
    TargetPlatform.windows,
  ]) {
    testWidgets('vertical pages keep one right scrollbar on ${platform.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(platform: platform, child: _longVerticalList()),
      );
      await tester.pumpAndSettle();

      expect(_persistentBar, findsOneWidget);
      final scrollbar = tester.widget<Scrollbar>(_persistentBar);
      expect(scrollbar.controller, isNotNull);
      expect(scrollbar.trackVisibility, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('help text leaves a separate gutter on every platform', (
    tester,
  ) async {
    for (final platform in TargetPlatform.values) {
      await tester.pumpWidget(
        _app(
          platform: platform,
          child: SingleChildScrollView(
            child: Container(
              key: const ValueKey('helpBody'),
              height: 900,
              width: double.infinity,
              child: const Text('A long help page'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final content = tester.getRect(find.byKey(const ValueKey('helpBody')));
      final bar = tester.getRect(_persistentBar);
      expect(content.right, lessThanOrEqualTo(bar.right - 20));
      expect(content.left, greaterThanOrEqualTo(bar.left + 20));
      expect(content.center.dx, closeTo(bar.center.dx, 0.01));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the gutter also covers a wider hovered thumb', (tester) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.windows,
        child: ScrollbarTheme(
          data: ScrollbarThemeData(
            thickness: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered) ? 32 : 8,
            ),
            crossAxisMargin: 3,
          ),
          child: SingleChildScrollView(
            child: Container(
              key: const ValueKey('helpBody'),
              height: 900,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final content = tester.getRect(find.byKey(const ValueKey('helpBody')));
    final bar = tester.getRect(_persistentBar);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset(bar.right - 5, bar.top + 30));
    await tester.pumpAndSettle();

    expect(content.right, lessThanOrEqualTo(bar.right - 42));
    expect(tester.getRect(find.byKey(const ValueKey('helpBody'))), content);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal controls keep their component-specific behavior', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: const SizedBox(width: 1200, height: 80),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an explicit scrollbar is not duplicated by app behavior', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: Scrollbar(
          key: const ValueKey('explicitScrollbar'),
          controller: controller,
          thumbVisibility: true,
          child: _longVerticalList(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byKey(const ValueKey('explicitScrollbar')), findsOneWidget);
    final viewport = tester.getRect(find.byType(Viewport));
    final bar = tester.getRect(find.byKey(const ValueKey('explicitScrollbar')));
    expect(viewport.right, lessThanOrEqualTo(bar.right - 20));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an explicit left scrollbar reserves space on the left', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.iOS,
        child: Scrollbar(
          key: const ValueKey('leftScrollbar'),
          controller: controller,
          thumbVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.left,
          child: _longVerticalList(controller: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(Viewport));
    final bar = tester.getRect(find.byKey(const ValueKey('leftScrollbar')));
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(viewport.left, greaterThanOrEqualTo(bar.left + 20));
    expect(viewport.right, lessThanOrEqualTo(bar.right - 20));
    expect(viewport.center.dx, closeTo(bar.center.dx, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('nested independent vertical regions each keep one scrollbar', (
    tester,
  ) async {
    final outerController = ScrollController();
    final innerController = ScrollController();
    addTearDown(outerController.dispose);
    addTearDown(innerController.dispose);

    await tester.pumpWidget(
      _app(
        platform: TargetPlatform.android,
        child: Scrollbar(
          key: const ValueKey('outerExplicitScrollbar'),
          controller: outerController,
          thumbVisibility: true,
          child: ListView(
            controller: outerController,
            children: [
              SizedBox(
                height: 120,
                child: ListView.builder(
                  key: const ValueKey('innerVerticalList'),
                  controller: innerController,
                  itemCount: 20,
                  itemBuilder: (_, index) =>
                      SizedBox(height: 36, child: Text('Nested item $index')),
                ),
              ),
              const SizedBox(height: 500),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsNWidgets(2));
    expect(
      tester
          .widgetList<Scrollbar>(find.byType(Scrollbar))
          .where((bar) => bar.controller == innerController),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
  });
}
