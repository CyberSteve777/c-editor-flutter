/// Reports batched web import/export progress (`completed` of `total`).
typedef WebTransferProgress = void Function(
  int completed,
  int total,
  String? currentLabel,
);

/// Optional cancel control for long-running web transfers.
class WebTransferController {
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() => _cancelled = true;
}

/// Yields to the UI thread between heavy batches.
Future<void> yieldToUi() => Future<void>.delayed(Duration.zero);
