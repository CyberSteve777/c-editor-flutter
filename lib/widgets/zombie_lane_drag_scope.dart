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
