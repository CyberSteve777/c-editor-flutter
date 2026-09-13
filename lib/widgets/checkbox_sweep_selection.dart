import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Adds press-and-sweep selection to the leading checkbox column of a list.
/// Tiles must use leading controls and zero horizontal content padding. Their
/// normal tap, keyboard and accessibility actions remain on the original tiles.
class CheckboxSweepSelection extends StatefulWidget {
  const CheckboxSweepSelection({super.key, required this.children});

  final List<CheckboxListTile> children;

  @override
  State<CheckboxSweepSelection> createState() => _CheckboxSweepSelectionState();
}

class _CheckboxSweepSelectionState extends State<CheckboxSweepSelection>
    with SingleTickerProviderStateMixin {
  final _listKey = GlobalKey();
  late List<GlobalKey> _rowKeys;
  late final Ticker _scrollTicker;
  final _visited = <int>{};
  Offset? _pointer;
  int? _lastIndex;
  bool _selecting = true;
  Duration? _previousTick;

  @override
  void initState() {
    super.initState();
    _rowKeys = List.generate(widget.children.length, (_) => GlobalKey());
    _scrollTicker = createTicker(_scrollAtEdge);
  }

  @override
  void didUpdateWidget(covariant CheckboxSweepSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _finish();
      _rowKeys = List.generate(widget.children.length, (_) => GlobalKey());
    }
  }

  @override
  void dispose() {
    _scrollTicker.dispose();
    super.dispose();
  }

  RenderBox? get _listBox =>
      _listKey.currentContext?.findRenderObject() as RenderBox?;

  RenderBox? get _viewportBox =>
      Scrollable.maybeOf(context)?.context.findRenderObject() as RenderBox?;

  bool _inCheckboxColumn(Offset globalPosition) {
    final box = _listBox;
    if (box == null || !box.hasSize) return false;
    final x = box.globalToLocal(globalPosition).dx;
    return Directionality.of(context) == TextDirection.ltr
        ? x >= 0 && x < kMinInteractiveDimension
        : x <= box.size.width && x > box.size.width - kMinInteractiveDimension;
  }

  int? _indexAt(Offset globalPosition, {bool clampToViewport = true}) {
    if (!_inCheckboxColumn(globalPosition)) return null;
    var position = globalPosition;
    final viewport = _viewportBox;
    if (clampToViewport && viewport != null && viewport.hasSize) {
      final local = viewport.globalToLocal(position);
      position = viewport.localToGlobal(
        Offset(local.dx, local.dy.clamp(0, viewport.size.height - 0.01)),
      );
    }
    for (var index = 0; index < _rowKeys.length; index++) {
      final box =
          _rowKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final y = box.globalToLocal(position).dy;
      if (y >= 0 && y < box.size.height) return index;
    }
    return null;
  }

  bool _canStart(Offset position) {
    final index = _indexAt(position, clampToViewport: false);
    return index != null && widget.children[index].onChanged != null;
  }

  void _start(DragStartDetails details) {
    final index = _indexAt(details.globalPosition);
    if (index == null) return;
    _pointer = details.globalPosition;
    _selecting = widget.children[index].value != true;
    _visited.clear();
    _lastIndex = index;
    _applyAtPointer();
    _previousTick = null;
    _scrollTicker.start();
  }

  void _update(DragUpdateDetails details) {
    if (_pointer == null) return;
    _pointer = details.globalPosition;
    _applyAtPointer();
  }

  void _applyAtPointer() {
    final pointer = _pointer;
    if (pointer == null) return;
    final index = _indexAt(pointer);
    if (index == null) {
      // Leaving the checkbox column pauses the brush. Re-entering does not
      // select rows crossed while the pointer was over the text area.
      _lastIndex = null;
      return;
    }
    final previous = _lastIndex ?? index;
    for (
      var row = math.min(previous, index);
      row <= math.max(previous, index);
      row++
    ) {
      if (!_visited.add(row)) continue;
      final tile = widget.children[row];
      if (tile.value != _selecting) tile.onChanged?.call(_selecting);
    }
    _lastIndex = index;
  }

  void _scrollAtEdge(Duration elapsed) {
    final previous = _previousTick;
    _previousTick = elapsed;
    final pointer = _pointer;
    if (previous == null || pointer == null || !_inCheckboxColumn(pointer)) {
      return;
    }
    final scrollable = Scrollable.maybeOf(context);
    final viewport = _viewportBox;
    if (scrollable == null || viewport == null || !viewport.hasSize) return;
    final position = scrollable.position;
    if (!position.hasContentDimensions || position.axis != Axis.vertical) {
      return;
    }
    final y = viewport.globalToLocal(pointer).dy;
    final edge = math.min(48.0, viewport.size.height / 4);
    if (edge <= 0) return;
    final speed = y < edge
        ? -((edge - y) / edge).clamp(0.0, 1.0)
        : y > viewport.size.height - edge
        ? ((y - viewport.size.height + edge) / edge).clamp(0.0, 1.0)
        : 0.0;
    if (speed == 0) return;
    final seconds = math.min(
      (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond,
      0.05,
    );
    final next = (position.pixels + speed * 420 * seconds).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (next == position.pixels) return;
    position.jumpTo(next);
    // Recompute row positions after scrolling, including when the pointer is
    // held still at the edge. No fixed row height is assumed for wrapped text.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _applyAtPointer();
    });
  }

  void _finish() {
    _scrollTicker.stop();
    _pointer = null;
    _lastIndex = null;
    _previousTick = null;
    _visited.clear();
  }

  @override
  Widget build(BuildContext context) => RawGestureDetector(
    excludeFromSemantics: true,
    gestures: {
      _CheckboxColumnDragRecognizer:
          GestureRecognizerFactoryWithHandlers<_CheckboxColumnDragRecognizer>(
            () => _CheckboxColumnDragRecognizer(debugOwner: this),
            (recognizer) => recognizer
              ..canStart = _canStart
              ..dragStartBehavior = DragStartBehavior.down
              ..onStart = _start
              ..onUpdate = _update
              ..onEnd = (_) {
                _finish();
              }
              ..onCancel = _finish,
          ),
    },
    child: Column(
      key: _listKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < widget.children.length; index++)
          KeyedSubtree(key: _rowKeys[index], child: widget.children[index]),
      ],
    ),
  );
}

class _CheckboxColumnDragRecognizer extends VerticalDragGestureRecognizer {
  _CheckboxColumnDragRecognizer({super.debugOwner});

  bool Function(Offset)? canStart;

  @override
  bool isPointerAllowed(PointerEvent event) =>
      super.isPointerAllowed(event) &&
      (canStart?.call(event.position) ?? false);

  // Trackpad scrolling has no pressed checkbox and must stay with Scrollable.
  @override
  bool isPointerPanZoomAllowed(PointerPanZoomStartEvent event) => false;
}
