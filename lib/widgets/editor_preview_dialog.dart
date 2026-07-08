import 'package:flutter/material.dart';

const _desktopInsetPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 24);
const _dialogPadding = EdgeInsets.fromLTRB(24, 20, 24, 12);
const _actionsGap = 12.0;
const _estimatedActionsHeight = 52.0;

/// Modal dialog for editor previews. Unlike [AlertDialog], does not use
/// [IntrinsicWidth], so flex-based lawn grids lay out correctly.
Future<T?> showEditorPreviewDialog<T>({
  required BuildContext context,
  Widget? title,
  required Widget content,
  List<Widget>? actions,
}) {
  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      final media = MediaQuery.of(dialogContext);
      final size = media.size;
      final isCompact = size.width < 600;
      final insetPadding = isCompact
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 16)
          : _desktopInsetPadding;
      final dialogWidth =
          (size.width - insetPadding.horizontal).clamp(280.0, 720.0);
      final maxDialogHeight =
          size.height - insetPadding.vertical - media.viewInsets.bottom;
      final hasActions = actions != null && actions.isNotEmpty;
      final footerHeight = hasActions
          ? _estimatedActionsHeight + _actionsGap
          : 0.0;
      final bodyMaxHeight =
          maxDialogHeight - _dialogPadding.vertical - footerHeight;

      return Dialog(
        insetPadding: insetPadding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth,
            maxHeight: maxDialogHeight,
          ),
          child: Padding(
            padding: _dialogPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: bodyMaxHeight),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (title != null) ...[
                          DefaultTextStyle(
                            style:
                                Theme.of(dialogContext).textTheme.titleLarge!,
                            child: title,
                          ),
                          const SizedBox(height: 16),
                        ],
                        content,
                      ],
                    ),
                  ),
                ),
                if (hasActions) ...[
                  const SizedBox(height: _actionsGap),
                  OverflowBar(
                    spacing: 8,
                    alignment: MainAxisAlignment.end,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
