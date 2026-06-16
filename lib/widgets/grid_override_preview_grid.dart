import 'package:flutter/material.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart' show isDesktopPlatform;

/// Read-only lawn grid preview for grid-override modules.
class GridOverridePreviewGrid extends StatelessWidget {
  const GridOverridePreviewGrid({
    super.key,
    required this.gridRows,
    required this.gridCols,
    required this.cellImageAt,
    this.cellImageScaleAt,
    this.maxWidth,
  });

  final int gridRows;
  final int gridCols;
  final String? Function(int col, int row) cellImageAt;
  final double? Function(int col, int row)? cellImageScaleAt;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedMaxWidth = maxWidth ?? gridOverridePreviewMaxWidth(context);

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
                    final imagePath = cellImageAt(col, row);
                    final scale = cellImageScaleAt?.call(col, row) ?? 1.0;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(0.5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF6B899A),
                            width: 0.5,
                          ),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: imagePath != null
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final w = constraints.maxWidth * scale;
                                  final h = constraints.maxHeight * scale;
                                  return Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      width: w,
                                      height: h,
                                      child: AssetImageWidget(
                                        assetPath: imagePath,
                                        width: w,
                                        height: h,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                },
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
      ),
    );
  }
}

double gridOverridePreviewMaxWidth(BuildContext context) {
  if (isDesktopPlatform(context)) return 480;
  return (MediaQuery.sizeOf(context).width - 48).clamp(260.0, 400.0);
}

/// Drop-ship area previews are shown 30% larger than other grid previews.
double dropShipPreviewMaxWidth(BuildContext context) {
  return gridOverridePreviewMaxWidth(context) * 1.3;
}

/// Renai statue wave previews use the same scale as drop-ship previews.
double renaiStatuePreviewMaxWidth(BuildContext context) {
  return dropShipPreviewMaxWidth(context);
}
