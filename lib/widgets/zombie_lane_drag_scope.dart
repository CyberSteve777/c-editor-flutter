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

/// Fraction of the half-gap past a virtual border before the insert index changes.
const double zombieLaneBorderCrossFraction = 0.5;

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

List<Rect> _stableCardRects(double maxWidth, int visibleCount) {
  return List<Rect>.generate(
    visibleCount,
    (i) => wrapCardRect(i, null, maxWidth, visibleCount),
  );
}

List<Rect> _stableInsertSlotRects(double maxWidth, int visibleCount) {
  return List<Rect>.generate(
    visibleCount + 1,
    (i) => wrapPreviewRect(i, maxWidth, visibleCount),
  );
}

/// Virtual border between insert slots [leftIndex] and [leftIndex + 1] (gap midpoint).
double _horizontalGapBorder(int leftIndex, List<Rect> slotRects) {
  return (slotRects[leftIndex].right + slotRects[leftIndex + 1].left) / 2;
}

/// Virtual border between display rows [upperRow] and [upperRow + 1] (gap midpoint).
double _verticalGapBorder(
  int upperRow,
  List<_WrapDisplayRow> rows,
  List<Rect> cardRects,
) {
  final upperLast = cardRects[rows[upperRow].cardIndices.last].bottom;
  final lowerFirst = cardRects[rows[upperRow + 1].cardIndices.first].top;
  return (upperLast + lowerFirst) / 2;
}

int _displayRowForInsertIndex(
  int insertIndex,
  List<_WrapDisplayRow> rows,
  List<Rect> slotRects,
) {
  final slotTop = slotRects[insertIndex].top;
  for (var r = 0; r < rows.length; r++) {
    if ((slotTop - rows[r].top).abs() < 0.5) return r;
  }
  return 0;
}

bool _insertIndexOnDisplayRow(
  int insertIndex,
  _WrapDisplayRow row,
  List<Rect> slotRects,
) {
  final slotTop = slotRects[insertIndex].top;
  return (slotTop - row.top).abs() < 0.5;
}

int _idealDisplayRowIndex(
  double localY,
  List<_WrapDisplayRow> rows,
  List<Rect> cardRects,
) {
  if (rows.length <= 1) return 0;

  for (var r = 0; r < rows.length - 1; r++) {
    if (localY < _verticalGapBorder(r, rows, cardRects)) return r;
  }
  return rows.length - 1;
}

int _stickyDisplayRowIndex(
  double localY,
  int currentInsert,
  List<_WrapDisplayRow> rows,
  List<Rect> cardRects,
  List<Rect> slotRects,
) {
  if (rows.length <= 1) return 0;

  var row = _displayRowForInsertIndex(currentInsert, rows, slotRects);
  final fraction = zombieLaneBorderCrossFraction;

  while (row < rows.length - 1) {
    final border = _verticalGapBorder(row, rows, cardRects);
    final halfGap = border - cardRects[rows[row].cardIndices.last].bottom;
    if (localY - border <= fraction * halfGap) break;
    row++;
  }

  while (row > 0) {
    final border = _verticalGapBorder(row - 1, rows, cardRects);
    final halfGap = border - cardRects[rows[row - 1].cardIndices.last].bottom;
    if (border - localY <= fraction * halfGap) break;
    row--;
  }

  return row;
}

int _idealInsertOnDisplayRow(
  double localX,
  _WrapDisplayRow row,
  List<Rect> slotRects,
) {
  final first = row.cardIndices.first;
  final last = row.cardIndices.last;

  for (var i = first; i <= last; i++) {
    if (localX < _horizontalGapBorder(i, slotRects)) return i;
  }
  return last + 1;
}

int _stickyInsertOnDisplayRow(
  double localX,
  int currentInsert,
  _WrapDisplayRow row,
  List<Rect> slotRects,
) {
  final first = row.cardIndices.first;
  final last = row.cardIndices.last;
  var index = currentInsert.clamp(first, last + 1);
  final fraction = zombieLaneBorderCrossFraction;

  while (index < last + 1) {
    final border = _horizontalGapBorder(index, slotRects);
    final halfGap = border - slotRects[index].right;
    if (localX - border <= fraction * halfGap) break;
    index++;
  }

  while (index > first) {
    final border = _horizontalGapBorder(index - 1, slotRects);
    final halfGap = border - slotRects[index - 1].right;
    if (border - localX <= fraction * halfGap) break;
    index--;
  }

  return index;
}

/// Maps a pointer inside a wrapped lane to an insert index (0..visibleCount).
///
/// Picks the display row (Y) first, then horizontal slot (X). End-of-line empty
/// space on a row inserts after the last card on that display row. Otherwise
/// the preview only moves once the pointer has crossed a gap border between
/// icons by more than [zombieLaneBorderCrossFraction] of the half-gap.
int insertIndexForWrappedPoint(
  Offset local,
  double maxWidth,
  int visibleCount, {
  int? currentInsert,
}) {
  if (maxWidth <= 0) return 0;
  if (visibleCount <= 0) return 0;

  final cardRects = _stableCardRects(maxWidth, visibleCount);
  final slotRects = _stableInsertSlotRects(maxWidth, visibleCount);
  final displayRows = _groupCardsByDisplayRow(cardRects);
  if (displayRows.isEmpty) return 0;

  final rowIndex = currentInsert == null
      ? _idealDisplayRowIndex(local.dy, displayRows, cardRects)
      : _stickyDisplayRowIndex(
          local.dy,
          currentInsert,
          displayRows,
          cardRects,
          slotRects,
        );
  final row = displayRows[rowIndex];
  if (row.cardIndices.isEmpty) return 0;

  final lastCardIndex = row.cardIndices.last;
  final endInsertIndex = lastCardIndex + 1;

  // Trailing empty space on the picked display row.
  if (local.dx >= cardRects[lastCardIndex].right) {
    return endInsertIndex;
  }

  if (currentInsert != null &&
      _insertIndexOnDisplayRow(currentInsert, row, slotRects)) {
    return _stickyInsertOnDisplayRow(local.dx, currentInsert, row, slotRects);
  }

  return _idealInsertOnDisplayRow(local.dx, row, slotRects);
}
