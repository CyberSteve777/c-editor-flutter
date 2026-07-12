import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';

export 'package:c_editor/widgets/zombie_lane_drag_widgets.dart' show ZombieLaneIconData;

/// Single-card row lane editor with layout grid, drag-reorder, and per-row add buttons.
class ZombieRowLaneEditor extends StatefulWidget {
  const ZombieRowLaneEditor({
    super.key,
    required this.maxRow,
    required this.items,
    required this.rowLabel,
    required this.randomRowLabel,
    required this.onTap,
    required this.onDelete,
    required this.onMove,
    required this.onAddToRow,
    this.onDraggingChanged,
  });

  final int maxRow;
  final List<ZombieLaneIconData> items;
  final String Function(int row) rowLabel;
  final String randomRowLabel;
  final void Function(int index) onTap;
  final void Function(int index) onDelete;
  final void Function(int fromIndex, int toRow, int? beforeIndex) onMove;
  final void Function(int row) onAddToRow;
  final ValueChanged<bool>? onDraggingChanged;

  @override
  State<ZombieRowLaneEditor> createState() => _ZombieRowLaneEditorState();
}

class _ZombieRowLaneEditorState extends State<ZombieRowLaneEditor> {
  int? _draggingIndex;
  int? _hoveredRow;

  void _setDragging(int? index) {
    if (_draggingIndex == index) return;
    setState(() {
      _draggingIndex = index;
      if (index == null) _hoveredRow = null;
    });
    widget.onDraggingChanged?.call(index != null);
  }

  void _handleMove(int fromIndex, int toRow, int? beforeIndex) {
    widget.onMove(fromIndex, toRow, beforeIndex);
    _setDragging(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <int>[for (var r = 1; r <= widget.maxRow; r++) r, 0];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutGrid(
          columnSizes: [auto, 1.fr],
          rowSizes: List.generate(rows.length, (_) => auto),
          columnGap: 12,
          rowGap: 12,
          children: [
            for (var i = 0; i < rows.length; i++)
              ..._buildRowCells(context, theme, gridRow: i, rowValue: rows[i]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRowCells(
    BuildContext context,
    ThemeData theme, {
    required int gridRow,
    required int rowValue,
  }) {
    final laneColor = rowValue == 0
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;
    final label = rowValue == 0
        ? widget.randomRowLabel
        : widget.rowLabel(rowValue);
    final rowItems = widget.items
        .where((e) => e.rowValue == rowValue)
        .toList(growable: false);
    final dragging = _draggingIndex != null;

    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: laneColor,
            ),
          ),
          Text(
            '${rowItems.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ).withGridPlacement(rowStart: gridRow, columnStart: 0),
      ZombieLaneDropBackground(
        draggingIndex: _draggingIndex,
        highlighted: _hoveredRow == rowValue,
        onHoverChanged: (hovering) {
          if (!dragging) return;
          setState(() => _hoveredRow = hovering ? rowValue : null);
        },
        onAcceptAppend: (data) => _handleMove(data.listIndex, rowValue, null),
        child: Wrap(
          spacing: dragging ? 0 : 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: buildZombieLaneChildren(
            items: rowItems,
            draggingIndex: _draggingIndex,
            onTap: widget.onTap,
            onDelete: widget.onDelete,
            onMoveToSlot: (from, before) => _handleMove(from, rowValue, before),
            onDragStarted: _setDragging,
            onDragEnded: () => _setDragging(null),
            onAdd: () => widget.onAddToRow(rowValue),
            useSecondaryAddColor: rowValue == 0,
          ),
        ),
      ).withGridPlacement(rowStart: gridRow, columnStart: 1),
    ];
  }
}
