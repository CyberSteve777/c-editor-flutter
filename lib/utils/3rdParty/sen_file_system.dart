import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'sen_buffer.dart';

class FileSystem {
  static SenBuffer openSenBuffer(String path) {
    final file = File(path);
    final length = file.lengthSync();
    final bytes = Uint8List(length);
    final raFile = file.openSync();
    int pos = 0;
    const chunkSize = 1000000000;
    while (pos < length) {
      raFile.readIntoSync(bytes, pos, (pos + chunkSize).clamp(0, length));
      pos += chunkSize;
    }
    raFile.closeSync();
    return SenBuffer.fromBytes(bytes);
  }

  static void saveSenBuffer(String path, SenBuffer buffer) {
    final file = File(path.replaceAll('\\', '/'));
    file.createSync(recursive: true);
    file.writeAsBytesSync(buffer.toBytes());
  }

  static String readFile(String path) {
    var file = File(path);
    if (file.existsSync()) {
      return file.readAsStringSync();
    } else {
      throw Exception('File not found: $path');
    }
  }

  static void writeFile(String path, String data) {
    var file = File(path);
    file.createSync(recursive: true);
    file.writeAsStringSync(data);
  }

  static Uint8List readBuffer(String path) {
    var file = File(path);
    if (file.existsSync()) {
      return file.readAsBytesSync();
    } else {
      throw Exception('File not found: $path');
    }
  }

  static void writeBuffer(String path, Uint8List data) {
    var file = File(path);
    file.createSync(recursive: true);
    file.writeAsBytesSync(data);
  }

  static bool fileExists(String path) => File(path).existsSync();

  static void createDirectory(String path) {
    Directory(path).createSync(recursive: true);
  }

  static bool directoryExists(String path) => Directory(path).existsSync();

  static dynamic readJson(String path) {
    return jsonDecode(readFile(path));
  }

  static void writeJson(String path, dynamic data, [String indent = '\t']) {
    var encoder = JsonEncoder.withIndent(indent);
    writeFile(path, encoder.convert(data));
  }

  static List<String> readDirectory(String inDirectory, bool recursive) {
    final dir = Directory(inDirectory);
    if (!dir.existsSync()) return [];
    final list = dir.listSync(recursive: recursive);
    return list.map((e) => e.path).toList();
  }
}
