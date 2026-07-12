import 'package:c_editor/data/repository/web/web_transfer_progress.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/labeled_progress_bar.dart';
import 'package:flutter/material.dart';

/// Runs [task] while showing a non-dismissible progress dialog.
Future<T?> runWebTransferWithProgress<T>(
  BuildContext context, {
  required String title,
  required Future<T> Function(WebTransferProgress report) task,
}) async {
  final l10n = AppLocalizations.of(context)!;
  var completed = 0;
  var total = 0;
  String? currentLabel;
  StateSetter? setDialogState;

  final dialogFuture = showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        setDialogState = setState;
        final progress = total > 0 ? completed / total : null;
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (progress != null) ...[
                LabeledProgressBar(value: progress),
                const SizedBox(height: 12),
                Text(
                  l10n.transferProgressCount(completed, total),
                  textAlign: TextAlign.center,
                ),
              ] else
                const LabeledProgressBar(value: null),
              if (currentLabel != null && currentLabel!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  currentLabel!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(ctx).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    ),
  );

  T? result;
  Object? error;
  try {
    result = await task((done, count, label) {
      completed = done;
      total = count;
      currentLabel = label;
      setDialogState?.call(() {});
    });
  } catch (e) {
    error = e;
  }

  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  await dialogFuture;

  if (error != null) {
    throw error;
  }
  return result;
}
