import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

/// Drag session + live insert preview for zombie lane editors.
class ZombieLaneDragScope extends InheritedWidget {
  const ZombieLaneDragScope({
    super.key,
    required this.isDragging,
    required this.draggingIdentity,
    required this.commitRowValue,
    required this.commitInsertIndex,
    required this.previewWidget,
    required this.onPreviewInsert,
    required this.onDragStarted,
    required this.onDragEnded,
    required super.child,
  });

  final bool isDragging;
  final Object? draggingIdentity;
  final int? commitRowValue;
  final int? commitInsertIndex;
  final Widget? previewWidget;
  final void Function(int rowValue, int insertIndex) onPreviewInsert;
  final void Function(Object identity) onDragStarted;
  final VoidCallback onDragEnded;

  static ZombieLaneDragScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ZombieLaneDragScope>();
  }

  @override
  bool updateShouldNotify(ZombieLaneDragScope oldWidget) {
    return isDragging != oldWidget.isDragging ||
        draggingIdentity != oldWidget.draggingIdentity ||
        commitRowValue != oldWidget.commitRowValue ||
        commitInsertIndex != oldWidget.commitInsertIndex ||
        previewWidget != oldWidget.previewWidget;
  }
}

const double zombieLaneSpacing = 8;
const double zombieLaneSlotWidth = zombieLaneCardSize + zombieLaneSpacing;

const Duration zombieLaneShiftDuration = Duration(milliseconds: 220);
const Curve zombieLaneShiftCurve = Curves.easeOutCubic;

/// Left edge for card [cardIndex] when preview sits at [insertAt] (null = no preview).
double laneCardLeft(int cardIndex, int? insertAt) {
  var left = 0.0;
  for (var j = 0; j < cardIndex; j++) {
    if (insertAt == j) {
      left += zombieLaneCardSize + zombieLaneSpacing;
    }
    left += zombieLaneCardSize + zombieLaneSpacing;
  }
  if (insertAt == cardIndex) {
    left += zombieLaneCardSize + zombieLaneSpacing;
  }
  return left;
}

/// Left edge for the preview ghost at [insertAt].
double lanePreviewLeft(int insertAt) {
  var left = 0.0;
  for (var j = 0; j < insertAt; j++) {
    left += zombieLaneCardSize + zombieLaneSpacing;
  }
  return left;
}

/// Total lane width for [visibleCount] cards and optional preview at [insertAt].
double laneContentWidth(int visibleCount, int? insertAt) {
  if (visibleCount == 0) {
    return insertAt != null ? zombieLaneCardSize : 0;
  }
  final slots = visibleCount + (insertAt != null ? 1 : 0);
  return slots * zombieLaneCardSize + (slots - 1) * zombieLaneSpacing;
}

/// Maps a local X coordinate in a lane to an insert index (0..visibleCount).
/// [previewAt] must match the inline preview position in the row layout.
int insertIndexForLaneX(
  double localX,
  int visibleCount, {
  int? previewAt,
}) {
  if (visibleCount <= 0) return 0;

  var x = 0.0;
  for (var i = 0; i < visibleCount; i++) {
    if (i > 0) x += zombieLaneSpacing;

    if (previewAt == i) {
      if (localX < x + zombieLaneCardSize) return i;
      x += zombieLaneCardSize;
    }

    if (localX < x + zombieLaneCardSize / 2) return i;
    if (localX < x + zombieLaneCardSize) return i + 1;
    x += zombieLaneCardSize;
  }

  if (previewAt == visibleCount) {
    if (visibleCount > 0) x += zombieLaneSpacing;
    if (localX < x + zombieLaneCardSize) return visibleCount;
  }

  return visibleCount;
}

const double zombieLaneWrapRunSpacing = 8;

/// Horizontal padding inside [ZombieHorizontalLaneRow] lane container (2 + 2).
const double zombieLaneHorizontalPadding = 4;

/// Pointer must move this far past a slot boundary before the insert index changes.
const double zombieLaneInsertHysteresis = 16;

double effectiveWrapContentWidth(double laneOuterWidth) =>
    math.max(0, laneOuterWidth - zombieLaneHorizontalPadding);

