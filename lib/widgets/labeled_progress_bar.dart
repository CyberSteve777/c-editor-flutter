import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Horizontal progress bar with an optional percentage label on the right.
///
/// The bar uses the full available width. The percent label is vertically
/// aligned with the bar and sits at the right edge of the row.
class LabeledProgressBar extends StatelessWidget {
  const LabeledProgressBar({
    super.key,
    required this.value,
    this.minHeight = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.color,
    this.backgroundColor,
    this.labelStyle,
    this.showLabel = true,
  });

  /// `null` shows an indeterminate bar without a percentage label.
  final double? value;
  final double minHeight;
  final BorderRadius borderRadius;
  final Color? color;
  final Color? backgroundColor;
  final TextStyle? labelStyle;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;
    final barBackground =
        backgroundColor ?? barColor.withValues(alpha: 0.18);
    final clamped = value?.clamp(0.0, 1.0);
    final percentLabel = clamped != null
        ? '${(clamped * 100).round()}%'
        : null;
    final textStyle = labelStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: theme.colorScheme.onSurface,
        ) ??
        const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        );
    final fontSize = textStyle.fontSize ?? 13;
    final rowHeight = math.max(20.0, fontSize + 8);
    final barTop = (rowHeight - minHeight) / 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return SizedBox(
          width: width,
          height: rowHeight,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: barTop,
                height: minHeight,
                child: LinearProgressIndicator(
                  value: clamped,
                  minHeight: minHeight,
                  borderRadius: borderRadius,
                  color: barColor,
                  backgroundColor: barBackground,
                ),
              ),
              if (showLabel && percentLabel != null)
                Positioned(
                  right: 0,
                  top: 0,
                  height: rowHeight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      percentLabel,
                      style: textStyle,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
