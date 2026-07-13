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

/// Maps a pointer inside a wrapped lane to an insert index (0..visibleCount).
int insertIndexForWrappedPoint(
  Offset local,
  double maxWidth,
  int visibleCount, {
  int? currentInsert,
}) {
  if (maxWidth <= 0) return 0;
  if (visibleCount <= 0) return 0;

  var ideal = 0;
  var idealDist = double.infinity;
  for (var i = 0; i <= visibleCount; i++) {
    final center = previewRectForInsertIndex(maxWidth, visibleCount, i).center;
    final distance = (local - center).distanceSquared;
    if (distance < idealDist) {
      idealDist = distance;
      ideal = i;
    }
  }

  if (currentInsert == null || ideal == currentInsert) {
    return ideal;
  }

  final currentCenter =
      previewRectForInsertIndex(maxWidth, visibleCount, currentInsert).center;
  final currentDist = (local - currentCenter).distanceSquared;
  final switchMargin = zombieLaneInsertHysteresis * zombieLaneInsertHysteresis;

  if (idealDist + switchMargin < currentDist) {
    return ideal;
  }
  return currentInsert;
}

/// Height of a wrapped lane with [slotCount] square slots.
double wrapLaneHeight(double maxWidth, int slotCount) {
  final rects = wrapLaneSlotRects(maxWidth, math.max(slotCount, 1));
  if (rects.isEmpty) return zombieLaneCardSize;
  return rects.last.bottom;
}
