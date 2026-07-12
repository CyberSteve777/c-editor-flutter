import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_drag_item.dart';
import 'package:c_editor/widgets/zombie_lane_drag_scope.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

/// One horizontal zombie row lane with drag preview and row-level drop targeting.
class ZombieHorizontalLaneRow extends StatelessWidget {
  const ZombieHorizontalLaneRow({
    super.key,
    required this.rowValue,
    required this.items,
    required this.highlighted,
    required this.labelSide,
    this.addButton,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
    required this.onPreviewInsert,
    required this.onDrop,
    required this.isDragging,
    required this.draggingIdentity,
    required this.commitRowValue,
    required this.commitInsertIndex,
    required this.previewWidget,
  });

  final int rowValue;
  final List<ZombieLaneIconData> items;
  final bool highlighted;
  final Widget labelSide;
  final Widget? addButton;
  final void Function(int listIndex) onTap;
  final void Function(Object identity) onDragStarted;
  final VoidCallback onDragEnded;
  final void Function(int rowValue, int insertIndex) onPreviewInsert;
  final VoidCallback onDrop;
  final bool isDragging;
  final Object? draggingIdentity;
  final int? commitRowValue;
  final int? commitInsertIndex;
  final Widget? previewWidget;

  List<ZombieLaneIconData> get _visible {
    if (!isDragging || draggingIdentity == null) return items;
    return items
        .where((item) => item.identity != draggingIdentity)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = _visible;
    final dragging = isDragging;
    final showPreview = dragging &&
        commitRowValue == rowValue &&
        commitInsertIndex != null &&
        previewWidget != null;
    final insertAt = showPreview
        ? commitInsertIndex!.clamp(0, visible.length)
        : null;
    final laneWidth = laneContentWidth(visible.length, insertAt);

    final shiftDuration = dragging ? zombieLaneShiftDuration : Duration.zero;
    final idleWidth = laneContentWidth(visible.length, null) +
        (addButton != null
            ? zombieLaneCardSize + (visible.isNotEmpty ? zombieLaneSpacing : 0)
            : 0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelSide,
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: highlighted
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: highlighted
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    )
                  : null,
            ),
            child: SizedBox(
              height: zombieLaneCardSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: dragging
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      child: AnimatedContainer(
                        duration: shiftDuration,
                        curve: zombieLaneShiftCurve,
                        width: dragging ? laneWidth : idleWidth,
                        height: zombieLaneCardSize,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (var i = 0; i < visible.length; i++)
                              AnimatedPositioned(
                                key: ValueKey<(Object, int)>(
                                  (visible[i].identity, visible[i].rowValue),
                                ),
                                duration: shiftDuration,
                                curve: zombieLaneShiftCurve,
                                left: dragging
                                    ? laneCardLeft(i, insertAt)
                                    : laneCardLeft(i, null),
                                top: 0,
                                width: zombieLaneCardSize,
                                height: zombieLaneCardSize,
                                child: ZombieLaneDraggableCard(
                                  item: visible[i],
                                  feedback: buildZombieLaneDragFeedback(visible[i]),
                                  onDragStarted: onDragStarted,
                                  onDragEnded: onDragEnded,
                                  child: buildZombieLaneCard(
                                    item: visible[i],
                                    onTap: () => onTap(visible[i].listIndex),
                                  ),
                                ),
                              ),
                            if (showPreview)
                              AnimatedPositioned(
                                duration: shiftDuration,
                                curve: zombieLaneShiftCurve,
                                left: lanePreviewLeft(insertAt!),
                                top: 0,
                                width: zombieLaneCardSize,
                                height: zombieLaneCardSize,
                                child: ZombieLanePreviewGap(
                                  previewWidget: previewWidget!,
                                ),
                              ),
                            if (!dragging && addButton != null)
                              AnimatedPositioned(
                                duration: Duration.zero,
                                left: laneContentWidth(visible.length, null) +
                                    (visible.isNotEmpty ? zombieLaneSpacing : 0),
                                top: 0,
                                width: zombieLaneCardSize,
                                height: zombieLaneCardSize,
                                child: addButton!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (dragging)
                    Positioned.fill(
                      child: ZombieLaneRowDropZone(
                        rowValue: rowValue,
                        visibleCount: visible.length,
                        onDrop: onDrop,
                        onPreviewInsert: onPreviewInsert,
                        commitRowValue: commitRowValue,
                        commitInsertIndex: commitInsertIndex,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
