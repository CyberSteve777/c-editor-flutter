import 'dart:typed_data';

import 'preview_png_writer_stub.dart'
    if (dart.library.io) 'preview_png_writer_io.dart' as impl;

Future<void> writeBytes(String path, Uint8List bytes) =>
    impl.writeBytes(path, bytes);

Future<bool> fileExists(String path) => impl.fileExists(path);
