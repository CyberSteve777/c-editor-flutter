import 'package:c_editor/data/repository/web/web_transfer_progress.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/labeled_progress_bar.dart';
import 'package:flutter/material.dart';

/// Runs [task] while showing a progress dialog.
Future<T?> runWebTransferWithProgress<T>(
  BuildContext context, {
  required String title,
  required Future<T> Function(
    WebTransferProgress report,
    WebTransferController controller,
  )
  task,
  bool cancellable = false,
}) async {
  if (!context.mounted) {
    return null;
  }

  final l10n = AppLocalizations.of(context)!;
  final controller = WebTransferController();
  var completed = 0;
  var total = 0;
  StateSetter? setDialogState;
  BuildContext? dialogContext;

  final dialogFuture = showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) {
      dialogContext = ctx;
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
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
                ],
              ),
              actions: cancellable
                  ? [
                      TextButton(
                        onPressed: controller.isCancelled
                            ? null
                            : () {
                                controller.cancel();
                                setState(() {});
                              },
                        child: Text(l10n.cancel),
                      ),
                    ]
                  : null,
            );
          },
        ),
      );
    },
  );

  T? result;
  Object? error;
  try {
    result = await task((done, count, label) {
      completed = done;
      total = count;
      setDialogState?.call(() {});
    }, controller);
  } catch (e) {
    error = e;
  } finally {
    final ctx = dialogContext;
    if (ctx != null && ctx.mounted) {
      Navigator.of(ctx, rootNavigator: true).pop();
    }
  }

  await dialogFuture;

  if (error != null) {
    throw error;
  }
  return result;
}
