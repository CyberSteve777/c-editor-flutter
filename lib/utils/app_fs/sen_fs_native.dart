import 'dart:io';
import 'dart:typed_data';

import 'sen_fs.dart';

/// Native default backend (also used inside `compute` isolates on native).
SenIo createDefaultSenIo() => IoSenIo();

/// `dart:io`-backed [SenIo]. Mirrors the behaviour of the original
/// `sen_file_system.dart` implementation.
class IoSenIo extends SenIo {
  @override
  Uint8List readBuffer(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }
    return file.readAsBytesSync();
  }

  @override
  void writeBuffer(String path, Uint8List data) {
    final file = File(path);
    file.createSync(recursive: true);
    file.writeAsBytesSync(data);
  }

  @override
  String readFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw Exception('File not found: $path');
    }
    return file.readAsStringSync();
  }

  @override
  void writeFile(String path, String data) {
    final file = File(path);
    file.createSync(recursive: true);
    file.writeAsStringSync(data);
  }

  @override
  bool fileExists(String path) => File(path).existsSync();

  @override
  bool directoryExists(String path) => Directory(path).existsSync();

  @override
  void createDirectory(String path) {
    Directory(path).createSync(recursive: true);
  }

  @override
  List<String> listDirectory(String path, {bool recursive = false}) {
    final dir = Directory(path);
    if (!dir.existsSync()) return [];
    return dir.listSync(recursive: recursive).map((e) => e.path).toList();
  }
}
