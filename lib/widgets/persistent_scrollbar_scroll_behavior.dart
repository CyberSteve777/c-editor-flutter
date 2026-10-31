import 'dart:math' as math;

import 'package:flutter/cupertino.dart' show CupertinoScrollbar;
import 'package:flutter/material.dart';

/// Keeps every vertical app scrollbar visible, beside rather than over content.
///
/// Flutter only inserts automatic scrollbars on desktop by default. C-Editor
/// uses the same persistent visual cue on mobile and web so a clipped page does
/// not look as though it ends at the bottom of the viewport. Horizontal
/// controls keep their existing, component-specific scrollbar behavior.
class PersistentScrollbarScrollBehavior extends MaterialScrollBehavior {
  const PersistentScrollbarScrollBehavior();

  ({Widget widget, BuildContext context})? _explicitScrollbar(
    BuildContext context,
  ) {
    ({Widget widget, BuildContext context})? found;
    context.visitAncestorElements((element) {
      final widget = element.widget;

      // An explicit scrollbar outside another Scrollable belongs to that outer
      // scrollable, not to this nested one. Stop there so each independently
      // scrolling vertical region can still receive its own thumb.
      if (widget is Scrollable) return false;

      if (widget is Scrollbar) {
        found = (widget: widget, context: element);
        return false;
      }
      // Material Scrollbar creates a RawScrollbar internally. Prefer its
      // public wrapper above, whose properties are the effective overrides.
      if (widget is RawScrollbar && found == null) {
        found = (widget: widget, context: element);
      }
      return true;
    });
    return found;
  }

  EdgeInsets _scrollbarGutter(BuildContext context, {Widget? scrollbar}) {
    final theme = Theme.of(context);
    var orientation = ScrollbarOrientation.right;
    double thickness;
    double margin;

    if (scrollbar is RawScrollbar) {
      orientation =
          scrollbar.scrollbarOrientation ??
          (Directionality.of(context) == TextDirection.rtl
              ? ScrollbarOrientation.left
              : ScrollbarOrientation.right);
      thickness = scrollbar.thickness ?? 6;
      margin = scrollbar.crossAxisMargin;
      if (scrollbar is CupertinoScrollbar) {
        thickness = math.max(thickness, scrollbar.thicknessWhileDragging);
        margin = 3;
      }
    } else {
      final materialBar = scrollbar is Scrollbar ? scrollbar : null;
      orientation =
          materialBar?.scrollbarOrientation ??
          (materialBar == null ||
                  Directionality.of(context) == TextDirection.ltr
              ? ScrollbarOrientation.right
              : ScrollbarOrientation.left);
      if (theme.platform == TargetPlatform.iOS) {
        thickness =
            materialBar?.thickness ??
            CupertinoScrollbar.defaultThicknessWhileDragging;
        margin = 3;
      } else {
        final scrollbarTheme = ScrollbarTheme.of(context);
        thickness = materialBar?.thickness ?? 12;
        if (materialBar?.thickness == null) {
          // Hovering can widen Material's thumb; reserve the largest state so
          // neither hover nor dragging can move it over the content.
          for (final states in const <Set<WidgetState>>[
            {},
            {WidgetState.hovered},
            {WidgetState.dragged},
            {WidgetState.hovered, WidgetState.dragged},
          ]) {
            thickness = math.max(
              thickness,
              scrollbarTheme.thickness?.resolve(states) ?? 12,
            );
          }
        }
        margin = scrollbarTheme.crossAxisMargin ?? 2;
      }
    }

    final onLeft = orientation == ScrollbarOrientation.left;
    final safePadding = MediaQuery.paddingOf(context);
    final safeInset = onLeft ? safePadding.left : safePadding.right;
    final width = math.max(20.0, thickness + margin * 2 + 4) + safeInset;
    // Keep centered content centered while reserving room for the thumb.
    return EdgeInsets.symmetric(horizontal: width);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) == Axis.horizontal ||
        details.controller == null) {
      return child;
    }

    final explicit = _explicitScrollbar(context);
    if (explicit != null) {
      return Padding(
        padding: _scrollbarGutter(explicit.context, scrollbar: explicit.widget),
        child: child,
      );
    }

    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      scrollbarOrientation: ScrollbarOrientation.right,
      child: Padding(padding: _scrollbarGutter(context), child: child),
    );
  }
}
