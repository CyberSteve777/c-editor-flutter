import 'package:flutter/material.dart';

/// Horizontal progress bar with an optional percentage label beside the bar.
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
    final barBackground = backgroundColor ?? barColor.withValues(alpha: 0.18);
    final clamped = value?.clamp(0.0, 1.0);
    final percentLabel =
        clamped != null ? '${(clamped * 100).round()}%' : null;
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: minHeight,
            borderRadius: borderRadius,
            color: barColor,
            backgroundColor: barBackground,
          ),
        ),
        if (showLabel && percentLabel != null) ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 44,
            child: Text(
              percentLabel,
              style: textStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ],
    );
  }
}
