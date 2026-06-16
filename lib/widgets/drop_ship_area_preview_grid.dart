import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';
/// Read-only lawn grid highlighting a drop-ship rectangular area.
class DropShipAreaPreviewGrid extends StatelessWidget {
  const DropShipAreaPreviewGrid({
    super.key,
    required this.gridRows,
    required this.gridCols,
    required this.rowRange,
    required this.colRange,
    this.maxWidth,
  });

  final int gridRows;
  final int gridCols;
  final MinMaxRange rowRange;
  final MinMaxRange colRange;
  final double? maxWidth;

  bool _isInRange(int col, int row) {
    return col >= colRange.min &&
        col <= colRange.max &&
        row >= rowRange.min &&
        row <= rowRange.max;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedMaxWidth = maxWidth ?? dropShipPreviewMaxWidth(context);
    final highlight = Colors.orange.withValues(alpha: 0.55);
    final empty = theme.colorScheme.surfaceContainerHighest;

    return SizedBox(
      width: resolvedMaxWidth,
      child: AspectRatio(
        aspectRatio: gridCols / gridRows,
        child: Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF31383B)
                : const Color(0xFFD7ECF1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF6B899A)),
          ),
          child: Column(
            children: List.generate(gridRows, (row) {
              return Expanded(
                child: Row(
                  children: List.generate(gridCols, (col) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          color: _isInRange(col, row) ? highlight : empty,
                          border: Border.all(
                            color: const Color(0xFF6B899A),
                            width: 0.5,
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
    );  }
}
