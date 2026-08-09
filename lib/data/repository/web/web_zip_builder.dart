import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'web_transfer_progress.dart';

const webZipBatchSize = 12;

/// File extensions whose contents are already compressed, so re-deflating them
/// in the ZIP just burns main-thread CPU for ~no size win. These are stored
/// (CompressionType.none) instead. `.rsb.smf` dynamics are the big one.
const _storeOnlyExtensions = {
  'smf',
  'rsb',
  'rsg',
  'rton',
  'zlib',
  'bin',
  'png',
  'jpg',
  'jpeg',
  'ogg',
  'obb',
  'zip',
};

bool _shouldStore(String path) {
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) return false;
  return _storeOnlyExtensions.contains(path.substring(dot + 1).toLowerCase());
}

/// Builds a ZIP archive in batches so the browser can repaint between chunks.
///
/// Already-compressed entries are stored (not deflated) to avoid multi-second
/// main-thread stalls when exporting large binary assets like `dynamic.rsb.smf`.
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
    final entry = ArchiveFile(file.path, file.bytes.length, file.bytes);
    if (_shouldStore(file.path)) {
      entry.compression = CompressionType.none;
    }
    archive.add(entry);
    onProgress?.call(i + 1, files.length, file.path);
    if (i % batchSize == batchSize - 1) {
      await yieldToUi();
    }
  }

  await yieldToUi();
  onProgress?.call(files.length, files.length, null);
  // encodeBytes returns a Uint8List directly (no extra List<int> -> Uint8List
  // copy); bestSpeed keeps deflate of the remaining text levels cheap.
  return ZipEncoder().encodeBytes(archive, level: DeflateLevel.bestSpeed);
}