/// Lays out [slotCount] square slots in a wrapped row and returns each slot rect.
List<Rect> wrapLaneSlotRects(double maxWidth, int slotCount) {
  if (slotCount <= 0 || maxWidth <= 0) return const [];

  final rects = <Rect>[];
  var x = 0.0;
  var y = 0.0;
  var runWidth = 0.0;

  for (var i = 0; i < slotCount; i++) {
    if (runWidth > 0 &&
        runWidth + zombieLaneSpacing + zombieLaneCardSize > maxWidth) {
      x = 0;
      y += zombieLaneCardSize + zombieLaneWrapRunSpacing;
      runWidth = 0;
    }
    rects.add(Rect.fromLTWH(x, y, zombieLaneCardSize, zombieLaneCardSize));
    if (runWidth == 0) {
      runWidth = zombieLaneCardSize;
      x += zombieLaneCardSize + zombieLaneSpacing;
    } else {
      runWidth += zombieLaneSpacing + zombieLaneCardSize;
      x += zombieLaneCardSize + zombieLaneSpacing;
    }
  }
  return rects;
}

/// Layout rect for visible card [cardIndex] when preview sits at [insertAt].
Rect wrapCardRect(
  int cardIndex,
  int? insertAt,
  double maxWidth,
  int cardCount,
) {
  if (cardCount <= 0 || maxWidth <= 0) {
    return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
  }
  final slotIndex =
      insertAt == null ? cardIndex : (cardIndex < insertAt ? cardIndex : cardIndex + 1);
  final slotCount = insertAt == null ? cardCount : cardCount + 1;
  return wrapLaneSlotRects(maxWidth, slotCount)[slotIndex];
}

/// Layout rect for the drag preview ghost at [insertAt].
Rect wrapPreviewRect(int insertAt, double maxWidth, int cardCount) {
  if (maxWidth <= 0) {
    return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
  }
  if (cardCount <= 0) {
    return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
  }
  return wrapLaneSlotRects(maxWidth, cardCount + 1)[insertAt];
}

/// Total lane height for [cardCount] cards plus optional preview / add slots.
double wrapLaneLayoutHeight(
  double maxWidth,
  int cardCount, {
  int? insertAt,
  bool includeAddButton = false,
}) {
  final slotCount =
      cardCount + (insertAt != null ? 1 : 0) + (includeAddButton ? 1 : 0);
  return wrapLaneHeight(maxWidth, math.max(slotCount, 1));
}

/// Where the preview ghost would appear if inserted at [insertIndex].
Rect previewRectForInsertIndex(
  double maxWidth,
  int cardCount,
  int insertIndex,
) {
  if (maxWidth <= 0) {
    return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
  }
  if (cardCount <= 0) {
    return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
  }

  var x = 0.0;
  var y = 0.0;
  var runWidth = 0.0;

  void startNewRun() {
    x = 0;
    y += zombieLaneCardSize + zombieLaneWrapRunSpacing;
    runWidth = 0;
  }

  void advanceAfterSlot() {
    if (runWidth == 0) {
      runWidth = zombieLaneCardSize;
      x += zombieLaneCardSize + zombieLaneSpacing;
    } else {
      runWidth += zombieLaneSpacing + zombieLaneCardSize;
      x += zombieLaneCardSize + zombieLaneSpacing;
    }
  }

  bool needsNewRun() =>
      runWidth > 0 &&
      runWidth + zombieLaneSpacing + zombieLaneCardSize > maxWidth;

  for (var i = 0; i < cardCount; i++) {
    if (i == insertIndex) {
      if (needsNewRun()) startNewRun();
      return Rect.fromLTWH(x, y, zombieLaneCardSize, zombieLaneCardSize);
    }
    if (needsNewRun()) startNewRun();
    advanceAfterSlot();
  }

  if (insertIndex == cardCount) {
    if (needsNewRun()) startNewRun();
    return Rect.fromLTWH(x, y, zombieLaneCardSize, zombieLaneCardSize);
  }

  return Rect.fromLTWH(0, 0, zombieLaneCardSize, zombieLaneCardSize);
}

/// Height of a wrapped lane with [slotCount] square slots.
double wrapLaneHeight(double maxWidth, int slotCount) {
  final rects = wrapLaneSlotRects(maxWidth, math.max(slotCount, 1));
  if (rects.isEmpty) return zombieLaneCardSize;
  return rects.last.bottom;
}

class _WrapDisplayRow {
  const _WrapDisplayRow({required this.top, required this.cardIndices});

  final double top;
  final List<int> cardIndices;
}

List<_WrapDisplayRow> _groupCardsByDisplayRow(List<Rect> cardRects) {
  if (cardRects.isEmpty) return const [];

  final rows = <_WrapDisplayRow>[];
  var currentTop = cardRects[0].top;
  var indices = <int>[0];

  for (var i = 1; i < cardRects.length; i++) {
    if ((cardRects[i].top - currentTop).abs() < 0.5) {
      indices.add(i);
    } else {
      rows.add(_WrapDisplayRow(top: currentTop, cardIndices: indices));
      currentTop = cardRects[i].top;
      indices = [i];
    }
  }
  rows.add(_WrapDisplayRow(top: currentTop, cardIndices: indices));
  return rows;
}

