import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_drag_scope.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

/// Draggable zombie card — callbacks are captured directly (not via [BuildContext])
/// because [childWhenDragging] unmounts the child context on drag end.
class ZombieLaneDraggableCard extends StatelessWidget {
  const ZombieLaneDraggableCard({
    super.key,
    required this.item,
    required this.feedback,
    required this.child,
    required this.onDragStarted,
    required this.onDragEnded,
  });

  final ZombieLaneIconData item;
  final Widget feedback;
  final Widget child;
  final void Function(Object identity) onDragStarted;
  final VoidCallback onDragEnded;

  @override
  Widget build(BuildContext context) {
    var ended = false;
    void endDrag() {
      if (ended) return;
      ended = true;
      onDragEnded();
    }

    return SizedBox(
      width: zombieLaneCardSize,
      height: zombieLaneCardSize,
      child: LongPressDraggable<Object>(
        data: item.identity,
        delay: zombieDragLongPressDelay,
        maxSimultaneousDrags: 1,
        rootOverlay: true,
        hapticFeedbackOnStart: true,
        feedback: SizedBox(
          width: zombieLaneCardSize,
          height: zombieLaneCardSize,
          child: Material(
            color: Colors.transparent,
            elevation: 8,
            shadowColor: Colors.black45,
            child: feedback,
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () => onDragStarted(item.identity),
        onDragCompleted: endDrag,
        onDragEnd: (_) => endDrag(),
        onDraggableCanceled: (_, _) => endDrag(),
        child: child,
      ),
    );
  }
}

/// Full-row drop zone — pointer X picks insert slot.
class ZombieLaneRowDropZone extends StatelessWidget {
  const ZombieLaneRowDropZone({
    super.key,
    required this.onDrop,
    required this.onPointerMove,
    this.onDragEntered,
  });

  final VoidCallback onDrop;
  final void Function(double localX, double localY, double viewportWidth)
      onPointerMove;
  final VoidCallback? onDragEntered;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAcceptWithDetails: (_) {
        onDragEntered?.call();
        return true;
      },
      onMove: (details) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final local = box.globalToLocal(details.offset);
        onPointerMove(local.dx, local.dy, box.size.width);
      },
      onLeave: (_) {},
      onAcceptWithDetails: (_) => onDrop(),
      builder: (context, candidate, rejected) {
        return const SizedBox.expand();
      },
    );
  }
}

/// Fixed-size preview slot matching a zombie card.
class ZombieLanePreviewGap extends StatelessWidget {
  const ZombieLanePreviewGap({
    super.key,
    required this.previewWidget,
  });

  final Widget previewWidget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: zombieLaneCardSize,
      height: zombieLaneCardSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: 0.55,
            child: previewWidget,
          ),
        ),
      ),
    );
  }
}

const Widget zombieLaneSpacingBox = SizedBox(
  width: zombieLaneSpacing,
  height: zombieLaneCardSize,
);
