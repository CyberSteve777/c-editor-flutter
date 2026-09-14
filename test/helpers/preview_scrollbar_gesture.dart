import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drags the painted thumb instead of accidentally scrolling its child.
Future<void> dragPreviewVerticalScrollbar(
  WidgetTester tester,
  Key scrollbarKey, {
  double distance = 100,
}) async {
  final controller = tester
      .widget<Scrollbar>(find.byKey(scrollbarKey))
      .controller;
  final rawScrollbar = find.descendant(
    of: find.byKey(scrollbarKey),
    matching: find.byWidgetPredicate(
      (widget) => widget is RawScrollbar && widget.controller == controller,
    ),
  );
  expect(rawScrollbar, findsOneWidget);
  final paint = find
      .descendant(
        of: rawScrollbar,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint &&
              widget.foregroundPainter is ScrollbarPainter,
        ),
      )
      .first;
  final painter =
      tester.widget<CustomPaint>(paint).foregroundPainter! as ScrollbarPainter;
  final box = tester.renderObject<RenderBox>(paint);
  final thumbPoints = <Offset>[];
  // Cupertino places the thumb three pixels inside the edge. Scan the painted
  // region rather than assuming the Material scrollbar's margin or thickness.
  for (var x = box.size.width - 0.5; x > box.size.width - 24; x -= 0.5) {
    for (var y = 0.0; y < box.size.height; y += 1) {
      final point = Offset(x, y);
      if (painter.hitTestOnlyThumbInteractive(point, PointerDeviceKind.mouse)) {
        thumbPoints.add(point);
      }
    }
  }
  expect(thumbPoints, isNotEmpty, reason: 'A vertical thumb must be painted.');
  final localThumbCenter = Rect.fromPoints(
    thumbPoints.first,
    thumbPoints.last,
  ).center;
  final gesture = await tester.startGesture(
    box.localToGlobal(localThumbCenter),
    kind: PointerDeviceKind.touch,
  );
  // CupertinoScrollbar begins a touch drag after a short press.
  await tester.pump(const Duration(milliseconds: 500));
  await gesture.moveBy(Offset(0, distance));
  await tester.pump(const Duration(milliseconds: 100));
  await gesture.up();
  await tester.pumpAndSettle();
}
