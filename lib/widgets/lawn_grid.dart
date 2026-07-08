import 'package:flutter/material.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';

class LawnGrid extends StatelessWidget {
  const LawnGrid({
    super.key,
    required this.rows,
    required this.cols,
    required this.style,
    this.cellBuilder,
    this.onCellTap,
    this.background,
    this.foreground,
    this.maxWidth = 650,
    this.selectedX,
    this.selectedY,
    this.cellDecorationBuilder,
    this.foregroundDecorationBuilder,
  });

  final int rows;
  final int cols;
  final LevelPreviewGridStyle style;
  final Widget? Function(BuildContext context, int col, int row)? cellBuilder;
  final void Function(int col, int row)? onCellTap;
  final Widget? background;
  final Widget? foreground;
  final double maxWidth;
  final int? selectedX;
  final int? selectedY;
  final BoxDecoration? Function(int col, int row, bool isSelected, bool isStripe)?
      cellDecorationBuilder;
  final BoxDecoration? Function(
    int col,
    int row,
    bool isSelected,
  )? foregroundDecorationBuilder;

  @override
  Widget build(BuildContext context) {
    final selectionColor =
        style.selectionColor ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: (cols / rows) * style.cellAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: style.gridBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: style.borderColor, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                if (background != null) Positioned.fill(child: background!),
                ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(scrollbars: false),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      childAspectRatio: style.cellAspectRatio,
                    ),
                    itemCount: rows * cols,
                    itemBuilder: (context, i) {
                      final col = i % cols;
                      final row = i ~/ cols;
                      final isSelected = selectedX == col && selectedY == row;

                      final decoration = cellDecorationBuilder?.call(
                            col,
                            row,
                            isSelected,
                            false,
                          ) ??
                          BoxDecoration(
                            color: isSelected
                                ? selectionColor.withValues(alpha: 0.25)
                                : Colors.transparent,
                          );

                      final foregroundDecoration =
                          foregroundDecorationBuilder?.call(
                            col,
                            row,
                            isSelected,
                          ) ??
                          BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? selectionColor
                                  : style.cellBorderColor,
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          );

                      return GestureDetector(
                        onTap:
                            onCellTap != null ? () => onCellTap!(col, row) : null,
                        child: Container(
                          decoration: decoration,
                          foregroundDecoration: foregroundDecoration,
                          child: cellBuilder?.call(context, col, row),
                        ),
                      );
                    },
                  ),
                ),
                if (foreground != null)
                  Positioned.fill(
                    child: IgnorePointer(child: foreground!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}