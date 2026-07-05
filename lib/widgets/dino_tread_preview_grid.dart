import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Lawn grid preview for dino stomp: union of all 3×3 footprints for valid centers.
class DinoTreadPreviewGrid extends StatelessWidget {
  const DinoTreadPreviewGrid({
    super.key,
    required this.gridRows,
    required this.gridCols,
    required this.gridY,
    required this.gridXMin,
    required this.gridXMax,
    this.maxWidthFactor = 0.7,
  });

  final int gridRows;
  final int gridCols;
  final int gridY;
  final int gridXMin;
  final int gridXMax;
  final double maxWidthFactor;

  static const _stompRadius = 1;

  static Color _lawnColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
  }

  static ({Color fill, Color border}) _stompAreaColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return (
        fill: const Color(0xFF6D4C14).withValues(alpha: 0.9),
        border: const Color(0xFFFF9800),
      );
    }
    return (
      fill: const Color(0xFFFFE0B2).withValues(alpha: 0.95),
      border: const Color(0xFFE65100),
    );
  }

  static Set<int> _stompCellIndices({
    required int gridRows,
    required int gridCols,
    required int gridY,
    required int gridXMin,
    required int gridXMax,
  }) {
    final minCol = gridXMin < gridXMax ? gridXMin : gridXMax;
    final maxCol = gridXMin > gridXMax ? gridXMin : gridXMax;
    final centerRow = gridY.clamp(0, gridRows - 1);
    final indices = <int>{};

    for (var centerCol = minCol; centerCol <= maxCol; centerCol++) {
      final col = centerCol.clamp(0, gridCols - 1);
      for (var dr = -_stompRadius; dr <= _stompRadius; dr++) {
        for (var dc = -_stompRadius; dc <= _stompRadius; dc++) {
          final row = centerRow + dr;
          final column = col + dc;
          if (row < 0 ||
              row >= gridRows ||
              column < 0 ||
              column >= gridCols) {
            continue;
          }
          indices.add(row * gridCols + column);
        }
      }
    }

    return indices;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lawnColor = _lawnColor(theme);
    final stompColors = _stompAreaColors(theme);
    final stompCells = _stompCellIndices(
      gridRows: gridRows,
      gridCols: gridCols,
      gridY: gridY,
      gridXMin: gridXMin,
      gridXMax: gridXMax,
    );

    return scaleTableForDesktop(
      context: context,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth:
              EditorItemCardLayout.gridPreviewMaxWidth(context) * maxWidthFactor,
        ),
        child: AspectRatio(
          aspectRatio: gridCols / gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: lawnColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: List.generate(gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(gridCols, (col) {
                      final inStompArea = stompCells.contains(
                        row * gridCols + col,
                      );
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: inStompArea ? stompColors.fill : null,
                            border: Border.all(
                              color: inStompArea
                                  ? stompColors.border
                                  : theme.dividerColor,
                              width: inStompArea ? 1.25 : 0.5,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
