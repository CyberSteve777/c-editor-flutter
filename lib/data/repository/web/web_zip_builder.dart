import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'web_transfer_progress.dart';

const webZipBatchSize = 12;

/// Builds a ZIP archive in batches so the browser can repaint between chunks.
Future<Uint8List> buildZipBytes(
  List<({String path, Uint8List bytes})> files, {
  WebTransferProgress? onProgress,
  int batchSize = webZipBatchSize,
}) async {
  if (files.isEmpty) {
    return Uint8List(0);
  }

  final archive = Archive();
  for (var i = 0; i < files.length; i++) {
    final file = files[i];
    archive.addFile(ArchiveFile(file.path, file.bytes.length, file.bytes));
    onProgress?.call(i + 1, files.length, file.path);
    if (i % batchSize == batchSize - 1) {
      await yieldToUi();
    }
  }

  await yieldToUi();
  onProgress?.call(files.length, files.length, null);
  final encoded = ZipEncoder().encode(archive);
  return Uint8List.fromList(encoded);
}
