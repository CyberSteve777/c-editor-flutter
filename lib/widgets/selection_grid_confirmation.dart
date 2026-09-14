import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Gives confirmation its own row when it would cover items at the grid's end.
class SelectionGridConfirmation extends StatelessWidget {
  const SelectionGridConfirmation({
    super.key,
    required this.child,
    required this.itemCount,
    required this.gridDelegate,
    this.gridPadding = const EdgeInsets.all(12),
    this.confirmation,
  });

  final Widget child;
  final int itemCount;
  final SliverGridDelegate gridDelegate;
  final EdgeInsets gridPadding;
  final Widget? confirmation;

  static const _buttonSize = 56.0;
  static const _margin = 16.0;

  @override
  Widget build(BuildContext context) {
    final button = confirmation;
    if (button == null) return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final safePadding = MediaQuery.paddingOf(context);
        final bottomInset = safePadding.bottom;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final endMargin =
            _margin + (isRtl ? safePadding.left : safePadding.right);
        final buttonRect = Rect.fromLTWH(
          isRtl ? endMargin : size.width - endMargin - _buttonSize,
          size.height - bottomInset - _margin - _buttonSize,
          _buttonSize,
          _buttonSize,
        );
        var needsRow = false;
        if (itemCount > 0 && size.isFinite) {
          // Use the same sliver geometry as the grid, including its RTL layout.
          final layout = gridDelegate.getLayout(
            SliverConstraints(
              axisDirection: AxisDirection.down,
              growthDirection: GrowthDirection.forward,
              userScrollDirection: ScrollDirection.idle,
              scrollOffset: 0,
              precedingScrollExtent: 0,
              overlap: 0,
              remainingPaintExtent: size.height,
              crossAxisExtent: math.max(0, size.width - gridPadding.horizontal),
              crossAxisDirection: isRtl
                  ? AxisDirection.left
                  : AxisDirection.right,
              viewportMainAxisExtent: size.height,
              remainingCacheExtent: size.height,
              cacheOrigin: 0,
            ),
          );
          final contentHeight =
              layout.computeMaxScrollOffset(itemCount) + gridPadding.vertical;
          final endOffset = math.max(0, contentHeight - size.height);
          // Safe areas can move the button over an earlier column or row, so
          // inspect every trailing item within its vertical range.
          for (var index = itemCount - 1; index >= 0; index--) {
            final item = layout.getGeometryForChildIndex(index);
            final itemRect = Rect.fromLTWH(
              gridPadding.left + item.crossAxisOffset,
              gridPadding.top + item.scrollOffset - endOffset,
              item.crossAxisExtent,
              item.mainAxisExtent,
            );
            if (itemRect.bottom <= buttonRect.top) break;
            if (itemRect.overlaps(buttonRect)) {
              needsRow = true;
              break;
            }
          }
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            // Keep the grid under the same parents when resizing switches the
            // confirmation position, so its scroll state remains attached.
            Column(
              children: [
                Expanded(child: child),
                if (needsRow)
                  SafeArea(
                    key: const ValueKey('selectionConfirmationRow'),
                    top: false,
                    minimum: const EdgeInsets.all(_margin),
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: SizedBox.square(
                        dimension: _buttonSize,
                        child: button,
                      ),
                    ),
                  ),
              ],
            ),
            if (!needsRow)
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: endMargin,
                bottom: _margin + bottomInset,
                child: SizedBox.square(dimension: _buttonSize, child: button),
              ),
          ],
        );
      },
    );
  }
}
