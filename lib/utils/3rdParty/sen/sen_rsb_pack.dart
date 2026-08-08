// ignore_for_file: unused_import, non_constant_identifier_names

import 'dart:io';
import 'dart:typed_data';

import 'sen_buffer.dart';
import "sen_rsb_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;

/// [RsbPack] is a utility for packing Resource Stream Bundle (RSB) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsbPack {
  static void process(
    String inFolder,
    String outFile,
  ) {
    process_package(inFolder, outFile);
    return;
  }

  static void process_package(
    String inFolder,
    String outFile,
  ) {
    final rsb = ResourceStreamBundle();
    final manifest = FileSystem.readJson(path.join(inFolder, "manifest.json"));
    if (manifest["version"] == 3) {
      manifest["description"] = FileSystem.readJson(path.join(inFolder, "description.json"));
    }
    final rsgFiles = <String, Uint8List>{};
    final rsgDir = Directory(path.join(inFolder, "packet"));
    if (rsgDir.existsSync()) {
      for (final file in rsgDir.listSync()) {
        if (file is File && file.path.endsWith(".rsg")) {
          rsgFiles[path.basename(file.path)] = file.readAsBytesSync();
        }
      }
    }

    final senFile = rsb.packRSB(rsgFiles, manifest);
    FileSystem.saveSenBuffer(outFile, senFile);
    return;
  }
}