double _distanceToDisplayRowBand(double localY, _WrapDisplayRow row) {
  final top = row.top;
  final bottom = top + zombieLaneCardSize;
  if (localY < top) return top - localY;
  if (localY > bottom) return localY - bottom;
  return 0;
}

int _pickDisplayRowIndex(List<_WrapDisplayRow> rows, double localY) {
  if (rows.isEmpty) return 0;
  if (rows.length == 1) return 0;

  var best = 0;
  var bestDist = double.infinity;
  for (var r = 0; r < rows.length; r++) {
    final dist = _distanceToDisplayRowBand(localY, rows[r]);
    if (dist < bestDist) {
      bestDist = dist;
      best = r;
    }
  }
  return best;
}

int _horizontalInsertOnDisplayRow(
  _WrapDisplayRow row,
  List<Rect> cardRects,
  double localX,
) {
  final indices = row.cardIndices;
  if (indices.isEmpty) return 0;

  final firstRect = cardRects[indices.first];
  if (localX < firstRect.left + zombieLaneCardSize / 2) {
    return indices.first;
  }

  for (var i = 0; i < indices.length - 1; i++) {
    final leftRect = cardRects[indices[i]];
    final rightRect = cardRects[indices[i + 1]];
    final boundary = (leftRect.right + rightRect.left) / 2;
    if (localX < boundary) {
      return indices[i + 1];
    }
  }

  return indices.last + 1;
}

int _rawInsertIndexForWrappedPoint(
  Offset local,
  double maxWidth,
  int visibleCount, {
  int? layoutInsert,
}) {
  if (visibleCount <= 0) return 0;

  final cardRects = List<Rect>.generate(
    visibleCount,
    (i) => wrapCardRect(i, layoutInsert, maxWidth, visibleCount),
  );
  final displayRows = _groupCardsByDisplayRow(cardRects);
  if (displayRows.isEmpty) return 0;

  final rowIndex = _pickDisplayRowIndex(displayRows, local.dy);
  return _horizontalInsertOnDisplayRow(
    displayRows[rowIndex],
    cardRects,
    local.dx,
  );
}

bool _crossedSchmittBoundary({
  required double pointer,
  required double idealAnchor,
  required double currentAnchor,
  required double margin,
}) {
  final boundary = (idealAnchor + currentAnchor) / 2;
  if (idealAnchor > currentAnchor) {
    return pointer >= boundary + margin / 2;
  }
  if (idealAnchor < currentAnchor) {
    return pointer <= boundary - margin / 2;
  }
  return false;
}

int _applyWrappedInsertHysteresis({
  required int ideal,
  required int current,
  required Offset local,
  required double maxWidth,
  required int visibleCount,
}) {
  if (ideal == current) return ideal;

  final idealPreview = wrapPreviewRect(ideal, maxWidth, visibleCount);
  final currentPreview = wrapPreviewRect(current, maxWidth, visibleCount);
  final margin = zombieLaneInsertHysteresis;
  final onSameDisplayRow = (idealPreview.top - currentPreview.top).abs() < 0.5;

  if (!onSameDisplayRow) {
    final idealRowCenter = idealPreview.top + zombieLaneCardSize / 2;
    final currentRowCenter = currentPreview.top + zombieLaneCardSize / 2;
    if (_crossedSchmittBoundary(
      pointer: local.dy,
      idealAnchor: idealRowCenter,
      currentAnchor: currentRowCenter,
      margin: margin,
    )) {
      return ideal;
    }
    return current;
  }

  final idealX = idealPreview.left + zombieLaneCardSize / 2;
  final currentX = currentPreview.left + zombieLaneCardSize / 2;
  if (_crossedSchmittBoundary(
    pointer: local.dx,
    idealAnchor: idealX,
    currentAnchor: currentX,
    margin: margin,
  )) {
    return ideal;
  }
  return current;
}

/// Maps a pointer inside a wrapped lane to an insert index (0..visibleCount).
///
/// Picks the display row (Y) first, then the horizontal slot (X) within it.
int insertIndexForWrappedPoint(
  Offset local,
  double maxWidth,
  int visibleCount, {
  int? currentInsert,
}) {
  if (maxWidth <= 0) return 0;
  if (visibleCount <= 0) return 0;

  final ideal = _rawInsertIndexForWrappedPoint(
    local,
    maxWidth,
    visibleCount,
    layoutInsert: currentInsert,
  );

  if (currentInsert == null) {
    return ideal;
  }

  return _applyWrappedInsertHysteresis(
    ideal: ideal,
    current: currentInsert,
    local: local,
    maxWidth: maxWidth,
    visibleCount: visibleCount,
  );
}
