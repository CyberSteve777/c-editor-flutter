import 'dart:io';
import 'dart:typed_data';

Future<void> writeBytes(String path, Uint8List bytes) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}

Future<bool> fileExists(String path) async => File(path).exists();
