import 'dart:typed_data';

import 'package:c_editor/utils/app_fs/sen_fs.dart';

import 'sen_buffer.dart';

/// Thin, platform-agnostic facade over the app-provided [senIo] backend.
///
/// The concrete filesystem backends (native `dart:io`, in-memory for web) live
/// outside this third-party folder, in `lib/utils/app_fs/`. This file only
/// bridges the sen tools to whichever backend is currently installed.
class FileSystem {
  static SenBuffer openSenBuffer(String path) =>
      SenBuffer.fromBytes(senIo.readBuffer(path));

  static void saveSenBuffer(String path, SenBuffer buffer) =>
      senIo.writeBuffer(path, buffer.toBytes());

  static String readFile(String path) => senIo.readFile(path);

  static void writeFile(String path, String data) => senIo.writeFile(path, data);

  static Uint8List readBuffer(String path) => senIo.readBuffer(path);

  static void writeBuffer(String path, Uint8List data) =>
      senIo.writeBuffer(path, data);

  static bool fileExists(String path) => senIo.fileExists(path);

  static void createDirectory(String path) => senIo.createDirectory(path);

  static bool directoryExists(String path) => senIo.directoryExists(path);

  static dynamic readJson(String path) => senIo.readJson(path);

  static void writeJson(String path, dynamic data, [String indent = '\t']) =>
      senIo.writeJson(path, data, indent);

  static List<String> readDirectory(String inDirectory, bool recursive) =>
      senIo.listDirectory(inDirectory, recursive: recursive);
}
