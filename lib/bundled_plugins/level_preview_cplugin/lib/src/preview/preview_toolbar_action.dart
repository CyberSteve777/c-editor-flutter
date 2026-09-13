import 'package:flutter/material.dart';

/// Compact controls expose their original labels through tooltips and semantics.
class PreviewToolbarAction extends StatelessWidget {
  const PreviewToolbarAction({
    super.key,
    required this.compact,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.choice = false,
  });

  final bool compact;
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;
  final bool choice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final button = choice
        ? ChoiceChip(
            label: compact
                ? Icon(icon, size: 18)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18),
                      const SizedBox(width: 6),
                      Text(label),
                    ],
                  ),
            selected: selected,
            showCheckmark: false,
            onSelected: onPressed == null ? null : (_) => onPressed!(),
          )
        : compact
        ? IconButton.outlined(
            onPressed: onPressed,
            icon: Icon(icon),
            style: selected
                ? IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  )
                : null,
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: selected
                ? OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  )
                : null,
          );
    return Tooltip(
      message: label,
      child: Semantics(label: label, child: button),
    );
  }
}
