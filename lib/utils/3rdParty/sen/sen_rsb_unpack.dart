// ignore_for_file: non_constant_identifier_names

import 'sen_buffer.dart';
import "sen_rsb_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;

/// [RsbUnpack] is a utility for unpacking Resource Stream Bundle (RSB) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsbUnpack {
  static void process(
    String inFile,
    String outFolder,
  ) {
    final senFile = FileSystem.openSenBuffer(inFile);
    process_package(
      senFile,
      outFolder,
    );
    return;
  }

  static void process_package(
    SenBuffer senFile,
    String outFolder,
  ) {
    final rsb = ResourceStreamBundle();
    // Stream each inner .rsg to disk instead of collecting them all in memory.
    final result = rsb.unpackRSB(
      senFile,
      onExtractRsg: (fileName, data) {
        FileSystem.writeBuffer(path.join(outFolder, "packet", fileName), data);
      },
    );
    final manifest = result["manifest"];

    FileSystem.writeJson(path.join(outFolder, "manifest.json"), manifest, "\t");
    if (manifest["description"] != null) {
      FileSystem.writeJson(path.join(outFolder, "description.json"), manifest["description"], "\t");
    }
    return;
  }
}
