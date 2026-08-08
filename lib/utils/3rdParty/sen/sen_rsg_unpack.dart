// ignore_for_file: non_constant_identifier_names

import 'sen_buffer.dart';
import "sen_rsg_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;

/// [RsgUnpack] is a utility for unpacking Resource Stream Group (RSG) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsgUnpack {
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
    final rsg = ResourceStreamGroup();
    // Stream each file straight to disk so we never hold the whole packet (nor
    // a JSON dump of every file) in memory — that OOMs on phones.
    var extractedCount = 0;
    final packet = rsg.unpackRSG(
      senFile,
      extractFiles: true,
      onExtract: (filePath, data) {
        extractedCount++;
        // Normalize backslashes to forward slashes for cross-platform compatibility
        final normalizedPath = filePath.replaceAll('\\', '/');
        FileSystem.writeBuffer(path.join(outFolder, "res", normalizedPath), data);
      },
    );

    // packet.json is metadata only: RsgPack reads the actual bytes back from the
    // res/ folder, not from here, so we never serialize file bytes into JSON.
    FileSystem.writeJson(
      path.join(outFolder, "packet.json"),
      {
        "version": packet["version"],
        "compression_flags": packet["compression_flags"],
        "res": packet["res"],
      },
      "\t",
    );

    if (extractedCount == 0) {
      throw Exception(
        "No files extracted from RSG. File count: ${packet["res"]?.length ?? 0}",
      );
    }
    return;
  }
}
