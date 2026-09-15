import 'package:flutter/material.dart';

/// A labeled editor action that can wrap without squeezing text beside its icon.
class EditorFilledButton extends StatelessWidget {
  const EditorFilledButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ).merge(style),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          icon,
          DefaultTextStyle.merge(
            textAlign: TextAlign.center,
            softWrap: true,
            child: label,
          ),
        ],
      ),
    );
  }
}
