import 'package:flutter/material.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/widgets/lawn_grid.dart';

/// Read-only fuse preview shared by the level overview and powder-keg editor.
class ExplosiveBarrelsPreviewGrid extends StatelessWidget {
  const ExplosiveBarrelsPreviewGrid({
    super.key,
    required this.rows,
    required this.cols,
    required this.fuseLengths,
    required this.style,
    this.maxWidth = 650,
    this.selectedX,
    this.selectedY,
    this.onCellTap,
  });

  final int rows;
  final int cols;
  final List<String> fuseLengths;
  final LevelPreviewGridStyle style;
  final double maxWidth;
  final int? selectedX;
  final int? selectedY;
  final void Function(int col, int row)? onCellTap;

  @override
  Widget build(BuildContext context) {
    return LawnGrid(
      rows: rows,
      cols: cols,
      style: style,
      maxWidth: maxWidth,
      selectedX: selectedX,
      selectedY: selectedY,
      onCellTap: onCellTap,
      cellBuilder: (context, col, row) {
        if (row >= fuseLengths.length) return null;
        final fuseLength = num.tryParse(fuseLengths[row])?.toInt() ?? 8;
        if (fuseLength <= 0 || col >= fuseLength) return null;
        return Center(
          child: Container(
            key: ValueKey('explosiveBarrelFuse-$row-$col'),
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA726).withValues(alpha: 0.8),
                  blurRadius: 3,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
