import 'dart:io';
import 'dart:typed_data';

Future<Uint8List> readPluginFileBytes(String path) =>
    File(path).readAsBytes();
