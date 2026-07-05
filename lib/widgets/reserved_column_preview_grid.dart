import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Lawn grid preview highlighting reserved (planting-disabled) columns on the right.
class ReservedColumnPreviewGrid extends StatelessWidget {
  const ReservedColumnPreviewGrid({
    super.key,
    required this.gridRows,
    required this.gridCols,
    required this.reservedColumnCount,
    this.maxWidthFactor = 0.7,
  });

  final int gridRows;
  final int gridCols;
  final int reservedColumnCount;
  final double maxWidthFactor;

  static ({Color fill, Color border}) _disabledColumnColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return (
        fill: const Color(0xFF5C2A2A).withValues(alpha: 0.88),
        border: const Color(0xFFEF5350),
      );
    }
    return (
      fill: const Color(0xFFFFCDD2).withValues(alpha: 0.92),
      border: const Color(0xFFD32F2F),
    );
  }

  static Color _lawnColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
  }

  bool _isReservedColumn(int col) {
    final reserved = reservedColumnCount.clamp(0, gridCols);
    if (reserved == 0) return false;
    return col >= gridCols - reserved;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lawnColor = _lawnColor(theme);
    final disabledColors = _disabledColumnColors(theme);

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
                      final reserved = _isReservedColumn(col);
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: reserved ? disabledColors.fill : null,
                            border: Border.all(
                              color: reserved
                                  ? disabledColors.border
                                  : theme.dividerColor,
                              width: reserved ? 1.25 : 0.5,
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
