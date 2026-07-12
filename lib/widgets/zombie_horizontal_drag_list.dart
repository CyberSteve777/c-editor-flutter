import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_drag_item.dart';
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
    final isCommitRow =
        dragging && commitRowValue == rowValue && commitInsertIndex != null;
    final insertAt = isCommitRow
        ? commitInsertIndex!.clamp(0, visible.length)
        : null;

    final laneChildren = <Widget>[];

    for (var i = 0; i < visible.length; i++) {
      if (i > 0) {
        laneChildren.add(zombieLaneSpacingBox);
      }
      if (dragging && insertAt == i && previewWidget != null) {
        laneChildren.add(ZombieLanePreviewGap(previewWidget: previewWidget!));
        laneChildren.add(zombieLaneSpacingBox);
      }
      laneChildren.add(
        ZombieLaneDraggableCard(
          key: ValueKey<(Object, int)>((visible[i].identity, visible[i].rowValue)),
          item: visible[i],
          feedback: buildZombieLaneDragFeedback(visible[i]),
          onDragStarted: onDragStarted,
          onDragEnded: onDragEnded,
          child: buildZombieLaneCard(
            item: visible[i],
            onTap: () => onTap(visible[i].listIndex),
          ),
        ),
      );
    }

    if (dragging) {
      if (visible.isNotEmpty) {
        laneChildren.add(zombieLaneSpacingBox);
      }
      if (insertAt == visible.length && previewWidget != null) {
        laneChildren.add(ZombieLanePreviewGap(previewWidget: previewWidget!));
      }
    } else if (addButton != null) {
      if (visible.isNotEmpty) {
        laneChildren.add(zombieLaneSpacingBox);
      }
      laneChildren.add(addButton!);
    } else if (visible.isEmpty && dragging && previewWidget != null) {
      laneChildren.add(ZombieLanePreviewGap(previewWidget: previewWidget!));
    }

    final laneContent = AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: laneChildren,
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelSide,
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
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
                      child: laneContent,
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
