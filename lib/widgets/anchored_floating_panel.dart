import 'package:flutter/material.dart';

enum _VerticalPlacement { below, above }

/// Shows a compact floating panel anchored to [anchorContext]'s widget bounds.
Future<void> showAnchoredFloatingPanel(
  BuildContext context, {
  required BuildContext anchorContext,
  required Widget child,
  double maxWidth = 300,
  double maxHeight = 360,
}) {
  final anchorBox = anchorContext.findRenderObject() as RenderBox?;
  if (anchorBox == null || !anchorBox.hasSize) {
    return Future.value();
  }

  final overlayBox =
      Overlay.of(context, rootOverlay: true).context.findRenderObject()
          as RenderBox?;
  if (overlayBox == null) return Future.value();

  final anchorTopLeft = anchorBox.localToGlobal(
    Offset.zero,
    ancestor: overlayBox,
  );
  final anchorBottomRight = anchorBox.localToGlobal(
    anchorBox.size.bottomRight(Offset.zero),
    ancestor: overlayBox,
  );
  final overlaySize = overlayBox.size;
  const margin = 8.0;
  const gap = 4.0;

  final availableWidth = overlaySize.width - margin * 2;
  final panelWidth = maxWidth.clamp(160.0, availableWidth);

  // Keep the panel adjacent to the invoking button (start-aligned by default).
  var panelLeft = anchorTopLeft.dx;
  if (panelLeft + panelWidth > overlaySize.width - margin) {
    panelLeft = overlaySize.width - panelWidth - margin;
  }
  if (panelLeft < margin) panelLeft = margin;

  final spaceBelow =
      overlaySize.height - anchorBottomRight.dy - gap - margin;
  final spaceAbove = anchorTopLeft.dy - gap - margin;
  final effectiveMaxHeight = maxHeight.clamp(
    80.0,
    overlaySize.height - margin * 2,
  );

  final placement = spaceBelow >= 80 || spaceBelow >= spaceAbove
      ? _VerticalPlacement.below
      : _VerticalPlacement.above;

  late double panelTop;
  if (placement == _VerticalPlacement.below) {
    panelTop = anchorBottomRight.dy + gap;
    final maxTop =
        overlaySize.height - margin - effectiveMaxHeight;
    if (panelTop > maxTop) panelTop = maxTop;
  } else {
    panelTop = anchorTopLeft.dy - gap - effectiveMaxHeight;
    if (panelTop < margin) panelTop = margin;
    // Never overlap the anchor button vertically.
    final maxBottom = anchorTopLeft.dy - gap;
    if (panelTop + effectiveMaxHeight > maxBottom) {
      panelTop = (maxBottom - effectiveMaxHeight).clamp(margin, maxBottom);
    }
  }

  final scaleAlignment = placement == _VerticalPlacement.below
      ? Alignment.topLeft
      : Alignment.bottomLeft;

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final theme = Theme.of(dialogContext);
      return Stack(
        children: [
          Positioned(
            left: panelLeft,
            top: panelTop,
            width: panelWidth,
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                alignment: scaleAlignment,
                child: Material(
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.35),
                  color: theme.colorScheme.surfaceContainerHigh,
                  surfaceTintColor: theme.colorScheme.surfaceTint,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: panelWidth,
                      maxHeight: effectiveMaxHeight,
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
