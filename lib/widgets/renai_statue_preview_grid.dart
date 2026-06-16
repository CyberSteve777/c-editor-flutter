import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';

/// Read-only lawn grid preview for Renai statue placements.
/// Matches the grid layout used in [RenaiModuleScreen].
class RenaiStatuePreviewGrid extends StatelessWidget {
  const RenaiStatuePreviewGrid({
    super.key,
    required this.levelFile,
    required this.statues,
    this.maxWidth,
    this.shrinkOnDesktop = true,
  });

  final PvzLevelFile levelFile;
  final List<RenaiStatueInfoData> statues;
  final double? maxWidth;

  /// When true (module editor), applies [scaleTableForDesktop]. Wave previews
  /// should pass false so the grid stays full size in dialogs.
  final bool shrinkOnDesktop;

  List<RenaiStatueInfoData> _statuesAt(int col, int row) {
    return statues.where((s) => s.gridX == col && s.gridY == row).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);
    final resolvedMaxWidth = maxWidth ??
        (shrinkOnDesktop
            ? EditorItemCardLayout.gridPreviewMaxWidth(context)
            : renaiStatuePreviewMaxWidth(context));

    final grid = AspectRatio(
      aspectRatio: cols / rows,
      child: Container(
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF31383B)
              : const Color(0xFFD7ECF1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF6B899A)),
        ),
        child: Column(
          children: List.generate(rows, (row) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (col) {
                  final cellItems = _statuesAt(col, row);
                  final firstItem = cellItems.firstOrNull;
                  final count = cellItems.length;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(0.5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF6B899A),
                          width: 0.5,
                        ),
                      ),
                      child: count > 0 && firstItem != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: RenaiStatueIcon(
                                        typeName: firstItem.typeName,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                                if (count > 1)
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(6),
                                        ),
                                      ),
                                      child: Text(
                                        '+${count - 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : null,
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );

    if (shrinkOnDesktop) {
      return scaleTableForDesktop(
        context: context,
        child: Container(
          constraints: BoxConstraints(maxWidth: resolvedMaxWidth),
          child: grid,
        ),
      );
    }

    return SizedBox(width: resolvedMaxWidth, child: grid);
  }
}
