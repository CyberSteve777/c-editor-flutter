import 'package:flutter/material.dart';

import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';

/// Single-card flat zombie list with drag-reorder (no row lanes).
class ZombieFlatLaneEditor extends StatefulWidget {
  const ZombieFlatLaneEditor({
    super.key,
    required this.items,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
    required this.onAdd,
    this.onDraggingChanged,
  });

  final List<ZombieLaneIconData> items;
  final void Function(int index) onTap;
  final void Function(int index) onDelete;
  final void Function(int fromIndex, int? beforeIndex) onMove;
  final VoidCallback onAdd;
  final ValueChanged<bool>? onDraggingChanged;

  @override
  State<ZombieFlatLaneEditor> createState() => _ZombieFlatLaneEditorState();
}

class _ZombieFlatLaneEditorState extends State<ZombieFlatLaneEditor> {
  int? _draggingIndex;

  void _setDragging(int? index) {
    if (_draggingIndex == index) return;
    setState(() => _draggingIndex = index);
    widget.onDraggingChanged?.call(index != null);
  }

  void _handleMove(int fromIndex, int? beforeIndex) {
    widget.onMove(fromIndex, beforeIndex);
    _setDragging(null);
  }

  @override
  Widget build(BuildContext context) {
    final dragging = _draggingIndex != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ZombieLaneDropBackground(
          draggingIndex: _draggingIndex,
          highlighted: false,
          onHoverChanged: (_) {},
          onAcceptAppend: (data) => _handleMove(data.listIndex, null),
          child: Wrap(
            spacing: dragging ? 0 : 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: buildZombieLaneChildren(
              items: widget.items,
              draggingIndex: _draggingIndex,
              onTap: widget.onTap,
              onDelete: widget.onDelete,
              onMoveToSlot: _handleMove,
              onDragStarted: _setDragging,
              onDragEnded: () => _setDragging(null),
              onAdd: widget.onAdd,
            ),
          ),
        ),
      ),
    );
  }
}
