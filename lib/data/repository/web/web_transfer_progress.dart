/// Reports batched web import/export progress (`completed` of `total`).
typedef WebTransferProgress = void Function(
  int completed,
  int total,
  String? currentLabel,
);

/// Yields to the UI thread between heavy batches.
Future<void> yieldToUi() => Future<void>.delayed(Duration.zero);
