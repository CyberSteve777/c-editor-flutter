import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

enum _DinoRunRowRole { normal, adjacent, center }

/// Lawn grid preview for dino stampede: center row (red) and adjacent rows (yellow).
class DinoRunPreviewGrid extends StatelessWidget {
  const DinoRunPreviewGrid({
    super.key,
    required this.gridRows,
    required this.gridCols,
    required this.dinoRow,
    this.maxWidthFactor = 0.7,
  });

  final int gridRows;
  final int gridCols;
  final int dinoRow;
  final double maxWidthFactor;

  static Color _lawnColor(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
  }

  static ({Color fill, Color border}) _centerRowColors(ThemeData theme) {
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

  static ({Color fill, Color border}) _adjacentRowColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    if (isDark) {
      return (
        fill: const Color(0xFF5C4A14).withValues(alpha: 0.9),
        border: const Color(0xFFFFCA28),
      );
    }
    return (
      fill: const Color(0xFFFFF59D).withValues(alpha: 0.95),
      border: const Color(0xFFF9A825),
    );
  }

  _DinoRunRowRole _rowRole(int row) {
    final center = dinoRow.clamp(0, gridRows - 1);
    if (row == center) return _DinoRunRowRole.center;
    if (row == center - 1 || row == center + 1) {
      return _DinoRunRowRole.adjacent;
    }
    return _DinoRunRowRole.normal;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lawnColor = _lawnColor(theme);
    final centerColors = _centerRowColors(theme);
    final adjacentColors = _adjacentRowColors(theme);

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
                final role = _rowRole(row);
                final ({Color fill, Color border})? accent = switch (role) {
                  _DinoRunRowRole.center => centerColors,
                  _DinoRunRowRole.adjacent => adjacentColors,
                  _DinoRunRowRole.normal => null,
                };

                return Expanded(
                  child: Row(
                    children: List.generate(gridCols, (col) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: accent?.fill,
                            border: Border.all(
                              color: accent?.border ?? theme.dividerColor,
                              width: accent != null ? 1.25 : 0.5,
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
