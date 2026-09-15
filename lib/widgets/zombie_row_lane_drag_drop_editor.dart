import 'package:flutter/material.dart';

import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_horizontal_drag_list.dart';
import 'package:c_editor/widgets/zombie_lane_drag_widgets.dart';
import 'package:c_editor/widgets/zombie_lane_editor_common.dart';

export 'package:c_editor/widgets/zombie_lane_drag_widgets.dart' show ZombieLaneIconData;

/// Row lane editor with horizontal drag-reorder and row-level drop targeting.
class ZombieRowLaneDragDropEditor extends StatefulWidget {
  const ZombieRowLaneDragDropEditor({
    super.key,
    required this.maxRow,
    required this.items,
    required this.rowLabel,
    required this.randomRowLabel,
    required this.onTap,
    this.onDelete,
    required this.onMove,
    required this.onAddToRow,
    this.onDraggingChanged,
  });

  final int maxRow;
  final List<ZombieLaneIconData> items;
  final String Function(int row) rowLabel;
  final String randomRowLabel;
  final void Function(int index) onTap;
  final void Function(int index)? onDelete;

  /// [rowInsertIndex] is 0-based within the target row (visible slots while dragging).
  final void Function(int fromIndex, int toRow, int rowInsertIndex) onMove;
  final void Function(int row) onAddToRow;
  final ValueChanged<bool>? onDraggingChanged;

  @override
  State<ZombieRowLaneDragDropEditor> createState() =>
      _ZombieRowLaneDragDropEditorState();
}

class _ZombieRowLaneDragDropEditorState extends State<ZombieRowLaneDragDropEditor> {
  bool _dragging = false;
  bool _endingDrag = false;
  Object? _draggingIdentity;
  int? _commitRow;
  int? _commitInsertIndex;
  Widget? _previewWidget;

  List<int> get _rows => [for (var r = 1; r <= widget.maxRow; r++) r, 0];

  List<ZombieLaneIconData> _itemsForRow(int rowValue) {
    return widget.items
        .where((item) => item.rowValue == rowValue)
        .toList(growable: false);
  }

  ZombieLaneIconData? _itemByIdentity(Object identity) {
    for (final item in widget.items) {
      if (item.identity == identity) return item;
    }
    return null;
  }

  int _visibleInsertIndexForIdentity(int rowValue, Object identity) {
    var insert = 0;
    for (final item in _itemsForRow(rowValue)) {
      if (item.identity == identity) return insert;
      insert++;
    }
    return insert;
  }

  Widget _rowLabelSide(int rowValue) {
    final theme = Theme.of(context);
    final laneColor = rowValue == 0
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary;
    final label = rowValue == 0
        ? widget.randomRowLabel
        : widget.rowLabel(rowValue);

    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 4),
      child: SizedBox(
        width: 72,
        child: Column(
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
              '${_itemsForRow(rowValue).length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setPreviewInsert(int rowValue, int insertIndex) {
    if (!_dragging || _endingDrag) return;
    if (_commitRow == rowValue && _commitInsertIndex == insertIndex) return;

    setState(() {
      _commitRow = rowValue;
      _commitInsertIndex = insertIndex;
    });
  }

  void _onDragStarted(Object identity) {
    final source = _itemByIdentity(identity);
    if (source == null) return;

    setState(() {
      _endingDrag = false;
      _dragging = true;
      _draggingIdentity = identity;
      _commitRow = source.rowValue;
      _commitInsertIndex =
          _visibleInsertIndexForIdentity(source.rowValue, identity);
      _previewWidget = buildZombieLaneDragFeedback(source);
    });
    widget.onDraggingChanged?.call(true);
  }

  void _applyMove(int? commitRow, int? commitInsert, Object? identity) {
    if (commitRow == null || commitInsert == null || identity == null) return;

    final source = _itemByIdentity(identity);
    if (source == null) return;

    final sameRow = source.rowValue == commitRow;
    final sameSlot = commitInsert ==
        _visibleInsertIndexForIdentity(commitRow, identity);
    if (sameRow && sameSlot) return;

    widget.onMove(source.listIndex, commitRow, commitInsert);
  }

  void _onDragEnded() {
    if (!_dragging || _endingDrag) return;
    _endingDrag = true;

    final commitRow = _commitRow;
    final commitInsert = _commitInsertIndex;
    final identity = _draggingIdentity;

    setState(() {
      _dragging = false;
      _draggingIdentity = null;
      _commitRow = null;
      _commitInsertIndex = null;
      _previewWidget = null;
    });
    widget.onDraggingChanged?.call(false);

    _applyMove(commitRow, commitInsert, identity);

    _endingDrag = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final rowValue in _rows) ...[
              ZombieHorizontalLaneRow(
                key: ValueKey('zombie_lane_row_$rowValue'),
                rowValue: rowValue,
                items: _itemsForRow(rowValue),
                highlighted: _dragging && _commitRow == rowValue,
                labelSide: _rowLabelSide(rowValue),
                addButton: _dragging
                    ? null
                    : PvzAddButton(
                        onPressed: () => widget.onAddToRow(rowValue),
                        useSecondaryColor: rowValue == 0,
                        size: zombieLaneCardSize,
                      ),
                onTap: widget.onTap,
                onDragStarted: _onDragStarted,
                onDragEnded: _onDragEnded,
                onPreviewInsert: _setPreviewInsert,
                onDrop: _onDragEnded,
                isDragging: _dragging,
                draggingIdentity: _draggingIdentity,
                commitRowValue: _commitRow,
                commitInsertIndex: _commitInsertIndex,
                previewWidget: _previewWidget,
              ),
              if (rowValue != _rows.last) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
