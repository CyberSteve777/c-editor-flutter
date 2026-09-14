import 'package:c_editor/widgets/app_ui_scale.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _filterScrollbarKey = ValueKey('accentBarFilterScrollbar');
const _tagScrollbarKey = ValueKey('horizontalTagScrollerScrollbar');

Widget _app({
  TargetPlatform platform = TargetPlatform.iOS,
  double bottomInset = 34,
  double scale = 1,
  bool overflowing = true,
  bool includeOtherInsets = true,
}) => MaterialApp(
  theme: ThemeData(platform: platform),
  builder: (context, child) {
    final media = MediaQuery.of(context);
    final logicalSize = media.size / scale;
    final safeInsets =
        EdgeInsets.fromLTRB(
          includeOtherInsets ? 47 : 0,
          includeOtherInsets ? 20 : 0,
          includeOtherInsets ? 21 : 0,
          bottomInset,
        ) /
        scale;
    return MediaQuery(
      data: media.copyWith(
        size: logicalSize,
        padding: safeInsets,
        viewPadding: safeInsets,
        viewInsets: EdgeInsets.zero,
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: logicalSize.width,
          height: logicalSize.height,
          child: AppUiScale(scale: scale, child: child!),
        ),
      ),
    );
  },
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.only(left: 24, top: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 360,
            child: AccentBarFilterTabRow(
              selectedIndex: 0,
              onSelected: (_) {},
              tabs: overflowing
                  ? const [
                      Text('All plants'),
                      Text('White quality'),
                      Text('Green quality'),
                      Text('Blue quality'),
                      Text('Purple quality'),
                      Text('Orange quality'),
                    ]
                  : const [Text('All plants')],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: 360,
            child: HorizontalTagScroller(
              children: List.generate(
                overflowing ? 8 : 1,
                (index) => SizedBox(
                  key: ValueKey('tag-content-$index'),
                  width: 120,
                  height: 32,
                  child: Text('Tag $index'),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);

Finder _paint(Key scrollbarKey) => find.descendant(
  of: find.byKey(scrollbarKey),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint && widget.foregroundPainter is ScrollbarPainter,
  ),
);

// Mouse hit testing exposes the painted rectangle, without the extra touch
// target that can overlap a tab even when its visible thumb is correctly placed.
Rect? _paintedThumb(WidgetTester tester, Key scrollbarKey) {
  final paint = _paint(scrollbarKey);
  expect(paint, findsOneWidget);
  final painter =
      tester.widget<CustomPaint>(paint).foregroundPainter! as ScrollbarPainter;
  final box = tester.renderObject<RenderBox>(paint);
  bool isThumb(Offset point) =>
      painter.hitTestOnlyThumbInteractive(point, PointerDeviceKind.mouse);
  Offset? seed;
  for (var y = 0.5; y < box.size.height && seed == null; y += 1) {
    for (var x = 0.5; x < box.size.width; x += 1) {
      if (isThumb(Offset(x, y))) {
        seed = Offset(x, y);
        break;
      }
    }
  }
  if (seed == null) return null;
  var left = seed.dx;
  var right = seed.dx;
  var top = seed.dy;
  var bottom = seed.dy;
  while (isThumb(Offset(left - 0.25, seed.dy))) {
    left -= 0.25;
  }
  while (isThumb(Offset(right + 0.25, seed.dy))) {
    right += 0.25;
  }
  while (isThumb(Offset(seed.dx, top - 0.25))) {
    top -= 0.25;
  }
  while (isThumb(Offset(seed.dx, bottom + 0.25))) {
    bottom += 0.25;
  }
  return Rect.fromPoints(
    box.localToGlobal(Offset(left, top)),
    box.localToGlobal(Offset(right, bottom)),
  );
}

Rect _globalRect(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
}

Future<void> _setView(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(900, 600);
  addTearDown(tester.view.reset);
}

void _expectSameRect(Rect actual, Rect expected, double scale) {
  expect(actual.left, closeTo(expected.left, 0.5 * scale));
  expect(actual.right, closeTo(expected.right, 0.5 * scale));
  expect(actual.top, closeTo(expected.top, 0.5 * scale));
  expect(actual.bottom, closeTo(expected.bottom, 0.5 * scale));
}

Future<void> _dragThumbRight(
  WidgetTester tester,
  Key scrollbarKey,
  double scale,
) async {
  final controller = tester
      .widget<Scrollbar>(find.byKey(scrollbarKey))
      .controller!;
  final before = controller.offset;
  final thumb = _paintedThumb(tester, scrollbarKey)!;
  final gesture = await tester.startGesture(
    thumb.center,
    kind: PointerDeviceKind.touch,
  );
  // Cupertino requires a press before dragging its thumb. Starting at the
  // painted thumb and moving right must increase the scroll offset; dragging
  // the content itself would decrease it instead.
  await tester.pump(const Duration(milliseconds: 500));
  await gesture.moveBy(Offset(70 * scale, 0));
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pumpAndSettle();
  expect(controller.offset, greaterThan(before + 30));
  final movedThumb = _paintedThumb(tester, scrollbarKey)!;
  expect(movedThumb.left, greaterThan(thumb.left + 20 * scale));
}

void main() {
  testWidgets('iOS filter thumb stays below underline with home indicator', (
    tester,
  ) async {
    await _setView(tester);
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final thumb = _paintedThumb(tester, _filterScrollbarKey);
    expect(thumb, isNotNull);
    final underline = _globalRect(
      tester,
      find.byKey(const ValueKey('accentBarFilterSelectedIndicator')),
    );
    expect(
      thumb!.top,
      greaterThan(underline.bottom),
      reason:
          'Screen bottom padding must not lift a local thumb above its tabs.',
    );
    final row = _globalRect(tester, find.byType(AccentBarFilterTabRow));
    expect(thumb.bottom, lessThanOrEqualTo(row.bottom));
    expect(row.bottom, lessThan(500));
    expect(tester.takeException(), isNull);
  });

  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final scale in [1.0, 1.5]) {
      for (final bottomInset in [0.0, 20.0, 34.0]) {
        testWidgets(
          '${platform.name} local horizontal thumbs keep position and drag '
          'with bottom $bottomInset at UI scale $scale',
          (tester) async {
            await _setView(tester);
            await tester.pumpWidget(
              _app(
                platform: platform,
                scale: scale,
                bottomInset: 0,
                includeOtherInsets: false,
              ),
            );
            await tester.pumpAndSettle();
            final filterBaseline = _paintedThumb(tester, _filterScrollbarKey)!;
            final tagBaseline = _paintedThumb(tester, _tagScrollbarKey)!;

            await tester.pumpWidget(
              _app(platform: platform, scale: scale, bottomInset: bottomInset),
            );
            await tester.pumpAndSettle();
            final filterThumb = _paintedThumb(tester, _filterScrollbarKey)!;
            final tagThumb = _paintedThumb(tester, _tagScrollbarKey)!;
            _expectSameRect(filterThumb, filterBaseline, scale);
            _expectSameRect(tagThumb, tagBaseline, scale);

            final underline = _globalRect(
              tester,
              find.byKey(const ValueKey('accentBarFilterSelectedIndicator')),
            );
            final tag = _globalRect(
              tester,
              find.byKey(const ValueKey('tag-content-0')),
            );
            expect(filterThumb.top, greaterThan(underline.bottom));
            expect(tagThumb.top, greaterThan(tag.bottom));

            // The surrounding screen retains its safe area. Only the local
            // scrollbar should stop applying those screen-edge insets.
            final outside = tester.element(find.byType(HorizontalTagScroller));
            expect(
              MediaQuery.paddingOf(outside),
              EdgeInsets.fromLTRB(47, 20, 21, bottomInset) / scale,
            );
            expect(AppUiScale.of(outside), scale);
            await _dragThumbRight(tester, _filterScrollbarKey, scale);
            await _dragThumbRight(tester, _tagScrollbarKey, scale);
            expect(tester.takeException(), isNull);
          },
        );
      }

      testWidgets('${platform.name} rows that fit paint no horizontal thumb '
          'with safe insets at UI scale $scale', (tester) async {
        await _setView(tester);
        await tester.pumpWidget(
          _app(platform: platform, scale: scale, overflowing: false),
        );
        await tester.pumpAndSettle();
        expect(_paintedThumb(tester, _filterScrollbarKey), isNull);
        expect(_paintedThumb(tester, _tagScrollbarKey), isNull);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
